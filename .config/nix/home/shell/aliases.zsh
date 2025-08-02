# --- ALIASES ---

# Meta-aliases
alias gaclp='gaa; aider-commit; gpl; gp;' # Git add, commit, pull, and push

# llm aliases
alias llmb='llm -t briefly' # uses the template 'briefly'

# Tmux aliases
alias tl='tmux list-sessions' # list all tmux sessions
alias taa=' tmux attach-session -t' # attach to a specific session
alias tka='tmux kill-session -t' # kill a specific session
alias tko='tmux kill-server' # kill all tmux sessions

# Attach to a tmux session or create a new one if none exists
t() {
  if [ $# -eq 0 ]; then
    tmux attach-session 2>/dev/null || tmux new-session
  else
    tmux attach-session -t "$1" 2>/dev/null || tmux new-session -s "$1"
  fi
}

# Nix aliases
# -- Uses hostname to determine the flake to switch to
alias dswitch='sudo darwin-rebuild switch --flake $(realpath ~/.config/nix)#$(hostname)'

alias nswitch='sudo nixos-rebuild switch --flake $(realpath ~/.config/nix)#$(hostname)'

# Aider-chat aliases
alias aider-proj='aider --model power --editor-model power --architect --watch-files'
alias aider-commit='aider --config $(realpath ~/.config/aider/commit.yml)'

# Aerc (mail)
alias mail='aerc -C ~/.config/aerc/aerc.conf -A ~/.config/aerc/accounts.conf -B ~/.config/aerc/binds.conf'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'

alias c='clear'

alias ls='eza --almost-all --dereference --no-quotes --icons=auto --ignore-glob=".DS_Store"'
alias la='eza --icons=auto --long --almost-all --smart-group --time=changed --color-scale=age --time-style=relative --color-scale-mode=gradient --ignore-glob=".git|.DS_Store"'
alias lt='la icons=auto --tree --level=2 --ignore-glob=".git|.DS_Store"'

# Use fd instead of find
alias fd="fd --hidden --exclude '.git'"

alias tree='tree -C'
alias cat='bat' # use bat instead of cat
alias df='duf' # use duf instead of df

# More verbose and interactive copy/move
alias cp='cp -iv'
alias mv='mv -iv'

# Better path display
alias path='echo -e ${PATH//:/\\n}'

# SSH aliases
alias minicore='TERM=xterm-256color ssh jeridf@mac-minicore'
alias airborne='TERM=xterm-256color ssh francojc@macbook-airborne'
alias home='TERM=xterm-256color ssh root@home'
alias docker-lxc='TERM=xterm-256color ssh jeridf@docker-lxc'

# Git aliases
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
alias gitit='gh browse > /dev/null 2>&1'
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias gmt='git mergetool'       # Use your configured nvimdiff for conflicts
alias gp='git push'
alias gpl='git pull'
alias grh='git reset HEAD'      # Unstage files
alias grhh='git reset --hard HEAD'  # Hard reset (use carefully!)
alias gss='git status'
alias gst='git stash'           # Quick stash
alias gstp='git stash pop'      # Quick stash pop

# Neovim aliases
alias v='NVIM_APPNAME="nvim" nvim'
alias b='NVIM_APPNAME="nvim-basic" nvim'

# Quarto aliases
alias q='quarto'
alias qp='quarto preview'
alias qph='quarto preview --to html'
alias qpp='quarto preview --to pdf'
alias qr='quarto render'
alias qrh='quarto render --no-clean --to html'
alias qrp='quarto render --no-clean --to pdf'
alias qpub='quarto publish gh-pages'

# --- FUNCTIONS ---
# list directory contents after changing directory
function zl() {
  z "$@" && eza --almost-all --dereference --no-quotes --icons=auto --ignore-glob=".DS_Store"
}

# Make and change to a directory
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Open iCloud Drive
function icloud() {
  if [ -z "$1" ]; then
    cd ~/Library/Mobile\ Documents/
  else
    cd "$1"
  fi
}

# Obsidian
# Notes
function on() {
  if [ -z "$1" ]; then
    cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Notes/ && nvim
  else
    cd "$1" && nvim
  fi
}
# Personal
function op() {
  if [ -z "$1" ]; then
    cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Personal/ && nvim
  else
    cd "$1" && nvim
  fi
}

# Last command related aliases
alias last='fc -ln -1'  # Print last command
alias lastrun='fc -e -'  # Re-execute last command

# Recall last command output
function r() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: r [PATTERN] [-p]"
    echo "Recall last command output and copy to clipboard"
    echo
    echo "Options:"
    echo "  PATTERN     Filter output using pattern"
    echo "  -p          Print to stdout instead of copying to clipboard"
    echo "  --help, -h  Show this help message"
    return 0
  fi

  if [ -z "$1" ]; then
    if [ "$2" = "-p" ]; then
      fc -ln -1  # Print to stdout with -p flag
    else
      fc -ln -1 | pbcopy
    fi
  else
    if [ "$2" = "-p" ]; then
      fc -ln -1 | grep "$1"  # Print to stdout with -p flag
    else
      fc -ln -1 | grep "$1" | pbcopy
    fi
  fi
}


# Setup qtree (Quick Tree) command
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
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
