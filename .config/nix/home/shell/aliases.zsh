# --- ALIASES ---

# --- META ALIASES ---
# Git workflow shortcut - combines git add, commit, pull, and push operations
alias gaclp='gaa; aider-commit; gpl; gp;' # Git add, commit, pull, and push

# --- AI/LLM ALIASES ---
# llm template shortcuts for quick text processing
alias llmb='llm -t briefly' # uses the template 'briefly' for concise summaries
alias llms='llm -t summarize' # uses the template 'summarize' for detailed summaries

# --- WORKFLOW ALIASES ---
# Workmux session management for quick workspace switching
alias wm='workmux'

# Secure Claude function that uses ZAI API endpoint (requires ZAI_BASE_URL and ZAI_API_KEY env vars)
# Usage: claudz [model_name] - defaults to glm-4.6v if no model specified
# Environment: ZAI_BASE_URL, ZAI_API_KEY must be set
claudz() {
  local model="${1:-glm-4.7}"
  env -u ANTHROPIC_API_KEY ANTHROPIC_BASE_URL="$ZAI_BASE_URL" ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY" ANTHROPIC_DEFAULT_SONNET_MODEL="$model" claude
}

# Secure Claude function that uses GitHub Copilot API endpoint (requires GITHUB_COPILOT_BASE_URL and GITHUB_COPILOT_API_KEY env vars)
# Usage: claudo [model_name] - defaults to gpt-4o if no model specified
# Environment: GITHUB_COPILOT_BASE_URL, GITHUB_COPILOT_API_KEY must be set
claudo() {
  local model="${1:-gpt-4.1}"
  env -u ANTHROPIC_API_KEY ANTHROPIC_BASE_URL=http://mac-minicore.gerbil-matrix.ts.net:4141 ANTHROPIC_AUTH_TOKEN="$GITHUB_COPILOT_API_KEY" ANTHROPIC_DEFAULT_SONNET_MODEL="$model" claude
}

# --- TMUX ALIASES ---
# Tmux session management for terminal multiplexing
alias tl='tmux list-sessions' # list all tmux sessions
alias taa=' tmux attach-session -t' # attach to a specific session
alias tka='tmux kill-session -t' # kill a specific session
alias tko='tmux kill-server' # kill all tmux sessions

