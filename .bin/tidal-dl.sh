#!/usr/bin/env bash

# tidal-dl.sh — Download tracks or albums via hifi-api
#
# Usage:
#   ./tidal-dl.sh track [OPTIONS] <track_id>
#   ./tidal-dl.sh track [OPTIONS] --artist <name> [--track <name>]
#   ./tidal-dl.sh album [OPTIONS] <album_id>
#   ./tidal-dl.sh album [OPTIONS] --artist <name> [--album <name>]
#
# Subcommands:
#   track     Download a single track (by ID or interactive search)
#   album     Download all tracks from an album (by ID or interactive search)
#
# Options:
#   -s, --server <url>      API base URL (default: https://api.monochrome.tf)
#   -q, --quality <q>       HI_RES_LOSSLESS | LOSSLESS | HIGH | LOW
#                           (default: LOSSLESS)
#   -o, --output <path>     Output parent (track) or directory (album)
#                           Defaults: <track_id>.<ext> / "<Artist> - <Album>"/
#   -i, --info              Print metadata and exit, don't download
#   -n, --dry-run           Show what would be downloaded without downloading
#   -h, --help              Show this help message
#
# Track search flags (use instead of <track_id>):
#   -A, --artist <name>     Filter results by artist name
#   -T, --track  <name>     Search by track name
#
# Album search flags (use instead of <album_id>):
#   -A, --artist <name>     Filter results by artist name
#   -L, --album  <name>     Search by album name
#
# Album output filenames:
#   Single-disc:  <NN>. <Title>.<ext>
#   Multi-disc:   <D>-<NN>. <Title>.<ext>

set -euo pipefail

# ── Defaults ────────────────────────────────────────────────────────────────
SERVER="https://api.monochrome.tf"
QUALITY="LOSSLESS"
OUTPUT=""
INFO_ONLY=false
DRY_RUN=false

# ── Helpers ──────────────────────────────────────────────────────────────────
die()     { echo "error: $*" >&2; exit 1; }
log()     { echo "  $*"; }
section() { echo; echo "── $* ──"; }

urlencode() {
  python3 -c \
    "import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1]))" "$1"
}

usage() {
  grep '^#' "$0" | sed 's/^# \{0,2\}//' | tail -n +2
  exit 0
}

require() {
  for cmd in "$@"; do
    command -v "$cmd" &>/dev/null || die "'$cmd' is required but not installed."
  done
}

# Sanitise a string for use as a filename
sanitise() {
  echo "$1" | tr '/:*?"<>|\\' '_' | sed 's/  */ /g; s/^ //; s/ $//'
}

validate_quality() {
  case "$1" in
    HI_RES_LOSSLESS|LOSSLESS|HIGH|LOW) ;;
    *) die "Invalid quality '$1'. Choose: HI_RES_LOSSLESS, LOSSLESS, HIGH, LOW" ;;
  esac
}

# ── Shared search helper ──────────────────────────────────────────────────────
# search_select <url> <category> <artist_filter>
#   <url>           Full search URL to fetch
#   <category>      "albums" or "tracks"
#   <artist_filter> Lowercase artist string, or empty string for no filtering
#
# Displays top 3 results interactively and echoes the selected ID to stdout.
search_select() {
  local url="$1"
  local category="$2"
  local artist_filter="$3"

  echo "→ Searching ..." >&2
  local search_json
  search_json=$(curl -sf "$url") \
    || die "Search request failed. Is hifi-api running?"

  local results
  results=$(echo "$search_json" | python3 -c "
import sys, json

raw  = json.load(sys.stdin)
items = raw.get('data', {}).get('$category', {}).get('items', [])

artist_filter = '${artist_filter}'

def primary_artist(item):
    arts = item.get('artists') or []
    for a in arts:
        if a.get('type') == 'MAIN':
            return a.get('name', '')
    return arts[0].get('name', '') if arts else 'Unknown'

if artist_filter:
    def score(item):
        return 0 if artist_filter in primary_artist(item).lower() else 1
    items = sorted(items, key=score)

for item in items[:3]:
    iid   = item.get('id', '')
    title = item.get('title', 'Unknown')
    aname = primary_artist(item)
    year  = (item.get('releaseDate') or '')[:4] or '????'
    if '$category' == 'albums':
        extra = str(item.get('numberOfTracks', '?')) + ' tracks'
        print(iid, aname, title, year, extra, sep='\t')
    else:
        s     = item.get('duration', 0)
        dur   = f'{s//60}:{s%60:02d}'
        alb   = item.get('album', {}).get('title', '?')
        print(iid, aname, title, alb, year, dur, sep='\t')
")

  [[ -z "$results" ]] && die "No results found."

  echo >&2
  local count=0
  declare -a ids=()
  while IFS=$'\t' read -r iid aname ititle rest1 rest2 rest3; do
    count=$((count + 1))
    ids+=("$iid")
    if [[ "$category" == "albums" ]]; then
      # rest1=year  rest2="N tracks"
      printf "  (%d) %s — %s [%s] (%s)\n" \
        "$count" "$aname" "$ititle" "$rest1" "$rest2" >&2
    else
      # rest1=album  rest2=year  rest3=mm:ss
      printf "  (%d) %s — %s [%s, %s] (%s)\n" \
        "$count" "$aname" "$ititle" "$rest1" "$rest2" "$rest3" >&2
    fi
  done <<< "$results"

  echo >&2
  printf "Select [1-%d] or q to quit: " "$count" >&2
  local choice
  read -r choice

  case "$choice" in
    q|Q) exit 0 ;;
    [1-9])
      if [[ "$choice" -ge 1 && "$choice" -le "$count" ]]; then
        echo "${ids[$((choice - 1))]}"
      else
        die "Invalid selection '$choice'. Choose 1–$count or q."
      fi
      ;;
    *) die "Invalid selection '$choice'. Choose 1–$count or q." ;;
  esac
}

