#!/usr/bin/env bash
set -euo pipefail

pane_position="${TUICR_PANE_POSITION:-top}"
pane_size="${TUICR_PANE_SIZE:-80}"

usage() {
	cat <<'EOF'
Usage: tuicr-tmux.sh [repository] [tuicr arguments...]

Launch tuicr in a detached tmux pane and return immediately.

Arguments:
  repository          Git repository to review. Default: current directory.
  tuicr arguments     Arguments passed to tuicr, for example -w or -r main..HEAD.

Environment:
  TUICR_PANE_POSITION top or bottom. Default: top.
  TUICR_PANE_SIZE     Pane height as percent. Default: 80.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	usage
	exit 0
fi

if [[ -z "${TMUX:-}" ]]; then
	printf '%s\n' 'Error: tmux environment required.' >&2
	exit 1
fi

if ! command -v tuicr >/dev/null 2>&1; then
	printf '%s\n' 'Error: tuicr not found on PATH.' >&2
	exit 1
fi

repo="${1:-.}"
if [[ $# -gt 0 ]]; then
	shift
fi

repo="$(cd "$repo" && pwd)"
if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
	printf 'Error: not a Git repository: %s\n' "$repo" >&2
	exit 1
fi

if [[ ! "$pane_position" =~ ^(top|bottom)$ ]]; then
	printf 'Error: TUICR_PANE_POSITION must be top or bottom, got %q.\n' "$pane_position" >&2
	exit 1
fi
if [[ ! "$pane_size" =~ ^([1-9][0-9]?|100)$ ]]; then
	printf 'Error: TUICR_PANE_SIZE must be an integer from 1 to 100, got %q.\n' "$pane_size" >&2
	exit 1
fi

window_height="$(tmux display-message -p '#{window_height}')"
pane_lines=$((window_height * pane_size / 100))
pane_lines=$((pane_lines > 0 ? pane_lines : 1))

command='exec tuicr'
for argument in "$@"; do
	printf -v quoted_argument ' %q' "$argument"
	command+="$quoted_argument"
done

split_args=(-d -P -F '#{pane_id}' -l "$pane_lines" -c "$repo")
if [[ "$pane_position" == "top" ]]; then
	split_args+=(-b)
fi

pane_id="$(tmux split-window "${split_args[@]}" "$command")"
printf 'tuicr started in tmux pane %s for %s\n' "$pane_id" "$repo"
printf 'Switch panes with Ctrl-b then arrow keys. Quit tuicr with q.\n'
