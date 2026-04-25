# --- AI/LLM TOOL FUNCTIONS & ALIASES ---

# --- WORKFLOW ALIASES ---
# Workmux session management for quick workspace switching
alias wm='workmux'
alias wma='workmux add'
alias wmo='workmux open'
alias wml='workmux list'
alias wmm='workmux merge'
alias wmr='workmux remove'

# --- AIDER ALIASES ---
alias aider-commit='aider --openai-api-base "$GITHUB_COPILOT_BASE_URL" --openai-api-key "$GITHUB_COPILOT_API_KEY" --config $(realpath ~/.config/aider/commit.yml)'
