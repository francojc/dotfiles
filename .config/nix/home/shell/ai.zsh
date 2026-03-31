# --- AI/LLM TOOL FUNCTIONS & ALIASES ---

# --- WORKFLOW ALIASES ---
# Workmux session management for quick workspace switching
alias wm='workmux'
alias wma='workmux add'
alias wmo='workmux open'
alias wml='workmux list'
alias wmm='workmux merge'
alias wmr='workmux remove'

# --- CLAUDE FUNCTIONS ---

# Secure Claude via ZAI API endpoint
# Usage: claudz [model_name] - defaults to glm-4.7
# Environment: ZAI_BASE_URL, ZAI_API_KEY must be set
claudz() {
  local model="${1:-glm-4.7}"
  env -u ANTHROPIC_API_KEY ANTHROPIC_BASE_URL="$ZAI_BASE_URL" ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY" ANTHROPIC_DEFAULT_SONNET_MODEL="$model" claude
}

# Secure Claude via GitHub Copilot API endpoint
# Usage: claudo [model_name] - defaults to claude-haiku-4.5
# Environment: GITHUB_COPILOT_BASE_URL, GITHUB_COPILOT_API_KEY must be set
claudo() {
  local model="${1:-claude-haiku-4.5}"
  env -u ANTHROPIC_API_KEY ANTHROPIC_BASE_URL=http://mac-minicore.gerbil-matrix.ts.net:4141 ANTHROPIC_AUTH_TOKEN="$GITHUB_COPILOT_API_KEY" ANTHROPIC_DEFAULT_SONNET_MODEL="$model" claude
}

# Headless Claude: apply targeted edits across files
# Usage: claude-edit "<prompt>"
claude-edit() {
  if [[ -z "$1" ]]; then
    echo "Usage: claude-edit \"<prompt>\""
    return 1
  fi
  claude -p "$1" \
    --allowedTools "Read,Edit,Glob,Grep,LS,Bash(git diff:*),Bash(git status:*),Bash(git log:*)"
}

# Headless Claude: multi-step operations with broader tool access
# Usage: claude-batch "<prompt>"
claude-batch() {
  if [[ -z "$1" ]]; then
    echo "Usage: claude-batch \"<prompt>\""
    return 1
  fi
  claude -p "$1" \
    --allowedTools "Read,Write,Edit,Glob,Grep,LS,WebFetch,WebSearch,Bash(git diff:*),Bash(git status:*),Bash(git log:*),Bash(git add:*)"
}

# --- AIDER ALIASES ---
alias aider-copilot='aider --openai-api-base "$GITHUB_COPILOT_BASE_URL" --openai-api-key "$GITHUB_COPILOT_API_KEY" --model openai/claude-haiku-4.5 --weak-model openai/gpt-4o --editor-model openai/gpt-4o'
alias aider-zai='aider --openai-api-base "$ZAI_BASE_URL" --openai-api-key "$ZAI_API_KEY" --model glm-4.7 --weak-model glm-4.7 --editor-model glm-4.7'
alias aider-ollama='aider --openai-api-base "http://localhost:11434/v1" --model ollama_chat/ministral-3:latest --weak-model ollama_chat/ministral-3:latest --editor-model ollama_chat/ministral-3:latest'
alias aider-commit='aider --openai-api-base "$GITHUB_COPILOT_BASE_URL" --openai-api-key "$GITHUB_COPILOT_API_KEY" --config $(realpath ~/.config/aider/commit.yml)'
