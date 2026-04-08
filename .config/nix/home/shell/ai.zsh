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
alias aider-copilot='aider --openai-api-base "$GITHUB_COPILOT_BASE_URL" --openai-api-key "$GITHUB_COPILOT_API_KEY" --model openai/claude-haiku-4.5 --weak-model openai/gpt-4o --editor-model openai/gpt-4o'
alias aider-zai='aider --openai-api-base "$ZAI_BASE_URL" --openai-api-key "$ZAI_API_KEY" --model glm-4.7 --weak-model glm-4.7 --editor-model glm-4.7'
alias aider-ollama='aider --openai-api-base "http://localhost:11434/v1" --model ollama_chat/ministral-3:latest --weak-model ollama_chat/ministral-3:latest --editor-model ollama_chat/ministral-3:latest'
alias aider-commit='aider --openai-api-base "$GITHUB_COPILOT_BASE_URL" --openai-api-key "$GITHUB_COPILOT_API_KEY" --config $(realpath ~/.config/aider/commit.yml)'
