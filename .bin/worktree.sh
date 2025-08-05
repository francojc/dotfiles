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

# Default configuration
readonly DEFAULT_WORKTREE_DIR=".worktrees"
readonly DEFAULT_BASE_BRANCH="main"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function: display_help()
# Purpose: Show comprehensive help information
# Usage: display_help
display_help() {
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
}

# Function: log_info(message)
# Purpose: Print informational messages with color coding
# Parameters: $1 - message to display
log_info() {
  # PSEUDOCODE:
  # - Print message with INFO prefix in blue
  # - Include timestamp if verbose mode enabled
  echo "Log info implementation..."
}

# Function: log_error(message)
# Purpose: Print error messages to stderr with color coding
# Parameters: $1 - error message to display
log_error() {
  # PSEUDOCODE:
  # - Print message with ERROR prefix in red to stderr
  # - Include stack trace if debug mode enabled
  echo "Log error implementation..."
}

# Function: log_success(message)
# Purpose: Print success messages with color coding
# Parameters: $1 - success message to display
log_success() {
  # PSEUDOCODE:
  # - Print message with SUCCESS prefix in green
  # - Add checkmark symbol if terminal supports it
  echo "Log success implementation..."
}

# Function: log_warning(message)
# Purpose: Print warning messages with color coding
# Parameters: $1 - warning message to display
log_warning() {
  # PSEUDOCODE:
  # - Print message with WARNING prefix in yellow
  # - Add warning symbol if terminal supports it
  echo "Log warning implementation..."
}

