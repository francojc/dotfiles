#!/usr/bin/env bash

# Description: This script leverages the Perplexica API to query and return results to the command line.
# Usage: perp.sh <prompt>
# Example: perp.sh "What is the latest news on AI?"
#          "AI is making significant strides in various fields, including healthcare, finance, and transportation. Recent advancements include..."
#          Sources: [1] [AI News Today](https://ainewstoday.com), [2] [TechCrunch](https://techcrunch.com), [3] [MIT Technology Review](https://technologyreview.com)
# Dependencies: curl, jq

# --- Configuration ---
# Set the URL for your Perplexica API instance
PERPLEXICA_API_URL="http://mac-minicore.tail5650e0.ts.net:3110/api/search"

# --- Model Configuration ---
# Chat Model (Using Custom OpenAI settings)
CHAT_PROVIDER="custom_openai" # <-- VERIFY THIS PROVIDER NAME
CHAT_MODEL_NAME="openai/gpt-4.1-mini"
# IMPORTANT: Set this to your custom OpenAI-compatible endpoint URL (e.g., OpenRouter)
CUSTOM_OPENAI_BASE_URL="https://openrouter.ai/api/v1" # <-- ADJUST IF NEEDED

# Embedding Model (Using transformers - see /api/models endpoint)
EMBEDDING_PROVIDER="transformers"
EMBEDDING_MODEL_NAME="xenova-bge-small-en-v1.5"

# Default focus mode (webSearch, academicSearch, writingAssistant, etc.)
DEFAULT_FOCUS_MODE="webSearch"
# Map user-friendly short names to API focus modes
declare -A FOCUS_MODE_MAP=(
  [web]="webSearch"
  [academic]="academicSearch"
  [writing]="writingAssistant"
  [wolfram]="wolframAlphaSearch"
  [youtube]="youtubeSearch"
  [reddit]="redditSearch"
)
AVAILABLE_FOCUS_MODES=("web" "academic" "writing" "wolfram" "youtube" "reddit")

# --- Functions ---

# Function to display usage information
usage() {
  echo "Usage: $(basename "$0") [--mode <focusMode>] <prompt>"
  echo "       $(basename "$0") [--mode <focusMode>] -m <focusMode> <prompt>"
  echo "       echo \"<prompt>\" | $(basename "$0") [--mode <focusMode>]"
  echo
  echo "Available focus modes: ${AVAILABLE_FOCUS_MODES[*]}"
  echo "Example: $(basename "$0") --mode academic \"What is the latest in AI research?\""
  exit 1
}

# Function to safely escape JSON strings
json_escape() {
  printf '%s' "$1" | jq -R -s '.'
}

# --- Main Script ---

# Parse arguments for --mode/-m and prompt
FOCUS_MODE="web"
PROMPT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode|-m)
      shift
      if [[ -z "$1" ]]; then
        echo "Error: --mode requires an argument." >&2
        usage
      fi
      FOCUS_MODE="$1"
      shift
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      if [[ -z "$PROMPT" ]]; then
        PROMPT="$1"
      else
        PROMPT="$PROMPT $1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$PROMPT" && ! -t 0 ]]; then
  PROMPT="$(cat -)"
fi

if [[ -z "$PROMPT" ]]; then
  usage
fi

# Validate and map focus mode
if [[ -z "${FOCUS_MODE_MAP[$FOCUS_MODE]}" ]]; then
  echo "Error: Invalid focus mode: $FOCUS_MODE" >&2
  echo "Available modes: ${AVAILABLE_FOCUS_MODES[*]}"
  exit 1
fi
API_FOCUS_MODE="${FOCUS_MODE_MAP[$FOCUS_MODE]}"

# Check if OPENROUTER_API_KEY environment variable is set
if [ -z "$OPENROUTER_API_KEY" ]; then
  echo "Error: OPENROUTER_API_KEY environment variable is not set." >&2
  exit 1
fi

