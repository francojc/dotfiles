#!/bin/bash

set -euo pipefail

PROMPT="$1"
OUTPUT_DIR="${2:-./generated_images}"

if [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "Error: GEMINI_API_KEY environment variable is required" >&2
  exit 1
fi

if [ -z "$PROMPT" ]; then
  echo "Error: Image prompt is required" >&2
  echo "Usage: $0 '<prompt>' [output_dir]" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SAFE_PROMPT=$(echo "$PROMPT" | tr ' ' '_' | tr -cd '[:alnum:]_-' | cut -c1-50)
OUTPUT_FILE="$OUTPUT_DIR/gemini_${SAFE_PROMPT}_${TIMESTAMP}.png"

REQUEST_BODY=$(cat <<EOF
{
  "contents": [{
    "parts": [
      {"text": "$PROMPT"}
    ]
  }],
  "generationConfig": {"responseModalities": ["TEXT", "IMAGE"]}
}
EOF
)

echo "Generating image with Gemini..." >&2
echo "Prompt: $PROMPT" >&2

RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-preview-image-generation:generateContent" \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$REQUEST_BODY")

if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
  echo "Error from Gemini API:" >&2
  echo "$RESPONSE" | jq -r '.error.message' >&2
  exit 1
fi

IMAGE_DATA=$(echo "$RESPONSE" | grep -o '"data": "[^"]*"' | cut -d'"' -f4)

if [ -z "$IMAGE_DATA" ]; then
  echo "Error: Failed to get image data from response" >&2
  echo "Response: $RESPONSE" >&2
  exit 1
fi

echo "Decoding image..." >&2
echo "$IMAGE_DATA" | base64 --decode > "$OUTPUT_FILE"

if [ -f "$OUTPUT_FILE" ]; then
  echo "Image saved to: $OUTPUT_FILE" >&2
  echo "$OUTPUT_FILE"
else
  echo "Error: Failed to save image" >&2
  exit 1
fi