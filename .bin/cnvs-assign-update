#!/usr/bin/env bash

set -euo pipefail # Exit on error, unset var, pipe failure

# --- Function Definitions ---

# Description: This script updates the due, availability (unlock), and lock dates for **Assignments** in a Canvas course.
# Usage: ./update_assignments.sh --course <course_id> --file <csv_file>
# # The CSV file should contain the following columns: title, assignment_id, due_at, unlock_at, lock_at
# # The 'title' column is present but ignored during processing.
# # The 'assignment_id' column is required and should contain the numeric ID of the Assignment.
# # The 'due_at', 'unlock_at', and 'lock_at' columns should contain date strings in the format "YYYY-MM-DD HH:MM".
# # IMPORTANT: The dates in the CSV are assumed to be in America/New_York timezone. The script will convert these
# # to UTC before sending to Canvas. Canvas will then display these times to users according to each user's
# # timezone preference in their Canvas profile.

usage() {
  echo "Usage: $0 --course <course_id> --file <csv_file>"
  echo ""
  echo "Updates the due, availability (unlock), and lock dates for **Assignments** in a Canvas course"
  echo "using data from a CSV file."
  echo ""
  echo "Arguments:"
  echo "  --course <course_id>   The numeric ID of the Canvas course."
  echo "  --file <csv_file>      Path to the CSV file containing quiz dates."
  echo "                         Expected CSV format: title,assignment_id,due_at,unlock_at,lock_at"
  echo "                         Where 'assignment_id' is the numeric ID of the Assignment."
  echo "                         The 'title' column is present but ignored during processing."
  echo "                         A header row (e.g., 'title,quiz_id,due_at,unlock_at,lock_at') is optional and skipped."
  echo "                         Dates should be in the format 'YYYY-MM-DD HH:MM' (e.g., '2023-10-01 23:59')."
  echo "                         These dates are assumed to be in America/New_York timezone."
  echo "                         Use empty strings for dates you don't want to update (e.g., 12345,2023-10-01T23:59:00Z,,)."
  echo ""
  echo "Environment Variables:"
  echo "  CANVAS_API_KEY        Your Canvas API token."
  echo "  CANVAS_BASE_URL       The base URL of your Canvas instance (e.g., https://canvas.instructure.com)."
  echo ""
  echo "Options:"
  echo "  -h, --help             Show this help message and exit."
}

die() {
  echo "Error: $*" >&2
  exit 1
}

parse_args() {

  local course_id="" # Make local to parse_args
  local csv_file=""  # Make local to parse_args

  while [[ $# -gt 0 ]]; do
    # echo "Parsing argument: $1" # Removed debugging echo
    key="$1"
    case $key in
      --course)
        [[ -z "${2:-}" ]] && die "Missing value for --course"
        # More robust check for missing value with set -e
        if [[ "$#" -lt 2 ]]; then
           die "Missing value for --course argument."
        fi
        course_id="$2"
        shift 2
         ;;
      --file)
        [[ -z "${2:-}" ]] && die "Missing value for --file"
        # More robust check for missing value with set -e
        if [[ "$#" -lt 2 ]]; then
            die "Missing value for --file argument."
        fi
        csv_file="$2"
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
    # echo "Arguments parsed" # Removed debugging echo
  done

  # Check required arguments
  [[ -z "$course_id" ]] && die "--course argument is required."
  [[ -z "$csv_file" ]] && die "--file argument is required."

  # Output the validated values
  echo "$course_id"
  echo "$csv_file"
}

validate_env() {
  echo "Validating environment variables..."
  [[ -z "${CANVAS_API_KEY:-}" ]] && die "CANVAS_API_KEY environment variable is not set."
  [[ -z "${CANVAS_BASE_URL:-}" ]] && die "CANVAS_BASE_URL environment variable is not set."
  # Remove trailing slash if present for consistency
  CANVAS_BASE_URL="${CANVAS_BASE_URL%/}"
}

validate_file() {
  echo "Validating CSV file..."
  local file_path="$1"

  if [[ ! -f "$file_path" ]]; then
    die "CSV file not found or is not a regular file: '$file_path'"
  fi

  if [[ ! -r "$file_path" ]]; then
    die "CSV file is not readable: '$file_path'"
  fi
}

