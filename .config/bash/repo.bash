# --- REPO HELPERS (bash port of home/shell/repo.zsh) ---
# --- REPOSITORY MANAGEMENT FUNCTIONS ---
# Dependencies: git, gh (authenticated), fzf
# Optional: repoindex (uv tool install repoindex)
#
# Google Drive helpers (repo-migrate, repo-init, drive-cleanup) are Mac-only
# and live only in the zsh version on Mac-Minicore.

# repo -- Fuzzy-jump to any local repo under ~/Projects
repo() {
  local dir
  dir=$(find ~/Projects -maxdepth 4 -name ".git" -type d 2>/dev/null | \
    sed 's|/.git$||' | \
    sed "s|$HOME/Projects/||" | \
    fzf --prompt="project> " --height=40% --reverse)
  [[ -n "$dir" ]] && cd "$HOME/Projects/$dir"
}

# repo-status -- Scan all repos for uncommitted or unpushed changes
repo-status() {
  find ~/Projects -maxdepth 4 -name ".git" -type d 2>/dev/null | \
    sed 's|/.git$||' | \
    while read -r repo; do
      local status ahead
      status=$(git -C "$repo" status --porcelain 2>/dev/null)
      ahead=$(git -C "$repo" log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')
      if [[ -n "$status" || "$ahead" -gt 0 ]]; then
        echo "── ${repo/$HOME\//}"
        [[ -n "$status" ]] && echo "   uncommitted changes"
        [[ "$ahead" -gt 0 ]] && echo "   $ahead unpushed commit(s)"
      fi
    done
}

# repo-bootstrap -- Clone all GitHub repos to ~/Projects/ on a new machine
repo-bootstrap() {
  local target="${1:-$HOME/Projects/francojc}"
  mkdir -p "$target"
  echo "Bootstrapping repos into $target ..."
  gh repo list francojc --limit 200 --json name \
    --jq '.[].name' | \
    while read -r name; do
      local dest="$target/$name"
      if [[ -d "$dest" ]]; then
        echo "  skip  $name (already exists)"
      else
        echo "  clone $name"
        git clone "git@github.com:francojc/$name.git" "$dest" --quiet
      fi
    done
  echo "Done. Run 'repoindex refresh' to update the index."
}
