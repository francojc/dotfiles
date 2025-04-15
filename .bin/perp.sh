#!/usr/bin/env bash

# Description: This script leverages the Perplexica API to query and return results to the command line.
# Usage: perp.sh <prompt>
# Example: perp.sh "What is the latest news on AI?"
#          > "AI is making significant strides in various fields, including healthcare, finance, and transportation. Recent advancements include..."
#          > Sources: [1] [AI News Today](https://ainewstoday.com), [2] [TechCrunch](https://techcrunch.com), [3] [MIT Technology Review](https://technologyreview.com)
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

# Embedding Model (Using Hugging Face - verify provider/name with your /api/models endpoint)
EMBEDDING_PROVIDER="huggingface"
EMBEDDING_MODEL_NAME="bge-small-en" # <-- VERIFY THIS NAME

# Default focus mode (webSearch, academicSearch, writingAssistant, etc.)
DEFAULT_FOCUS_MODE="webSearch"

# --- Functions ---

# Function to display usage information
usage() {
  echo "Usage: $(basename "$0") <prompt>"
  echo "Example: $(basename "$0") \"What is the latest news on AI?\""
  exit 1
}

# Function to safely escape JSON strings
json_escape() {
  printf '%s' "$1" | jq -R -s '.'
}

# --- Main Script ---

# Check if prompt argument is provided
if [ -z "$1" ]; then
  usage
fi

# Check if OPENROUTER_API_KEY environment variable is set
if [ -z "$OPENROUTER_API_KEY" ]; then
  echo "Error: OPENROUTER_API_KEY environment variable is not set." >&2
  exit 1
fi

PROMPT="$1"
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
  "focusMode": "$DEFAULT_FOCUS_MODE",
  "query": $ESCAPED_PROMPT,
  "stream": false
}
EOF
)

# Make the API call using curl and capture the response
# Use -s for silent mode, -S to show errors, -X POST, -H for headers, -d for data
API_RESPONSE=$(curl -s -S -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "$JSON_PAYLOAD" \
  "$PERPLEXICA_API_URL")

# Check if curl command was successful
CURL_EXIT_CODE=$?
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
echo "> $MESSAGE"

# Format and print the sources
SOURCES_STRING=""
SOURCE_COUNT=$(echo "$SOURCES_JSON" | jq 'length')

if [ "$SOURCE_COUNT" -gt 0 ]; then
  SOURCES_STRING="> Sources:"
  for i in $(seq 0 $((SOURCE_COUNT - 1))); do
    # Use jq -c to get compact JSON for the source object, then parse fields
    SOURCE_COMPACT=$(echo "$SOURCES_JSON" | jq -c ".[$i]")
    TITLE=$(echo "$SOURCE_COMPACT" | jq -r '.metadata.title // "No Title"')
    URL=$(echo "$SOURCE_COMPACT" | jq -r '.metadata.url // "#"')
    # Append comma and space if not the first source
    if [ "$i" -gt 0 ]; then
      SOURCES_STRING+=", "
    else
      SOURCES_STRING+=" " # Add initial space after "Sources:"
    fi
    SOURCES_STRING+="[$((i + 1))] [$TITLE]($URL)"
  done
  echo "$SOURCES_STRING"
fi

exit 0
