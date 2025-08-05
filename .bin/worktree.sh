#!/usr/bin/env bash

# worktree.sh - Git Worktree Management Script
# A comprehensive tool for creating, managing, merging, and deleting git worktrees
#
# Author: [Your Name]
# Version: 1.0.0
# Requirements: git >= 2.5 (for worktree support)

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# =============================================================================
# CONFIGURATION AND CONSTANTS
# =============================================================================

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="1.0.0"

# Color codes for output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Function to check if colors should be used
use_colors() {
  # Check if stdout is a terminal and colors are supported
  [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && [[ "${NO_COLOR:-}" != "1" ]]
}

# Default configuration
readonly DEFAULT_WORKTREE_DIR=".worktrees"
readonly DEFAULT_BASE_BRANCH="main"

# Global flags
VERBOSE=false
FORCE=false
DEBUG=false

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function: display_help()
# Purpose: Show comprehensive help information
# Usage: display_help
display_help() {
  if use_colors; then
    cat << EOF
${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}
${BLUE}│${NC}                     ${WHITE}Git Worktree Management Script${NC}                     ${BLUE}│${NC}
${BLUE}│${NC}                            ${CYAN}Version ${VERSION}${NC}                              ${BLUE}│${NC}
${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}

${WHITE}DESCRIPTION:${NC}
  A comprehensive tool for creating, managing, merging, and deleting git worktrees.
  Simplifies parallel development workflows and feature branch management.

${WHITE}USAGE:${NC}
  ${SCRIPT_NAME} ${YELLOW}<command>${NC} ${CYAN}[options]${NC} ${GREEN}[arguments]${NC}

${WHITE}GLOBAL OPTIONS:${NC}
  ${CYAN}--verbose, -v${NC}     Enable verbose output
  ${CYAN}--force, -f${NC}       Skip confirmation prompts
  ${CYAN}--help, -h${NC}        Show this help message
  ${CYAN}--version${NC}         Show version information

${WHITE}COMMANDS:${NC}

${YELLOW}Worktree Management:${NC}
  ${GREEN}create${NC} ${CYAN}<branch>${NC} ${PURPLE}[path]${NC} ${PURPLE}[base-branch]${NC}
  ${GREEN}new, add${NC}                    Create a new worktree
                              ${PURPLE}path${NC}: Custom path (default: .worktrees/<branch>)
                              ${PURPLE}base-branch${NC}: Base branch (default: main)

  ${GREEN}list${NC} ${PURPLE}[format]${NC}               List all worktrees
  ${GREEN}ls${NC}                         ${PURPLE}format${NC}: table (default), json, simple

  ${GREEN}switch${NC} ${CYAN}<target>${NC}              Switch to worktree directory
  ${GREEN}checkout, cd${NC}               ${CYAN}target${NC}: branch name or path

  ${GREEN}remove${NC} ${CYAN}<target>${NC} ${PURPLE}[--force]${NC}    Remove a worktree
  ${GREEN}delete, rm${NC}                 ${CYAN}target${NC}: branch name or path

  ${GREEN}status${NC} ${PURPLE}[target]${NC}             Show worktree status information
  ${GREEN}st${NC}                         ${PURPLE}target${NC}: specific worktree (default: all)

${YELLOW}Branch Operations:${NC}
  ${GREEN}merge${NC} ${CYAN}<source>${NC} ${PURPLE}[target]${NC} ${PURPLE}[strategy]${NC}
                              Merge worktree branch
                              ${PURPLE}target${NC}: destination branch (default: main)
                              ${PURPLE}strategy${NC}: merge, squash, rebase

  ${GREEN}sync${NC} ${CYAN}<target>${NC}               Sync worktree with upstream
  ${GREEN}pull${NC}                       ${CYAN}target${NC}: worktree identifier

  ${GREEN}pr${NC} ${CYAN}<branch>${NC} ${PURPLE}[title]${NC} ${PURPLE}[description]${NC}
  ${GREEN}pull-request${NC}               Create GitHub pull request

${YELLOW}Maintenance:${NC}
  ${GREEN}prune${NC}                      Clean up stale worktree references
  ${GREEN}cleanup${NC}

  ${GREEN}clean-merged${NC}               Remove worktrees for merged branches

  ${GREEN}backup${NC}                     Backup worktree configuration

  ${GREEN}restore${NC} ${CYAN}<backup-file>${NC}        Restore from backup

${WHITE}EXAMPLES:${NC}

${YELLOW}Basic Workflow:${NC}
  # Create a new feature worktree
  ${SCRIPT_NAME} ${GREEN}create${NC} feature/user-auth

  # List all worktrees
  ${SCRIPT_NAME} ${GREEN}list${NC}

  # Switch to the feature worktree
  ${SCRIPT_NAME} ${GREEN}switch${NC} feature/user-auth

  # Check status of all worktrees
  ${SCRIPT_NAME} ${GREEN}status${NC}

  # Merge feature back to main
  ${SCRIPT_NAME} ${GREEN}merge${NC} feature/user-auth main squash

  # Clean up after merge
  ${SCRIPT_NAME} ${GREEN}remove${NC} feature/user-auth

${YELLOW}Advanced Usage:${NC}
  # Create worktree with custom path
  ${SCRIPT_NAME} ${GREEN}create${NC} hotfix/critical-bug ../hotfix-workspace

  # Create worktree from specific base branch
  ${SCRIPT_NAME} ${GREEN}create${NC} feature/new-api develop

  # Sync all worktrees (if no target specified)
  ${SCRIPT_NAME} ${GREEN}sync${NC}

  # Create PR directly from worktree
  ${SCRIPT_NAME} ${GREEN}pr${NC} feature/user-auth "Add user authentication" "Implements OAuth2 login"

  # List worktrees in JSON format
  ${SCRIPT_NAME} ${GREEN}list${NC} json

  # Remove worktree with uncommitted changes
  ${SCRIPT_NAME} ${GREEN}remove${NC} feature/abandoned --force

${YELLOW}Maintenance Workflow:${NC}
  # Clean up stale references
  ${SCRIPT_NAME} ${GREEN}prune${NC}

  # Remove all merged feature branches
  ${SCRIPT_NAME} ${GREEN}clean-merged${NC}

  # Backup current configuration
  ${SCRIPT_NAME} ${GREEN}backup${NC}

${WHITE}CONFIGURATION:${NC}
  ${CYAN}Default worktree directory:${NC} ${DEFAULT_WORKTREE_DIR}
  ${CYAN}Default base branch:${NC}        ${DEFAULT_BASE_BRANCH}
  ${CYAN}Required git version:${NC}       >= 2.5

${WHITE}REQUIREMENTS:${NC}
  • Git >= 2.5 (for worktree support)
  • GitHub CLI (gh) for pull request functionality (optional)
  • Write permissions in repository directory

${WHITE}FILES:${NC}
  ${CYAN}.git/worktrees/${NC}            Git worktree metadata
  ${CYAN}.git/worktree-backups/${NC}     Configuration backups
  ${CYAN}.worktrees/${NC}                Default worktree directory

${YELLOW}For more information about git worktrees:${NC}
  git help worktree

${YELLOW}Report issues or contribute at:${NC}
  https://github.com/your-username/worktree-script

EOF
  else
    # No color version
    cat << EOF
╭─────────────────────────────────────────────────────────────────────────────╮
│                     Git Worktree Management Script                         │
│                            Version ${VERSION}                              │
╰─────────────────────────────────────────────────────────────────────────────╯

DESCRIPTION:
  A comprehensive tool for creating, managing, merging, and deleting git worktrees.
  Simplifies parallel development workflows and feature branch management.

USAGE:
  ${SCRIPT_NAME} <command> [options] [arguments]

GLOBAL OPTIONS:
  --verbose, -v     Enable verbose output
  --force, -f       Skip confirmation prompts
  --help, -h        Show this help message
  --version         Show version information

COMMANDS:

Worktree Management:
  create <branch> [path] [base-branch]
  new, add                    Create a new worktree
                              path: Custom path (default: .worktrees/<branch>)
                              base-branch: Base branch (default: main)

  list [format]               List all worktrees
  ls                          format: table (default), json, simple

  switch <target>             Switch to worktree directory
  checkout, cd                target: branch name or path

  remove <target> [--force]   Remove a worktree
  delete, rm                  target: branch name or path

  status [target]             Show worktree status information
  st                          target: specific worktree (default: all)

Branch Operations:
  merge <source> [target] [strategy]
                              Merge worktree branch
                              target: destination branch (default: main)
                              strategy: merge, squash, rebase

  sync <target>               Sync worktree with upstream
  pull                        target: worktree identifier

  pr <branch> [title] [description]
  pull-request                Create GitHub pull request

Maintenance:
  prune                       Clean up stale worktree references
  cleanup

  clean-merged                Remove worktrees for merged branches

  backup                      Backup worktree configuration

  restore <backup-file>       Restore from backup

EXAMPLES:

Basic Workflow:
  # Create a new feature worktree
  ${SCRIPT_NAME} create feature/user-auth

  # List all worktrees
  ${SCRIPT_NAME} list

  # Switch to the feature worktree
  ${SCRIPT_NAME} switch feature/user-auth

  # Check status of all worktrees
  ${SCRIPT_NAME} status

  # Merge feature back to main
  ${SCRIPT_NAME} merge feature/user-auth main squash

  # Clean up after merge
  ${SCRIPT_NAME} remove feature/user-auth

Advanced Usage:
  # Create worktree with custom path
  ${SCRIPT_NAME} create hotfix/critical-bug ../hotfix-workspace

  # Create worktree from specific base branch
  ${SCRIPT_NAME} create feature/new-api develop

  # Sync all worktrees (if no target specified)
  ${SCRIPT_NAME} sync

  # Create PR directly from worktree
  ${SCRIPT_NAME} pr feature/user-auth "Add user authentication" "Implements OAuth2 login"

  # List worktrees in JSON format
  ${SCRIPT_NAME} list json

  # Remove worktree with uncommitted changes
  ${SCRIPT_NAME} remove feature/abandoned --force

Maintenance Workflow:
  # Clean up stale references
  ${SCRIPT_NAME} prune

  # Remove all merged feature branches
  ${SCRIPT_NAME} clean-merged

  # Backup current configuration
  ${SCRIPT_NAME} backup

CONFIGURATION:
  Default worktree directory: ${DEFAULT_WORKTREE_DIR}
  Default base branch:        ${DEFAULT_BASE_BRANCH}
  Required git version:       >= 2.5

REQUIREMENTS:
  • Git >= 2.5 (for worktree support)
  • GitHub CLI (gh) for pull request functionality (optional)
  • Write permissions in repository directory

FILES:
  .git/worktrees/             Git worktree metadata
  .git/worktree-backups/      Configuration backups
  .worktrees/                 Default worktree directory

For more information about git worktrees:
  git help worktree

Report issues or contribute at:
  https://github.com/your-username/worktree-script

EOF
  fi
}
# Function: log_info(message)
# Purpose: Print informational messages with color coding
# Parameters: $1 - message to display
log_info() {
  local message="$1"
  local timestamp=""

  if [[ "$VERBOSE" == true ]]; then
    timestamp="[$(date '+%H:%M:%S')] "
  fi

  printf "${timestamp}${BLUE}[INFO]${NC} %s\n" "$message"
}

# Function: log_error(message)
# Purpose: Print error messages to stderr with color coding
# Parameters: $1 - error message to display
log_error() {
  local message="$1"
  local timestamp=""

  if [[ "$VERBOSE" == true ]]; then
    timestamp="[$(date '+%H:%M:%S')] "
  fi

  printf "${timestamp}${RED}[ERROR]${NC} %s\n" "$message" >&2

  if [[ "$DEBUG" == true ]]; then
    printf "${RED}[DEBUG]${NC} Call stack:\n" >&2
    local frame=0
    while caller $frame; do
      ((frame++))
    done >&2
  fi
}

# Function: log_success(message)
# Purpose: Print success messages with color coding
# Parameters: $1 - success message to display
log_success() {
  local message="$1"
  local timestamp=""
  local checkmark="✓"

  if [[ "$VERBOSE" == true ]]; then
    timestamp="[$(date '+%H:%M:%S')] "
  fi

  # Check if terminal supports Unicode
  if [[ "$TERM" =~ (xterm|screen|tmux) ]]; then
    printf "${timestamp}${GREEN}[SUCCESS]${NC} ${checkmark} %s\n" "$message"
  else
    printf "${timestamp}${GREEN}[SUCCESS]${NC} %s\n" "$message"
  fi
}

# Function: log_warning(message)
# Purpose: Print warning messages with color coding
# Parameters: $1 - warning message to display
log_warning() {
  local message="$1"
  local timestamp=""
  local warning_symbol="⚠"

  if [[ "$VERBOSE" == true ]]; then
    timestamp="[$(date '+%H:%M:%S')] "
  fi

  # Check if terminal supports Unicode
  if [[ "$TERM" =~ (xterm|screen|tmux) ]]; then
    printf "${timestamp}${YELLOW}[WARNING]${NC} ${warning_symbol} %s\n" "$message"
  else
    printf "${timestamp}${YELLOW}[WARNING]${NC} %s\n" "$message"
  fi
}

# Function: confirm_action(prompt)
# Purpose: Ask user for confirmation before destructive actions
# Parameters: $1 - confirmation prompt
# Returns: 0 if confirmed, 1 if denied
confirm_action() {
  local prompt="$1"

  # Skip confirmation if force flag is set
  if [[ "$FORCE" == true ]]; then
    log_info "Skipping confirmation (--force flag set)"
    return 0
  fi

  printf "${YELLOW}%s${NC} [y/N]: " "$prompt" >&2
  read -r response

  case "$response" in
    [yY]|[yY][eE][sS])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Function: validate_git_repo()
# Purpose: Ensure we're in a git repository
# Returns: 0 if valid git repo, 1 otherwise
# Function: validate_git_repo()
# Purpose: Ensure we're in a git repository
# Returns: 0 if valid git repo, 1 otherwise
validate_git_repo() {
  # Check if git command is available
  if ! command -v git >/dev/null 2>&1; then
    log_error "Git is not installed or not in PATH"
    return 1
  fi

  # Check if we're in a git repository
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    log_error "Not in a git repository"
    return 1
  fi

  # Check if repository has at least one commit
  if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    log_error "Repository has no commits yet"
    return 1
  fi

  # Check git version for worktree support (>= 2.5)
  local git_version
  git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+')
  local major minor
  major=$(echo "$git_version" | cut -d. -f1)
  minor=$(echo "$git_version" | cut -d. -f2)

  if [[ $major -lt 2 ]] || [[ $major -eq 2 && $minor -lt 5 ]]; then
    log_error "Git version $git_version is too old. Worktree support requires Git >= 2.5"
    return 1
  fi

  return 0
}

# Function: validate_branch_name(branch_name)
# Purpose: Validate that branch name follows git naming conventions
# Parameters: $1 - branch name to validate
# Returns: 0 if valid, 1 otherwise
# Function: validate_branch_name(branch_name)
# Purpose: Validate that branch name follows git naming conventions
# Parameters: $1 - branch name to validate
# Returns: 0 if valid, 1 otherwise
validate_branch_name() {
  local branch_name="$1"

  if [[ -z "$branch_name" ]]; then
    log_error "Branch name cannot be empty"
    return 1
  fi

  # Check length (reasonable limit)
  if [[ ${#branch_name} -gt 250 ]]; then
    log_error "Branch name is too long (max 250 characters)"
    return 1
  fi

  # Check for invalid characters and patterns
  if [[ "$branch_name" =~ [[:space:]] ]]; then
    log_error "Branch name cannot contain spaces"
    return 1
  fi

  if [[ "$branch_name" =~ [\~\^\:\?\*\[\]] ]]; then
    log_error "Branch name contains invalid characters (~^:?*[])"
    return 1
  fi

  # Cannot start with hyphen or dot
  if [[ "$branch_name" =~ ^[-\.] ]]; then
    log_error "Branch name cannot start with hyphen or dot"
    return 1
  fi

  # Cannot end with dot or slash
  if [[ "$branch_name" =~ [\.\/]$ ]]; then
    log_error "Branch name cannot end with dot or slash"
    return 1
  fi

  # Reserved names
  case "$branch_name" in
    "HEAD"|"FETCH_HEAD"|"ORIG_HEAD"|"MERGE_HEAD")
      log_error "Branch name '$branch_name' is reserved"
      return 1
      ;;
  esac

  # Cannot have consecutive dots or slashes
  if [[ "$branch_name" =~ \.\. ]] || [[ "$branch_name" =~ // ]]; then
    log_error "Branch name cannot contain consecutive dots or slashes"
    return 1
  fi

  return 0
}

# Function: validate_worktree_path(path)
# Purpose: Validate worktree path is suitable for creation
# Parameters: $1 - proposed worktree path
# Returns: 0 if valid, 1 otherwise
# Function: validate_worktree_path(path)
# Purpose: Validate worktree path is suitable for creation
# Parameters: $1 - proposed worktree path
# Returns: 0 if valid, 1 otherwise
validate_worktree_path() {
  local path="$1"

  if [[ -z "$path" ]]; then
    log_error "Worktree path cannot be empty"
    return 1
  fi

  # Convert to absolute path for validation
  local abs_path
  abs_path=$(realpath -m "$path" 2>/dev/null) || {
    log_error "Invalid path: $path"
    return 1
  }

  # Check if path already exists
  if [[ -e "$abs_path" ]]; then
    log_error "Path already exists: $abs_path"
    return 1
  fi

  # Check if parent directory exists and is writable
  local parent_dir
  parent_dir=$(dirname "$abs_path")

  if [[ ! -d "$parent_dir" ]]; then
    log_error "Parent directory does not exist: $parent_dir"
    return 1
  fi

  if [[ ! -w "$parent_dir" ]]; then
    log_error "Parent directory is not writable: $parent_dir"
    return 1
  fi

  # Check for conflicts with existing worktrees
  if git worktree list --porcelain 2>/dev/null | grep -q "^worktree $abs_path$"; then
    log_error "Worktree already exists at: $abs_path"
    return 1
  fi

  # Check path length (reasonable limit)
  if [[ ${#abs_path} -gt 400 ]]; then
    log_error "Path is too long (max 400 characters)"
    return 1
  fi

  return 0
}

# =============================================================================
# CORE WORKTREE FUNCTIONS
# =============================================================================

# Function: create_worktree(branch_name, [path], [base_branch])
# Purpose: Create a new git worktree
# Parameters:
#   $1 - branch name for the worktree
#   $2 - optional path (defaults to branch name in worktree dir)
#   $3 - optional base branch (defaults to main/master)
# Function: create_worktree(branch_name, [path], [base_branch])
# Purpose: Create a new git worktree
# Parameters:
#   $1 - branch name for the worktree
#   $2 - optional path (defaults to branch name in worktree dir)
#   $3 - optional base branch (defaults to main/master)
create_worktree() {
  local branch_name="${1:-}"
  local worktree_path="${2:-}"
  local base_branch="${3:-}"

  # Validate required parameter
  if [[ -z "$branch_name" ]]; then
    log_error "Branch name is required"
    return 1
  fi

  # Validate branch name
  if ! validate_branch_name "$branch_name"; then
    return 1
  fi

  # Determine worktree path
  if [[ -z "$worktree_path" ]]; then
    worktree_path="$DEFAULT_WORKTREE_DIR/$branch_name"
  fi

  # Validate worktree path
  if ! validate_worktree_path "$worktree_path"; then
    return 1
  fi

  # Determine base branch
  if [[ -z "$base_branch" ]]; then
    # Try to detect default branch
    if git show-ref --verify --quiet refs/heads/main; then
      base_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
      base_branch="master"
    else
      base_branch="$DEFAULT_BASE_BRANCH"
    fi
  fi

  log_info "Creating worktree for branch '$branch_name' at '$worktree_path'"

  # Check if branch exists locally
  local branch_exists=false
  if git show-ref --verify --quiet "refs/heads/$branch_name"; then
    branch_exists=true
    log_info "Using existing local branch '$branch_name'"
  fi

  # Check if branch exists remotely
  local remote_branch_exists=false
  if git ls-remote --heads origin "$branch_name" | grep -q "refs/heads/$branch_name"; then
    remote_branch_exists=true
    log_info "Found remote branch 'origin/$branch_name'"
  fi

  # Create worktree based on branch status
  if [[ "$branch_exists" == true ]]; then
    # Branch exists locally, use it
    git worktree add "$worktree_path" "$branch_name"
  elif [[ "$remote_branch_exists" == true ]]; then
    # Branch exists remotely, create tracking branch
    git worktree add -b "$branch_name" "$worktree_path" "origin/$branch_name"
  else
    # Create new branch from base branch
    git worktree add -b "$branch_name" "$worktree_path" "$base_branch"
  fi

  if [[ $? -eq 0 ]]; then
    log_success "Worktree created successfully"
    log_info "Path: $(realpath "$worktree_path")"
    log_info "Branch: $branch_name"

    # Display next steps
    echo
    if use_colors; then
      printf "${CYAN}Next steps:${NC}\n"
    else
      printf "Next steps:\n"
    fi
    echo "  cd \"$worktree_path\""
    echo "  # Start working on your changes"
    echo "  # When ready to switch back: $SCRIPT_NAME switch main"
  else
    log_error "Failed to create worktree"
    return 1
  fi
}

# Function: list_worktrees([format])
# Purpose: List all existing worktrees with detailed information
# Parameters: $1 - optional format (table, json, simple)
# Function: list_worktrees([format])
# Purpose: List all existing worktrees with detailed information
# Parameters: $1 - optional format (table, json, simple)
list_worktrees() {
  local format="${1:-table}"

  # Get worktree information
  local worktree_data
  worktree_data=$(git worktree list --porcelain 2>/dev/null)

  if [[ -z "$worktree_data" ]]; then
    log_info "No worktrees found"
    return 0
  fi

  case "$format" in
    "json")
      _list_worktrees_json "$worktree_data"
      ;;
    "simple")
      _list_worktrees_simple "$worktree_data"
      ;;
    "table"|*)
      _list_worktrees_table "$worktree_data"
      ;;
  esac
}

# Helper function for table format
_list_worktrees_table() {
  local worktree_data="$1"
  local current_worktree
  current_worktree=$(git rev-parse --show-toplevel 2>/dev/null)

  if use_colors; then
    printf "${WHITE}Git Worktrees:${NC}\n"
  else
    printf "Git Worktrees:\n"
  fi
  echo
  printf "%-40s %-25s %-15s %s\n" "PATH" "BRANCH" "STATUS" "COMMIT"
  printf "%-40s %-25s %-15s %s\n" "$(printf '%.40s' "$(printf '%*s' 40 '' | tr ' ' '-')")" "$(printf '%.25s' "$(printf '%*s' 25 '' | tr ' ' '-')")" "$(printf '%.15s' "$(printf '%*s' 15 '' | tr ' ' '-')")" "$(printf '%*s' 8 '' | tr ' ' '-')"

  local path="" branch="" commit="" status=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
      path="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^HEAD\ ([a-f0-9]+)$ ]]; then
      commit="${BASH_REMATCH[1]:0:8}"
    elif [[ "$line" =~ ^branch\ refs/heads/(.+)$ ]]; then
      branch="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^detached$ ]]; then
      branch="(detached)"
    elif [[ "$line" =~ ^bare$ ]]; then
      status="bare"
    elif [[ "$line" =~ ^locked$ ]]; then
      status="locked"
    elif [[ -z "$line" ]] && [[ -n "$path" ]]; then
      # End of worktree entry
      local display_path="$path"
      if [[ ${#path} -gt 37 ]]; then
        display_path="...${path: -34}"
      fi

      # Mark current worktree
      local marker=""
      if [[ "$path" == "$current_worktree" ]]; then
        marker="${GREEN}*${NC}"
        display_path="${GREEN}$display_path${NC}"
      fi

      printf "%s%-40s %-25s %-15s %s\n" "$marker" "$display_path" "$branch" "$status" "$commit"

      # Reset for next worktree
      path="" branch="" commit="" status=""
    fi
  done <<< "$worktree_data"

  # Handle last entry if no trailing newline
  if [[ -n "$path" ]]; then
    local display_path="$path"
    if [[ ${#path} -gt 37 ]]; then
      display_path="...${path: -34}"
    fi

    local marker=""
    if [[ "$path" == "$current_worktree" ]]; then
      marker="${GREEN}*${NC}"
      display_path="${GREEN}$display_path${NC}"
    fi

    printf "%s%-40s %-25s %-15s %s\n" "$marker" "$display_path" "$branch" "$status" "$commit"
  fi

  echo
  local count
  count=$(echo "$worktree_data" | grep -c "^worktree ")
  if use_colors; then
    printf "${CYAN}Total worktrees: %d${NC}\n" "$count"
  else
    printf "Total worktrees: %d\n" "$count"
  fi
}

# Helper function for JSON format
_list_worktrees_json() {
  local worktree_data="$1"

  echo "["
  local first=true
  local path="" branch="" commit="" status=""

  while IFS= read -r line; do
    if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
      path="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^HEAD\ ([a-f0-9]+)$ ]]; then
      commit="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^branch\ refs/heads/(.+)$ ]]; then
      branch="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^detached$ ]]; then
      branch="detached"
    elif [[ "$line" =~ ^bare$ ]]; then
      status="bare"
    elif [[ "$line" =~ ^locked$ ]]; then
      status="locked"
    elif [[ -z "$line" ]] && [[ -n "$path" ]]; then
      if [[ "$first" == false ]]; then
        echo ","
      fi
      first=false

      echo "  {"
      echo "    \"path\": \"$path\","
      echo "    \"branch\": \"$branch\","
      echo "    \"commit\": \"$commit\","
      echo "    \"status\": \"$status\""
      echo -n "  }"

      path="" branch="" commit="" status=""
    fi
  done <<< "$worktree_data"

  # Handle last entry
  if [[ -n "$path" ]]; then
    if [[ "$first" == false ]]; then
      echo ","
    fi
    echo "  {"
    echo "    \"path\": \"$path\","
    echo "    \"branch\": \"$branch\","
    echo "    \"commit\": \"$commit\","
    echo "    \"status\": \"$status\""
    echo -n "  }"
  fi

  echo
  echo "]"
}

# Helper function for simple format
_list_worktrees_simple() {
  local worktree_data="$1"
  local current_worktree
  current_worktree=$(git rev-parse --show-toplevel 2>/dev/null)

  local path="" branch=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
      path="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^branch\ refs/heads/(.+)$ ]]; then
      branch="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^detached$ ]]; then
      branch="(detached)"
    elif [[ -z "$line" ]] && [[ -n "$path" ]]; then
      if [[ "$path" == "$current_worktree" ]]; then
        if use_colors; then
          printf "${GREEN}* %s (%s)${NC}\n" "$path" "$branch"
        else
          printf "* %s (%s)\n" "$path" "$branch"
        fi
      else
        printf "  %s (%s)\n" "$path" "$branch"
      fi
      path="" branch=""
    fi
  done <<< "$worktree_data"

  # Handle last entry
  if [[ -n "$path" ]]; then
    if [[ "$path" == "$current_worktree" ]]; then
      if use_colors; then
        printf "${GREEN}* %s (%s)${NC}\n" "$path" "$branch"
      else
        printf "* %s (%s)\n" "$path" "$branch"
      fi
    else
      printf "  %s (%s)\n" "$path" "$branch"
    fi
  fi
}

# Function: switch_worktree(target)
# Purpose: Switch to a specific worktree directory
# Parameters: $1 - worktree identifier (branch name or path)
# Function: switch_worktree(target)
# Purpose: Switch to a specific worktree directory
# Parameters: $1 - worktree identifier (branch name or path)
switch_worktree() {
  local target="${1:-}"

  if [[ -z "$target" ]]; then
    log_error "Worktree target is required"
    return 1
  fi

  local worktree_path=""

  # Try to resolve target to worktree path
  if [[ -d "$target" ]]; then
    # Target is a directory path
    if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      worktree_path="$target"
    else
      log_error "'$target' is not a valid worktree directory"
      return 1
    fi
  else
    # Try to find worktree by branch name
    local found_path
    found_path=$(git worktree list --porcelain | awk -v branch="$target" '
      /^worktree / { path = substr($0, 10) }
      /^branch refs\/heads\// {
        if (substr($0, 20) == branch) {
          print path
          exit
        }
      }
    ')

    if [[ -n "$found_path" ]]; then
      worktree_path="$found_path"
    else
      log_error "No worktree found for branch '$target'"
      return 1
    fi
  fi

  # Validate worktree still exists and is accessible
  if [[ ! -d "$worktree_path" ]]; then
    log_error "Worktree directory does not exist: $worktree_path"
    return 1
  fi

  # Get absolute path
  worktree_path=$(realpath "$worktree_path")

  # Switch to the worktree directory
  if cd "$worktree_path"; then
    log_success "Switched to worktree: $worktree_path"

    # Display current branch info
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null)
    if [[ -n "$current_branch" ]]; then
      log_info "Current branch: $current_branch"
    fi

    # Show git status if verbose
    if [[ "$VERBOSE" == true ]]; then
      echo
      git status --short
    fi

    # Update shell environment for subshell
    export GIT_WORKTREE_ROOT="$worktree_path"

    # Start a new subshell in the worktree directory
    if use_colors; then
      printf "${CYAN}Starting new shell in worktree. Type 'exit' to return.${NC}\n"
    else
      printf "Starting new shell in worktree. Type 'exit' to return.\n"
    fi
    exec "${SHELL:-/bin/bash}"
  else
    log_error "Failed to switch to worktree directory"
    return 1
  fi
}

# Function: remove_worktree(target, [force])
# Purpose: Remove a git worktree
# Parameters:
#   $1 - worktree identifier (branch name or path)
#   $2 - optional force flag
# Function: remove_worktree(target, [force])
# Purpose: Remove a git worktree
# Parameters:
#   $1 - worktree identifier (branch name or path)
#   $2 - optional force flag
remove_worktree() {
  local target="${1:-}"
  local force_flag="${2:-}"

  if [[ -z "$target" ]]; then
    log_error "Worktree target is required"
    return 1
  fi

  local worktree_path=""
  local branch_name=""

  # Resolve target to worktree path and branch
  if [[ -d "$target" ]]; then
    # Target is a directory path
    if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      worktree_path="$target"
      branch_name=$(git -C "$target" branch --show-current 2>/dev/null)
    else
      log_error "'$target' is not a valid worktree directory"
      return 1
    fi
  else
    # Try to find worktree by branch name
    local found_info
    found_info=$(git worktree list --porcelain | awk -v branch="$target" '
      /^worktree / { path = substr($0, 10) }
      /^branch refs\/heads\// {
        if (substr($0, 20) == branch) {
          print path "|" branch
          exit
        }
      }
    ')

    if [[ -n "$found_info" ]]; then
      worktree_path="${found_info%|*}"
      branch_name="${found_info#*|}"
    else
      log_error "No worktree found for branch '$target'"
      return 1
    fi
  fi

  # Validate worktree exists
  if [[ ! -d "$worktree_path" ]]; then
    log_warning "Worktree directory does not exist: $worktree_path"
    log_info "Attempting to remove stale worktree reference..."
  else
    # Check for uncommitted changes
    if git -C "$worktree_path" diff --quiet && git -C "$worktree_path" diff --cached --quiet; then
      log_info "No uncommitted changes found"
    else
      log_warning "Worktree has uncommitted changes"
      if [[ "$force_flag" != "--force" ]] && [[ "$FORCE" != true ]]; then
        if ! confirm_action "Are you sure you want to remove worktree with uncommitted changes?"; then
          log_info "Operation cancelled"
          return 1
        fi
      fi
    fi

    # Check if worktree is currently in use
    local current_worktree
    current_worktree=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ "$worktree_path" == "$current_worktree" ]]; then
      log_error "Cannot remove current worktree. Switch to another worktree first."
      return 1
    fi
  fi

  # Confirm removal
  if [[ "$force_flag" != "--force" ]] && [[ "$FORCE" != true ]]; then
    if ! confirm_action "Remove worktree '$worktree_path' (branch: $branch_name)?"; then
      log_info "Operation cancelled"
      return 1
    fi
  fi

  # Remove the worktree
  log_info "Removing worktree: $worktree_path"

  if git worktree remove "$worktree_path" --force 2>/dev/null; then
    log_success "Worktree removed successfully"
  else
    # Try manual cleanup if git command failed
    log_warning "Git worktree remove failed, attempting manual cleanup..."

    # Remove directory if it exists
    if [[ -d "$worktree_path" ]]; then
      rm -rf "$worktree_path"
    fi

    # Prune stale references
    git worktree prune 2>/dev/null

    log_success "Worktree cleaned up manually"
  fi

  # Ask about branch deletion
  if [[ -n "$branch_name" ]] && git show-ref --verify --quiet "refs/heads/$branch_name"; then
    # Check if branch is merged
    local is_merged=false
    if git merge-base --is-ancestor "$branch_name" HEAD 2>/dev/null; then
      is_merged=true
    fi

    if [[ "$is_merged" == true ]]; then
      log_info "Branch '$branch_name' appears to be merged"
    fi

    if confirm_action "Also delete branch '$branch_name'?"; then
      if git branch -d "$branch_name" 2>/dev/null; then
        log_success "Branch '$branch_name' deleted"
      elif git branch -D "$branch_name" 2>/dev/null; then
        log_success "Branch '$branch_name' force deleted"
      else
        log_warning "Failed to delete branch '$branch_name'"
      fi
    fi
  fi
}

# Function: prune_worktrees()
# Purpose: Clean up stale worktree references
# Function: prune_worktrees()
# Purpose: Clean up stale worktree references
prune_worktrees() {
  log_info "Cleaning up stale worktree references..."

  # Get list of worktrees before pruning
  local before_count
  before_count=$(git worktree list --porcelain 2>/dev/null | grep -c "^worktree " || echo "0")

  # Run git worktree prune
  local prune_output
  prune_output=$(git worktree prune --verbose 2>&1)

  if [[ $? -eq 0 ]]; then
    # Get list of worktrees after pruning
    local after_count
    after_count=$(git worktree list --porcelain 2>/dev/null | grep -c "^worktree " || echo "0")

    local removed_count=$((before_count - after_count))

    if [[ $removed_count -gt 0 ]]; then
      log_success "Pruned $removed_count stale worktree reference(s)"
      if [[ "$VERBOSE" == true ]] && [[ -n "$prune_output" ]]; then
        echo "$prune_output"
      fi
    else
      log_info "No stale worktree references found"
    fi

    # Look for manually deleted worktree directories
    log_info "Checking for orphaned worktree directories..."

    local orphaned_found=false
    while IFS= read -r line; do
      if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
        local wt_path="${BASH_REMATCH[1]}"
        if [[ ! -d "$wt_path" ]]; then
          log_warning "Found reference to non-existent directory: $wt_path"
          orphaned_found=true
        fi
      fi
    done < <(git worktree list --porcelain 2>/dev/null)

    if [[ "$orphaned_found" == true ]]; then
      log_info "Run 'git worktree prune' again or manually clean up .git/worktrees/"
    else
      log_info "No orphaned directories found"
    fi

    # Optionally suggest cleaning up merged branches
    if confirm_action "Also clean up branches for merged worktrees?"; then
      cleanup_merged_worktrees
    fi

  else
    log_error "Failed to prune worktrees: $prune_output"
    return 1
  fi
}

# =============================================================================
# BRANCH MANAGEMENT FUNCTIONS
# =============================================================================

# Function: merge_worktree_branch(source_branch, [target_branch], [strategy])
# Purpose: Merge a worktree branch into another branch
# Parameters:
#   $1 - source branch to merge from
#   $2 - optional target branch (defaults to main/master)
#   $3 - optional merge strategy (merge, squash, rebase)
# Function: merge_worktree_branch(source_branch, [target_branch], [strategy])
# Purpose: Merge a worktree branch into another branch
# Parameters:
#   $1 - source branch to merge from
#   $2 - optional target branch (defaults to main/master)
#   $3 - optional merge strategy (merge, squash, rebase)
merge_worktree_branch() {
  local source_branch="${1:-}"
  local target_branch="${2:-}"
  local strategy="${3:-}"

  if [[ -z "$source_branch" ]]; then
    log_error "Source branch is required"
    return 1
  fi

  # Determine target branch
  if [[ -z "$target_branch" ]]; then
    if git show-ref --verify --quiet refs/heads/main; then
      target_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
      target_branch="master"
    else
      target_branch="$DEFAULT_BASE_BRANCH"
    fi
  fi

  # Set default strategy
  if [[ -z "$strategy" ]]; then
    strategy="merge"
  fi

  # Validate strategy
  case "$strategy" in
    "merge"|"squash"|"rebase")
      ;;
    *)
      log_error "Invalid merge strategy: $strategy (use: merge, squash, rebase)"
      return 1
      ;;
  esac

  # Validate branches exist
  if ! git show-ref --verify --quiet "refs/heads/$source_branch"; then
    log_error "Source branch '$source_branch' does not exist"
    return 1
  fi

  if ! git show-ref --verify --quiet "refs/heads/$target_branch"; then
    log_error "Target branch '$target_branch' does not exist"
    return 1
  fi

  # Check if source branch has uncommitted changes
  local source_worktree
  source_worktree=$(git worktree list --porcelain | awk -v branch="$source_branch" '
    /^worktree / { path = substr($0, 10) }
    /^branch refs\/heads\// {
      if (substr($0, 20) == branch) {
        print path
        exit
      }
    }
  ')

  if [[ -n "$source_worktree" ]] && [[ -d "$source_worktree" ]]; then
    if ! git -C "$source_worktree" diff --quiet || ! git -C "$source_worktree" diff --cached --quiet; then
      log_error "Source branch '$source_branch' has uncommitted changes"
      log_info "Please commit or stash changes before merging"
      return 1
    fi
  fi

  log_info "Merging '$source_branch' into '$target_branch' using '$strategy' strategy"

  # Switch to target branch worktree or main repo
  local target_worktree
  target_worktree=$(git worktree list --porcelain | awk -v branch="$target_branch" '
    /^worktree / { path = substr($0, 10) }
    /^branch refs\/heads\// {
      if (substr($0, 20) == branch) {
        print path
        exit
      }
    }
  ')

  local work_dir
  if [[ -n "$target_worktree" ]] && [[ -d "$target_worktree" ]]; then
    work_dir="$target_worktree"
  else
    work_dir="$(git rev-parse --show-toplevel)"
  fi

  # Ensure we're on the target branch
  if ! git -C "$work_dir" checkout "$target_branch" 2>/dev/null; then
    log_error "Failed to checkout target branch '$target_branch'"
    return 1
  fi

  # Fetch latest changes
  log_info "Fetching latest changes..."
  git -C "$work_dir" fetch origin 2>/dev/null || log_warning "Failed to fetch from origin"

  # Perform merge based on strategy
  case "$strategy" in
    "merge")
      if git -C "$work_dir" merge "$source_branch"; then
        log_success "Merge completed successfully"
      else
        log_error "Merge failed. Please resolve conflicts manually."
        return 1
      fi
      ;;
    "squash")
      if git -C "$work_dir" merge --squash "$source_branch"; then
        log_info "Squash merge completed. Please commit the changes."
        if confirm_action "Commit squashed changes now?"; then
          local commit_msg="Merge branch '$source_branch' (squashed)"
          if git -C "$work_dir" commit -m "$commit_msg"; then
            log_success "Squashed changes committed"
          else
            log_error "Failed to commit squashed changes"
            return 1
          fi
        fi
      else
        log_error "Squash merge failed"
        return 1
      fi
      ;;
    "rebase")
      if git -C "$work_dir" rebase "$source_branch"; then
        log_success "Rebase completed successfully"
      else
        log_error "Rebase failed. Please resolve conflicts manually."
        return 1
      fi
      ;;
  esac

  # Offer to push changes
  if confirm_action "Push changes to remote?"; then
    if git -C "$work_dir" push origin "$target_branch"; then
      log_success "Changes pushed to remote"
    else
      log_warning "Failed to push changes"
    fi
  fi

  # Offer to clean up source branch and worktree
  if confirm_action "Remove source branch '$source_branch' and its worktree?"; then
    if [[ -n "$source_worktree" ]] && [[ -d "$source_worktree" ]]; then
      remove_worktree "$source_branch" --force
    fi
  fi
}

# Function: sync_worktree(target)
# Purpose: Sync a worktree with its upstream branch
# Parameters: $1 - worktree identifier
# Function: sync_worktree(target)
# Purpose: Sync a worktree with its upstream branch
# Parameters: $1 - worktree identifier
sync_worktree() {
  local target="${1:-}"

  # If no target specified, sync all worktrees
  if [[ -z "$target" ]]; then
    log_info "Syncing all worktrees..."

    local worktree_data
    worktree_data=$(git worktree list --porcelain 2>/dev/null)

    local path="" branch=""
    while IFS= read -r line; do
      if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
        path="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^branch\ refs/heads/(.+)$ ]]; then
        branch="${BASH_REMATCH[1]}"
      elif [[ -z "$line" ]] && [[ -n "$path" ]] && [[ -n "$branch" ]]; then
        log_info "Syncing worktree: $path ($branch)"
        if ! _sync_single_worktree "$path" "$branch"; then
          log_warning "Failed to sync worktree: $path"
        fi
        path="" branch=""
      fi
    done <<< "$worktree_data"

    # Handle last entry
    if [[ -n "$path" ]] && [[ -n "$branch" ]]; then
      log_info "Syncing worktree: $path ($branch)"
      if ! _sync_single_worktree "$path" "$branch"; then
        log_warning "Failed to sync worktree: $path"
      fi
    fi

    return 0
  fi

  # Resolve target to worktree path and branch
  local worktree_path="" branch_name=""

  if [[ -d "$target" ]]; then
    # Target is a directory path
    if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      worktree_path="$target"
      branch_name=$(git -C "$target" branch --show-current 2>/dev/null)
    else
      log_error "'$target' is not a valid worktree directory"
      return 1
    fi
  else
    # Try to find worktree by branch name
    local found_info
    found_info=$(git worktree list --porcelain | awk -v branch="$target" '
      /^worktree / { path = substr($0, 10) }
      /^branch refs\/heads\// {
        if (substr($0, 20) == branch) {
          print path "|" branch
          exit
        }
      }
    ')

    if [[ -n "$found_info" ]]; then
      worktree_path="${found_info%|*}"
      branch_name="${found_info#*|}"
    else
      log_error "No worktree found for branch '$target'"
      return 1
    fi
  fi

  log_info "Syncing worktree: $worktree_path ($branch_name)"
  _sync_single_worktree "$worktree_path" "$branch_name"
}

# Helper function to sync a single worktree
_sync_single_worktree() {
  local worktree_path="$1"
  local branch_name="$2"

  if [[ ! -d "$worktree_path" ]]; then
    log_error "Worktree directory does not exist: $worktree_path"
    return 1
  fi

  # Check for uncommitted changes
  if ! git -C "$worktree_path" diff --quiet || ! git -C "$worktree_path" diff --cached --quiet; then
    log_warning "Worktree has uncommitted changes, skipping sync: $worktree_path"
    return 1
  fi

  # Fetch latest changes
  log_info "Fetching latest changes for $branch_name..."
  if ! git -C "$worktree_path" fetch origin 2>/dev/null; then
    log_warning "Failed to fetch from origin for $branch_name"
    return 1
  fi

  # Check if remote branch exists
  if ! git -C "$worktree_path" ls-remote --heads origin "$branch_name" | grep -q "refs/heads/$branch_name"; then
    log_warning "No remote branch found for $branch_name, skipping sync"
    return 0
  fi

  # Check for conflicts between local and remote
  local local_commit remote_commit merge_base
  local_commit=$(git -C "$worktree_path" rev-parse HEAD)
  remote_commit=$(git -C "$worktree_path" rev-parse "origin/$branch_name" 2>/dev/null)

  if [[ -z "$remote_commit" ]]; then
    log_warning "Cannot resolve remote commit for $branch_name"
    return 1
  fi

  if [[ "$local_commit" == "$remote_commit" ]]; then
    log_info "Branch $branch_name is already up to date"
    return 0
  fi

  merge_base=$(git -C "$worktree_path" merge-base HEAD "origin/$branch_name" 2>/dev/null)

  if [[ "$merge_base" == "$local_commit" ]]; then
    # Fast-forward merge possible
    log_info "Fast-forwarding $branch_name..."
    if git -C "$worktree_path" merge --ff-only "origin/$branch_name"; then
      log_success "Successfully fast-forwarded $branch_name"
    else
      log_error "Fast-forward failed for $branch_name"
      return 1
    fi
  elif [[ "$merge_base" == "$remote_commit" ]]; then
    # Local is ahead of remote
    log_info "Local branch $branch_name is ahead of remote"
    if confirm_action "Push local changes to remote?"; then
      if git -C "$worktree_path" push origin "$branch_name"; then
        log_success "Pushed local changes for $branch_name"
      else
        log_error "Failed to push changes for $branch_name"
        return 1
      fi
    fi
  else
    # Branches have diverged
    log_warning "Local and remote branches have diverged for $branch_name"
    log_info "Local: $local_commit"
    log_info "Remote: $remote_commit"
    log_info "Merge base: $merge_base"

    if confirm_action "Attempt to merge remote changes?"; then
      if git -C "$worktree_path" merge "origin/$branch_name"; then
        log_success "Successfully merged remote changes for $branch_name"
      else
        log_error "Merge failed for $branch_name. Please resolve conflicts manually."
        return 1
      fi
    else
      log_info "Skipping merge for $branch_name"
    fi
  fi

  return 0
}

# Function: create_pull_request(branch_name, [title], [description])
# Purpose: Create a pull request for a worktree branch (if GitHub CLI available)
# Parameters:
#   $1 - branch name
#   $2 - optional PR title
#   $3 - optional PR description
# Function: create_pull_request(branch_name, [title], [description])
# Purpose: Create a pull request for a worktree branch (if GitHub CLI available)
# Parameters:
#   $1 - branch name
#   $2 - optional PR title
#   $3 - optional PR description
create_pull_request() {
  local branch_name="${1:-}"
  local pr_title="${2:-}"
  local pr_description="${3:-}"

  if [[ -z "$branch_name" ]]; then
    log_error "Branch name is required"
    return 1
  fi

  # Check if GitHub CLI is available
  if ! command -v gh >/dev/null 2>&1; then
    log_error "GitHub CLI (gh) is not installed"
    log_info "Install it from: https://cli.github.com/"
    return 1
  fi

  # Validate branch exists
  if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
    log_error "Branch '$branch_name' does not exist locally"
    return 1
  fi

  # Check if branch has commits different from main/master
  local base_branch
  if git show-ref --verify --quiet refs/heads/main; then
    base_branch="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    base_branch="master"
  else
    base_branch="$DEFAULT_BASE_BRANCH"
  fi

  local commit_count
  commit_count=$(git rev-list --count "$base_branch..$branch_name" 2>/dev/null || echo "0")

  if [[ "$commit_count" -eq 0 ]]; then
    log_error "Branch '$branch_name' has no unique commits compared to '$base_branch'"
    return 1
  fi

  log_info "Branch '$branch_name' has $commit_count unique commit(s)"

  # Find worktree for the branch
  local worktree_path
  worktree_path=$(git worktree list --porcelain | awk -v branch="$branch_name" '
    /^worktree / { path = substr($0, 10) }
    /^branch refs\/heads\// {
      if (substr($0, 20) == branch) {
        print path
        exit
      }
    }
  ')

  # Check if branch is pushed to remote
  if ! git ls-remote --heads origin "$branch_name" | grep -q "refs/heads/$branch_name"; then
    log_info "Branch '$branch_name' is not pushed to remote"

    if confirm_action "Push branch '$branch_name' to remote?"; then
      local push_dir
      if [[ -n "$worktree_path" ]] && [[ -d "$worktree_path" ]]; then
        push_dir="$worktree_path"
      else
        push_dir="$(git rev-parse --show-toplevel)"
        git checkout "$branch_name" || {
          log_error "Failed to checkout branch '$branch_name'"
          return 1
        }
      fi

      if git -C "$push_dir" push -u origin "$branch_name"; then
        log_success "Branch '$branch_name' pushed to remote"
      else
        log_error "Failed to push branch '$branch_name'"
        return 1
      fi
    else
      log_error "Cannot create PR without pushing branch to remote"
      return 1
    fi
  fi

  # Generate PR title if not provided
  if [[ -z "$pr_title" ]]; then
    # Use the latest commit message as title
    pr_title=$(git log -1 --pretty=format:"%s" "$branch_name" 2>/dev/null)
    if [[ -z "$pr_title" ]]; then
      pr_title="Merge $branch_name"
    fi
  fi

  # Generate PR description if not provided
  if [[ -z "$pr_description" ]]; then
    # Create a simple description with commit list
    pr_description="## Changes

This PR contains the following commits:

$(git log --oneline "$base_branch..$branch_name" 2>/dev/null | sed 's/^/- /')

## Checklist
- [ ] Code follows project style guidelines
- [ ] Tests pass locally
- [ ] Documentation updated if needed"
  fi

  log_info "Creating pull request for branch '$branch_name'..."
  log_info "Title: $pr_title"

  # Create the pull request
  local pr_url
  if pr_url=$(gh pr create \
    --title "$pr_title" \
    --body "$pr_description" \
    --head "$branch_name" \
    --base "$base_branch" 2>&1); then

    log_success "Pull request created successfully!"
    echo
    if use_colors; then
      printf "${CYAN}Pull Request URL:${NC} %s\n" "$pr_url"
    else
      printf "Pull Request URL: %s\n" "$pr_url"
    fi
    echo

    # Offer to open in browser
    if confirm_action "Open pull request in browser?"; then
      gh pr view --web "$branch_name" 2>/dev/null || {
        log_warning "Failed to open in browser"
      }
    fi

  else
    log_error "Failed to create pull request: $pr_url"
    return 1
  fi
}

# =============================================================================
# MAINTENANCE AND UTILITY FUNCTIONS
# =============================================================================

# Function: worktree_status([target])
# Purpose: Show detailed status of worktrees
# Parameters: $1 - optional specific worktree to check
worktree_status() {
  local target="${1:-}"

  if [[ -n "$target" ]]; then
    # Show status for specific worktree
    _show_single_worktree_status "$target"
  else
    # Show status for all worktrees
    log_info "Checking status of all worktrees..."
    echo

    local worktree_data
    worktree_data=$(git worktree list --porcelain 2>/dev/null)

    if [[ -z "$worktree_data" ]]; then
      log_info "No worktrees found"
      return 0
    fi

    local total_count=0
    local clean_count=0
    local dirty_count=0
    local ahead_count=0
    local behind_count=0
    local total_size=0

    local path="" branch=""
    while IFS= read -r line; do
      if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
        path="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^branch\ refs/heads/(.+)$ ]]; then
        branch="${BASH_REMATCH[1]}"
      elif [[ -z "$line" ]] && [[ -n "$path" ]] && [[ -n "$branch" ]]; then
        ((total_count++))
        if use_colors; then
          printf "${WHITE}Worktree %d: %s${NC}\n" "$total_count" "$path"
        else
          printf "Worktree %d: %s\n" "$total_count" "$path"
        fi

        local status_info
        status_info=$(_get_worktree_status_info "$path" "$branch")

        # Parse status info
        IFS='|' read -r is_clean ahead_count_single behind_count_single size_kb <<< "$status_info"

        if [[ "$is_clean" == "true" ]]; then
          ((clean_count++))
          if use_colors; then
            printf "  Status: ${GREEN}Clean${NC}\n"
          else
            printf "  Status: Clean\n"
          fi
        else
          ((dirty_count++))
          if use_colors; then
            printf "  Status: ${YELLOW}Uncommitted changes${NC}\n"
          else
            printf "  Status: Uncommitted changes\n"
          fi
        fi

        if [[ "$ahead_count_single" -gt 0 ]]; then
          ((ahead_count++))
          if use_colors; then
            printf "  Remote: ${YELLOW}%d commit(s) ahead${NC}\n" "$ahead_count_single"
          else
            printf "  Remote: %d commit(s) ahead\n" "$ahead_count_single"
          fi
        fi

        if [[ "$behind_count_single" -gt 0 ]]; then
          ((behind_count++))
          if use_colors; then
            printf "  Remote: ${YELLOW}%d commit(s) behind${NC}\n" "$behind_count_single"
          else
            printf "  Remote: %d commit(s) behind\n" "$behind_count_single"
          fi
        fi

        if [[ "$ahead_count_single" -eq 0 ]] && [[ "$behind_count_single" -eq 0 ]]; then
          if use_colors; then
            printf "  Remote: ${GREEN}Up to date${NC}\n"
          else
            printf "  Remote: Up to date\n"
          fi
        fi

        echo "  Branch: $branch"
        echo "  Size: ${size_kb} KB"
        echo

        ((total_size += size_kb))

        path="" branch=""
      fi
    done <<< "$worktree_data"

    # Handle last entry
    if [[ -n "$path" ]] && [[ -n "$branch" ]]; then
      ((total_count++))
      if use_colors; then
        printf "${WHITE}Worktree %d: %s${NC}\n" "$total_count" "$path"
      else
        printf "Worktree %d: %s\n" "$total_count" "$path"
      fi

      local status_info
      status_info=$(_get_worktree_status_info "$path" "$branch")

      IFS='|' read -r is_clean ahead_count_single behind_count_single size_kb <<< "$status_info"

      if [[ "$is_clean" == "true" ]]; then
        ((clean_count++))
        if use_colors; then
          printf "  Status: ${GREEN}Clean${NC}\n"
        else
          printf "  Status: Clean\n"
        fi
      else
        ((dirty_count++))
        if use_colors; then
          printf "  Status: ${YELLOW}Uncommitted changes${NC}\n"
        else
          printf "  Status: Uncommitted changes\n"
        fi
      fi

      if [[ "$ahead_count_single" -gt 0 ]]; then
        ((ahead_count++))
        if use_colors; then
          printf "  Remote: ${YELLOW}%d commit(s) ahead${NC}\n" "$ahead_count_single"
        else
          printf "  Remote: %d commit(s) ahead\n" "$ahead_count_single"
        fi
      fi

      if [[ "$behind_count_single" -gt 0 ]]; then
        ((behind_count++))
        if use_colors; then
          printf "  Remote: ${YELLOW}%d commit(s) behind${NC}\n" "$behind_count_single"
        else
          printf "  Remote: %d commit(s) behind\n" "$behind_count_single"
        fi
      fi

      if [[ "$ahead_count_single" -eq 0 ]] && [[ "$behind_count_single" -eq 0 ]]; then
        if use_colors; then
          printf "  Remote: ${GREEN}Up to date${NC}\n"
        else
          printf "  Remote: Up to date\n"
        fi
      fi

      echo "  Branch: $branch"
      echo "  Size: ${size_kb} KB"
      echo

      ((total_size += size_kb))
    fi

    # Show summary
    if use_colors; then
      printf "${WHITE}Summary:${NC}\n"
    else
      printf "Summary:\n"
    fi
    echo "  Total worktrees: $total_count"
    echo "  Clean worktrees: $clean_count"
    echo "  Dirty worktrees: $dirty_count"
    echo "  Ahead of remote: $ahead_count"
    echo "  Behind remote: $behind_count"
    echo "  Total disk usage: $total_size KB"
  fi
}

# Helper function to show status for a single worktree
_show_single_worktree_status() {
  local target="${1:-}"

  # Resolve target to worktree path and branch
  local worktree_path="" branch_name=""

  if [[ -d "$target" ]]; then
    if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      worktree_path="$target"
      branch_name=$(git -C "$target" branch --show-current 2>/dev/null)
    else
      log_error "'$target' is not a valid worktree directory"
      return 1
    fi
  else
    local found_info
    found_info=$(git worktree list --porcelain | awk -v branch="$target" '
      /^worktree / { path = substr($0, 10) }
      /^branch refs\/heads\// {
        if (substr($0, 20) == branch) {
          print path "|" branch
          exit
        }
      }
    ')

    if [[ -n "$found_info" ]]; then
      worktree_path="${found_info%|*}"
      branch_name="${found_info#*|}"
    else
      log_error "No worktree found for '$target'"
      return 1
    fi
  fi

  if use_colors; then
    printf "${WHITE}Worktree Status: %s${NC}\n" "$worktree_path"
  else
    printf "Worktree Status: %s\n" "$worktree_path"
  fi
  echo "Branch: $branch_name"
  echo

  # Show git status
  if use_colors; then
    printf "${CYAN}Git Status:${NC}\n"
  else
    printf "Git Status:\n"
  fi
  git -C "$worktree_path" status --short --branch
  echo

  # Show last commit
  if use_colors; then
    printf "${CYAN}Last Commit:${NC}\n"
  else
    printf "Last Commit:\n"
  fi
  git -C "$worktree_path" log -1 --pretty=format:"%h %s (%an, %ar)" 2>/dev/null
  echo
  echo

  # Show remote status
  if use_colors; then
    printf "${CYAN}Remote Status:${NC}\n"
  else
    printf "Remote Status:\n"
  fi
  local remote_info
  remote_info=$(git -C "$worktree_path" status --porcelain=v1 --branch 2>/dev/null | head -1)

  if [[ "$remote_info" =~ \[ahead\ ([0-9]+)\] ]]; then
    if use_colors; then
      printf "  ${YELLOW}Ahead by %s commit(s)${NC}\n" "${BASH_REMATCH[1]}"
    else
      printf "  Ahead by %s commit(s)\n" "${BASH_REMATCH[1]}"
    fi
  fi

  if [[ "$remote_info" =~ \[behind\ ([0-9]+)\] ]]; then
    if use_colors; then
      printf "  ${YELLOW}Behind by %s commit(s)${NC}\n" "${BASH_REMATCH[1]}"
    else
      printf "  Behind by %s commit(s)\n" "${BASH_REMATCH[1]}"
    fi
  fi

  if [[ ! "$remote_info" =~ \[ahead\ [0-9]+\] ]] && [[ ! "$remote_info" =~ \[behind\ [0-9]+\] ]]; then
    if use_colors; then
      printf "  ${GREEN}Up to date with remote${NC}\n"
    else
      printf "  Up to date with remote\n"
    fi
  fi
}

# Helper function to get worktree status information
_get_worktree_status_info() {
  local path="$1"
  local branch="$2"

  if [[ ! -d "$path" ]]; then
    echo "false|0|0|0"
    return
  fi

  # Check if clean
  local is_clean=true
  if ! git -C "$path" diff --quiet 2>/dev/null || ! git -C "$path" diff --cached --quiet 2>/dev/null; then
    is_clean=false
  fi

  # Get ahead/behind counts
  local ahead=0 behind=0
  if git -C "$path" ls-remote --heads origin "$branch" >/dev/null 2>&1; then
    local counts
    counts=$(git -C "$path" rev-list --left-right --count "HEAD...origin/$branch" 2>/dev/null)
    if [[ -n "$counts" ]]; then
      ahead=$(echo "$counts" | cut -f1)
      behind=$(echo "$counts" | cut -f2)
    fi
  fi

  # Get directory size in KB
  local size_kb=0
  if command -v du >/dev/null 2>&1; then
    size_kb=$(du -sk "$path" 2>/dev/null | cut -f1)
  fi

  echo "$is_clean|$ahead|$behind|$size_kb"
}

# Function: cleanup_merged_worktrees()
# Purpose: Remove worktrees for branches that have been merged
# Function: cleanup_merged_worktrees()
# Purpose: Remove worktrees for branches that have been merged
cleanup_merged_worktrees() {
  log_info "Checking for merged branches with worktrees..."

  # Determine main branch
  local main_branch
  if git show-ref --verify --quiet refs/heads/main; then
    main_branch="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    main_branch="master"
  else
    main_branch="$DEFAULT_BASE_BRANCH"
  fi

  log_info "Using '$main_branch' as the main branch"

  # Get list of merged branches
  local merged_branches
  merged_branches=$(git branch --merged "$main_branch" | grep -v "^\*" | grep -v "^\s*$main_branch$" | sed 's/^\s*//')

  if [[ -z "$merged_branches" ]]; then
    log_info "No merged branches found"
    return 0
  fi

  log_info "Found merged branches:"
  echo "$merged_branches" | sed 's/^/  /'
  echo

  # Find worktrees for merged branches
  local worktrees_to_remove=()
  local branches_to_remove=()

  while IFS= read -r branch; do
    [[ -z "$branch" ]] && continue

    # Check if this branch has a worktree
    local worktree_path
    worktree_path=$(git worktree list --porcelain | awk -v branch="$branch" '
      /^worktree / { path = substr($0, 10) }
      /^branch refs\/heads\// {
        if (substr($0, 20) == branch) {
          print path
          exit
        }
      }
    ')

    if [[ -n "$worktree_path" ]]; then
      worktrees_to_remove+=("$worktree_path|$branch")
      branches_to_remove+=("$branch")
    fi
  done <<< "$merged_branches"

  if [[ ${#worktrees_to_remove[@]} -eq 0 ]]; then
    log_info "No worktrees found for merged branches"
    return 0
  fi

  if use_colors; then
    printf "${YELLOW}Worktrees to be removed:${NC}\n"
  else
    printf "Worktrees to be removed:\n"
  fi
  for entry in "${worktrees_to_remove[@]}"; do
    local path="${entry%|*}"
    local branch="${entry#*|}"
    echo "  $path ($branch)"
  done
  echo

  if ! confirm_action "Remove ${#worktrees_to_remove[@]} worktree(s) for merged branches?"; then
    log_info "Operation cancelled"
    return 0
  fi

  local removed_count=0
  local failed_count=0

  for entry in "${worktrees_to_remove[@]}"; do
    local path="${entry%|*}"
    local branch="${entry#*|}"

    log_info "Removing worktree: $path ($branch)"

    # Check for uncommitted changes
    if [[ -d "$path" ]]; then
      if ! git -C "$path" diff --quiet || ! git -C "$path" diff --cached --quiet; then
        log_warning "Worktree has uncommitted changes: $path"
        if ! confirm_action "Remove anyway?"; then
          log_info "Skipping worktree: $path"
          ((failed_count++))
          continue
        fi
      fi
    fi

    # Remove worktree
    if git worktree remove "$path" --force 2>/dev/null; then
      log_success "Removed worktree: $path"
      ((removed_count++))
    else
      log_warning "Failed to remove worktree: $path"
      ((failed_count++))

      # Try manual cleanup
      if [[ -d "$path" ]]; then
        rm -rf "$path" 2>/dev/null
      fi
    fi

    # Remove branch
    if confirm_action "Also delete merged branch '$branch'?"; then
      if git branch -d "$branch" 2>/dev/null; then
        log_success "Deleted branch: $branch"
      else
        log_warning "Failed to delete branch: $branch"
      fi
    fi
  done

  # Prune stale references
  git worktree prune 2>/dev/null

  echo
  log_success "Cleanup completed: $removed_count removed, $failed_count failed"
}

# Function: backup_worktree_config()
# Purpose: Backup worktree configuration and branch information
# Function: backup_worktree_config()
# Purpose: Backup worktree configuration and branch information
backup_worktree_config() {
  log_info "Creating worktree configuration backup..."

  # Create backup directory
  local backup_dir=".git/worktree-backups"
  mkdir -p "$backup_dir"

  # Generate backup filename with timestamp
  local timestamp
  timestamp=$(date '+%Y%m%d_%H%M%S')
  local backup_file="$backup_dir/worktree_backup_$timestamp.json"

  # Get current repository root
  local repo_root
  repo_root=$(git rev-parse --show-toplevel)

  # Start building JSON backup
  cat > "$backup_file" << EOF
{
  "backup_info": {
    "timestamp": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
    "script_version": "$VERSION",
    "repository": "$repo_root",
    "git_version": "$(git --version)"
  },
  "worktrees": [
EOF

  # Export worktree information
  local worktree_data
  worktree_data=$(git worktree list --porcelain 2>/dev/null)

  local first_entry=true
  local path="" branch="" commit="" locked="" bare=""

  while IFS= read -r line; do
    if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
      path="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^HEAD\ ([a-f0-9]+)$ ]]; then
      commit="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^branch\ refs/heads/(.+)$ ]]; then
      branch="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^detached$ ]]; then
      branch="(detached)"
    elif [[ "$line" =~ ^locked$ ]]; then
      locked="true"
    elif [[ "$line" =~ ^bare$ ]]; then
      bare="true"
    elif [[ -z "$line" ]] && [[ -n "$path" ]]; then
      # End of worktree entry, write to backup
      if [[ "$first_entry" == false ]]; then
        echo "," >> "$backup_file"
      fi
      first_entry=false

      # Get relative path if possible
      local rel_path="$path"
      if [[ "$path" == "$repo_root"* ]]; then
        rel_path=".${path#$repo_root}"
      fi

      # Get remote tracking info
      local upstream=""
      if [[ -d "$path" ]] && [[ "$branch" != "(detached)" ]]; then
        upstream=$(git -C "$path" rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null || echo "")
      fi

      cat >> "$backup_file" << EOF
    {
      "path": "$path",
      "relative_path": "$rel_path",
      "branch": "$branch",
      "commit": "$commit",
      "upstream": "$upstream",
      "locked": ${locked:-false},
      "bare": ${bare:-false}
    }
EOF

      # Reset for next entry
      path="" branch="" commit="" locked="" bare=""
    fi
  done <<< "$worktree_data"

  # Handle last entry
  if [[ -n "$path" ]]; then
    if [[ "$first_entry" == false ]]; then
      echo "," >> "$backup_file"
    fi

    local rel_path="$path"
    if [[ "$path" == "$repo_root"* ]]; then
      rel_path=".${path#$repo_root}"
    fi

    local upstream=""
    if [[ -d "$path" ]] && [[ "$branch" != "(detached)" ]]; then
      upstream=$(git -C "$path" rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null || echo "")
    fi

    cat >> "$backup_file" << EOF
    {
      "path": "$path",
      "relative_path": "$rel_path",
      "branch": "$branch",
      "commit": "$commit",
      "upstream": "$upstream",
      "locked": ${locked:-false},
      "bare": ${bare:-false}
    }
EOF
  fi

  # Close JSON structure
  cat >> "$backup_file" << EOF
  ]
}
EOF

  # Create restoration script
  local restore_script="$backup_dir/restore_$timestamp.sh"
  cat > "$restore_script" << 'EOF'
#!/usr/bin/env bash
# Worktree Restoration Script
# Generated by worktree.sh

set -euo pipefail

BACKUP_FILE="$(dirname "$0")/worktree_backup_TIMESTAMP.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "Error: Backup file not found: $BACKUP_FILE"
  exit 1
fi

echo "Restoring worktrees from backup: $BACKUP_FILE"

# Parse JSON and recreate worktrees
# Note: This is a simplified restoration script
# Full implementation would parse JSON and recreate worktrees

echo "Please use: worktree.sh restore \"$BACKUP_FILE\""
EOF

  # Replace placeholder in restore script
  sed -i.bak "s/TIMESTAMP/$timestamp/g" "$restore_script" && rm "$restore_script.bak"
  chmod +x "$restore_script"

  log_success "Backup created: $backup_file"
  log_info "Restoration script: $restore_script"

  # Display backup summary
  local worktree_count
  worktree_count=$(echo "$worktree_data" | grep -c "^worktree " || echo "0")

  echo
  if use_colors; then
    printf "${CYAN}Backup Summary:${NC}\n"
  else
    printf "Backup Summary:\n"
  fi
  echo "  Worktrees backed up: $worktree_count"
  echo "  Backup file: $backup_file"
  echo "  File size: $(ls -lh "$backup_file" | awk '{print $5}')"

  # Clean up old backups (keep last 10)
  log_info "Cleaning up old backups (keeping last 10)..."
  local old_backups
  old_backups=$(ls -1t "$backup_dir"/worktree_backup_*.json 2>/dev/null | tail -n +11)

  if [[ -n "$old_backups" ]]; then
    echo "$old_backups" | while IFS= read -r old_file; do
      rm -f "$old_file"
      # Also remove corresponding restore script
      local old_timestamp
      old_timestamp=$(basename "$old_file" | sed 's/worktree_backup_\(.*\)\.json/\1/')
      rm -f "$backup_dir/restore_$old_timestamp.sh"
    done
    local removed_count
    removed_count=$(echo "$old_backups" | wc -l | tr -d ' ')
    log_info "Removed $removed_count old backup(s)"
  fi
}

# Function: restore_worktree_config(backup_file)
# Purpose: Restore worktrees from backup
# Parameters: $1 - backup file path
# Function: restore_worktree_config(backup_file)
# Purpose: Restore worktrees from backup
# Parameters: $1 - backup file path
restore_worktree_config() {
  local backup_file="${1:-}"

  if [[ -z "$backup_file" ]]; then
    log_error "Backup file path is required"
    return 1
  fi

  if [[ ! -f "$backup_file" ]]; then
    log_error "Backup file not found: $backup_file"
    return 1
  fi

  log_info "Restoring worktrees from backup: $backup_file"

  # Verify backup file format
  if ! command -v jq >/dev/null 2>&1; then
    log_error "jq is required for backup restoration but not installed"
    log_info "Install jq or manually restore worktrees from the backup file"
    return 1
  fi

  # Validate JSON format
  if ! jq empty "$backup_file" 2>/dev/null; then
    log_error "Invalid JSON format in backup file"
    return 1
  fi

  # Display backup information
  local backup_timestamp backup_repo
  backup_timestamp=$(jq -r '.backup_info.timestamp' "$backup_file" 2>/dev/null)
  backup_repo=$(jq -r '.backup_info.repository' "$backup_file" 2>/dev/null)

  if use_colors; then
    printf "${CYAN}Backup Information:${NC}\n"
  else
    printf "Backup Information:\n"
  fi
  echo "  Created: $backup_timestamp"
  echo "  Repository: $backup_repo"
  echo

  # Get current repository root
  local current_repo
  current_repo=$(git rev-parse --show-toplevel)

  if [[ "$backup_repo" != "$current_repo" ]]; then
    log_warning "Backup was created for a different repository"
    log_warning "  Backup repo: $backup_repo"
    log_warning "  Current repo: $current_repo"

    if ! confirm_action "Continue with restoration anyway?"; then
      log_info "Restoration cancelled"
      return 1
    fi
  fi

  # Get worktrees from backup
  local worktree_count
  worktree_count=$(jq '.worktrees | length' "$backup_file")

  if [[ "$worktree_count" -eq 0 ]]; then
    log_info "No worktrees found in backup"
    return 0
  fi

  log_info "Found $worktree_count worktree(s) in backup"

  # Show what will be restored
  if use_colors; then
    printf "${YELLOW}Worktrees to restore:${NC}\n"
  else
    printf "Worktrees to restore:\n"
  fi
  jq -r '.worktrees[] | "  \(.relative_path) (\(.branch))"' "$backup_file"
  echo

  if ! confirm_action "Restore these worktrees?"; then
    log_info "Restoration cancelled"
    return 1
  fi

  local restored_count=0
  local failed_count=0
  local skipped_count=0

  # Process each worktree
  for ((i=0; i<worktree_count; i++)); do
    local wt_path wt_branch wt_commit wt_upstream
    wt_path=$(jq -r ".worktrees[$i].path" "$backup_file")
    wt_branch=$(jq -r ".worktrees[$i].branch" "$backup_file")
    wt_commit=$(jq -r ".worktrees[$i].commit" "$backup_file")
    wt_upstream=$(jq -r ".worktrees[$i].upstream" "$backup_file")

    # Skip main worktree (usually the repository root)
    if [[ "$wt_path" == "$current_repo" ]]; then
      log_info "Skipping main worktree: $wt_path"
      ((skipped_count++))
      continue
    fi

    # Skip detached HEAD worktrees
    if [[ "$wt_branch" == "(detached)" ]]; then
      log_warning "Skipping detached HEAD worktree: $wt_path"
      ((skipped_count++))
      continue
    fi

    log_info "Restoring worktree: $wt_path ($wt_branch)"

    # Check if path already exists
    if [[ -e "$wt_path" ]]; then
      log_warning "Path already exists: $wt_path"
      if ! confirm_action "Skip this worktree?"; then
        ((failed_count++))
        continue
      else
        ((skipped_count++))
        continue
      fi
    fi

    # Check if branch exists locally
    local branch_exists=false
    if git show-ref --verify --quiet "refs/heads/$wt_branch"; then
      branch_exists=true
    fi

    # Check if branch exists remotely
    local remote_exists=false
    if git ls-remote --heads origin "$wt_branch" | grep -q "refs/heads/$wt_branch"; then
      remote_exists=true
    fi

    # Create worktree based on branch availability
    if [[ "$branch_exists" == true ]]; then
      # Use existing local branch
      if git worktree add "$wt_path" "$wt_branch" 2>/dev/null; then
        log_success "Restored worktree: $wt_path"
        ((restored_count++))
      else
        log_error "Failed to restore worktree: $wt_path"
        ((failed_count++))
      fi
    elif [[ "$remote_exists" == true ]]; then
      # Create tracking branch from remote
      if git worktree add -b "$wt_branch" "$wt_path" "origin/$wt_branch" 2>/dev/null; then
        log_success "Restored worktree with tracking branch: $wt_path"
        ((restored_count++))
      else
        log_error "Failed to restore worktree with tracking branch: $wt_path"
        ((failed_count++))
      fi
    else
      # Branch doesn't exist, try to create from commit if available
      if [[ "$wt_commit" != "null" ]] && git cat-file -e "$wt_commit" 2>/dev/null; then
        if git worktree add -b "$wt_branch" "$wt_path" "$wt_commit" 2>/dev/null; then
          log_success "Restored worktree from commit: $wt_path"
          ((restored_count++))
        else
          log_error "Failed to restore worktree from commit: $wt_path"
          ((failed_count++))
        fi
      else
        log_error "Cannot restore worktree '$wt_path': branch '$wt_branch' not found"
        ((failed_count++))
      fi
    fi
  done

  # Clean up any stale references
  git worktree prune 2>/dev/null

  # Show restoration summary
  echo
  log_success "Restoration completed:"
  echo "  Restored: $restored_count"
  echo "  Failed: $failed_count"
  echo "  Skipped: $skipped_count"

  if [[ $failed_count -gt 0 ]]; then
    log_warning "Some worktrees could not be restored"
    log_info "You may need to manually recreate missing branches or resolve conflicts"
  fi
}

# =============================================================================
# COMMAND PARSING AND MAIN LOGIC
# =============================================================================

# Function: parse_global_options()
# Purpose: Parse global command line options
# Function: parse_global_options()
# Purpose: Parse global command line options
parse_global_options() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --verbose|-v)
        VERBOSE=true
        shift
        ;;
      --force|-f)
        FORCE=true
        shift
        ;;
      --debug)
        DEBUG=true
        VERBOSE=true
        shift
        ;;
      --help|-h)
        display_help
        exit 0
        ;;
      --version)
        echo "$SCRIPT_NAME version $VERSION"
        exit 0
        ;;
      --)
        # End of options
        shift
        break
        ;;
      -*)
        # Unknown option, might be command-specific
        break
        ;;
      *)
        # Not an option, must be command
        break
        ;;
    esac
  done

  # Return remaining arguments
  return 0
}