convert_date_format() {
  local date_str="$1"
  # Output in ISO 8601 format with Z suffix indicating UTC

  # Step 1: Interpret the input date string as America/New_York time
  #         and get the corresponding epoch timestamp (seconds since UTC epoch).
  local epoch_timestamp date_output exit_code

  if date --version >/dev/null 2>&1; then
    # GNU date path
    date_output=$(TZ="America/New_York" date --date="$date_str" "+%s" 2>&1) || {
      echo "Error: Failed to parse date string '$date_str' with GNU date" >&2
      return 1
    }
  else
    # BSD/macOS date path
    # Expect input as "YYYY-MM-DD HH:MM"
    date_output=$(TZ="America/New_York" date -j -f "%Y-%m-%d %H:%M" "$date_str" "+%s" 2>&1) || {
      echo "Error: Failed to parse date string '$date_str' with BSD date (-j -f)" >&2
      return 1
    }
  fi

  # Validate numeric epoch
  if ! [[ "$date_output" =~ ^[0-9]+$ ]]; then
    echo "Error: Date parsing produced non-numeric epoch: '$date_output'" >&2
    return 1
  fi
  epoch_timestamp="$date_output"

  # Step 2: Convert the epoch timestamp to the desired UTC ISO 8601 format.
  if date --version >/dev/null 2>&1; then
    date -u -d "@$epoch_timestamp" +"%Y-%m-%dT%H:%M:%SZ"
  else
    date -u -r "$epoch_timestamp" +"%Y-%m-%dT%H:%M:%SZ"
  fi
}

# Function to update assignment dates
update_assignment() {
  echo "Updating assignment..."
  local c_id="$1"
  local a_id="$2"
  # Store original date strings
  local original_due_at="$3"
  local original_unlock_at="$4"
  local original_lock_at="$5"

  # Convert dates to ISO 8601 format only if they are not empty
  local c_due_at="" c_unlock_at="" c_lock_at=""
  [[ -n "$original_due_at" ]] && c_due_at=$(convert_date_format "$original_due_at")
  [[ -n "$original_unlock_at" ]] && c_unlock_at=$(convert_date_format "$original_unlock_at")
  [[ -n "$original_lock_at" ]] && c_lock_at=$(convert_date_format "$original_lock_at")

  # --- Debugging Date Conversion ---
  echo "--- Date Conversion Debug ---"
  echo "Original Due (America/New_York):    '$original_due_at'"
  echo "Converted Due (UTC):                '$c_due_at'"
  echo "Original Unlock (America/New_York): '$original_unlock_at'"
  echo "Converted Unlock (UTC):             '$c_unlock_at'"
  echo "Original Lock (America/New_York):   '$original_lock_at'"
  echo "Converted Lock (UTC):               '$c_lock_at'"
  echo "---------------------------"
  echo "Note: Canvas will display these times to users according to each user's timezone preference."
  # --- End Debugging ---

  # Use the Assignments API endpoint
  local api_url="${CANVAS_BASE_URL}/api/v1/courses/${c_id}/assignments/${a_id}"
  local json_payload='{"assignment":{' # Changed from "quiz"
  local add_comma=false

  # Build JSON payload, adding keys only if the corresponding date is not empty
  if [[ -n "$original_due_at" ]]; then # Check original value
    json_payload+="\"due_at\":\"$c_due_at\""
    add_comma=true
  fi
  if [[ -n "$original_unlock_at" ]]; then # Check original value
    [[ "$add_comma" == true ]] && json_payload+=','
    json_payload+="\"unlock_at\":\"$c_unlock_at\""
    add_comma=true
  fi
  if [[ -n "$original_lock_at" ]]; then # Check original value
    [[ "$add_comma" == true ]] && json_payload+=','
    json_payload+="\"lock_at\":\"$c_lock_at\""
  fi

  json_payload+='}}'

  echo "--- Updating Assignment ---"
  echo "Assignment Title: $current_title"
  echo "Course ID: $c_id"
  echo "Assignment ID: $a_id"
  echo "API URL:   $api_url"
  echo "Payload:   $json_payload"
  echo "---------------------"

  # Make the API call using curl
  # -s: Silent mode
  # -w "\nHTTP_STATUS:%{http_code}": Append HTTP status code to output
  # -X PUT: Use PUT method for Assignments update
  # -H: Headers for token and content type
  # -d: Data payload (JSON)
  # Changed from PATCH to PUT for Assignments API
  response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
    -X PUT "$api_url" \
    -H "Authorization: Bearer ${CANVAS_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$json_payload")

  # Extract status code and response body
  http_status=$(echo "$response" | tail -n1)
  response_body=$(echo "$response" | sed '$d') # Remove last line (status code)

  # Check HTTP status code
  if [[ "$http_status" == "HTTP_STATUS:200" ]]; then
    echo "Successfully updated assignment $a_id." # Changed from "quiz"
    # Optionally print response body on success:
    # echo "Response:"
    # echo "$response_body" | jq . # Requires jq to be installed for pretty printing
  else
    echo "Error updating assignment $a_id." >&2 # Changed from "quiz"
    echo "Status: $http_status" >&2
    echo "Response Body:" >&2
    echo "$response_body" >&2
    # Consider exiting with non-zero status specific to API errors
    exit 2
  fi
}

