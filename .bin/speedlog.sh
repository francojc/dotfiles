#!/usr/bin/env bash

# Desription: This script runs `speedtest` and logs the results. The logs will be include the date, time, ip address (and location), download speed, upload speed, and ping. The logs will be saved in a file named `speedtest.log` in the `~/.local/share/speedtest/` directory. The script will also perform checks to ensure that the `speedtest` command is available and that the log directory exists. If the directory does not exist, it will be created. The script will also check if the `jq` command is available, as it is used to parse the JSON output from the `speedtest` command. If `jq` is not available, the script will exit with an error message. The script will also check if the `speedtest` command is available, and if it is not, it will exit with an error message. The script will also check if the `curl` command is available, and if it is not, it will exit with an error message.
# Usage: speedlog.sh [-h|--help]

# Strict mode
set -o errexit  # Exit immediately if a command exits with a non-zero status.
set -o nounset  # Treat unset variables as an error when substituting.
set -o pipefail # Return value of a pipeline is the value of the last command to exit with a non-zero status,
                # or zero if all commands in the pipeline exit successfully.

# --- Configuration ---
readonly LOG_DIR="$HOME/.local/share/speedtest"
readonly LOG_FILE="$LOG_DIR/speedtest.csv"
readonly REQUIRED_COMMANDS=("speedtest" "jq" "curl" "mktemp") # Added mktemp

# --- Functions ---

# Function to print usage/help message
show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTION]
Runs a speedtest using the Ookla speedtest CLI and logs the results.

Options:
  -h, --help    Display this help message and exit.

Description:
  This script performs an internet speed test and records the timestamp,
  IP address, client location (latitude, longitude, country), download speed (Mbps),
  upload speed (Mbps), and ping (ms).

  Logs are stored in: $LOG_FILE
  The script requires 'speedtest', 'jq', 'curl', and 'mktemp' to be installed.
  It will automatically create the log directory if it doesn't exist
  and initialize the log file with a header row if it's new or empty.
EOF
}

# Function to print error messages to stderr and exit
error_exit() {
  echo -e "ERROR: $1" >&2 # Use -e to interpret newlines if any are passed
  exit 1
}

# Check for required command-line utilities
check_dependencies() {
  local cmd
  for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      error_exit "$cmd is not installed. Please install it and try again."
    fi
  done
}

# Ensure the log directory exists
ensure_log_dir() {
  if ! mkdir -p "$LOG_DIR"; then
    error_exit "Failed to create log directory: $LOG_DIR"
  fi
  if [[ ! -d "$LOG_DIR" ]]; then
    error_exit "Log directory $LOG_DIR could not be created or is not a directory."
  fi
}

# Add header to log file if it's new or empty
initialize_log_file() {
  if [[ ! -f "$LOG_FILE" ]] || [[ ! -s "$LOG_FILE" ]]; then
    # Check if we can write to the directory by attempting to write the header
    if ! echo "timestamp,ip_address,client_lat,client_lon,client_country,download_mbps,upload_mbps,ping_ms" > "$LOG_FILE"; then
      error_exit "Failed to write header to log file: $LOG_FILE. Check permissions."
    fi
  fi
}

