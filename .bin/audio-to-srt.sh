#!/bin/bash

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
API_ENDPOINT="https://api.elevenlabs.io/v1/speech-to-text"
DEFAULT_MODEL="scribe_v1"
DEFAULT_CHUNK_DURATION=3

show_usage() {
  cat << EOF
Usage: $SCRIPT_NAME <input_file> [output_file] [options]

Convert audio/video files to SRT subtitles using ElevenLabs Scribe v1.

Arguments:
  input_file          Audio or video file to transcribe
  output_file         Output SRT file (default: input_file.srt)

Options:
  -k, --api-key KEY   ElevenLabs API key (or set ELEVENLABS_API_KEY)
  -l, --language CODE Language code (optional, auto-detect by default)
  -d, --diarize       Enable speaker diarization
  -c, --chunk-duration SECONDS  Subtitle chunk duration (default: $DEFAULT_CHUNK_DURATION)
  -m, --model MODEL   Model ID (default: $DEFAULT_MODEL)
  -h, --help          Show this help message

Examples:
  $SCRIPT_NAME audio.mp3
  $SCRIPT_NAME video.mp4 subtitles.srt --diarize
  $SCRIPT_NAME audio.wav output.srt -k your_api_key -l en

Environment Variables:
  ELEVENLABS_API_KEY  Your ElevenLabs API key
EOF
}

main() {
  local input_file=""
  local output_file=""
  local api_key="${ELEVENLABS_API_KEY:-}"
  local language_code=""
  local diarize=false
  local chunk_duration="$DEFAULT_CHUNK_DURATION"
  local model="$DEFAULT_MODEL"

  if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
  fi

  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_usage
        exit 0
        ;;
      -k|--api-key)
        api_key="$2"
        shift 2
        ;;
      -l|--language)
        language_code="$2"
        shift 2
        ;;
      -d|--diarize)
        diarize=true
        shift
        ;;
      -c|--chunk-duration)
        chunk_duration="$2"
        shift 2
        ;;
      -m|--model)
        model="$2"
        shift 2
        ;;
      -*)
        echo "Error: Unknown option $1" >&2
        show_usage >&2
        exit 1
        ;;
      *)
        if [[ -z "$input_file" ]]; then
          input_file="$1"
        elif [[ -z "$output_file" ]]; then
          output_file="$1"
        else
          echo "Error: Too many arguments" >&2
          show_usage >&2
          exit 1
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$input_file" ]]; then
    echo "Error: Input file is required" >&2
    show_usage >&2
    exit 1
  fi

  if [[ -z "$output_file" ]]; then
    output_file="${input_file%.*}.srt"
  fi

  if [[ -z "$api_key" ]]; then
    echo "Error: API key is required. Set ELEVENLABS_API_KEY or use -k option" >&2
    exit 1
  fi

  if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' does not exist" >&2
    exit 1
  fi

  if [[ ! -r "$input_file" ]]; then
    echo "Error: Input file '$input_file' is not readable" >&2
    exit 1
  fi

  local file_size
  file_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file" 2>/dev/null)
  if [[ -n "$file_size" && "$file_size" -gt 1073741824 ]]; then
    echo "Error: Input file is larger than 1GB limit ($(( file_size / 1024 / 1024 ))MB)" >&2
    exit 1
  fi

  echo "Converting '$input_file' to SRT format..."
  echo "Output file: $output_file"

  convert_audio_to_srt "$input_file" "$output_file" "$api_key" "$language_code" "$diarize" "$chunk_duration" "$model"
}

check_dependencies() {
  local missing_deps=()

  if ! command -v curl >/dev/null 2>&1; then
    missing_deps+=("curl")
  fi

  if ! command -v jq >/dev/null 2>&1; then
    missing_deps+=("jq")
  fi

  if ! command -v bc >/dev/null 2>&1; then
    missing_deps+=("bc")
  fi

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo "Error: Missing required dependencies: ${missing_deps[*]}" >&2
    echo "Please install the missing tools and try again." >&2
    exit 1
  fi
}

call_elevenlabs_api() {
  local input_file="$1"
  local api_key="$2"
  local language_code="$3"
  local diarize="$4"
  local model="$5"

  local curl_args=(
    -X POST
    -H "xi-api-key: $api_key"
    -F "file=@$input_file"
    -F "model_id=$model"
  )

  if [[ -n "$language_code" ]]; then
    curl_args+=(-F "language_code=$language_code")
  fi

  if [[ "$diarize" == "true" ]]; then
    curl_args+=(-F "diarize=true")
  fi

  echo "Sending request to ElevenLabs API..." >&2

  local response
  response=$(curl -s "${curl_args[@]}" "$API_ENDPOINT")
  local curl_exit_code=$?

  if [[ $curl_exit_code -ne 0 ]]; then
    echo "Error: Failed to connect to ElevenLabs API (curl exit code: $curl_exit_code)" >&2
    return 1
  fi

  if [[ -z "$response" ]]; then
    echo "Error: Empty response from ElevenLabs API" >&2
    return 1
  fi

  local error_message status_code
  error_message=$(echo "$response" | jq -r '.detail.message // .error // empty' 2>/dev/null)
  if [[ -n "$error_message" ]]; then
    echo "Error: API returned error: $error_message" >&2
    return 1
  fi

  status_code=$(echo "$response" | jq -r '.status_code // empty' 2>/dev/null)
  if [[ -n "$status_code" && "$status_code" != "200" ]]; then
    echo "Error: API returned status code: $status_code" >&2
    return 1
  fi

  echo "$response"
}

