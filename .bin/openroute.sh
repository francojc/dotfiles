#!/usr/bin/env bash

# Description: Connects to the OpenRouter AI service providing input/output from many different AI models from one service.
# Usage: openroute.sh [options] ["<prompt>"]
#   or   openroute.sh [options] -p "<prompt>"
#
# Options:
#   -p <prompt>:      The user instructions/prompt text. Can also be provided as the last argument without the flag.
#   -m <model>:       The model to use (default: google/gemini-flash-1.5).
#                     Format: 'vendor/model-name' or 'vendor/model-name:version'.
#   -a <attachment>:  Path to an attachment file (e.g., image, pdf).
#   -i <input_file>:  Path to a file containing additional input text (prepended to prompt).
#   -o <output_file>: File to write the output to (default: stdout).
#   -h:               Display this help message.
#
# Defaults:
#   Model (-m): google/gemini-flash-1.5
#
# Environment Variables:
#   OPENROUTER_API_KEY: Must be set to your OpenRouter API key.
#
# Author: Jerid Francom/Assistant

# --- Configuration ---
DEFAULT_MODEL="google/gemini-flash-1.5"
API_URL="https://openrouter.ai/api/v1/chat/completions"

# --- Helper Functions ---

# Function to display usage information
usage() {
  echo "Usage: openroute.sh [options] [\"<prompt>\"]"
  echo "   or  openroute.sh [options] -p \"<prompt>\""
  echo
  echo "Description: Sends a prompt (and optionally an attachment) to the OpenRouter API."
  echo
  echo "Options:"
  echo "  -p <prompt>:      The user instructions/prompt text."
  echo "                    Alternatively, provide the prompt as the last argument without the -p flag."
  echo "  -m <model>:       The model to use (default: $DEFAULT_MODEL)."
  echo "                    Format: 'vendor/model-name' or 'vendor/model-name:version'."
  echo "  -a <attachment>:  Path to an attachment file (e.g., image, pdf)."
  echo "  -i <input_file>:  Path to a file containing additional input text."
  echo "                    Content will be prepended to the prompt (-p or positional)."
  echo "  -o <output_file>: File to write the output to (default: stdout)."
  echo "  -h:               Display this help message."
  echo
  echo "Environment Variables:"
  echo "  OPENROUTER_API_KEY: Must be set to your OpenRouter API key."
  exit 1
}

# Function for logging errors and exiting
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# --- Script Execution ---

# Set strict mode
set -euo pipefail

# --- Argument Parsing ---
prompt=""
model="$DEFAULT_MODEL"
attachment_path=""
input_file=""
output_file=""
prompt_from_p_option="" # Track if -p was used

while getopts ":p:m:a:i:o:h" opt; do
  case ${opt} in
    p )
      prompt_from_p_option="$OPTARG"
      ;;
    m )
      model="$OPTARG"
      ;;
    a )
      attachment_path="$OPTARG"
      ;;
    i )
      input_file="$OPTARG"
      ;;
    o )
      output_file="$OPTARG"
      ;;
    h )
      usage
      ;;
    \? )
      # Check if it looks like a positional argument after options
      if [[ "$OPTARG" == "-" ]] && [[ "${!OPTIND}" != -* ]]; then
          # This case handles things like `script -m model prompt` where `prompt` might be misinterpreted
          # We break here and let the positional argument handling below take care of it.
          break
      fi
      echo "Invalid option: -$OPTARG" 1>&2
      usage
      ;;
    : )
      echo "Invalid option: -$OPTARG requires an argument" 1>&2
      usage
      ;;
  esac
done
shift $((OPTIND -1))

