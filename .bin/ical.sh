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

# Define the jq filter to convert Reminders JSON to ICS VTODO format with correct block separation
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
# Array of VTODO blocks, each as a single string
(
  map(select(.startDate != null and .isCompleted == false)) # Filter reminders
  | map( # Transform each reminder into a VTODO string block
      [
        "BEGIN:VTODO",
        "UID:" + .externalId + "@reminders.local", # Using a dummy domain for UID
        "SUMMARY:" + .title,
        "DTSTART;VALUE=DATE-TIME:" + (.startDate | gsub("[-:]"; "")), # Format date-time
        "DTSTAMP:" + (now | strftime("%Y%m%dT%H%M%SZ")), # Current timestamp
        "STATUS:NEEDS-ACTION"
      ] +
      # Add DESCRIPTION field only if .notes is not null and not empty, escaping newlines
      (if .notes and (.notes | length > 0) then ["DESCRIPTION:" + (.notes | gsub("\n"; "\\\\n"))] else [] end) +
      ["END:VTODO"]
      | join("\r\n") # Join lines within this VTODO block
    )
) +
[
  # Footer block as a single string
  "END:VCALENDAR"
]
# Join Header, VTODO blocks, and Footer with double CRLF for separation
| join("\r\n\r\n")
'

echo "DEBUG: Exporting reminders and constructing ICS data..."
ics_data=$(reminders show-all --format json | jq -r "$jq_filter")

if [ $? -ne 0 ]; then
    echo "Error: Failed during reminders export or jq conversion." >&2
    exit 1
fi

# DEBUG: Print the generated ICS data for inspection
echo "DEBUG: Generated ICS Data BEGIN >>>"
echo "$ics_data"
echo "<<< DEBUG: Generated ICS Data END"

if [ -z "$ics_data" ]; then
    echo "Warning: No reminder data generated for import (check filters or source)." >&2
    # Decide if this is an error or just informational. Let's proceed for now.
else
    echo "DEBUG: Piping generated ICS data to khal import..."
    if echo "$ics_data" | khal import -a Reminders --batch -; then
        echo "Reminders imported successfully."
    else
        echo "Error: Failed during khal import." >&2
        # Ensure script exits on import failure
        exit 1
    fi
fi

# Step 4: Display calendar
echo "Opening interactive khal (ikhal)..."
echo "DEBUG: Proceeding to launch ikhal..."
ikhal



