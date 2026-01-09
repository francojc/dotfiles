#!/bin/sh
# Auto-mark self-sent messages as read when they arrive in the inbox
# This script is triggered by aerc's mail-received hook

# Debug logging
LOGFILE="$HOME/.config/aerc/mark-self-read.log"
exec >> "$LOGFILE" 2>&1
echo "=== $(date) ==="
echo "AERC_ACCOUNT: $AERC_ACCOUNT"
echo "AERC_FOLDER: $AERC_FOLDER"
echo "AERC_FROM_ADDRESS: $AERC_FROM_ADDRESS"
echo "AERC_FROM_NAME: $AERC_FROM_NAME"

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
    echo "Unknown account: $AERC_ACCOUNT, exiting"
    exit 0
    ;;
esac
echo "MY_EMAIL: $MY_EMAIL"

# Only process messages in the Inbox folder
# Note: Folder names may have emoji prefixes like "  Inbox"
case "$AERC_FOLDER" in
  *Inbox)
    # This is an Inbox folder (may have emoji prefix)
    echo "Folder is Inbox (or variant)"
    ;;
  *)
    # Not an Inbox folder, skip
    echo "Not Inbox folder: $AERC_FOLDER, exiting"
    exit 0
    ;;
esac

# Check if the sender is yourself
if [ "$AERC_FROM_ADDRESS" = "$MY_EMAIL" ]; then
  echo "Sender is myself, marking as read..."

  # Wait a moment for the message to be fully indexed
  sleep 2

  # Try multiple approaches to mark messages as read
  echo "=== Approach 1: Direct :read command ==="
  # First, try to just send :read command (operates on current selection)
  aerc :read 2>&1 | head -10 >> "$LOGFILE"

  sleep 1

  echo "=== Approach 2: Search then mark all and read ==="
  # Second approach: search, mark all, read, clear
  aerc :search -f "from:$MY_EMAIL" unread :mark -a :read :clear 2>&1 | head -20 >> "$LOGFILE"

  echo "Command execution completed"
else
  echo "Sender is not myself ($AERC_FROM_ADDRESS != $MY_EMAIL), exiting"
fi