# ── Core: download a single track by ID ──────────────────────────────────────
# Args: track_id [output_path]
# Uses globals: SERVER, QUALITY, INFO_ONLY, DRY_RUN
download_track() {
  local track_id="$1"
  local out_path="${2:-}"      # full path (exec_album), or empty for auto
  local base_prefix="${3:-}"   # optional base directory (cmd_track -o flag)

  # Fetch track info
  local info_json
  info_json=$(curl -sf "${SERVER}/info/?id=${track_id}") \
    || die "Could not fetch info for track ${track_id}. Is hifi-api running?"

  local title artist album duration track_num disc_num
  title=$(     echo "$info_json" | python3 -c "import sys,json; d=json.load(sys.stdin)['data']; print(d['title'])")
  artist=$(    echo "$info_json" | python3 -c "import sys,json; d=json.load(sys.stdin)['data']; print(d['artist']['name'])")
  album=$(     echo "$info_json" | python3 -c "import sys,json; d=json.load(sys.stdin)['data']; print(d['album']['title'])")
  duration=$(  echo "$info_json" | python3 -c "import sys,json; d=json.load(sys.stdin)['data']; s=d['duration']; print(f'{s//60}:{s%60:02d}')")
  track_num=$( echo "$info_json" | python3 -c "import sys,json; d=json.load(sys.stdin)['data']; print(d.get('trackNumber', 0))")
  disc_num=$(  echo "$info_json" | python3 -c "import sys,json; d=json.load(sys.stdin)['data']; print(d.get('volumeNumber', 1))")

  log "Title:    $title"
  log "Artist:   $artist"
  log "Album:    $album"
  log "Duration: $duration"
  log "Track:    disc $disc_num, track $track_num"

  $INFO_ONLY && return 0

  # Build a structured default path when the caller didn't specify one.
  # exec_album() always passes an explicit path, so this only fires for
  # standalone `track` downloads.
  local out_dir="" out_base=""
  if [[ -z "$out_path" ]]; then
    local prefix_root="${base_prefix:+${base_prefix%/}/}"
    out_dir="${prefix_root}$(sanitise "$artist")/$(sanitise "$album")"
    local prefix
    if [[ "$disc_num" -gt 1 ]]; then
      prefix=$(printf "%d-%02d" "$disc_num" "$track_num")
    else
      prefix=$(printf "%02d" "$track_num")
    fi
    out_base="${out_dir}/${prefix}. $(sanitise "$title")"
  fi

  $DRY_RUN && {
    if [[ -n "$out_base" ]]; then
      local display_path="${out_base}.flac"
      [[ -z "$base_prefix" ]] && display_path="./${display_path}"
      log "[dry-run] would download → ${display_path}"
    else
      log "[dry-run] would download → ${out_path}"
    fi
    return 0
  }

  # Fetch manifest
  local track_json
  track_json=$(curl -sf "${SERVER}/track/?id=${track_id}&quality=${QUALITY}") \
    || die "Failed to fetch manifest for track ${track_id}."

  local mime manifest_b64
  mime=$(         echo "$track_json" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['manifestMimeType'])")
  manifest_b64=$( echo "$track_json" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['manifest'])")

  case "$mime" in

    "application/vnd.tidal.bts")
      local stream_url ext
      stream_url=$(echo "$manifest_b64" | python3 -c "
import sys, json, base64
manifest = json.loads(base64.b64decode(sys.stdin.read().strip()))
print(manifest['urls'][0])
")
      ext="${stream_url%%\?*}"; ext="${ext##*.}"
      if [[ -z "$out_path" ]]; then
        out_path="${out_base}.${ext}"
        mkdir -p "$out_dir"
      fi

      log "Format:   $ext / $QUALITY"
      log "Output:   $out_path"
      curl -L --progress-bar -o "$out_path" "$stream_url"
      ;;

    "application/dash+xml")
      require ffmpeg
      local tmpmpd
      tmpmpd=$(mktemp /tmp/tidal-XXXXXX.mpd)
      # shellcheck disable=SC2064
      trap "rm -f '$tmpmpd'" RETURN

      echo "$manifest_b64" | python3 -c "
