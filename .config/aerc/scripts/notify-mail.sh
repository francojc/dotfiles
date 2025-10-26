#!/bin/bash
#
# aerc mail notification script for macOS
# Called by the mail-received hook with AERC_* environment variables

# Escape double quotes in variables to prevent AppleScript errors
SUBJECT="${AERC_SUBJECT//\"/\\\"}"
FROM="${AERC_FROM_NAME//\"/\\\"}"
ACCOUNT="${AERC_ACCOUNT//\"/\\\"}"
FOLDER="${AERC_FOLDER//\"/\\\"}"

# Send native macOS notification
osascript -e "display notification \"$SUBJECT\" with title \"📧 New Mail: $FROM\" subtitle \"$ACCOUNT/$FOLDER\" sound name \"Glass\""
