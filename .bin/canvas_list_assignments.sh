#!/usr/bin/env bash

# Description: This script lists Assignments for a specific Canvas course in CSV format.
# It outputs assignment ID, title, and empty columns for due_at, unlock_at, lock_at.
# This format serves as a template for the 'update_assignments.sh' script, which reads all columns
# but only uses assignment_id, due_at, unlock_at, and lock_at.
# Therefore, the output of this script can be used directly as input for 'update_assignments.sh'.

set -euo pipefail # Exit on error, unset var, pipe failure

# --- Function Definitions ---

usage() {
  echo "Usage: $0 --course <course_id> --output <output_directory>"
  echo ""
  echo "Lists assignments for a specific Canvas course in CSV format."
  echo "Outputs assignment ID, title, and empty columns for due_at, unlock_at, lock_at."
  echo "This format serves as a template for the 'update_assignments.sh' script."
  echo "The 'update_assignments.sh' script reads all columns but only uses the Assignment ID, due_at, unlock_at, and lock_at."
  echo "Therefore, the output of this script can be used directly as input for 'update_assignments.sh'."
  echo ""
  echo "The output is saved to '<output_directory>/assignments.csv'."
  echo ""
  echo "Arguments:"
  echo "  --course <course_id>   The numeric ID of the Canvas course."
  echo "  --output <dir_path>    The directory where 'assignments.csv' will be saved."
  echo ""
  echo "Environment Variables:"
  echo "  CANVAS_API_KEY        Your Canvas API token."
  echo "  CANVAS_BASE_URL       The base URL of your Canvas instance (e.g., https://canvas.instructure.com)."
  echo ""
  echo "Prerequisites:"
  echo "  jq     (Command-line JSON processor) is required."
  echo ""
  echo "Options:"
  echo "  -h, --help             Show this help message and exit."
  echo ""
  echo "Example Output:"
  echo "title,assignment_id,due_at,unlock_at,lock_at"
  echo "\"Assignment A\", 9876,,,,"
  echo "\"Assignment B\", 5432,,,," # Example output
}


# Function to handle errors and exit
die() {
  echo -n "Error: " >&2
  echo "$@" >&2
  exit 1
}

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    die "This script requires 'jq'. Please install it (e.g., 'brew install jq' or 'sudo apt install jq')."
fi

# Function to parse command-line arguments
parse_args() {
  # Initialize variables in the calling scope
  course_id=""
  output_dir=""

  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      --course)
        [[ -z "${2:-}" ]] && die "Missing value for --course"
        course_id="$2"
        shift 2
        ;;
      --output)
        [[ -z "${2:-}" ]] && die "Missing value for --output"
        output_dir="$2"
        shift 2
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *) # unknown option
        usage
        die "Unknown option: $1"
        ;;
    esac
  done

  # Check required arguments
  [[ -z "$course_id" ]] && die "--course argument is required."
  [[ -z "$output_dir" ]] && die "--output argument is required."

}

# Function to validate output directory
validate_output_dir() {
    local dir_path="$1"
    echo "Validating output directory: $dir_path" >&2
    if [[ ! -d "$dir_path" ]]; then
        die "Output path exists, but is not a directory, or path does not exist: '$dir_path'. Please provide a valid directory path for --output."
    fi
    if [[ ! -w "$dir_path" ]]; then
        die "Output directory is not writable: $dir_path"
    fi
    echo "Output directory validated." >&2
}

validate_env() {
  echo "Validating environment variables (CANVAS_API_KEY, CANVAS_BASE_URL)..." >&2
  [[ -z "${CANVAS_API_KEY:-}" ]] && die "Required environment variable CANVAS_API_KEY is not set."
  [[ -z "${CANVAS_BASE_URL:-}" ]] && die "Required environment variable CANVAS_BASE_URL is not set."
  # Remove trailing slash if present for consistency
  CANVAS_BASE_URL="${CANVAS_BASE_URL%/}"
  echo "Environment variables validated." >&2
}

fetch_and_format_assignments() {
  local c_id="$1"
  local api_url="${CANVAS_BASE_URL}/api/v1/courses/${c_id}/assignments?per_page=100" # Fetch up to 100 Assignments
  echo "Fetching assignments from: $api_url" >&2
  # Fetch data using curl, pipe to jq for processing
  # -s: Silent curl operation
  # jq:
  #   -r: Raw output (removes quotes from strings)
  #   .[]: Iterate over each element in the top-level array
  #   [.name, .id,  "", "", ""]: Create an array with name, id, and 3 empty strings
  #   @csv: Format the array as a CSV line
  curl -s -H "Authorization: Bearer ${CANVAS_API_KEY}" "$api_url" | \
    jq -r '.[] | [.name, .id,"", "", ""] | @csv'

  # Check if curl or jq failed (simplistic check based on pipe status)
  local pipe_status=("${PIPESTATUS[@]}")
  if [[ ${pipe_status[0]} -ne 0 ]]; then
      die "curl command failed to fetch data from API URL: $api_url"
  elif [[ ${pipe_status[1]} -ne 0 ]]; then
      die "jq command failed to process the JSON data."
  fi
  echo "Assignment data fetched and formatted successfully." >&2
}


# --- Main Script Logic ---

main() {
  local course_id output_dir output_file
  echo "Parsing arguments..." >&2
  parse_args "$@" # Populates course_id
  echo "Arguments parsed. Course ID: $course_id, Output Dir: $output_dir" >&2 # Added

  echo "Entering validate_env..." >&2 # Added
  validate_env
  echo "Exited validate_env." >&2 # Added

  echo "Entering validate_output_dir..." >&2 # Added
  # output_dir is now populated by parse_args
  validate_output_dir "$output_dir"
  echo "Exited validate_output_dir." >&2 # Added

  # Define the output file path
  output_file="${output_dir}/assignments.csv"

  echo "Writing CSV header to: $output_file" >&2
  # Output the CSV header, overwriting the file if it exists
  echo "title,assignment_id,due_at,unlock_at,lock_at" > "$output_file"

  echo "Starting assignment fetch and format process..." >&2
  # Fetch assignment data and append formatted CSV lines to the file
  # The fetch_and_format_assignments function prints to stdout, which we redirect
  fetch_and_format_assignments "$course_id" >> "$output_file"

  echo "Script finished. CSV template generated at: $output_file" >&2
  # Reminder message to add dates
  echo "Reminder: Edit the generated file $output_file and add dates before using with update_assignments.sh" >&2
}

# --- Execute Main Function ---
main "$@"