import sys, base64
sys.stdout.buffer.write(base64.b64decode(sys.stdin.read().strip()))
" > "$tmpmpd"

      if [[ -z "$out_path" ]]; then
        out_path="${out_base}.flac"
        mkdir -p "$out_dir"
      fi

      log "Format:   FLAC Hi-Res / $QUALITY"
      log "Output:   $out_path"
      ffmpeg -loglevel warning -stats -i "$tmpmpd" -c copy "$out_path"
      ;;

    *)
      die "Unrecognised manifest MIME type: $mime"
      ;;
  esac

  echo "  ✓ Saved: $out_path"
}

# ── Subcommand: track ─────────────────────────────────────────────────────────
cmd_track() {
  local track_id="" artist_q="" track_q=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--server)  SERVER="${2:?}";   shift 2 ;;
      -q|--quality) QUALITY="${2:?}";  shift 2 ;;
      -o|--output)  OUTPUT="${2:?}";   shift 2 ;;
      -i|--info)    INFO_ONLY=true;    shift   ;;
      -n|--dry-run) DRY_RUN=true;      shift   ;;
      -A|--artist)  artist_q="${2:?}"; shift 2 ;;
      -T|--track)   track_q="${2:?}";  shift 2 ;;
      -h|--help)    usage ;;
      -*)           die "Unknown option: $1" ;;
      *)            track_id="$1"; shift ;;
    esac
  done

  [[ -n "$track_id" && (-n "$artist_q" || -n "$track_q") ]] \
    && die "Provide a track ID or search flags (--artist/--track), not both."

  validate_quality "$QUALITY"
  require curl python3

  if [[ -n "$track_id" ]]; then
    section "Track $track_id"
    download_track "$track_id" "" "$OUTPUT"
  elif [[ -n "$artist_q" || -n "$track_q" ]]; then
    local query
    query="${track_q:-$artist_q}"
    local search_url="${SERVER}/search/?a=$(urlencode "$query")&limit=10"
    local filter
    filter=$(echo "$artist_q" | tr '[:upper:]' '[:lower:]')
    local selected_id
    selected_id=$(search_select "$search_url" "tracks" "$filter")
    section "Track $selected_id"
    download_track "$selected_id" "" "$OUTPUT"
  else
    die "Provide a track ID or --artist/--track flags."
  fi
}