ESCAPED_PROMPT=$(json_escape "$PROMPT")
ESCAPED_API_KEY=$(json_escape "$OPENROUTER_API_KEY")
ESCAPED_BASE_URL=$(json_escape "$CUSTOM_OPENAI_BASE_URL")

# Construct the JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
  "chatModel": {
    "provider": "$CHAT_PROVIDER",
    "name": "$CHAT_MODEL_NAME",
    "customOpenAIBaseURL": $ESCAPED_BASE_URL,
    "customOpenAIKey": $ESCAPED_API_KEY
  },
  "embeddingModel": {
    "provider": "$EMBEDDING_PROVIDER",
    "name": "$EMBEDDING_MODEL_NAME"
  },
  "focusMode": "$API_FOCUS_MODE",
  "query": $ESCAPED_PROMPT,
  "stream": false,
  "optimizationMode": "balanced"
}
EOF
)

# Make the API call using curl and capture the response
API_RESPONSE=$(curl -s -S -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "$JSON_PAYLOAD" \
  "$PERPLEXICA_API_URL")
CURL_EXIT_CODE=$?

# Check if curl command was successful
if [ $CURL_EXIT_CODE -ne 0 ]; then
  echo "Error: Failed to connect to Perplexica API at $PERPLEXICA_API_URL (curl exit code: $CURL_EXIT_CODE)" >&2
  # Optionally print the raw response if available
  if [ -n "$API_RESPONSE" ]; then
    echo "API Response: $API_RESPONSE" >&2
  fi
  exit 1
fi

# Check if the response is valid JSON using jq
echo "$API_RESPONSE" | jq empty > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Received invalid JSON response from API." >&2
  echo "Raw Response: $API_RESPONSE" >&2
  exit 1
fi

# Check for error messages within the JSON response (adjust based on actual API error structure if needed)
# Example: Assuming errors might have a top-level "error" key or "message" on failure
if echo "$API_RESPONSE" | jq -e '.error' > /dev/null; then
  ERROR_MSG=$(echo "$API_RESPONSE" | jq -r '.error')
  echo "Error from API: $ERROR_MSG" >&2
  exit 1
elif echo "$API_RESPONSE" | jq -e 'if .message and (.sources | length == 0) then true else false end' > /dev/null; then
  # Sometimes errors might just be a message without sources
  ERROR_MSG=$(echo "$API_RESPONSE" | jq -r '.message')
  # Check for common connection refused or model not found errors in the message
  if [[ "$ERROR_MSG" == *"Connection refused"* || "$ERROR_MSG" == *"Could not find model"* || "$ERROR_MSG" == *"Invalid API Key"* ]]; then
     echo "Error from API: $ERROR_MSG" >&2
     exit 1
  fi
  # If it's not a clear error, proceed to print the message but warn
  echo "Warning: Received a message but no sources. Potential API issue or simple response." >&2
fi


# Parse the response using jq
MESSAGE=$(echo "$API_RESPONSE" | jq -r '.message // "No message found in response."')
SOURCES_JSON=$(echo "$API_RESPONSE" | jq -c '.sources // []') # Get sources as compact JSON array

# Print the message
echo -e "\n$MESSAGE"

# Format and print the sources
# SOURCES_STRING=""
SOURCE_COUNT=$(echo "$SOURCES_JSON" | jq 'length')

if [ "$SOURCE_COUNT" -gt 0 ]; then
  echo -e "\n\nSources:"
  for i in $(seq 0 $((SOURCE_COUNT - 1))); do
    SOURCE_COMPACT=$(echo "$SOURCES_JSON" | jq -c ".[$i]")
    TITLE=$(echo "$SOURCE_COMPACT" | jq -r '.metadata.title // "No Title"')
    URL=$(echo "$SOURCE_COMPACT" | jq -r '.metadata.url // "#"')
    echo "  - [$((i + 1))] [$TITLE]($URL)"
  done
fi

exit 0
