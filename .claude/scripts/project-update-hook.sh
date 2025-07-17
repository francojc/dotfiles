#!/bin/bash

# Generic Project Update Hook for Claude Code
# Automatically updates project documentation when Claude stops responding
# Works with any project that has CLAUDE.md or uses Claude commands

# Removed set -e for better error handling

# Configuration
LOG_FILE="${HOME}/.claude/project-hook.log"
HOOK_DISABLED_ENV="${PROJECT_HOOK_ENABLED:-true}"

# Logging function
log_message() {
  local message="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[${timestamp}] ${message}" >> "${LOG_FILE}"
}

# Check if hook is disabled via environment variable
check_hook_enabled() {
  if [[ "${HOOK_DISABLED_ENV,,}" == "false" ]]; then
    log_message "Hook disabled via PROJECT_HOOK_ENABLED=false"
    exit 0
  fi
}

# Detect if current directory has project structure
is_project_directory() {
  # Check for CLAUDE.md file
  if [[ -f "CLAUDE.md" ]]; then
    return 0
  fi
  
  # Check for .claude/commands directory (custom commands)
  if [[ -d ".claude/commands" ]]; then
    return 0
  fi
  
  # Check for specs directory (academic projects)
  if [[ -d "specs" ]]; then
    return 0
  fi
  
  return 1
}

# Identify project type from available indicators
get_project_type() {
  local project_type="generic"
  
  if [[ -f "CLAUDE.md" ]]; then
    # Look for project type indicators in CLAUDE.md
    if grep -qi "research\|methodology\|hypothesis\|data collection" "CLAUDE.md"; then
      project_type="research"
    elif grep -qi "course\|teaching\|students\|learning\|pedagogical" "CLAUDE.md"; then
      project_type="teaching"
    elif grep -qi "grant\|proposal\|funding\|sponsor" "CLAUDE.md"; then
      project_type="grant"
    elif grep -qi "committee\|service\|governance\|meeting" "CLAUDE.md"; then
      project_type="service"
    elif grep -qi "development\|software\|application\|code" "CLAUDE.md"; then
      project_type="development"
    fi
  fi
  
  echo "${project_type}"
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

# Log session completion to appropriate file
log_session_completion() {
  local project_type="$1"
  local commit_count="$2"
  local current_time=$(date '+%Y-%m-%d %H:%M:%S')
  local log_file=""
  
  # Determine where to log based on project structure
  if [[ -f "specs/progress.md" ]]; then
    log_file="specs/progress.md"
  elif [[ -f "PROGRESS.md" ]]; then
    log_file="PROGRESS.md"
  elif [[ -f "CHANGELOG.md" ]]; then
    log_file="CHANGELOG.md"
  else
    # Create a simple session log file
    log_file=".claude/session-log.md"
    if [[ ! -f "${log_file}" ]]; then
      mkdir -p ".claude"
      echo "# Claude Session Log" > "${log_file}"
      echo "" >> "${log_file}"
    fi
  fi
  
  # Create automated session log section if it doesn't exist
  if ! grep -q "## Automated Session Log\|## Session Log" "${log_file}"; then
    echo "" >> "${log_file}"
    echo "## Automated Session Log" >> "${log_file}"
    echo "" >> "${log_file}"
  fi
  
  # Add session entry
  local commit_msg="(${commit_count} new commits since last update)"
  if [[ "${commit_count}" == "0" ]]; then
    commit_msg="(no new commits since last update)"
  elif [[ "${commit_count}" == "1" ]]; then
    commit_msg="(1 new commit since last update)"
  fi
  
  echo "- ${current_time} - Claude session completed ${commit_msg}" >> "${log_file}"
  
  log_message "Added session log to ${PWD}/${log_file} (${project_type} project, ${commit_count} commits)"
}

# Main execution function
main() {
  # Ensure log directory exists
  mkdir -p "$(dirname "${LOG_FILE}")"
  
  # Check if hook is enabled
  check_hook_enabled
  
  # Check if we're in a project directory
  if ! is_project_directory; then
    # Silent exit for non-project directories
    exit 0
  fi
  
  # We're in a project directory - proceed with logging
  local project_type=$(get_project_type)
  local commit_count=$(count_recent_commits)
  
  # Log session completion
  log_session_completion "${project_type}" "${commit_count}"
  
  # Update hook timestamp
  update_hook_timestamp
  
  # Log successful completion
  log_message "Project hook completed successfully in ${PWD} (${project_type} project)"
}

# Execute main function, catching any errors
main "$@" 2>/dev/null || {
  # Silent failure - log error but don't disrupt Claude workflow
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Project hook failed in ${PWD}: $?" >> "${HOME}/.claude/project-hook.log" 2>/dev/null || true
}

exit 0