# Function: execute_command(command, args...)
# Purpose: Main command dispatcher
# Parameters: $1 - command name, $@ - command arguments
# Function: execute_command(command, args...)
# Purpose: Main command dispatcher
# Parameters: $1 - command name, $@ - command arguments
execute_command() {
  local command="$1"
  shift

  # Validate git repository for most commands
  case "$command" in
    "help"|"--help"|"-h"|"version"|"--version")
      # These commands don't require a git repository
      ;;
    *)
      if ! validate_git_repo; then
        return 1
      fi
      ;;
  esac

  # Route to appropriate function based on command
  case "$command" in
    "create"|"new"|"add")
      create_worktree "$@"
      ;;
    "list"|"ls")
      list_worktrees "$@"
      ;;
    "switch"|"checkout"|"cd")
      switch_worktree "$@"
      ;;
    "remove"|"delete"|"rm")
      remove_worktree "$@"
      ;;
    "merge")
      merge_worktree_branch "$@"
      ;;
    "sync"|"pull")
      sync_worktree "$@"
      ;;
    "status"|"st")
      worktree_status "$@"
      ;;
    "prune"|"cleanup")
      prune_worktrees "$@"
      ;;
    "pr"|"pull-request")
      create_pull_request "$@"
      ;;
    "clean-merged")
      cleanup_merged_worktrees "$@"
      ;;
    "backup")
      backup_worktree_config "$@"
      ;;
    "restore")
      restore_worktree_config "$@"
      ;;
    "help"|"-h"|"--help")
      display_help
      ;;
    "version"|"-v"|"--version")
      echo "$SCRIPT_NAME version $VERSION"
      ;;
    *)
      log_error "Unknown command: $command"
      echo
      echo "Available commands:"
      echo "  create, list, switch, remove, merge, sync, status, prune"
      echo "  pr, clean-merged, backup, restore, help, version"
      echo
      echo "Run '$SCRIPT_NAME help' for detailed usage information."

      # Suggest similar commands
      _suggest_similar_command "$command"
      return 1
      ;;
  esac
}