# Attach to a named tmux session (1-based); create if absent
# Usage: t [session_name] - creates or attaches to session
t() {
  if [ $# -eq 0 ]; then
    tmux new-session -As 1
  else
    tmux new-session -As "$1"
  fi
}

# --- NIX ALIASES ---
# System rebuild commands - uses hostname to determine the flake to switch to
# Usage: dswitch - rebuilds Darwin system configuration
alias dswitch='sudo darwin-rebuild switch --flake $(realpath ~/.config/nix)#$(hostname)'

# Usage: nswitch - rebuilds NixOS system configuration
alias nswitch='sudo nixos-rebuild switch --flake $(realpath ~/.config/nix)#$(hostname)'

# --- AIDER ALIASES ---
# AI coding assistant configurations for code generation and review
# Usage: aider-copilot - uses GitHub Copilot API
alias aider-copilot='aider --openai-api-base "$GITHUB_COPILOT_BASE_URL" --openai-api-key "$GITHUB_COPILOT_API_KEY"'
# Usage: aider-zai - uses ZAI API with glm-4.6 model
alias aider-zai='aider --openai-api-base "$ZAI_BASE_URL" --openai-api-key "$ZAI_API_KEY" --model glm-4.6'
# Usage: aider-commit - specialized for commit message generation
alias aider-commit='aider --openai-api-base "$GITHUB_COPILOT_BASE_URL" --openai-api-key "$GITHUB_COPILOT_API_KEY" --config $(realpath ~/.config/aider/commit.yml)' # Note: uses the `aider-copilot` command in ~/.bin/ to access the GitHub Copilot api

# --- MAIL ALIASES ---
# Aerc email client configuration with custom config files
# Usage: mail - launches Aerc email client with configured settings
alias mail='aerc -C ~/.config/aerc/aerc.conf -A ~/.config/aerc/accounts.conf -B ~/.config/aerc/binds.conf'

# --- DIRECTORY NAVIGATION ---
# Basic directory navigation for quick path movement
alias ..='cd ..'        # Move up one directory level
alias ...='cd ../..'    # Move up two directory levels

alias c='clear'

# File listing with eza - enhanced file listing with icons and color
alias ls='eza --almost-all --dereference --no-quotes --icons=auto --ignore-glob=".DS_Store"' # List files with icons, excluding .DS_Store
alias la='eza --icons=auto --long --almost-all --smart-group --time=changed --color-scale=age --time-style=relative --color-scale-mode=gradient --ignore-glob=".git|.DS_Store"' # Detailed list with smart grouping
alias lt='la --icons=auto --tree --level=2 --ignore-glob=".git|.DS_Store"' # Tree view of current directory

# Use fd instead of find - faster file searching
alias fd="fd --hidden --exclude '.git'"

# File utilities - enhanced command replacements
alias tree='tree -C'    # Colorized tree output
alias cat='bat'        # Use bat instead of cat for syntax highlighting
alias df='duf'         # Use duf instead of df for better disk usage display

# More verbose and interactive copy/move operations
alias cp='cp -iv'      # Interactive copy with verbose output
alias mv='mv -iv'      # Interactive move with verbose output

# Better path display - shows PATH variable with newlines
alias path='echo -e ${PATH//:/\\n}'

# --- SSH ALIASES (CONSOLIDATED) ---
# SSH Aliases - Consolidated with parameterized function
# Usage: ssh_connect [host] [user] - connects to SSH server with optional user override
ssh_connect() {
  local host="$1"
  local user="$2"
  [ -z "$user" ] && user="jeridf"
  TERM=xterm-256color ssh "$user@$host"
}

# Individual aliases (preserve for backward compatibility)
# Usage: minicore - connect to mac-minicore
alias minicore='ssh_connect mac-minicore'
# Usage: airborne - connect to macbook-airborne with francojc user
alias airborne='ssh_connect macbook-airborne francojc'
# Usage: rover - connect to mini-rover
alias rover='ssh_connect mini-rover'
# Usage: proxmox - connect to minis-proxmox with root user
alias proxmox='ssh_connect minis-proxmox root'
# Usage: services - connect to minis-services
alias services='ssh_connect minis-services'
# Usage: ai - connect to minis-ai
alias ai='ssh_connect minis-ai'

# --- GIT ALIASES ---
# Git workflow shortcuts
alias ga='git add'
alias gaa='git add --all'
alias gba='git branch -a'

alias gsw='git switch'
alias gswc='git switch -c'      # Create and switch to new branch (newer syntax)
alias gcb='git checkout -b'     # Create and switch to new branch
alias gco='git checkout'

alias gc='git commit -m'
alias gd='git diff'
alias gdf='git diff --name-only'
alias gdt='git difftool'        # Use your configured nvimdiff
alias gf='git fetch'
alias gb='gh browse > /dev/null 2>&1'
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias gmt='git mergetool'       # Use your configured nvimdiff for conflicts
alias gp='git push'
alias gpl='git pull'
alias gr='git remote -v'        # Show remotes
alias grb='git rebase -i'       # Interactive rebase
alias grh='git reset HEAD'      # Unstage files
alias grhh='git reset --hard HEAD'  # Hard reset (use carefully!)
alias gss='git status'
alias gst='git stash'           # Quick stash
alias gstp='git stash pop'

# --- EDITOR ALIASES ---
# Neovim shortcuts for quick editing
alias v='nvim'                             # Open Neovim
# alias b='NVIM_APPNAME="nvim-dev" nvim-dev'  # Alternative Neovim instance (commented out)

# Obsidian notes
alias on='cd ~/Obsidian/Notes && nvim'
alias op='cd ~/Obsidian/Personal && nvim'

# --- QUARTO ALIASES ---
# Academic publishing tools for creating and rendering documents
alias q='quarto'                              # Main Quarto command
alias qp='quarto preview'                      # Preview current document
alias qph='quarto preview --to html'           # Preview as HTML
alias qpp='quarto preview --to pdf'            # Preview as PDF
alias qr='quarto render'                      # Render current document
alias qrh='quarto render --no-clean --to html' # Render as HTML without cleaning
alias qrp='quarto render --no-clean --to pdf'  # Render as PDF without cleaning
alias qpub='quarto publish gh-pages'           # Publish to GitHub Pages

# --- CLOUD ALIASES ---
# iCloud
alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'
# Google Drive
alias gdrive='cd ~/Google\ Drive/My\ Drive/'

# Last command related aliases
# Reminder: `fc` is a built-in Zsh command to edit the last command in $EDITOR
alias last='fc -ln -1'  # Print last command
alias lastrun='fc -e -'  # Re-execute last command

# --- FUNCTIONS ---
# list directory contents after changing directory
# Usage: zl [path] - changes directory and lists contents with eza
function zl() {
  z "$@" && eza --almost-all --dereference --no-quotes --icons=auto --ignore-glob=".DS_Store"
}

# Make and change to a directory
# Usage: mkcd [directory] - creates directory and changes to it
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Recall last command output - Simplified
# Usage: r [PATTERN] [-p] - recalls last command output with optional filtering
function r() {
  local pattern="$1"
  local print_only="$2"

  # Help output
  if [[ "$pattern" == "--help" || "$pattern" == "-h" ]]; then
    echo "Usage: r [PATTERN] [-p]"
    echo "Recall last command output and copy to clipboard"
    echo
    echo "Options:"
    echo "  PATTERN     Filter output using pattern"
    echo "  -p          Print to stdout instead of copying to clipboard"
    echo "  --help, -h  Show this help message"
    return 0
  fi

  # Determine output method
  local output_cmd="pbcopy"
  if [[ "$print_only" == "-p" ]]; then
    output_cmd="cat"
  fi

  # Execute command
  if [ -z "$pattern" ]; then
    fc -ln -1 | $output_cmd
  else
    fc -ln -1 | grep "$pattern" | $output_cmd
  fi
}


# Setup qtree (Quick Tree) command
# Usage: qtree [directory] [depth] - lists directory tree with custom depth
# - first argument is the directory to list (default is current directory)
# - second argument is the -L value (default is 2)
function qtree() {
  if [ -z "$1" ]; then
    DIR="."
  else
    DIR=$1
  fi
  if [ -z "$2" ]; then
    L=2
  else
    L=$2
  fi
  command tree $DIR -L $L -CF
}

# -- Setup yazi (Yet Another Zoxide Integration) command
# Usage: y [arguments] - opens yazi file manager with directory navigation
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
