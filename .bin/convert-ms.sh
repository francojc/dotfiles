#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s TARGET_DIRECTORY\n' "${0##*/}" >&2
  exit 2
}

[[ $# -eq 1 ]] || usage
target=$1
[[ -d "$target" ]] || { printf 'Error: not a directory: %s\n' "$target" >&2; exit 1; }
target=$(cd "$target" && pwd -P)

command -v pandoc >/dev/null || { printf 'Error: pandoc is required to convert .docx files.\n' >&2; exit 1; }

source_dir="$target/source"
mkdir -p "$source_dir"

# Convert DOCX files, then archive originals. Skip files already in source/.
while IFS= read -r -d '' file; do
  [[ "$file" == "$source_dir/"* ]] && continue
  output="${file%.docx}.md"
  if [[ -e "$output" ]]; then
    printf 'Skipping existing output: %s\n' "$output" >&2
    continue
  fi
  pandoc "$file" --to=markdown --output="$output"
  mv "$file" "$source_dir/"
done < <(find "$target" -type f -iname '*.docx' -print0)

# Archive XLSX files unchanged; skip files already in source/.
while IFS= read -r -d '' file; do
  [[ "$file" == "$source_dir/"* ]] && continue
  mv "$file" "$source_dir/"
done < <(find "$target" -type f -iname '*.xlsx' -print0)