# Helper function to suggest similar commands
_suggest_similar_command() {
  local input="$1"
  local commands=(
    "create" "new" "add" "list" "ls" "switch" "checkout" "cd"
    "remove" "delete" "rm" "merge" "sync" "pull" "status" "st"
    "prune" "cleanup" "pr" "pull-request" "clean-merged"
    "backup" "restore" "help" "version"
  )

  # Simple fuzzy matching
  local suggestions=()
  for cmd in "${commands[@]}"; do
    # Check if input is a substring of command or vice versa
    if [[ "$cmd" == *"$input"* ]] || [[ "$input" == *"$cmd"* ]]; then
      suggestions+=("$cmd")
    fi
  done

  if [[ ${#suggestions[@]} -gt 0 ]]; then
    echo "Did you mean one of these?"
    printf '  %s\n' "${suggestions[@]}"
  fi
}

# =============================================================================
# MAIN ENTRY POINT
# =============================================================================

main() {
  # Check if any arguments provided
  if [[ $# -eq 0 ]]; then
    display_help
    exit 0
  fi

  # Parse global options first
  local original_args=("$@")
  parse_global_options "$@"

  # Find where the command starts (skip parsed global options)
  local command_args=()
  local found_command=false

  for arg in "${original_args[@]}"; do
    case "$arg" in
      --verbose|-v|--force|-f|--debug|--help|-h|--version)
        # Skip global options
        ;;
      --)
        # End of options marker
        found_command=true
        ;;
      *)
        if [[ "$found_command" == true ]] || [[ "$arg" != -* ]]; then
          command_args+=("$arg")
        fi
        ;;
    esac
  done

  # If no command found after parsing options, show help
  if [[ ${#command_args[@]} -eq 0 ]]; then
    display_help
    exit 0
  fi

  # Extract command and its arguments
  local command="${command_args[0]}"
  local cmd_args=("${command_args[@]:1}")

  # Check minimum requirements (for commands that need git)
  case "$command" in
    "help"|"--help"|"-h"|"version"|"--version")
      # Skip requirements check for help/version
      ;;
    *)
      # Check git version and repository
      if ! command -v git >/dev/null 2>&1; then
        log_error "Git is not installed or not in PATH"
        exit 1
      fi

      local git_version
      git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
      local major minor
      major=$(echo "$git_version" | cut -d. -f1)
      minor=$(echo "$git_version" | cut -d. -f2)

      if [[ $major -lt 2 ]] || [[ $major -eq 2 && $minor -lt 5 ]]; then
        log_error "Git version $git_version is too old. Worktree support requires Git >= 2.5"
        exit 1
      fi
      ;;
  esac

  # Execute command with error handling
  local exit_code=0
  if ! execute_command "$command" "${cmd_args[@]}"; then
    exit_code=$?
  fi

  # Exit with appropriate code
  exit $exit_code
}

# Execute main function with all arguments
main "$@"