# --- Main Script Logic ---

main() {

  local course_id csv_file
  echo "Starting script..."

  # Capture the output from parse_args
  local parsed_output
  parsed_output=$(parse_args "$@") || exit 1 # Exit if parse_args failed

  # Read the output into local variables
  # Use process substitution and read for safety with special characters/newlines
  { read -r course_id && read -r csv_file; } < <(printf '%s\n' "$parsed_output")

  echo "Parsed arguments: course_id='$course_id', csv_file='$csv_file'"

  # Add validation after capturing output
  [[ -z "$course_id" ]] && die "Failed to capture course_id from parse_args."
  [[ -z "$csv_file" ]] && die "Failed to capture csv_file from parse_args."

  validate_env
  echo "Environment variables validated."

  validate_file "$csv_file"
  echo "CSV file validated: $csv_file"

  local processed_count=0

  # Read CSV line by line (handles various line endings)
  # Skip header specifically by checking content, not just line number
  # Read 5 columns, expecting title first, then assignment_id
  while IFS=',' read -r csv_title csv_assignment_id csv_due_at csv_unlock_at csv_lock_at || [[ -n "$csv_title" ]]; do # Changed csv_quiz_id
    # Trim leading/trailing whitespace from title and ID
    local current_title
    current_title=$(echo "$csv_title" | xargs) # Trim title (though it's ignored mostly)
    local current_assignment_id # Changed from current_quiz_id
    current_assignment_id=$(echo "$csv_assignment_id" | xargs) # Changed csv_quiz_id

    # Validate assignment ID - should be numeric
    if ! [[ "$current_assignment_id" =~ ^[0-9]+$ ]]; then # Changed current_quiz_id
      # Skip header row - check second column (assignment_id) or first (title)
      if [[ "$current_assignment_id" == "assignment_id" || "$current_title" == "title" ]]; then # Changed quiz_id
         continue
      # Skip potential empty lines (if first column is empty)
      elif [[ -z "$current_title" && -z "$current_assignment_id" ]]; then # Changed current_quiz_id
         continue
      else
         echo "Warning: Skipping row with non-numeric or invalid quiz ID in second column: '$current_quiz_id'" >&2
         continue
      fi
    fi

    # Trim dates as well
    local due_at unlock_at lock_at
    due_at=$(echo "$csv_due_at" | xargs)
    unlock_at=$(echo "$csv_unlock_at" | xargs)
    # Handle potential trailing carriage return if file came from Windows
    lock_at=$(echo "${csv_lock_at//$'\r'/}" | xargs)

    # Check if at least one date field has content for this specific assignment
    if [[ -z "$due_at" && -z "$unlock_at" && -z "$lock_at" ]]; then # Check moved slightly down
        echo "Skipping Assignment ID '$current_assignment_id': No date values found in CSV row. Nothing to update." >&2 # Changed Quiz ID, current_quiz_id
        continue
    fi

    # Call update_assignment for the current assignment ID from the CSV
    update_assignment "$course_id" "$current_assignment_id" "$due_at" "$unlock_at" "$lock_at" # Changed function name, current_quiz_id
    processed_count=$((processed_count + 1))

  done < "$csv_file"

  # Check if any quizzes were processed
  if [[ "$processed_count" -eq 0 ]]; then
    if grep -q -E '^[0-9]+,' "$csv_file"; then # Check if there are any valid-looking data rows
       echo "Warning: No assignments were updated. Check CSV format and content." >&2 # Changed quizzes
    else
       echo "Warning: No assignments were updated. CSV file appears to be empty or only contains a header." >&2 # Changed quizzes
    fi
  fi

  echo "Script finished. Processed $processed_count assignments."
}

# --- Execute Main Function ---
main "$@"