convert_audio_to_srt() {
  local input_file="$1"
  local output_file="$2"
  local api_key="$3"
  local language_code="$4"
  local diarize="$5"
  local chunk_duration="$6"
  local model="$7"

  check_dependencies

  local api_response
  api_response=$(call_elevenlabs_api "$input_file" "$api_key" "$language_code" "$diarize" "$model")
  if [[ $? -ne 0 ]]; then
    exit 1
  fi

  echo "Transcription completed successfully. Processing response..." >&2

  process_transcription_to_srt "$api_response" "$output_file" "$chunk_duration" "$diarize"
}

format_timestamp() {
  local seconds="$1"
  local hours minutes secs milliseconds

  # Convert to integer calculations to avoid printf issues
  local total_ms
  total_ms=$(echo "scale=0; $seconds * 1000 / 1" | bc)

  hours=$(echo "scale=0; $total_ms / 3600000" | bc)
  minutes=$(echo "scale=0; ($total_ms % 3600000) / 60000" | bc)
  secs=$(echo "scale=0; ($total_ms % 60000) / 1000" | bc)
  milliseconds=$(echo "scale=0; $total_ms % 1000" | bc)

  printf "%02d:%02d:%02d,%03d" "$hours" "$minutes" "$secs" "$milliseconds"
}

process_transcription_to_srt() {
  local api_response="$1"
  local output_file="$2"
  local chunk_duration="$3"
  local diarize="$4"

  local transcript
  transcript=$(echo "$api_response" | jq -r '.text // empty')
  if [[ -z "$transcript" ]]; then
    echo "Error: No transcript text found in API response" >&2
    exit 1
  fi

  local words_data
  words_data=$(echo "$api_response" | jq -c '.words[]? // empty')
  if [[ -z "$words_data" ]]; then
    echo "Warning: No word-level timing data found, creating simple SRT from text" >&2
    create_simple_srt "$transcript" "$output_file"
    return
  fi
  create_timed_srt "$words_data" "$output_file" "$chunk_duration" "$diarize"
}

create_simple_srt() {
  local transcript="$1"
  local output_file="$2"

  {
    echo "1"
    echo "00:00:00,000 --> 00:00:10,000"
    echo "$transcript"
    echo ""
  } > "$output_file"

  echo "Created basic SRT file: $output_file"
}

create_timed_srt() {
  local words_data="$1"
  local output_file="$2"
  local chunk_duration="$3"
  local diarize="$4"

  local subtitle_num=1
  local current_text=""
  local chunk_start=""
  local chunk_end=""
  local current_speaker=""

  {
    while IFS= read -r word_json; do
      local word_type
      word_type=$(echo "$word_json" | jq -r '.type // "word"')

      # Skip spacing tokens
      if [[ "$word_type" == "spacing" ]]; then
        continue
      fi

      local word start_time end_time speaker
      word=$(echo "$word_json" | jq -r '.text')
      start_time=$(echo "$word_json" | jq -r '.start')
      end_time=$(echo "$word_json" | jq -r '.end')

      if [[ "$diarize" == "true" ]]; then
        speaker=$(echo "$word_json" | jq -r '.speaker // ""')
      fi

      if [[ -z "$chunk_start" ]]; then
        chunk_start="$start_time"
        current_speaker="$speaker"
      fi

      if [[ -n "$current_text" ]]; then
        current_text="$current_text $word"
      else
        current_text="$word"
      fi
      chunk_end="$end_time"

      local should_break=false
      if [[ -n "$chunk_start" && -n "$chunk_end" ]]; then
        local duration
        duration=$(echo "$chunk_end - $chunk_start" | bc)
        if (( $(echo "$duration >= $chunk_duration" | bc -l) )); then
          should_break=true
        fi
      fi

      if [[ "$diarize" == "true" && -n "$speaker" && "$speaker" != "$current_speaker" ]]; then
        should_break=true
      fi

      if [[ "$should_break" == "true" && -n "$current_text" ]]; then
        echo "$subtitle_num"
        echo "$(format_timestamp "$chunk_start") --> $(format_timestamp "$chunk_end")"

        if [[ "$diarize" == "true" && -n "$current_speaker" ]]; then
          echo "Speaker $current_speaker: $current_text"
        else
          echo "$current_text"
        fi
        echo ""

        subtitle_num=$((subtitle_num + 1))
        current_text=""
        chunk_start="$start_time"
        current_speaker="$speaker"
      fi
    done <<< "$words_data"

    if [[ -n "$current_text" ]]; then
      echo "$subtitle_num"
      echo "$(format_timestamp "$chunk_start") --> $(format_timestamp "$chunk_end")"

      if [[ "$diarize" == "true" && -n "$current_speaker" ]]; then
        echo "Speaker $current_speaker: $current_text"
      else
        echo "$current_text"
      fi
      echo ""
    fi
  } > "$output_file"

  echo "Created SRT file with timed subtitles: $output_file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
