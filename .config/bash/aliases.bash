# --- ALIASES (bash port of home/shell/aliases.zsh) ---
# Sourced from ~/.bashrc. Mac-only aliases (iCloud, Google Drive, darwin-rebuild,
# nixos-rebuild) are left out; Omarchy-only differences are noted inline.

# --- META ALIASES ---
alias gaclp='gaa && pi-commit && gpl && gp' # Git add, commit, pull, and push

# --- DIRECTORY NAVIGATION ---
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'

# --- FILE LISTING (eza) ---
alias ls='eza --dereference --no-quotes --icons=auto --color=auto --ignore-glob=".DS_Store"'
alias la='ls --almost-all'
alias ll='ls --long --time-style=relative --ignore-glob=.git'
alias lla='la --long --time-style=relative --ignore-glob=.git'
alias lt='ls --tree --level=2 --ignore-glob=.git'
alias llt='ll --tree --level=2 --ignore-glob=.git'
alias lat='lla --tree --level=2 --ignore-glob=.git'

# fd: include hidden files, skip .git
alias fd="fd --hidden --exclude '.git'"

# --- FILE UTILITIES ---
alias tree='tree -C'
alias cat='bat'
alias df='duf'

# Interactive copy/move/remove, verbose
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -v'

# One PATH entry per line
path() { printf '%s\n' "${PATH//:/$'\n'}"; }

# --- SSH ALIASES ---
# Hosts come from ssh_config (config.d/nix-managed.conf); plain `ssh <alias>` works.
alias minicore='ssh minicore'
alias airborne='ssh airborne'
alias rover='ssh rover'
alias proxmox='ssh proxmox'
alias services='ssh services'
alias media='ssh media'
alias homeassistant='ssh homeassistant'

# --- GIT ALIASES ---
alias lgit='lazygit'
alias gi='git init'
# gip / gmp (bin/) initialise and protect repos; see the repo's bin/ scripts.

alias ga='git add'
alias gaa='git add --all'
alias gba='git branch -a'

alias gsw='git switch'
alias gswc='git switch -c'
alias gcb='git checkout -b'
alias gco='git checkout'

alias gc='git commit -m'
alias gf='git fetch'
alias gb='gh browse > /dev/null 2>&1'
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"

alias gd='git diff'
alias gdf='git diff --name-only'
gdt() { nvim -f -c "DiffviewOpen $*"; } # Open Diffview for a revision or range
alias gmt='git mergetool'

alias gp='git push'
alias gpl='git pull'
alias gr='git remote -v'

alias grb='git rebase -i'
alias grh='git reset HEAD'
alias grhh='git reset --hard HEAD' # hard reset: use carefully

alias gss='git status'
alias gst='git stash'
alias gstp='git stash pop'

# --- TMUX ALIASES ---
alias tl='tmux list-sessions'
alias taa='tmux attach-session -t'
alias tka='tmux kill-session -t'
alias tko='tmux kill-server'

# --- EDITOR ALIASES ---
alias v='nvim'

# Obsidian notes
alias on='cd ~/Obsidian/Notes && nvim'
alias op='cd ~/Obsidian/Personal && nvim'

# --- QUARTO ALIASES ---
# Quarto comes from per-project flake devShells, not the global profile.
alias q='quarto'
alias qp='quarto preview'
alias qph='quarto preview --to html'
alias qpp='quarto preview --to pdf'
alias qr='quarto render'
alias qrh='quarto render --no-clean --to html'
alias qrp='quarto render --no-clean --to pdf'
alias qpub='quarto publish gh-pages'

# --- MAIL ---
alias mail='aerc -C ~/.config/aerc/aerc.conf -A ~/.config/aerc/accounts.conf -B ~/.config/aerc/binds.conf'

# --- KETCH ---
# Web + code + docs research (backend brave, code github)
alias ks='ketch search'
alias kss='ketch search --scrape --max-chars 8000 --trim'
alias kc='ketch code -b github'
alias kd='ketch docs --tokens 6000'
alias ksc='ketch scrape'
alias kx='pbpaste | ketch extract' # clipboard HTML -> markdown (pbpaste -> wl-paste, see .bashrc)
alias kdr='ketch doctor'
alias kcr='ketch crawl'

# --- NIX ---
# Switch the Omarchy Home Manager config from any directory. Mirrors the zsh
# alias in modules/arch/shell.nix (shellAliases); HM only generates zsh aliases.
alias nswitch='nix run home-manager/master -- switch -b backup --flake $HOME/.dotfiles/.config/nix#omarchy'

# --- MISC ---
alias last='fc -ln -1'
alias lastrun='fc -e -'

# macOS clipboard names used by the shared aliases map to Wayland tools on Omarchy.
if command -v wl-copy &>/dev/null; then
  alias pbcopy='wl-copy'
  alias pbpaste='wl-paste'
fi
