#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Username (only show if sudo or root)
user=""
if [[ $(id -u) -eq 0 ]]; then
  user=$(printf "\033[35;1;3m⭘ %s\033[0m " "$(whoami)")
elif [[ -n "$SUDO_USER" ]]; then
  user=$(printf "\033[93;1;3m⭘ %s\033[0m " "$SUDO_USER")
fi

# Directory formatting
home_symbol="~"
dir_path="${cwd/#$HOME/$home_symbol}"

# Check if in a git repo and format accordingly
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  repo_name=$(basename "$repo_root")

  # Calculate relative path from repo root
  if [[ "$cwd" == "$repo_root" ]]; then
    rel_path=""
  else
    rel_path="${cwd/#$repo_root\//}"
  fi

  # Format with repo root in yellow, rest in blue
  if [[ -w "$cwd" ]]; then
    read_only=""
  else
    read_only=" ◈"
  fi

  if [[ -z "$rel_path" ]]; then
    directory=$(printf "\033[93;1m%s\033[34;3m%s\033[0m \033[91;1m\033[0m" "$repo_name" "$read_only")
  else
    directory=$(printf "\033[93;1m%s\033[34;3m/%s%s\033[0m \033[91;1m\033[0m" "$repo_name" "$rel_path" "$read_only")
  fi
else
  # Not in a git repo, just show directory
  if [[ -w "$cwd" ]]; then
    read_only=""
  else
    read_only=" ◈"
  fi
  directory=$(printf "\033[34;3m%s%s\033[0m" "$dir_path" "$read_only")
fi

# Git branch (skip if on main/master)
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n "$branch" && "$branch" != "main" && "$branch" != "master" ]]; then
    # Truncate if longer than 11 chars
    if [[ ${#branch} -gt 11 ]]; then
      branch="${branch:0:11}⋯"
    fi
    git_branch=$(printf "\033[91;3m%s\033[0m " "$branch")
  fi
fi

# Git status
git_status=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  status_output=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)

  # Count status indicators
  modified=$(echo "$status_output" | grep -c "^ M" || true)
  untracked=$(echo "$status_output" | grep -c "^??" || true)
  deleted=$(echo "$status_output" | grep -c "^ D" || true)

  status_str=""
  [[ $modified -gt 0 ]] && status_str+="!"
  [[ $untracked -gt 0 ]] && status_str+="?"
  [[ $deleted -gt 0 ]] && status_str+="✘"

  # Check ahead/behind
  ahead_behind=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
  if [[ -n "$ahead_behind" ]]; then
    behind=$(echo "$ahead_behind" | awk '{print $1}')
    ahead=$(echo "$ahead_behind" | awk '{print $2}')
    [[ $ahead -gt 0 ]] && status_str+="⇡"
    [[ $behind -gt 0 ]] && status_str+="⇣"
  fi

  # If no changes, show check mark
  if [[ -z "$status_str" ]]; then
    status_str="✔"
  fi

  git_status=$(printf "\033[91m%s\033[0m " "$status_str")
fi

# Nix shell indicator
nix_shell=""
if [[ -n "$IN_NIX_SHELL" ]]; then
  nix_shell=$(printf "\033[34;2;3m  \033[0m")
fi

# Character prompt
char=$(printf "\033[34m❯\033[0m")

# Construct the status line
# Left side: user + char
left="${user}${char}"

# Right side: directory + git + nix
right="${directory}${git_status}${git_branch}${nix_shell}"

# Output the status line
echo "${left} ${right}"
