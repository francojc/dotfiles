#!/usr/bin/env bash

# SwiftBar plugin: shows caffeinate -di state managed by tinycast-awake
#
# Install: either point SwiftBar at ~/.dotfiles/swiftbar/ or symlink this
# file into SwiftBar's plugin directory. Refresh interval is 5 seconds.
#
# Plugin only reads state files — it does NOT run pgrep itself, so the
# default pattern (pi-coding-agent) cannot self-match this script.
#
# Icons are SF Symbols via SwiftBar's inline :symbol: syntax (Big Sur+).
# They render as monochrome templates that auto-tint to the menu bar.
# :sun.max.fill:   awake (caffeinate -di active in either mode)
# :moon.fill:      asleep (normal macOS sleep behavior)
# :eye:            watch mode armed
# :eye.slash:      stop watching
# :power:          manual toggle / kill
# :arrow.clockwise: refresh

set -euo pipefail

STATE_DIR="${TINYCAST_STATE_DIR:-$HOME/.local/state/tinycast}"
SCRIPT="$HOME/.dotfiles/.bin/tinycast-awake"

MAIN_PID_FILE="$STATE_DIR/main.pid"
WATCH_PID_FILE="$STATE_DIR/watch.pid"
PATTERN_FILE="$STATE_DIR/watch.pattern"

_pid_alive() {
  local pid_file="$1"
  local pid
  pid=$(cat "$pid_file" 2>/dev/null) || return 1
  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  kill -0 "$pid" 2>/dev/null || return 1
  ps -p "$pid" -o args= 2>/dev/null | grep -q -- 'caffeinate.*-d'
}

main_alive=0
watch_alive=0
_pid_alive "$MAIN_PID_FILE" && main_alive=1
_pid_alive "$WATCH_PID_FILE" && watch_alive=1

if (( main_alive || watch_alive )); then
  echo ":sun.max.fill:"
  echo "---"
  (( main_alive )) && echo ":power: Manual: ON"
  if (( watch_alive )); then
    pat="-"
    [[ -f "$PATTERN_FILE" ]] && pat=$(cat "$PATTERN_FILE")
    echo ":eye: Watch ($pat): ON"
  fi
  echo "---"
  echo ":moon.fill: Allow Sleep | bash=$SCRIPT param0=off terminal=false refresh=true"
  if (( watch_alive )); then
    echo ":eye.slash: Stop Watching | bash=$SCRIPT param0=unwatch terminal=false refresh=true"
  fi
else
  echo ":moon.fill:"
  echo "---"
  echo "Normal Sleep Enabled"
  echo "---"
  echo ":sun.max.fill: Keep Awake | bash=$SCRIPT param0=on terminal=false refresh=true"
  echo ":eye: Watch Pi | bash=$SCRIPT param0=watch terminal=false refresh=true"
fi

echo "---"
echo ":arrow.clockwise: Refresh | refresh=true"
