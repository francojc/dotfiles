# --- REPOSITORY MANAGEMENT FUNCTIONS ---
# Dependencies: git, gh (authenticated), fzf, rclone (for repo-migrate Path B)
# Optional: repoindex (uv tool install repoindex)

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

# repo-migrate -- On-demand migration of a Git repo out of Google Drive
# Usage: cd into a Drive directory containing a .git repo, then run: repo-migrate
repo-migrate() {
  local drive_dir="$PWD"

  # Guard: confirm we are inside a Drive-synced directory
  if [[ "$drive_dir" != *"/Library/CloudStorage/"* ]]; then
    echo "Error: current directory does not appear to be inside Google Drive."
    echo "  $drive_dir"
    return 1
  fi

  # Guard: confirm this directory contains a git repo
  if [[ ! -d ".git" ]] && ! git rev-parse --git-dir &>/dev/null 2>&1; then
    echo "Error: no Git repository found in current directory."
    return 1
  fi

  echo "=== repo-migrate ==="
  echo "Drive directory: $drive_dir"
  echo ""

  # Detect repo name from directory and remote
  local repo_name
  repo_name="$(basename "$drive_dir")"
  local remote_url
  remote_url=$(git remote get-url origin 2>/dev/null || echo "")

  # Try to extract GitHub user/org and repo from remote URL
  local gh_user=""
  local gh_repo=""
  if [[ "$remote_url" == *"github.com"* ]]; then
    gh_user=$(echo "$remote_url" | sed -E 's|.*github\.com[:/]([^/]+)/.*|\1|')
    gh_repo=$(echo "$remote_url" | sed -E 's|.*github\.com[:/][^/]+/([^/.]+).*|\1|')
  fi

  # Prompt for GitHub user if not detected
  if [[ -z "$gh_user" ]]; then
    read "gh_user?GitHub username or org [francojc]: "
    gh_user="${gh_user:-francojc}"
  else
    echo "Detected GitHub owner: $gh_user"
  fi

  # Prompt for repo name, defaulting to detected value
  read "input_name?Repo name [$repo_name]: "
  repo_name="${input_name:-$repo_name}"

  local dest="$HOME/Projects/$gh_user/$repo_name"
  local github_url="https://github.com/$gh_user/$repo_name"
  local ssh_url="git@github.com:$gh_user/$repo_name.git"

  # Check if destination already exists
  if [[ -d "$dest" ]]; then
    echo "Error: destination already exists: $dest"
    return 1
  fi

  # Check for unpushed or uncommitted work in the Drive copy
  local dirty=""
  local unpushed=""
  if git status --porcelain 2>/dev/null | grep -q .; then
    dirty="yes"
    echo ""
    echo "Warning: uncommitted changes detected in Drive copy:"
    git status --short
  fi
  if git log --oneline @{u}..HEAD 2>/dev/null | grep -q .; then
    unpushed="yes"
    echo ""
    echo "Warning: unpushed commits detected in Drive copy:"
    git log --oneline @{u}..HEAD
  fi

  if [[ -n "$dirty" || -n "$unpushed" ]]; then
    echo ""
    echo "The Drive copy has work that is not on GitHub."
    echo "You should commit and push before migrating, or choose"
    echo "the rclone path below to preserve the Drive copy exactly."
    read "proceed?Continue anyway? (y/n) [n]: "
    [[ "${proceed:-n}" != "y" ]] && return 1
  fi

  # Determine migration path
  mkdir -p "$HOME/Projects/$gh_user"

  if gh repo view "$gh_user/$repo_name" &>/dev/null; then
    # --- Path A: repo exists on GitHub -> clone fresh ---
    echo ""
    echo "Found on GitHub. Cloning fresh copy..."
    git clone "$ssh_url" "$dest" --quiet

    if [[ $? -ne 0 ]]; then
      echo "Error: clone failed."
      return 1
    fi

    # Verify
    git -C "$dest" fsck --full --quiet 2>/dev/null
    echo "Cloned and verified: $dest"

  else
    # --- Path B: not on GitHub -> pull via rclone, then create repo ---
    echo ""
    echo "Not found on GitHub. Pulling from Drive via rclone..."

    # Build the rclone source path relative to Drive root
    local drive_relative
    drive_relative=$(echo "$drive_dir" | sed -E 's|.*/My Drive/||')

    if [[ "$drive_relative" == "$drive_dir" ]]; then
      echo "Error: could not determine Drive-relative path."
      echo "Expected path containing '/My Drive/'"
      return 1
    fi

    rclone copy "gdrive:$drive_relative" "$dest" --progress

    if [[ $? -ne 0 ]]; then
      echo "Error: rclone copy failed."
      return 1
    fi

    # Verify the pulled copy
    if git -C "$dest" fsck --full --quiet 2>/dev/null; then
      echo "Pulled and verified: $dest"
    else
      echo "Warning: git fsck reported issues. The Drive copy may have been corrupted by sync conflicts."
      echo "Repo is at $dest -- inspect manually before proceeding."
    fi

    # Create GitHub repo
    read "do_create?Create GitHub repo? (y/n) [y]: "
    if [[ "${do_create:-y}" == "y" ]]; then
      read "visibility?Visibility (public/private) [private]: "
      visibility="${visibility:-private}"
      read "description?Description: "

      gh repo create "$gh_user/$repo_name" \
        --"$visibility" \
        --description "$description" \
        --source "$dest" \
        --remote origin \
        --push
      echo "Created: $github_url"
    fi
  fi

  # Gather metadata for marker and tagging
  read "tags?repoindex tags (space-separated): "
  read "has_pages?Publishes to GitHub Pages? (y/n) [n]: "
  has_pages="${has_pages:-n}"

  # Write _repo.md marker into the Drive directory
  local marker_path="$drive_dir/_repo.md"
  echo "Writing marker to: $marker_path"

  if [[ ! -w "$drive_dir" ]]; then
    echo "Warning: Drive directory is not writable: $drive_dir"
    echo "Attempting write anyway..."
  fi

  {
    echo "# $repo_name"
    echo ""
    echo "- **GitHub**: $github_url"
    echo "- **Clone**: \`$ssh_url\`"
    [[ "$has_pages" == "y" ]] && \
      echo "- **Pages**: https://$gh_user.github.io/$repo_name"
    echo "- **Local**: ~/Projects/$gh_user/$repo_name"
    echo "- **Status**: migrated $(date +%Y-%m-%d) -- Drive copy can be removed"
    [[ -n "$tags" ]] && echo "- **Tags**: $tags"
  } > "$marker_path" 2>&1

  if [[ -f "$marker_path" ]]; then
    echo "Created marker: $marker_path"
  else
    echo "Error: failed to create marker at $marker_path"
    echo "You can create it manually later."
  fi

  # Register in repoindex
  repoindex refresh --path "$dest" 2>/dev/null
  if [[ -n "$tags" ]]; then
    for tag in ${=tags}; do
      repoindex tag add "$repo_name" "$tag"
    done
    echo "Tagged: $tags"
  fi

  # Move into the new repo
  cd "$dest"
  echo ""
  echo "Now in: $PWD"
  echo "Drive copy flagged for cleanup: $drive_dir"
}