# Run speedtest, parse results, and format them
get_speedtest_data() {
  local speedtest_json
  local speedtest_cmd_path
  local speedtest_stderr_content # Renamed from speedtest_stderr to avoid conflict
  local speedtest_exit_code
  local stderr_file
  local error_message

  if ! speedtest_cmd_path=$(command -v speedtest); then
    error_exit "speedtest command not found in PATH."
  fi
  echo "Running speedtest (this may take a moment)..." >&2

  # Create a temporary file to capture stderr
  if ! stderr_file=$(mktemp); then
    error_exit "Failed to create temporary file for stderr."
  fi

  # Execute speedtest, attempting to capture stdout, stderr, and exit code.
  # The --accept-license and --accept-gdpr flags are for the Ookla CLI.
  # If you are using a different speedtest client, these flags may not be supported.
  if ! speedtest_json=$(speedtest --json 2> "$stderr_file"); then
    speedtest_exit_code=$? # Capture exit code immediately

    if [[ -s "$stderr_file" ]]; then # Check if stderr_file has content
        speedtest_stderr_content=$(<"$stderr_file")
    else
        speedtest_stderr_content="<empty>"
    fi
    rm -f "$stderr_file"

    error_message=$(printf "speedtest command failed.\n  Path: %s\n  Exit code: %s\n  STDERR:\n%s" \
        "$speedtest_cmd_path" "$speedtest_exit_code" "$speedtest_stderr_content")
    error_exit "$error_message"
  else
    # speedtest command succeeded
    # stderr might still contain warnings (e.g. from Ookla client), but we'll ignore it if exit code was 0
    rm -f "$stderr_file"
  fi

  # Basic check for empty or non-JSON output
  if [[ -z "$speedtest_json" ]] || ! echo "$speedtest_json" | jq empty 2>/dev/null; then
    error_message=$(printf "speedtest did not return valid JSON data.\n  Path: %s\n  STDOUT:\n%s" \
        "$speedtest_cmd_path" "$speedtest_json")
    error_exit "$error_message"
  fi

  local timestamp ip_address client_lat client_lon client_country download_bps upload_bps ping_ms
  local download_mbps upload_mbps

  timestamp=$(echo "$speedtest_json" | jq -e -r '.timestamp')
  ip_address=$(echo "$speedtest_json" | jq -e -r '.client.ip')
  client_lat=$(echo "$speedtest_json" | jq -e -r '.client.lat // "N/A"')
  client_lon=$(echo "$speedtest_json" | jq -e -r '.client.lon // "N/A"')
  client_country=$(echo "$speedtest_json" | jq -e -r '.client.country // "N/A"')
  download_bps=$(echo "$speedtest_json" | jq -e -r '.download')
  upload_bps=$(echo "$speedtest_json" | jq -e -r '.upload')
  ping_ms=$(echo "$speedtest_json" | jq -e -r '.ping')

  if [[ "$timestamp" == "null" || -z "$timestamp" ]]; then error_exit "Failed to parse timestamp."; fi
  if [[ "$ip_address" == "null" || -z "$ip_address" ]]; then error_exit "Failed to parse client IP."; fi
  if [[ "$download_bps" == "null" || -z "$download_bps" ]]; then error_exit "Failed to parse download speed."; fi
  if [[ "$upload_bps" == "null" || -z "$upload_bps" ]]; then error_exit "Failed to parse upload speed."; fi
  if [[ "$ping_ms" == "null" || -z "$ping_ms" ]]; then error_exit "Failed to parse ping."; fi

  download_mbps=$(awk "BEGIN {printf \"%.2f\", $download_bps / 1000000}")
  upload_mbps=$(awk "BEGIN {printf \"%.2f\", $upload_bps / 1000000}")

  # Return the comma-separated data line and the pretty-printed output
  echo "$timestamp,$ip_address,$client_lat,$client_lon,$client_country,$download_mbps,$upload_mbps,$ping_ms"
  echo "--- Speedtest Results ---" >&2
  echo "Timestamp: $timestamp" >&2
  echo "IP Address: $ip_address" >&2
  echo "Location: $client_lat, $client_lon ($client_country)" >&2
  echo "Download: ${download_mbps} Mbps" >&2
  echo "Upload: ${upload_mbps} Mbps" >&2
  echo "Ping: ${ping_ms} ms" >&2
  echo "-------------------------" >&2
}

# Append data to the log file
append_to_log() {
  local data_line="$1"
  if ! echo "$data_line" >> "$LOG_FILE"; then
    error_exit "Failed to append data to log file: $LOG_FILE. Check permissions."
  fi
  echo "Speedtest results logged to $LOG_FILE" >&2
}

# --- Main script execution ---
main() {
  if [[ $# -gt 0 ]]; then
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
      show_help
      exit 0
    fi
  fi

  check_dependencies
  ensure_log_dir
  initialize_log_file

  local speed_data
  # Capture both the data line (stdout) and the pretty-printed output (stderr)
  speed_data=$(get_speedtest_data)

  append_to_log "$speed_data"
}

main "$@"
