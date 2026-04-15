# --- ALIASES ---

# --- META ALIASES ---
# Git workflow shortcut - combines git add, commit, pull, and push operations
alias gaclp='gaa; aider-commit; gpl; gp;' # Git add, commit, pull, and push

# --- DIRECTORY NAVIGATION ---
# Basic directory navigation for quick path movement
alias ..='cd ..'        # Move up one directory level
alias ...='cd ../..'    # Move up two directory levels

alias c='clear'

# File listing with eza - enhanced file listing with icons and color
alias ls='eza --dereference --no-quotes --icons=auto --color=auto --ignore-glob=".DS_Store"'
alias la='ls --almost-all'
alias ll='ls --long --time-style=relative --ignore-glob=.git'
alias lla='la --long --time-style=relative --ignore-glob=.git'
alias lt='ls --tree --level=2 --ignore-glob=.git'
alias llt='ll --tree --level=2 --ignore-glob=.git'
alias lat='lla --tree --level=2 --ignore-glob=.git'

# Use fd instead of find - faster file searching
alias fd="fd --hidden --exclude '.git'"

# File utilities - enhanced command replacements
alias tree='tree -C'    # Colorized tree output
alias cat='bat'        # Use bat instead of cat for syntax highlighting
alias df='duf'         # Use duf instead of df for better disk usage display

# More verbose and interactive copy/move operations
alias cp='cp -iv'      # Interactive copy with verbose output
alias mv='mv -iv'      # Interactive move with verbose output
alias rm='rm -v'      # Remove with verbose output

# Better path display - shows PATH variable with newlines
alias path='echo -e ${PATH//:/\\n}'

# --- SSH ALIASES ---
# Individual aliases using ssh_connect() from functions.zsh
alias minicore='ssh_connect mac-minicore'
alias airborne='ssh_connect macbook-airborne francojc'
alias rover='ssh_connect mini-rover'
alias proxmox='ssh_connect minis-proxmox root'
alias services='ssh_connect core-services root'
alias media='ssh_connect media-services root'
alias pi-meta='ssh_connect pi-meta root'
alias pi-agents='ssh_connect pi-agents root'

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
alias gd='git diff'             # Show working tree diff
alias gdf='git diff --name-only'  # List changed files in diff
alias gdt='git difftool'        # Open Git difftool with nvimdiff
alias gdv='git dv'              # Open Diffview for a revision or range
alias gf='git fetch'            # Fetch from remotes
alias gb='gh browse > /dev/null 2>&1'
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias gmt='git mergetool'       # Open Diffview merge UI for conflicts
alias gp='git push'
alias gpl='git pull'
alias gr='git remote -v'        # Show remotes
alias grb='git rebase -i'       # Interactive rebase
alias grh='git reset HEAD'      # Unstage files
alias grhh='git reset --hard HEAD'  # Hard reset (use carefully!)
alias gss='git status'
alias gst='git stash'           # Quick stash
alias gstp='git stash pop'

# --- NIX ALIASES ---
alias dswitch='sudo darwin-rebuild switch --flake $(realpath ~/.config/nix)#$(hostname)'
alias nswitch='sudo nixos-rebuild switch --flake $(realpath ~/.config/nix)#$(hostname)'

# --- TMUX ALIASES ---
alias tl='tmux list-sessions'
alias taa=' tmux attach-session -t'
alias tka='tmux kill-session -t'
alias tko='tmux kill-server'

# --- EDITOR ALIASES ---
alias v='nvim'

# Obsidian notes
alias on='cd ~/Obsidian/Notes && nvim'
alias op='cd ~/Obsidian/Personal && nvim'

# --- QUARTO ALIASES ---
alias q='quarto'
alias qp='quarto preview'
alias qph='quarto preview --to html'
alias qpp='quarto preview --to pdf'
alias qr='quarto render'
alias qrh='quarto render --no-clean --to html'
alias qrp='quarto render --no-clean --to pdf'
alias qpub='quarto publish gh-pages'

# --- CLOUD ALIASES ---
alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'
alias gdrive='cd ~/Google\ Drive/My\ Drive/'

# --- MAIL ALIASES ---
alias mail='aerc -C ~/.config/aerc/aerc.conf -A ~/.config/aerc/accounts.conf -B ~/.config/aerc/binds.conf'

# --- MISC ---
alias last='fc -ln -1'
alias lastrun='fc -e -'
