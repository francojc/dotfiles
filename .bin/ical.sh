#!/usr/bin/env bash

# Description: This script updates the `kcal` calendar by running `vdirsyncer` to sync the calendar files and then using `khal` to import an `ics` file which is the export from `reminders-cli` in JSON format converted to `ics` for this import specifically.
# Usage: ical.sh
# Dependencies: vdirsyncer, khal, reminders-cli

set -euo pipefail

# Check for required commands
for cmd in vdirsyncer reminders jq khal ikhal; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: Required command '$cmd' not found." >&2
    exit 1
  fi
done

# Step 1: Sync calendars with vdirsyncer
echo "Syncing calendars with vdirsyncer..."
echo "DEBUG: Starting calendar sync..."
if ! vdirsyncer sync; then
  echo "Error: vdirsyncer sync failed." >&2
  exit 1
fi
echo "Sync complete."

# Step 2 & 3: Export reminders, convert to ICS, and import into khal
echo "Exporting reminders and importing into khal..."

# Define the jq filter to convert Reminders JSON to ICS VEVENT format with correct block separation
jq_filter='
[
  # Header block as a single string
  (
    [
      "BEGIN:VCALENDAR",
      "VERSION:2.0",
      "PRODID:-//reminders-cli_to_khal//EN",
      "CALSCALE:GREGORIAN"
    ] | join("\r\n")
  )
] +
# Array of VEVENT blocks, each as a single string
(
  map(select(.startDate != null and .isCompleted == false)) # Filter reminders
  | map( # Transform each reminder into a VEVENT string block
      [
        "BEGIN:VEVENT",
        "UID:" + .externalId + "@reminders.local", # Using a dummy domain for UID
        # Prepend checkbox emoji to the summary
        "SUMMARY:☑️ " + .title,
        # Use DTSTART for the event start time
        "DTSTART;VALUE=DATE-TIME:" + (.startDate | gsub("[-:]"; "")), # Format date-time
        # Add DTEND, making it same as DTSTART for a zero-duration event marker
        "DTEND;VALUE=DATE-TIME:" + (.startDate | gsub("[-:]"; "")),
        "DTSTAMP:" + (now | strftime("%Y%m%dT%H%M%SZ")) # Current timestamp
      ] +
      # Add DESCRIPTION field only if .notes is not null and not empty, escaping newlines
      (if .notes and (.notes | length > 0) then ["DESCRIPTION:" + (.notes | gsub("\n"; "\\\\n"))] else [] end) +
      ["END:VEVENT"]
      | join("\r\n") # Join lines within this VEVENT block
    )
) +
[
  # Footer block as a single string
  "END:VCALENDAR"
]
# Join Header, VEVENT blocks, and Footer with double CRLF for separation
| join("\r\n\r\n")
'

# Define the target directory and file for the consolidated ICS data
reminders_dir="$HOME/.calendars/local/reminders"
target_ics_file="$reminders_dir/reminders.ics"

# Ensure the target directory exists
mkdir -p "$reminders_dir"

echo "DEBUG: Exporting reminders and constructing ICS data..."
if ! reminders show-all --format json | jq -r "$jq_filter" > "$target_ics_file"; then
    echo "Error: Failed during reminders export or jq conversion or file saving." >&2
    # Optional: Remove potentially incomplete file
    rm -f "$target_ics_file"
    exit 1
fi

# DEBUG: Verify file content (optional)
echo "DEBUG: Generated ICS data saved to $target_ics_file"
echo "DEBUG: File Content BEGIN >>>"
head -n 20 "$target_ics_file" # Show beginning of file
echo "..."
tail -n 5 "$target_ics_file" # Show end of file
echo "<<< DEBUG: File Content END"

if [ -z "$(cat "$target_ics_file")" ]; then
    echo "Warning: No reminder data generated for import (check filters or source)." >&2
    # Decide if this is an error or just informational. Let's proceed for now.
else
    # Import the specific ICS file
    echo "DEBUG: Importing ICS file ($target_ics_file) with khal..."
    if khal import -a Reminders --batch "$target_ics_file"; then
        echo "Apple Reminders import command completed."

        # Optional: You might still check if khal now sees the events
        # event_count=$(khal list -a Reminders --format "{uid}" | wc -l)
        # echo "DEBUG: khal list reports $event_count items in Reminders calendar."

        # We keep the single file; khal should now read it.
        # No need to delete the target_ics_file unless you want to clean up *after* ikhal runs.
    else
        echo "Error: Failed during khal import of $target_ics_file." >&2
        # Keep the file for debugging in case of error
        echo "The generated ICS file is preserved at: $target_ics_file for debugging"
        exit 1
    fi
fi

# Step 4: Display calendar
echo "Opening interactive khal (ikhal)..."
echo "DEBUG: Proceeding to launch ikhal..."
ikhal

