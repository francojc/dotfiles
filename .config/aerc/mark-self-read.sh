#!/bin/sh
# Auto-mark self-sent messages as read when they arrive in the inbox
# This script is triggered by aerc's mail-received hook

# Map aerc account names to email addresses
case "$AERC_ACCOUNT" in
  Work)
    MY_EMAIL="francojc@wfu.edu"
    ;;
  Personal)
    MY_EMAIL="glitchprone@fastmail.com"
    ;;
  *)
    # Unknown account, do nothing
    exit 0
    ;;
esac

# Only process messages in the Inbox folder
if [ "$AERC_FOLDER" != "Inbox" ]; then
  exit 0
fi

# Check if the sender is yourself
if [ "$AERC_FROM_ADDRESS" = "$MY_EMAIL" ]; then
  # Use aerc's IPC to search for and mark unread messages from self as read
  # The search finds messages from your address that are unread
  # :read marks the selected/filtered messages as read
  aerc ":search -f \"from:$MY_EMAIL\" AND unread<Enter>:read<Enter>"
fi
