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
#   -o <output_file>: File to write the output to (default: stdout).
#   -t <tokens>:      Maximum number of tokens to generate (optional).
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
  echo "  -o <output_file>: File to write the output to (default: stdout)."
  echo "  -t <tokens>:      Maximum number of tokens to generate (optional)."
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
output_file=""
max_tokens=""
prompt_from_p_option="" # Track if -p was used

# Process options using getopts
# Options must come before the optional positional prompt argument
while getopts ":p:m:a:o:t:h" opt; do
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
    o )
      output_file="$OPTARG"
      ;;
    t )
      max_tokens="$OPTARG"
      ;;
    h )
      usage
      ;;
    \? )
      # Check if it looks like a positional argument after options
      if [[ "$OPTARG" != "-" ]]; then
          echo "Invalid option: -$OPTARG" 1>&2
          usage
      fi
      break
      ;;
    : )
      echo "Invalid option: -$OPTARG requires an argument" 1>&2
      usage
      ;;
  esac
done
shift $((OPTIND -1)) # Shift processed options away

# Handle positional argument as prompt (must be the *only* remaining argument)
positional_prompt=""
if [[ $# -eq 1 ]]; then
  # Check if the single remaining argument looks like an option - safeguard
  if [[ "$1" == -* ]]; then
      error_exit "Unexpected option '$1' found where positional prompt was expected. Options must precede the prompt."
  fi
  positional_prompt="$1"
  shift # Consume the positional prompt argument
elif [[ $# -gt 1 ]]; then
  # If more than one argument remains, it's an error
   error_exit "Unexpected arguments found: '$*'. Options must come before the single positional prompt, or use -p."
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

# Check for any remaining unexpected arguments (double check, should be caught above)
if [[ $# -gt 0 ]]; then
    error_exit "Unexpected arguments found after processing: '$*'. Check argument order and quoting."
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

# Check if tr command is installed
if ! command -v tr &> /dev/null; then
    error_exit "'tr' command is not found. Please install tr (translate characters)."
fi

# Ensure prompt or attachment is provided
if [[ -z "$prompt" ]] && [[ -z "$attachment_path" ]]; then
    error_exit "A prompt (via -p or positional argument) or an attachment (-a) must be provided."
fi

# Validate max_tokens if provided
if [[ -n "$max_tokens" ]]; then
  if ! [[ "$max_tokens" =~ ^[1-9][0-9]*$ ]]; then
    error_exit "Invalid value for -t (max_tokens): '$max_tokens'. Must be a positive integer."
  fi
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

  # Base64 encode the file content and remove newlines for portability
  base64_content=$(base64 < "$attachment_path" | tr -d '\n')
  if [[ -z "$base64_content" ]]; then
      # Check if base64 command succeeded but produced empty output (e.g., empty file)
      # Or if tr failed, though less likely if the command check passed.
      # Get exit status of the pipeline components
      pipe_status=("${PIPESTATUS[@]}")
      if [[ ${pipe_status[0]} -ne 0 ]]; then
          error_exit "base64 command failed for attachment: $attachment_path"
      elif [[ ${pipe_status[1]} -ne 0 ]]; then
          error_exit "tr command failed while processing base64 output for attachment: $attachment_path"
      else
          # Base64 succeeded, tr succeeded, but output is empty. Likely an empty input file.
          # Allow empty content, as it might be valid for some use cases or APIs.
          : # Keep base64_content as empty string
      fi
  fi


  # Construct the JSON part for the attachment based on MIME type
  if [[ "$mime_type" == image/* ]]; then
      # Structure for images using data URI
      attachment_json_part=$(jq -n --arg mime "$mime_type" --arg data "$base64_content" \
        '{type: "image_url", image_url: {url: ("data:" + $mime + ";base64," + $data)}}')
  elif [[ "$mime_type" == "application/pdf" ]]; then
      # Structure for PDFs (using a common pattern for base64 documents)
      # This structure might need adjustment based on specific OpenRouter/model requirements.
      attachment_json_part=$(jq -n \
        --arg mime "$mime_type" \
        --arg data "$base64_content" \
        '{type: "document_attachment", source: {type: "base64", media_type: $mime, data: $data}}')
  else
      # Handle unsupported types
      error_exit "Unsupported attachment type '$mime_type'. Currently only image/* and application/pdf types are explicitly supported by this script's structure."
  fi

fi

# --- Construct JSON Payload ---

# Start building the messages array. Handle case where prompt might be empty (e.g., only attachment provided)
messages_content_array='[]'
if [[ -n "$prompt" ]]; then
    # Ensure prompt is treated as a single JSON string, even with newlines/quotes
    messages_content_array=$(jq -n --arg text_prompt "$prompt" '[{type: "text", text: $text_prompt}]')
fi

# If there's an attachment, add it to the content array
if [[ -n "$attachment_json_part" ]]; then
  messages_content_array=$(echo "$messages_content_array" | jq --argjson attachment "$attachment_json_part" '. += [$attachment]')
fi

# Construct the messages array with the user role and the content array
messages_json=$(jq -n --argjson content "$messages_content_array" '[{role: "user", content: $content}]')


# Construct the base JSON payload by piping messages_json to jq stdin
base_payload=$(echo "$messages_json" | jq --arg model "$model" \
  '{model: $model, messages: .}')

# Add max_tokens to the payload if it was provided
if [[ -n "$max_tokens" ]]; then
  # Use --argjson to ensure max_tokens is treated as a number
  json_payload=$(echo "$base_payload" | jq --argjson tokens "$max_tokens" '. + {max_tokens: $tokens}')
else
  json_payload="$base_payload"
fi


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
          # Provide more context if response isn't JSON
          error_exit "API call failed (curl exit code $curl_exit_status). Response was not valid JSON: $(echo "$api_response" | head -c 200) ..." # Show beginning of response
      else
          # Valid JSON but no specific error message found
          error_exit "API call failed (curl exit code $curl_exit_status). Response: $(echo "$api_response" | jq -c .)" # Show compact JSON
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
           error_exit "API returned empty content and response was not valid JSON. Response: $(echo "$api_response" | head -c 200) ..."
      else
           # It's valid JSON but content is missing/empty.
           # This might be valid in some cases, but often indicates an issue.
           # Check if choices array exists but is empty or message is null
           if [[ $(echo "$api_response" | jq '.choices | length') -eq 0 ]] || \
              [[ $(echo "$api_response" | jq -r '.choices[0].message // "null"') == "null" ]]; then
               error_exit "API returned no message content. Check model compatibility or prompt. Response: $(echo "$api_response" | jq -c .)"
           else
               # Content is genuinely empty string "" - pass it through
               : # No error, content is just empty
           fi
      fi
  fi
fi

# --- Output Result ---

if [[ -n "$output_file" ]]; then
  # Write to output file
  # Use printf to handle potential edge cases like content starting with '-'
  printf "%s\n" "$response_content" > "$output_file"
  echo "Output written to $output_file" >&2 # Send confirmation message to stderr
else
  # Print to stdout
  # Use printf for robustness
  printf "%s\n" "$response_content"
fi

exit 0
