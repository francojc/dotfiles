#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s TARGET_DIRECTORY\n' "${0##*/}" >&2
  exit 2
}

[[ $# -eq 1 ]] || usage

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

# Remove directories left empty by the moves, deepest first.
find "$target" -mindepth 1 -type d -empty -depth -delete
