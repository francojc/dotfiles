#!/usr/bin/env bash

# Usage: ./dl-youtube.sh "<URL>" [caption_lang]
#
URL="$1"
LANG="${2:-en}"  # default caption language

COOKIES="$HOME/.bin/cookies.txt"

# --- Basic checks ---
if ! command -v yt-dlp &> /dev/null; then
  echo "❌ yt-dlp not found. Please install it and try again."
  exit 1
fi

if [ -z "$URL" ]; then
  echo "❌ Usage: $0 <URL> [caption_language]"
  exit 1
fi

# --- Format selector ---
if echo "$URL" | grep -qi 'youtube'; then
  FORMAT='bv*[height<=720]+ba/b[height<=720]'
else
  FORMAT='bestvideo[height<=720]+bestaudio/best[height<=720]'
fi

# --- Determine output filename safely ---
echo "📥 Determining expected output filename..."
VIDEO_FILENAME=$(yt-dlp \
  -f "$FORMAT" \
  --merge-output-format mp4 \
  --cookies "$COOKIES" \
  --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  --legacy-server-connect \
  --print "%(title)s.%(ext)s" \
  "$URL")

if [ -z "$VIDEO_FILENAME" ]; then
  echo "❌ Failed to determine output filename."
  exit 1
fi

echo "📄 Output file will be: $VIDEO_FILENAME"

# --- Download video (no subtitles yet) ---
echo "📥 Downloading video..."
yt-dlp \
  -f "$FORMAT" \
  --merge-output-format mp4 \
  --cookies "$COOKIES" \
  --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  --legacy-server-connect \
  -o "%(title)s.%(ext)s" \
  "$URL"

# --- Check if file was created ---
if [ ! -f "$VIDEO_FILENAME" ]; then
  echo "❌ Video download appears to have failed. File not found: $VIDEO_FILENAME"
  exit 1
fi

# --- Attempt subtitles (safe to fail) ---
echo "📝 Attempting to download subtitles in language: $LANG"
yt-dlp \
  --skip-download \
  --write-sub \
  --write-auto-sub \
  --sub-lang "$LANG" \
  --sub-format srt \
  --cookies "$COOKIES" \
  --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  --legacy-server-connect \
  "$URL" || echo "⚠️ Subtitles not available or failed to download."

echo "✅ Done. Video saved as: $VIDEO_FILENAME"
