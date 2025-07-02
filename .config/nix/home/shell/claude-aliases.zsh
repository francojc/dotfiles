# --- CLAUDE CODE SPECIALIZED ALIASES ---
# Leveraging allowedTools for focused AI-assisted workflows

# === Research & Academic Tools ===
# Academic paper research assistant
alias claude-research='claude -p --allowedTools "mcp__mcp-scholarly__*" "mcp__zotero__*" "WebSearch" "Read"'

# Literature review helper with Zotero integration
alias claude-litreview='claude -p "Help me with literature review" --allowedTools "mcp__zotero__*" "mcp__obsidian__*" "WebSearch"'

# Teaching assistant for Canvas
alias claude-teach='claude -p --allowedTools "mcp__canvas-api__*" "mcp__google_workspace__*" "Read" "Write"'

# === Note-Taking & Knowledge Management ===
# Obsidian note processor
alias claude-notes='claude -p --allowedTools "mcp__obsidian__*" "Read" "Write" "Grep"'

# Daily note generator
alias claude-daily='claude -p "Create daily note with agenda from calendar" --allowedTools "mcp__obsidian__create-note" "mcp__google_workspace__list_calendars" "mcp__google_workspace__get_events"'

# Research note linker
alias claude-link='claude -p "Find connections between notes" --allowedTools "mcp__obsidian__search-vault" "mcp__obsidian__read-note" "mcp__zotero__zotero_search_items"'

# === Code Analysis & Development ===
# Deep code analysis with sequential thinking
alias claude-analyze='claude -p --allowedTools "mcp__sequential-thinking__*" "Read" "Grep" "Glob" "mcp__zen__analyze"'

# Security audit specialist
alias claude-audit='claude -p "Security audit" --allowedTools "mcp__zen__secaudit" "Read" "Grep" "WebSearch"'

# Code documentation generator
alias claude-docgen='claude -p --allowedTools "mcp__zen__docgen" "Read" "Write" "MultiEdit"'

# Test generator
alias claude-test='claude -p "Generate tests" --allowedTools "mcp__zen__testgen" "Read" "Write" "Bash(npm test*)" "Bash(pytest*)"'

# === Git Workflow Helpers ===
# Smart commit helper
alias claude-commit='claude -p "Create commit" --allowedTools "Bash(git status)" "Bash(git diff*)" "Bash(git add*)" "Bash(git commit*)" "Read"'

# PR reviewer
alias claude-pr='claude -p "Review PR" --allowedTools "Bash(git log*)" "Bash(git diff*)" "Read" "mcp__zen__codereview"'

# Pre-commit validator
alias claude-precommit='claude -p --allowedTools "mcp__zen__precommit" "Bash(git status)" "Bash(git diff*)" "Read"'

# === Data & Project Management ===
# Airtable data assistant
alias claude-data='claude -p --allowedTools "mcp__airtable__*" "Read" "Write"'

# Google Workspace automation
alias claude-workspace='claude -p --allowedTools "mcp__google_workspace__*" "Read" "Write"'

# Project consultation with AI
alias claude-consult='claude -p --allowedTools "mcp__consult7__*" "mcp__Context7__*" "Read"'

# === Specialized Development Modes ===
# Debug-only mode (read-only investigation)
alias claude-debug='claude -p "Debug issue" --allowedTools "Read" "Grep" "Glob" "Bash(ls*)" "Bash(cat*)" "mcp__zen__debug"'

# Refactor assistant
alias claude-refactor='claude -p --allowedTools "mcp__zen__refactor" "Read" "MultiEdit" "Bash(npm test*)"'

# Architecture planner
alias claude-architect='claude -p --allowedTools "mcp__zen__planner" "mcp__sequential-thinking__*" "Read" "Glob"'

# === Context-Aware Helpers ===
# Library documentation lookup
alias claude-docs='claude -p "Find docs" --allowedTools "mcp__Context7__*" "WebSearch" "Read"'

# Multi-model consensus builder
alias claude-consensus='claude -p --allowedTools "mcp__zen__consensus" "mcp__sequential-thinking__*"'

# Challenge mode for critical thinking
alias claude-challenge='claude -p --allowedTools "mcp__zen__challenge" "Read" "WebSearch"'

# === Advanced Functions ===
# Function for custom tool combinations
claude-with() {
  local prompt="$1"
  shift
  claude -p "$prompt" --allowedTools "$@"
}

# Safe mode - only non-destructive tools
claude-safe() {
  claude -p "$1" --allowedTools "Read" "Grep" "Glob" "Bash(ls*)" "Bash(cat*)" "Bash(git status)" "Bash(git diff*)"
}

# Full development mode
claude-dev() {
  claude -p "$1" --allowedTools "Read" "Write" "MultiEdit" "Bash(*)" "mcp__zen__*"
}

# Quick code explainer (pipe code into it)
claude-explain() {
  if [ -t 0 ]; then
    # No pipe input, use file
    if [ -z "$1" ]; then
      echo "Usage: claude-explain <file> or pipe code | claude-explain"
      return 1
    fi
    cat "$1" | claude -p "Explain this code concisely"
  else
    # Pipe input
    claude -p "Explain this code concisely"
  fi
}

# Error analyzer (pipe errors into it)
claude-error() {
  claude -p "Explain this error and suggest solutions" --allowedTools "WebSearch" "Read"
}