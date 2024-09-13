# --- ALIASES ---
# Nix aliases
alias switch='darwin-rebuild switch --flake ~/.config/nix'

alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'

alias ls='eza --almost-all --dereference --no-quotes --icons=auto --ignore-glob=".DS_Store"'
alias la='ls --long --almost-all --smart-group --time=changed --color-scale=age --time-style=relative --color-scale-mode=gradient --ignore-glob=".git|.DS_Store"'
alias lt='la --tree --level=2 --ignore-glob=".git|.DS_Store"'

alias fd="fd --hidden --exclude '.git'"

alias tree='tree -C'
alias cat='bat' # use bat instead of cat
alias df='duf' # use duf instead of df

# more verbose and interactive copy/move
alias cp='cp -iv'
alias mv='mv -iv'

# Better path display
alias path='echo -e ${PATH//:/\\n}'

 # Rerun last command with sudo
alias please='sudo $(fc -ln -1)'

# Taskwarrior aliases
alias tt='taskwarrior-tui'

# Homebrew aliases
alias buu='brew update && brew upgrade && brew cleanup && brew doctor'
alias bs='brew search'
alias bi='brew install'
alias bic='brew install --cask'
alias bc='brew cleanup'

# Git aliases
alias gss='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gl='git log --oneline --decorate --graph'
alias gba='git branch -a'
alias gd='git diff'
alias gdf='git diff --name-only'
alias gitit='gh browse > /dev/null 2>&1'

# Docker aliases
alias d='docker'
alias dr='docker run'
alias di='docker images -a'
alias dps='docker ps -a'

# Quarto aliases
alias q='quarto'
alias qp='quarto preview'
alias qph='quarto preview --to html'
alias qpp='quarto preview --to pdf'
alias qr='quarto render'
alias qrh='quarto render --no-clean --to html'
alias qrp='quarto render --no-clean --to pdf'
alias qpub='quarto publish gh-pages'

# Obsidian
alias on='cd /Users/francojc/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes && nvim'

# --- FUNCTIONS ---
# list directory contents after changing directory
function cd() {
    z "$@" && eza --almost-all --dereference --no-quotes --icons=auto --ignore-glob=".DS_Store"
}

# Neomutt
# function nm() {
#     mailsync && neomutt
#   }

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
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
