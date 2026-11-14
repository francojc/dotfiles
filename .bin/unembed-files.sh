#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s TARGET_DIRECTORY\n' "${0##*/}"
}

help() {
  usage
  cat <<'EOF'

Flatten a directory tree: move every regular file found in any subdirectory
of TARGET_DIRECTORY up into TARGET_DIRECTORY itself, then delete empty
subdirectories.

Behavior:
  - Hidden files are included; symlinks and other non-regular files are not moved.
  - Existing files are never overwritten. When a basename already exists in
    TARGET_DIRECTORY, the file stays in its subdirectory and a
    "Skipping name conflict" message is printed to stderr.
  - All empty subdirectories are removed afterward, including ones that were
    empty before the script ran.

Options:
  -h, --help   Show this help and exit.

Exit status:
  0  Success (name conflicts are reported but do not cause failure).
  1  TARGET_DIRECTORY is not a directory, or a move/delete failed.
  2  Invalid usage.

Example:
  unembed-files.sh ~/Downloads/album
    album/disc1/01.flac -> album/01.flac
EOF
}

case ${1-} in
  -h|--help) help; exit 0 ;;
esac

[[ $# -eq 1 ]] || { usage >&2; printf "Try '%s --help' for more information.\n" "${0##*/}" >&2; exit 2; }

target=$1
[[ -d "$target" ]] || { printf 'Error: not a directory: %s\n' "$target" >&2; exit 1; }

# Resolve target to an absolute path so find and moves behave consistently.
target=$(cd "$target" && pwd -P)

# Move every regular file below target into target root. Refuse overwrite;
# duplicate basenames are preserved in their original subdirectories and reported.
while IFS= read -r -d '' file; do
  [[ $(dirname "$file") == "$target" ]] && continue
  destination="$target/$(basename "$file")"

  if [[ -e "$destination" ]]; then
    printf 'Skipping name conflict: %s -> %s\n' "$file" "$destination" >&2
    continue
  fi

  mv "$file" "$destination"
done < <(find "$target" -type f -print0)

# Remove directories left empty by the moves. -delete implies -depth (deepest first).
find "$target" -mindepth 1 -type d -empty -delete
