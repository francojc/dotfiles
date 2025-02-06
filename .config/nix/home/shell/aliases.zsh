# --- ALIASES ---
# Nix aliases
# -- Uses hostname to determine the flake to switch to
# HACK: Allows unfree packages (temporary hack)
alias switch='NIXPKGS_ALLOW_UNFREE=1 darwin-rebuild switch --flake $(realpath ~/.config/nix)#$(hostname) --impure'

# Aider-chat aliases
alias aider-proj-high='aider --model r1 --editor-model v3 --architect --watch-files'
alias aider-proj-local='aider --model r1l --editor-model phi4 --architect --watch-files'

alias aider-helper-high='aider --model sonnet --no-git --watch-files'
alias aider-helper-mid='aider --model v3 --no-git --watch-files'
alias aider-helper-local='aider --model phi4 --no-git --watch-files'

alias aider-commit='aider --commit --weak-model phi4 --no-gitignore'

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

alias minicore='TERM=xterm-256color ssh jeridf@mac-minicore.tail5650e0.ts.net'
alias airborne='TERM=xterm-256color ssh francojc@macbook-airborne.tail5650e0.ts.net'

# Git aliases
alias gss='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias gba='git branch -a'
alias gco='git checkout'
alias gsw='git switch'
alias gd='git diff'
alias gdf='git diff --name-only'
alias gitit='gh browse > /dev/null 2>&1'

# Docker aliases
alias d='docker'
alias dr='docker run'
alias di='docker images -a'
alias dc='docker ps -a'

# Neovim aliases
alias v='nvim'

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
function cd() {
    z "$@" && eza --almost-all --dereference --no-quotes --icons=auto --ignore-glob=".DS_Store"
}

# Obsidian
function on() {
    if [ -z "$1" ]; then
        cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Notes/ && nvim
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
