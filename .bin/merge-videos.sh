#!/usr/bin/env bash

# Usage:
#   ./merge-videos.sh video1.mp4 video2.mp4 video3.mp4 ...
# Optional:
#   ./merge-videos.sh video1.mp4 video2.mp4 -o final.mp4

# Requirements:
#   - ffmpeg installed (`brew install ffmpeg` or `apt install ffmpeg`)

set -e

# Default output filename
OUTFILE="merged_output.mp4"

# Parse -o flag for custom output
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)
      OUTFILE="$2"
      shift 2
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

if [ "${#ARGS[@]}" -lt 2 ]; then
  echo "❌ Provide at least two video files to merge."
  echo "Usage: $0 video1.mp4 video2.mp4 ... [-o output.mp4]"
  exit 1
fi

# Create temporary file list for ffmpeg concat
LISTFILE=$(mktemp)
for f in "${ARGS[@]}"; do
  echo "file '$PWD/$f'" >> "$LISTFILE"
done

echo "📦 Merging ${#ARGS[@]} videos into $OUTFILE ..."

# Try fast (stream copy) concat
ffmpeg -hide_banner -loglevel warning -f concat -safe 0 -i "$LISTFILE" -c copy "$OUTFILE" || {
  echo "⚠️ Fast merge failed, falling back to re-encode..."
  ffmpeg -hide_banner -loglevel warning -f concat -safe 0 -i "$LISTFILE" -c:v libx264 -c:a aac "$OUTFILE"
}

rm "$LISTFILE"

echo "✅ Merge complete: $OUTFILE"
