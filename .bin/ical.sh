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
#    `khal import -a Scheduled --batch <input.ics>` is a command that imports the `ics` file into the "Scheduled" calendar without confirmation overwritting exisiting UIDs in the calendar.
#
# 4. Finally, the script runs `ikhal` to display the calendar.
#   `ikhal` is a command that opens the calendar in an interactive terminal interface.


