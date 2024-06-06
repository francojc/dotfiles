# ZSH configuration file

# --- FZF ---
eval "$(fzf --zsh)"

# --- Keybindings for VS Code ---
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-whole-line
bindkey '^U' backward-kill-line
bindkey '^Y' yank
bindkey '^[[1;3D' backward-word # ctrl + left arrow
bindkey '^[[1;3C' forward-word # ctrl + right arrow (not working)
bindkey '^[[A' up-line-or-history # up arrow
bindkey '^[[B' down-line-or-history # down arrow

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
alias ls='lsd -1A --group-dirs=first --hyperlink=auto' # use lsd instead of ls
alias ll='ls -G'
alias la='ls -1alG'

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

# Homebrew aliases
alias buu='brew update && brew upgrade && brew cleanup && brew doctor'
alias bs='brew search'
alias bi='brew install'
alias bic='brew install --cask'
alias bc='brew cleanup'

# Git aliases
alias gs='git status'
alias gaa='git add --all'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gl='git log --oneline --decorate --graph'
alias gba='git branch -a'
alias gitit='gh browse > /dev/null 2>&1'

# Docker aliases
alias d='docker'

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
# open md, txt, qmd, r files in VS Code
alias -s md=code
alias -s txt=code
alias -s qmd=code
alias -s r=code

# --- FUNCTIONS ---
# list directory contents after changing directory
function cd() {
    builtin cd "$@" && ll
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

# --- ZSH PLUGINS ---
# ZSH autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# ZSH syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# ZSH history substring search
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh
# ZSH autocomplete
source $(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# ZSH alias-tips
# source ~/.zsh/alias-tips/alias-tips.plugin.zsh

# Deduplicate entries in PATH
typeset -U PATH
export PATH

# --- STARSHIP PROMPT ---
eval "$(starship init zsh)"
