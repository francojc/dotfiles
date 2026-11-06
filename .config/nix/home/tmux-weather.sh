#!/usr/bin/env bash
# Cached weather fetch for tmux status bar.
# Refreshes every CACHE_TTL seconds; survives wttr.in hiccups by
# serving the last good result from the cache file.
#
# Fetches wttr.in j1 JSON, maps weatherCode to a Nerd Font weather
# glyph (monochrome, not emoji), and caches "<glyph> <temp>".
#
# Called by tmux as #(~/.config/tmux/tmux-weather.sh)
# Configure via env (defaults shown):
#   WTTR_LOCATION  "" (empty = IP geolocate)
#   WTTR_UNITS     "u"  (u=imperial, m=metric)
#   CACHE_TTL      600  (seconds between refetches)
#
# Requires: curl, jq, a Nerd Font (v3+) in the terminal.

set -u

LOCATION="${WTTR_LOCATION-}"
UNITS="${WTTR_UNITS-u}"
CACHE_TTL="${CACHE_TTL-600}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux"
CACHE_FILE="$CACHE_DIR/weather.txt"

mkdir -p "$CACHE_DIR"

# Map WWO weatherCode to Nerd Font weather glyph (Weather Icons set,
# codepoints from Nerd Fonts glyphnames.json "weather-*").
glyph_for() {
  case "$1" in
    113)                                    printf '\U000e30d' ;;  # weather-day_sunny
    116)                                    printf '\U000e302' ;;  # weather-day_cloudy
    119|122)                                printf '\U000e33d' ;;  # weather-cloud
    143|248|260)                            printf '\U000e313' ;;  # weather-fog
    200|386|389)                            printf '\U000e31d' ;;  # weather-thunderstorm
    392|395)                                printf '\U000e365' ;;  # weather-day_snow_thunderstorm
    179|323|326|329|332|335|338|368|371)    printf '\U000e31a' ;;  # weather-snow
    227|230)                                printf '\U000e35e' ;;  # weather-snow_wind (blowing/blizzard)
    182|317|320|350|362|365|374|377)        printf '\U000e3ad' ;;  # weather-sleet (sleet, ice pellets)
    281|284|311|314)                        printf '\U000e316' ;;  # weather-rain_mix (freezing rain)
    176|263|266|293|296|299|302|305|308|353|356|359)
                                            printf '\U000e318' ;;  # weather-rain (rain, drizzle, showers)
    *)                                      printf '\U000e33d' ;;  # unknown: neutral cloud
  esac
}

# Fetch j1 JSON, render "<glyph> <temp>", write cache.
# Returns 1 on any failure so the stale cache is kept.
refresh() {
  local url="wttr.in/${LOCATION}?format=j1"
  local json code temp tmp
  json="$(curl -fsS --max-time 5 "$url" 2>/dev/null)" || return 1

  if [ "$UNITS" = "m" ]; then
    temp="$(jq -r '.current_condition[0].temp_C' <<< "$json" 2>/dev/null)" || return 1
    temp="${temp}°C"
  else
    temp="$(jq -r '.current_condition[0].temp_F' <<< "$json" 2>/dev/null)" || return 1
    temp="${temp}°F"
  fi
  code="$(jq -r '.current_condition[0].weatherCode' <<< "$json" 2>/dev/null)" || return 1

  [ -n "$code" ] && [ "$code" != "null" ] || return 1

  tmp="$(mktemp "$CACHE_DIR/weather.XXXXXX")" || return 1
  printf '%s %s' "$(glyph_for "$code")" "$temp" > "$tmp" && mv "$tmp" "$CACHE_FILE"
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
