#!/usr/bin/env bash
# Rebuild work-emailbook.txt from professional.txt + wake.txt.
# Backs up the existing work-emailbook.txt to .bak first and writes via
# temp file + mv so a failed cat cannot truncate the target.
set -euo pipefail

dir="${EMAILBOOK_DIR:-$HOME/.local/share/emailbook}"
src1="$dir/professional.txt"
src2="$dir/wake.txt"
target="$dir/work-emailbook.txt"

for f in "$src1" "$src2"; do
  [ -r "$f" ] || { echo "merge.sh: missing source $f" >&2; exit 1; }
done

tmp=$(mktemp "$dir/.work-emailbook.XXXXXX")
trap 'rm -f "$tmp"' EXIT

cat "$src1" "$src2" > "$tmp"

if [ -e "$target" ]; then
  cp -p "$target" "$target.bak"
fi
mv "$tmp" "$target"
trap - EXIT
echo "merge.sh: wrote $(wc -l < "$target") lines to $target" >&2
