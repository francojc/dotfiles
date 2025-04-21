#!/usr/bin/env bash

# Description: This script updates the `kcal` calendar by running `vdirsyncer` to sync the calendar files and then using `khal` to import an `ics` file which is the export from `reminders-cli` in JSON format converted to `ics` for this import specifically.
# # Usage: ical.sh
# # Dependencies: vdirsyncer, khal, reminders-cli

# Detailed description:
# 1. The script first runs `vdirsyncer` to sync the calendar files.
#    `vdirsyncer sync` is a command that synchronizes the local calendar files with the remote server (already set up).
# 2. Export the reminders from `reminders-cli` in JSON format and convert it to `ics` format.
#    `reminders show-all --format json` is a command that exports all reminders in JSON format:
#    ```json
#    [
#    {
#   "externalId" : "6864101F-0009-4A32-8FE3-C5AC674E15E1",
#   "isCompleted" : false,
#   "list" : "Personal",
#   "priority" : 0,
#   "startDate" : "2025-04-18T04:00:00Z",
#   "title" : "Do the laundry"
#   },
#   {
#   "externalId" : "CE4E7778-B8F9-4D76-8D2F-4BFC7E322A5C",
#   "isCompleted" : false,
#   "list" : "Research",
#   "notes" : "Since TBDBr is not on CRAN qtkit cannot depend on it. Reach out to the devs and\/ or fork the repo to brainstorm getting the package on CRAN",
#   "priority" : 0,
#   "title" : "Consider TBDBr collab to publish on CRAN"
#    }
#    ]
#    ```
# Reminder objects without `startDate` are ignored.
# The final output of the `reminders-cli` command is piped to `jq` to convert it to `ics` format similar to the following (note that the reminder with no date is ignored):
# BEGIN:VCALENDAR
# VERSION:2.0
# PRODID:-//Your Organization//Your App//EN
# CALSCALE:GREGORIAN
#
# BEGIN:VTODO
# UID:06ABA2FF-3487-4C4E-8406-96E042AC9EFA@yourdomain.com
# SUMMARY:Check out Nix and Nix flakes intro book
# DTSTAMP:20250421T161313Z
# STATUS:NEEDS-ACTION
# END:VTODO
#
# END:VCALENDAR
#
# 3. The script then uses `khal` to import the `ics` file into the calendar.
#    `khal import -a Scheduled --batch <input.ics>` is a command that imports the `ics` file into the "Scheduled" calendar.
#    By default, `khal import` asks before updating an event if an event with the same UID already exists.
#    The `--batch` flag used here forces `khal` to always update (overwrite) existing events with the same UID without asking.
#    The input is piped from the previous command instead of reading from a file.
#
# 4. Finally, the script runs `ikhal` to display the calendar.
#   `ikhal` is a command that opens the calendar in an interactive terminal interface.

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
    if echo "$ics_data" | khal import -a Scheduled --batch -; then
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