# Handle positional argument as prompt
positional_prompt=""
if [[ $# -gt 0 ]]; then
  # Check if the first positional argument looks like an option - this shouldn't happen if getopts worked correctly, but as a safeguard.
  if [[ "$1" == -* ]]; then
      error_exit "Unexpected option '$1' found after arguments."
  fi
  positional_prompt="$1"
  shift # Consume the positional prompt argument
fi

# Check for conflicting prompt inputs
if [[ -n "$prompt_from_p_option" ]] && [[ -n "$positional_prompt" ]]; then
  error_exit "Prompt provided with both -p option and as a positional argument. Use only one method."
fi

# Assign the prompt
if [[ -n "$prompt_from_p_option" ]]; then
  prompt="$prompt_from_p_option"
elif [[ -n "$positional_prompt" ]]; then
  prompt="$positional_prompt"
fi

# Check for any remaining unexpected arguments
if [[ $# -gt 0 ]]; then
    error_exit "Unexpected arguments found: '$*'. Did you forget to quote the prompt?"
fi


# --- Input Validation ---

# Check for API Key
if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
  error_exit "OPENROUTER_API_KEY environment variable is not set."
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    error_exit "'jq' command is not found. Please install jq (JSON processor)."
fi

# Check if file command is installed (for MIME type detection)
if ! command -v file &> /dev/null; then
    error_exit "'file' command is not found. Please install file."
fi

# Check if base64 command is installed
if ! command -v base64 &> /dev/null; then
    error_exit "'base64' command is not found. Please install base64."
fi


# --- Prepare Input ---

# Read input from file if specified
input_content=""
if [[ -n "$input_file" ]]; then
  if [[ ! -f "$input_file" ]]; then
    error_exit "Input file not found: $input_file"
  fi
  input_content=$(<"$input_file")
  # Prepend file content to the prompt, separated by a newline
  if [[ -n "$prompt" ]]; then
      # Use printf for potentially multi-line content preservation
      prompt="$(printf "%s\n\n%s" "$input_content" "$prompt")"
  else
      prompt="$input_content"
  fi
fi

# Ensure prompt is not empty if no input file or attachment was given
if [[ -z "$prompt" ]] && [[ -z "$attachment_path" ]]; then
    error_exit "A prompt (via -p, positional argument, or -i) or an attachment (-a) must be provided."
fi


# --- Prepare Attachment (if any) ---
attachment_json_part=""
if [[ -n "$attachment_path" ]]; then
  if [[ ! -f "$attachment_path" ]]; then
    error_exit "Attachment file not found: $attachment_path"
  fi

  # Get MIME type using 'file' command
  mime_type=$(file --brief --mime-type "$attachment_path")
  if [[ -z "$mime_type" ]]; then
      error_exit "Could not determine MIME type for attachment: $attachment_path"
  fi

  # Base64 encode the file content
  # Use standard base64 without options for portability
  base64_content=$(base64 < "$attachment_path" | tr -d '\n') # Remove newlines for JSON compatibility

  # Construct the JSON part for the attachment using data URI scheme
  # Note: OpenRouter expects image content within an "image_url" field using a data URI.
  # This might need adjustment if non-image types require a different structure.
  # We assume 'image_url' works for common types based on the example.
  attachment_json_part=$(jq -n --arg mime "$mime_type" --arg data "$base64_content" \
    '{type: "image_url", image_url: {url: ("data:" + $mime + ";base64," + $data)}}')

fi

# --- Construct JSON Payload ---

# Start building the messages array. Handle case where prompt might be empty (e.g., only attachment provided)
messages_content_array='[]'
if [[ -n "$prompt" ]]; then
    messages_content_array=$(jq -n --arg text_prompt "$prompt" '[{type: "text", text: $text_prompt}]')
fi

# If there's an attachment, add it to the content array
if [[ -n "$attachment_json_part" ]]; then
  messages_content_array=$(echo "$messages_content_array" | jq --argjson attachment "$attachment_json_part" '. += [$attachment]')
fi

# Construct the messages array with the user role and the content array
messages_json=$(jq -n --argjson content "$messages_content_array" '[{role: "user", content: $content}]')


# Construct the final JSON payload
json_payload=$(jq -n --arg model "$model" --argjson messages "$messages_json" \
  '{model: $model, messages: $messages}')

# --- Make API Call ---
# Use curl to send the request
# -s for silent, -S to show errors, -f to fail fast on HTTP errors
api_response=$(curl -s -S -f -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -d "$json_payload")

# Check curl exit status
curl_exit_status=$?
if [[ $curl_exit_status -ne 0 ]]; then
  # Try to parse error from response if available
  error_message=$(echo "$api_response" | jq -r '.error.message // empty')
  if [[ -n "$error_message" ]]; then
      error_exit "API call failed (curl exit code $curl_exit_status): $error_message"
  else
      # Check if the response is valid JSON before trying to parse further
      if ! echo "$api_response" | jq -e . > /dev/null 2>&1; then
          error_exit "API call failed (curl exit code $curl_exit_status). Response was not valid JSON: $api_response"
      else
          error_exit "API call failed (curl exit code $curl_exit_status). Response: $api_response"
      fi
  fi
fi

# --- Process Response ---

# Extract the content from the response using jq
# Assumes the response structure contains choices[0].message.content
response_content=$(echo "$api_response" | jq -r '.choices[0].message.content // empty')

if [[ -z "$response_content" ]]; then
  # Attempt to extract a potential error message from the API response JSON
  error_message=$(echo "$api_response" | jq -r '.error.message // empty')
  if [[ -n "$error_message" ]]; then
      error_exit "API returned an error: $error_message"
  else
      # Check if the response is valid JSON
      if ! echo "$api_response" | jq -e . > /dev/null 2>&1; then
           error_exit "API returned empty content and response was not valid JSON. Response: $api_response"
      else
           # It's valid JSON but content is missing/empty, which might be valid in some cases?
           # Or it could indicate an unexpected response structure.
           # Let's consider it an error for now if content is expected.
           error_exit "API returned empty content. Response: $api_response"
      fi
  fi
fi

# --- Output Result ---

if [[ -n "$output_file" ]]; then
  # Write to output file
  echo "$response_content" > "$output_file"
  echo "Output written to $output_file" >&2 # Send confirmation message to stderr
else
  # Print to stdout
  echo "$response_content"
fi

exit 0