# Function: confirm_action(prompt)
# Purpose: Ask user for confirmation before destructive actions
# Parameters: $1 - confirmation prompt
# Returns: 0 if confirmed, 1 if denied
confirm_action() {
  # PSEUDOCODE:
  # - Display prompt with [y/N] options
  # - Read user input
  # - Return appropriate exit code
  # - Support --force flag to bypass confirmation
  echo "Confirm action implementation..."
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Function: validate_git_repo()
# Purpose: Ensure we're in a git repository
# Returns: 0 if valid git repo, 1 otherwise
validate_git_repo() {
  # PSEUDOCODE:
  # - Check if .git directory exists or we're in a git worktree
  # - Verify git command is available
  # - Check if repository has at least one commit
  echo "Validate git repo implementation..."
}

# Function: validate_branch_name(branch_name)
# Purpose: Validate that branch name follows git naming conventions
# Parameters: $1 - branch name to validate
# Returns: 0 if valid, 1 otherwise
validate_branch_name() {
  # PSEUDOCODE:
  # - Check for invalid characters (spaces, special chars)
  # - Ensure branch name doesn't start with hyphen
  # - Verify it's not a reserved name (HEAD, etc.)
  # - Check length limitations
  echo "Validate branch name implementation..."
}

# Function: validate_worktree_path(path)
# Purpose: Validate worktree path is suitable for creation
# Parameters: $1 - proposed worktree path
# Returns: 0 if valid, 1 otherwise
validate_worktree_path() {
  # PSEUDOCODE:
  # - Check if path already exists
  # - Ensure parent directory is writable
  # - Verify path doesn't conflict with existing worktrees
  # - Check for reasonable path length and characters
  echo "Validate worktree path implementation..."
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
create_worktree() {
  # PSEUDOCODE:
  # - Validate input parameters
  # - Determine worktree path (use provided or generate from branch name)
  # - Check if branch already exists locally or remotely
  # - If branch exists remotely but not locally, create tracking branch
  # - If branch doesn't exist, create new branch from base branch
  # - Execute git worktree add command
  # - Set up any additional configuration (git hooks, etc.)
  # - Display success message with path information
  echo "Create worktree implementation..."
}

# Function: list_worktrees([format])
# Purpose: List all existing worktrees with detailed information
# Parameters: $1 - optional format (table, json, simple)
list_worktrees() {
  # PSEUDOCODE:
  # - Get worktree list from git worktree list --porcelain
  # - Parse output to extract path, branch, and status information
  # - Add additional metadata (creation date, last activity, etc.)
  # - Format output according to specified format
  # - Highlight current worktree
  # - Show statistics (total count, disk usage, etc.)
  echo "List worktrees implementation..."
}

# Function: switch_worktree(target)
# Purpose: Switch to a specific worktree directory
# Parameters: $1 - worktree identifier (branch name or path)
switch_worktree() {
  # PSEUDOCODE:
  # - Resolve target to actual worktree path
  # - Validate worktree exists and is accessible
  # - Change directory to worktree path
  # - Update shell environment if needed
  # - Display current location and branch information
  echo "Switch worktree implementation..."
}

# Function: remove_worktree(target, [force])
# Purpose: Remove a git worktree
# Parameters: 
#   $1 - worktree identifier (branch name or path)
#   $2 - optional force flag
remove_worktree() {
  # PSEUDOCODE:
  # - Resolve target to actual worktree path
  # - Validate worktree exists
  # - Check for uncommitted changes (warn user)
  # - Confirm deletion unless force flag is set
  # - Remove worktree using git worktree remove
  # - Clean up any additional files or configurations
  # - Optionally delete the associated branch
  echo "Remove worktree implementation..."
}

# Function: prune_worktrees()
# Purpose: Clean up stale worktree references
prune_worktrees() {
  # PSEUDOCODE:
  # - Run git worktree prune to remove stale references
  # - Identify manually deleted worktree directories
  # - Report what was cleaned up
  # - Optionally clean up orphaned branches
  echo "Prune worktrees implementation..."
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
merge_worktree_branch() {
  # PSEUDOCODE:
  # - Validate source and target branches exist
  # - Check if source branch has uncommitted changes
  # - Switch to target branch worktree or main repo
  # - Fetch latest changes
  # - Perform merge according to specified strategy
  # - Handle merge conflicts if they occur
  # - Push changes if successful
  # - Optionally clean up source branch and worktree
  echo "Merge worktree branch implementation..."
}

# Function: sync_worktree(target)
# Purpose: Sync a worktree with its upstream branch
# Parameters: $1 - worktree identifier
sync_worktree() {
  # PSEUDOCODE:
  # - Switch to specified worktree
  # - Fetch latest changes from remote
  # - Check for conflicts between local and remote changes
  # - Perform merge or rebase as configured
  # - Report sync status and any issues
  echo "Sync worktree implementation..."
}

# Function: create_pull_request(branch_name, [title], [description])
# Purpose: Create a pull request for a worktree branch (if GitHub CLI available)
# Parameters:
#   $1 - branch name
#   $2 - optional PR title
#   $3 - optional PR description
create_pull_request() {
  # PSEUDOCODE:
  # - Check if GitHub CLI (gh) is available
  # - Validate branch exists and has commits
  # - Push branch to remote if not already pushed
  # - Generate PR title and description if not provided
  # - Create pull request using gh pr create
  # - Display PR URL and information
  echo "Create pull request implementation..."
}

# =============================================================================
# MAINTENANCE AND UTILITY FUNCTIONS
# =============================================================================

# Function: worktree_status([target])
# Purpose: Show detailed status of worktrees
# Parameters: $1 - optional specific worktree to check
worktree_status() {
  # PSEUDOCODE:
  # - For each worktree (or specified worktree):
  #   - Show git status (uncommitted changes, ahead/behind)
  #   - Display last commit information
  #   - Show disk usage
  #   - Check for stale branches
  # - Provide summary statistics
  echo "Worktree status implementation..."
}

# Function: cleanup_merged_worktrees()
# Purpose: Remove worktrees for branches that have been merged
cleanup_merged_worktrees() {
  # PSEUDOCODE:
  # - Identify branches that have been merged into main/master
  # - Find corresponding worktrees for these branches
  # - Confirm with user before deletion
  # - Remove worktrees and optionally delete branches
  # - Report cleanup results
  echo "Cleanup merged worktrees implementation..."
}

# Function: backup_worktree_config()
# Purpose: Backup worktree configuration and branch information
backup_worktree_config() {
  # PSEUDOCODE:
  # - Export list of current worktrees
  # - Save branch relationships and configurations
  # - Create restoration script
  # - Store in .git/worktree-backups/ directory
  echo "Backup worktree config implementation..."
}

# Function: restore_worktree_config(backup_file)
# Purpose: Restore worktrees from backup
# Parameters: $1 - backup file path
restore_worktree_config() {
  # PSEUDOCODE:
  # - Read backup configuration
  # - Recreate worktrees according to backup
  # - Restore branch configurations
  # - Report restoration results
  echo "Restore worktree config implementation..."
}

# =============================================================================
# COMMAND PARSING AND MAIN LOGIC
# =============================================================================

# Function: parse_global_options()
# Purpose: Parse global command line options
parse_global_options() {
  # PSEUDOCODE:
  # - Parse options like --verbose, --force, --help, --version
  # - Set global variables accordingly
  # - Handle configuration file options
  echo "Parse global options implementation..."
}

# Function: execute_command(command, args...)
# Purpose: Main command dispatcher
# Parameters: $1 - command name, $@ - command arguments
execute_command() {
  # PSEUDOCODE:
  # - Validate git repository (except for help/version commands)
  # - Route to appropriate function based on command
  # - Handle unknown commands gracefully
  # - Provide suggestions for similar commands
  echo "Execute command implementation..."
}

# =============================================================================
# MAIN ENTRY POINT
# =============================================================================

main() {
  # PSEUDOCODE:
  # - Parse global options
  # - Check for minimum requirements (git version, etc.)
  # - If no arguments provided, show help or interactive mode
  # - Extract command and arguments
  # - Execute appropriate command
  # - Handle errors and exit with appropriate code
  
  # Check if any arguments provided
  if [[ $# -eq 0 ]]; then
    display_help
    exit 0
  fi
  
  # Parse global options first
  parse_global_options "$@"
  
  # Extract command
  local command="$1"
  shift
  
  # Execute command
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
      echo "Run '$SCRIPT_NAME help' for usage information."
      exit 1
      ;;
  esac
}

# Execute main function with all arguments
main "$@"