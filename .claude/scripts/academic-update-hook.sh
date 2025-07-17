#!/bin/bash

# Academic Project Auto-Update Hook for Claude Code
# Automatically updates project documentation when Claude stops responding
# Only runs in academic project directories with CLAUDE.md and specs/ structure

set -euo pipefail

# Configuration
LOG_FILE="${HOME}/.claude/academic-hook.log"
HOOK_DISABLED_ENV="${ACADEMIC_HOOK_ENABLED:-true}"

# Logging function
log_message() {
  local message="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[${timestamp}] ${message}" >> "${LOG_FILE}"
}

# Check if hook is disabled via environment variable
check_hook_enabled() {
  if [[ "${HOOK_DISABLED_ENV,,}" == "false" ]]; then
    log_message "Hook disabled via ACADEMIC_HOOK_ENABLED=false"
    exit 0
  fi
}

# Detect if current directory is an academic project
is_academic_project() {
  # Check for CLAUDE.md file
  if [[ ! -f "CLAUDE.md" ]]; then
    return 1
  fi
  
  # Check for specs directory
  if [[ ! -d "specs" ]]; then
    return 1
  fi
  
  # Check for specs/progress.md file  
  if [[ ! -f "specs/progress.md" ]]; then
    return 1
  fi
  
  return 0
}

# Identify project type from CLAUDE.md content
get_project_type() {
  if [[ -f "CLAUDE.md" ]]; then
    # Look for project type indicators in CLAUDE.md
    if grep -qi "research\|methodology\|hypothesis\|data collection" "CLAUDE.md"; then
      echo "research"
    elif grep -qi "course\|teaching\|students\|learning\|pedagogical" "CLAUDE.md"; then
      echo "teaching"
    elif grep -qi "grant\|proposal\|funding\|sponsor" "CLAUDE.md"; then
      echo "grant"
    elif grep -qi "committee\|service\|governance\|meeting" "CLAUDE.md"; then
      echo "service"
    else
      echo "academic"
    fi
  else
    echo "unknown"
  fi
}

# Count git commits since last hook run
count_recent_commits() {
  local last_hook_file=".claude/last-hook-run"
  local commit_count=0
  
  if [[ -f "${last_hook_file}" ]]; then
    local last_run=$(cat "${last_hook_file}")
    if git rev-parse --git-dir > /dev/null 2>&1; then
      commit_count=$(git rev-list --count --since="${last_run}" HEAD 2>/dev/null || echo "0")
    fi
  else
    # First run - count commits from last 24 hours
    if git rev-parse --git-dir > /dev/null 2>&1; then
      commit_count=$(git rev-list --count --since="24 hours ago" HEAD 2>/dev/null || echo "0")
    fi
  fi
  
  echo "${commit_count}"
}

# Update last hook run timestamp
update_hook_timestamp() {
  local timestamp_file=".claude/last-hook-run"
  local current_time=$(date '+%Y-%m-%d %H:%M:%S')
  
  mkdir -p ".claude"
  echo "${current_time}" > "${timestamp_file}"
}

# Add session log entry to specs/progress.md
log_session_completion() {
  local project_type="$1"
  local commit_count="$2"
  local current_time=$(date '+%Y-%m-%d %H:%M:%S')
  
  # Create automated session log section if it doesn't exist
  if ! grep -q "## Automated Session Log" "specs/progress.md"; then
    echo "" >> "specs/progress.md"
    echo "## Automated Session Log" >> "specs/progress.md"
    echo "" >> "specs/progress.md"
  fi
  
  # Add session entry
  local commit_msg="(${commit_count} new commits since last update)"
  if [[ "${commit_count}" == "0" ]]; then
    commit_msg="(no new commits since last update)"
  elif [[ "${commit_count}" == "1" ]]; then
    commit_msg="(1 new commit since last update)"
  fi
  
  echo "- ${current_time} - Claude session completed ${commit_msg}" >> "specs/progress.md"
  
  log_message "Added session log to ${PWD}/specs/progress.md (${project_type} project, ${commit_count} commits)"
}

# Main execution function
main() {
  # Ensure log directory exists
  mkdir -p "$(dirname "${LOG_FILE}")"
  
  # Check if hook is enabled
  check_hook_enabled
  
  # Check if we're in an academic project directory
  if ! is_academic_project; then
    # Silent exit for non-academic projects
    exit 0
  fi
  
  # We're in an academic project - proceed with logging
  local project_type=$(get_project_type)
  local commit_count=$(count_recent_commits)
  
  # Log session completion
  log_session_completion "${project_type}" "${commit_count}"
  
  # Update hook timestamp
  update_hook_timestamp
  
  # Log successful completion
  log_message "Academic hook completed successfully in ${PWD} (${project_type} project)"
}

# Execute main function, catching any errors
if ! main "$@" 2>/dev/null; then
  # Silent failure - log error but don't disrupt Claude workflow
  log_message "Academic hook failed in ${PWD}: $?" 2>/dev/null || true
fi

exit 0