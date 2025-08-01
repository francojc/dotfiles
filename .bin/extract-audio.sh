#!/usr/bin/env bash

# Usage: ./extract-audio.sh <video_file> [output_format]
# Example: ./extract-audio.sh "Lecture1.mp4" mp3

INPUT="$1"
FORMAT="${2:-mp3}"  # Default format: mp3

# Check for input
if [ -z "$INPUT" ]; then
  echo "❌ Usage: $0 <video_file> [output_format]"
  exit 1
fi

# Check if input file exists
if [ ! -f "$INPUT" ]; then
  echo "❌ File not found: $INPUT"
  exit 1
fi

# Check for ffmpeg
if ! command -v ffmpeg &> /dev/null; then
  echo "❌ ffmpeg not found. Please install it and try again."
  exit 1
fi

# Generate output filename
BASENAME=$(basename "$INPUT")
OUTPUT="${BASENAME%.*}.$FORMAT"

# Extract audio
echo "🎧 Extracting audio from: $INPUT"
ffmpeg -i "$INPUT" -vn -acodec libmp3lame -q:a 2 "$OUTPUT"

# Check success
if [ $? -eq 0 ]; then
  echo "✅ Audio saved to: $OUTPUT"
else
  echo "❌ Audio extraction failed."
  exit 1
fi