# repo-init -- Create a new Git repo linked to a Google Drive project folder
# Usage: cd into a Drive project folder (no existing .git), then run: repo-init
repo-init() {
  local drive_dir="$PWD"

  # Guard: confirm we are inside a Drive-synced directory
  if [[ "$drive_dir" != *"/Library/CloudStorage/"* ]]; then
    echo "Warning: current directory does not appear to be inside Google Drive."
    echo "  $drive_dir"
    read "confirm?Continue anyway? (y/n) [n]: "
    [[ "${confirm:-n}" != "y" ]] && return 1
  fi

  echo "=== repo-init ==="
  echo "Drive directory: $drive_dir"
  echo ""

  # Gather details interactively
  read "gh_user?GitHub username or org [francojc]: "
  gh_user="${gh_user:-francojc}"
  read "repo_name?Repo name: "
  [[ -z "$repo_name" ]] && { echo "Repo name required. Aborting."; return 1; }
  read "description?Description: "
  read "visibility?Visibility (public/private) [private]: "
  visibility="${visibility:-private}"
  read "tags?repoindex tags (space-separated, e.g. 'research lang:r active'): "
  read "has_pages?Publishes to GitHub Pages? (y/n) [n]: "
  has_pages="${has_pages:-n}"

  local repo_dir="$HOME/Projects/$gh_user/$repo_name"
  local github_url="https://github.com/$gh_user/$repo_name"
  local ssh_url="git@github.com:$gh_user/$repo_name.git"

  # Clone if repo already exists on GitHub; otherwise create directory and init
  mkdir -p "$HOME/Projects/$gh_user"
  if gh repo view "$gh_user/$repo_name" &>/dev/null; then
    echo ""
    echo "Found existing GitHub repo -- cloning..."
    git clone "$ssh_url" "$repo_dir" --quiet
  else
    echo ""
    read "do_create?Repo not found on GitHub. Create it now? (y/n) [y]: "
    do_create="${do_create:-y}"
    mkdir -p "$repo_dir"
    git -C "$repo_dir" init --quiet
    if [[ "$do_create" == "y" ]]; then
      gh repo create "$gh_user/$repo_name" \
        --"$visibility" \
        --description "$description" \
        --source "$repo_dir" \
        --remote origin
      echo "Created GitHub repo: $github_url"
    fi
  fi

  # Write _repo.md into the Drive directory
  {
    echo "# $repo_name"
    echo ""
    echo "- **GitHub**: $github_url"
    echo "- **Clone**: \`$ssh_url\`"
    [[ "$has_pages" == "y" ]] && \
      echo "- **Pages**: https://$gh_user.github.io/$repo_name"
    echo "- **Local**: $repo_dir"
    echo "- **Visibility**: $visibility"
    [[ -n "$tags" ]] && echo "- **Tags**: $tags"
    echo "- **Description**: $description"
  } > "$drive_dir/_repo.md"

  echo "Created: $drive_dir/_repo.md"

  # Register and tag in repoindex
  repoindex refresh --path "$repo_dir" 2>/dev/null
  if [[ -n "$tags" ]]; then
    for tag in ${=tags}; do
      repoindex tag add "$repo_name" "$tag"
    done
    echo "Tagged: $tags"
  fi

  # Move into the new repo
  cd "$repo_dir"
  echo ""
  echo "Now in: $PWD"
}

# drive-cleanup -- List Drive directories flagged for cleanup after migration
drive-cleanup() {
  local count=0
  echo "Drive directories flagged for cleanup:"
  echo ""

  grep -rl "Drive copy can be removed" \
    ~/Library/CloudStorage/GoogleDrive-*/My\ Drive/ \
    --include="_repo.md" 2>/dev/null | \
    while read -r marker; do
      local dir
      dir="$(dirname "$marker")"
      local repo_line
      repo_line=$(grep "GitHub" "$marker" | head -1 | sed 's/.*\*\*: //')
      echo "  $dir"
      [[ -n "$repo_line" ]] && echo "    -> $repo_line"
      echo ""
      ((count++))
    done

  if [[ $count -eq 0 ]]; then
    echo "  (none found)"
  fi
}
