# ZSH configuration file
# ---
# ZSH autocomplete WARN: temporary fix for freezing terminal
source $(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# --- Keybindings for VS Code ---
bindkey -v

# --- HISTORY ---
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_ignore_space

# --- ALIASES ---
# General aliases
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

# Tmux aliases
alias t='tmux'
alias tn='tmux new -s'
alias ta='tmux attach -t'
alias td='tmux detach'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'

# Homebrew aliases
alias buu='brew update && brew upgrade && brew cleanup && brew doctor'
alias bs='brew search'
alias bi='brew install'
alias bic='brew install --cask'
alias bc='brew cleanup'

# Git aliases
alias gs='git status'
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

# Suffix aliases
# open md, txt, qmd, r files in Neovim
alias -s md=nvim
alias -s txt=nvim
alias -s qmd=nvim
alias -s r=nvim

# --- FUNCTIONS ---
# list directory contents after changing directory
function cd() {
    z "$@" && eza --almost-all --dereference --no-quotes --icons=auto --ignore-glob=".DS_Store"
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
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
# --- ZSH PLUGINS ---
# ZSH syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# ZSH completions
FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
# ZSH autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# ZSH fzf-tab
source $HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh

# ZSH alias-tips
source ~/.zsh/alias-tips/alias-tips.plugin.zsh
# ZSH vi-mode
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Load completions
# autoload -U compinit && compinit

zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
# WARN: temporary fix for freezing terminal
zstyle ':autocomplete:history-search-backward:*' list-lines 10

# Deduplicate entries in PATH
typeset -U PATH
export PATH

# Shell integrations
# --- THEFUCK ---
eval $(thefuck --alias)
# --- FZF ---
eval "$(fzf --zsh)"
# --- ZOXIDE ---
eval "$(zoxide init zsh)"
# --- OH-MY_POSH ---
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
    eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/bubbles.omp.yaml)"
fi