# ── Core: download all tracks in an album by ID ───────────────────────────────
# Args: album_id
# Uses globals: SERVER, QUALITY, OUTPUT, INFO_ONLY, DRY_RUN
exec_album() {
  local album_id="$1"

  # Fetch full album metadata (limit=500 to capture everything in one shot)
  echo "→ Fetching album $album_id ..."
  local album_json
  album_json=$(curl -sf "${SERVER}/album/?id=${album_id}&limit=500") \
    || die "Could not fetch album ${album_id}. Is hifi-api running?"

  local album_title artist total_tracks num_discs duration
  album_title=$(  echo "$album_json" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['title'])")
  artist=$(       echo "$album_json" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['artist']['name'])")
  total_tracks=$( echo "$album_json" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['numberOfTracks'])")
  num_discs=$(    echo "$album_json" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['numberOfVolumes'])")
  duration=$(     echo "$album_json" | python3 -c "
import sys, json
d = json.load(sys.stdin)['data']
s = d['duration']
print(f'{s//60}:{s%60:02d}')
")

  echo
  log "Album:    $album_title"
  log "Artist:   $artist"
  log "Tracks:   $total_tracks across $num_discs disc(s)"
  log "Duration: $duration"
  log "Quality:  $QUALITY"

  $INFO_ONLY && exit 0

  # Determine output directory
  local out_dir
  if [[ -n "$OUTPUT" ]]; then
    out_dir="$OUTPUT"
  else
    out_dir="$(sanitise "$artist") - $(sanitise "$album_title")"
  fi

  $DRY_RUN || mkdir -p "$out_dir"
  log "Output:   $out_dir/"

  # Extract track list as TSV: id <tab> trackNumber <tab> volumeNumber <tab> title
  local track_list
  track_list=$(echo "$album_json" | python3 -c "
import sys, json
data = json.load(sys.stdin)['data']
for item in data['items']:
    t = item['item']
    print(t['id'], t['trackNumber'], t['volumeNumber'], t['title'], sep='\t')
")

  local total count=0 failed=0
  total=$(echo "$track_list" | wc -l | tr -d ' ')

  while IFS=$'\t' read -r tid tnum vnum ttitle; do
    count=$((count + 1))

    # Build filename prefix: multi-disc gets D-NN, single-disc gets NN
    local prefix
    if [[ "$num_discs" -gt 1 ]]; then
      prefix=$(printf "%d-%02d" "$vnum" "$tnum")
    else
      prefix=$(printf "%02d" "$tnum")
    fi

    local safe_title
    safe_title=$(sanitise "$ttitle")

    section "[$count/$total] $prefix. $ttitle"

    if $DRY_RUN; then
      log "[dry-run] track $tid → $out_dir/$prefix. $safe_title.<ext>"
      continue
    fi

    # Peek at the manifest to learn the file extension before naming the output
    local probe_json probe_mime
    probe_json=$(curl -sf "${SERVER}/track/?id=${tid}&quality=${QUALITY}" 2>/dev/null) || {
      log "⚠ Skipping track $tid (manifest fetch failed)"
      failed=$((failed + 1))
      continue
    }
    probe_mime=$(echo "$probe_json" | python3 -c "
import sys,json
print(json.load(sys.stdin)['data']['manifestMimeType'])
")

    local ext
    case "$probe_mime" in
      "application/vnd.tidal.bts")
        local probe_url
        probe_url=$(echo "$probe_json" | python3 -c "
import sys,json,base64
m = json.loads(base64.b64decode(json.load(sys.stdin)['data']['manifest']))
print(m['urls'][0])
")
        ext="${probe_url%%\?*}"; ext="${ext##*.}"
        ;;
      "application/dash+xml") ext="flac" ;;
      *)                       ext="bin"  ;;
    esac

    local final_out="${out_dir}/${prefix}. ${safe_title}.${ext}"

    if [[ -f "$final_out" ]]; then
      log "Skipping (already exists): $final_out"
      continue
    fi

    if ! download_track "$tid" "$final_out"; then
      log "⚠ Failed: $ttitle"
      failed=$((failed + 1))
    fi

  done <<< "$track_list"

  echo
  echo "── Done ──"
  log "Downloaded: $((count - failed))/$total tracks → $out_dir/"
  [[ $failed -gt 0 ]] && log "Failed:     $failed track(s) — re-run to retry skipped files."
  echo
}

# ── Subcommand: album ─────────────────────────────────────────────────────────
cmd_album() {
  local album_id="" artist_q="" album_q=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--server)  SERVER="${2:?}";   shift 2 ;;
      -q|--quality) QUALITY="${2:?}";  shift 2 ;;
      -o|--output)  OUTPUT="${2:?}";   shift 2 ;;
      -i|--info)    INFO_ONLY=true;    shift   ;;
      -n|--dry-run) DRY_RUN=true;      shift   ;;
      -A|--artist)  artist_q="${2:?}"; shift 2 ;;
      -L|--album)   album_q="${2:?}";  shift 2 ;;
      -h|--help)    usage ;;
      -*)           die "Unknown option: $1" ;;
      *)            album_id="$1"; shift ;;
    esac
  done

  [[ -n "$album_id" && (-n "$artist_q" || -n "$album_q") ]] \
    && die "Provide an album ID or search flags (--artist/--album), not both."

  validate_quality "$QUALITY"
  require curl python3

  if [[ -n "$album_id" ]]; then
    section "Album $album_id"
    exec_album "$album_id"
  elif [[ -n "$artist_q" || -n "$album_q" ]]; then
    local query
    query="${album_q:-$artist_q}"
    local search_url="${SERVER}/search/?al=$(urlencode "$query")&limit=10"
    local filter
    filter=$(echo "$artist_q" | tr '[:upper:]' '[:lower:]')
    local selected_id
    selected_id=$(search_select "$search_url" "albums" "$filter")
    section "Album $selected_id"
    exec_album "$selected_id"
  else
    die "Provide an album ID or --artist/--album flags."
  fi
}

# ── Entry point ───────────────────────────────────────────────────────────────
[[ $# -eq 0 ]] && usage

case "$1" in
  track)     shift; cmd_track "$@" ;;
  album)     shift; cmd_album "$@" ;;
  -h|--help) usage ;;
  *)         die "Unknown subcommand '$1'. Use 'track' or 'album'." ;;
esac
