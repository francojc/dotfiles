#!/bin/bash

set -euo pipefail

PROMPT="$1"
SIZE="${2:-1024x1024}"
QUALITY="${3:-standard}"
OUTPUT_DIR="${4:-./generated_images}"

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "Error: OPENAI_API_KEY environment variable is required" >&2
  exit 1
fi

if [ -z "$PROMPT" ]; then
  echo "Error: Image prompt is required" >&2
  echo "Usage: $0 '<prompt>' [size] [quality] [output_dir]" >&2
  echo "  size: 1024x1024, 1024x1792, 1792x1024 (default: 1024x1024)" >&2
  echo "  quality: standard, hd (default: standard)" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SAFE_PROMPT=$(echo "$PROMPT" | tr ' ' '_' | tr -cd '[:alnum:]_-' | cut -c1-50)
OUTPUT_FILE="$OUTPUT_DIR/dalle_${SAFE_PROMPT}_${TIMESTAMP}.png"

REQUEST_BODY=$(cat <<EOF
{
  "model": "dall-e-3",
  "prompt": "$PROMPT",
  "n": 1,
  "size": "$SIZE",
  "quality": "$QUALITY"
}
EOF
)

echo "Generating image with DALL-E 3..." >&2
echo "Prompt: $PROMPT" >&2
echo "Size: $SIZE" >&2
echo "Quality: $QUALITY" >&2

RESPONSE=$(curl -s -X POST "https://api.openai.com/v1/images/generations" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$REQUEST_BODY")

if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
  echo "Error from OpenAI API:" >&2
  echo "$RESPONSE" | jq -r '.error.message' >&2
  exit 1
fi

IMAGE_URL=$(echo "$RESPONSE" | jq -r '.data[0].url')

if [ "$IMAGE_URL" = "null" ] || [ -z "$IMAGE_URL" ]; then
  echo "Error: Failed to get image URL from response" >&2
  echo "Response: $RESPONSE" >&2
  exit 1
fi

echo "Downloading image..." >&2
curl -s -o "$OUTPUT_FILE" "$IMAGE_URL"

if [ -f "$OUTPUT_FILE" ]; then
  echo "Image saved to: $OUTPUT_FILE" >&2
  echo "$OUTPUT_FILE"
else
  echo "Error: Failed to save image" >&2
  exit 1
fi