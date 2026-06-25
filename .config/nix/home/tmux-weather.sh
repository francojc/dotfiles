#!/usr/bin/env bash
# Cached weather fetch for tmux status bar.
# Refreshes every CACHE_TTL seconds; survives wttr.in hiccups by
# serving the last good result from the cache file.
#
# Called by tmux as #(~/.config/tmux/tmux-weather.sh)
# Configure via env (defaults shown):
#   WTTR_LOCATION  "" (empty = IP geolocate)
#   WTTR_FORMAT    "3"  (wttr.in format string)
#   WTTR_UNITS     "u"  (u=imperial, m=metric)
#   CACHE_TTL      600  (seconds between refetches)

set -u

LOCATION="${WTTR_LOCATION-}"
FORMAT="${WTTR_FORMAT-%c+%t}"
UNITS="${WTTR_UNITS-u}"
CACHE_TTL="${CACHE_TTL-600}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux"
CACHE_FILE="$CACHE_DIR/weather.txt"

mkdir -p "$CACHE_DIR"

# Refresh if cache missing or stale.
refresh() {
  local url="wttr.in/${LOCATION}?format=${FORMAT}&${UNITS}"
  local result
  result="$(curl -fsS --max-time 5 "$url" 2>/dev/null)" || return 1
  printf '%s' "$result" > "$CACHE_FILE"
}

# Serve cached if fresh enough; else refetch.
if [ -f "$CACHE_FILE" ]; then
  age=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null) ))
  if [ "$age" -ge "$CACHE_TTL" ]; then
    refresh || true  # keep stale cache on failure
  fi
else
  refresh || printf 'weather unavailable' > "$CACHE_FILE"
fi

cat "$CACHE_FILE" 2>/dev/null || printf ''
