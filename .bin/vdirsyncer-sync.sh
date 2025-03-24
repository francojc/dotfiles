#!/usr/bin/env bash

# Description: This script is used to syncronize my Google Calendar with vdirsyncer
# and my local calendar. It is called by a cron job every 15 minutes.
# Usage: ~/.bin/vdirsyncer-sync.sh

USERNAME=$(whoami)

export PATH=/usr/local/bin:/usr/bin:/bin:/etc/profiles/per-user/$USERNAME/bin

export GNUPGHOME=/Users/$USERNAME/.gnupg

/etc/profiles/per-user/$USERNAME/bin/vdirsyncer sync
