# Z profile file

# --- Hombrew ---
# Brew binary (Apple Silicon)
if [[ -f "/opt/homebrew/bin/brew" ]] then
 eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ZSH fzf-tab
# If ~/.zsh/fzf-tab does not exist, clone the repository
if [ ! -d ~/.zsh/fzf-tab ]; then
    git clone https://github.com/Aloxaf/fzf-tab ~/.zsh/fzf-tab
fi
# ZSH alias-tips
# If ~/.zsh/alias-tips does not exist, clone the repository
if [ ! -d ~/.zsh/alias-tips ]; then
    git clone https://github.com/djui/alias-tips.git ~/.zsh/alias-tips
fi

# --- PATH ---
export PATH="/usr/local/sbin:$PATH"
export PATH="/Users/francojc/.bin:$PATH"

# --- ENVIRONMENT VARIABLES ---
export EDITOR='nvim'
export PAGER='bat'
export MANPAGER="sh -c 'col -b | bat -l man -p'"
export VISUAL='nvim'
export HOMEBREW_NO_ENV_HINTS=true
export LUA_CPATH=""

# --- ZSH ---
# ZSH plugins
export ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
export ZVM_KEYTIMEOUT=1 # 1 second

# --- NEOVIM R ---
export R_AUTO_START=true

# --- SECRETS (from `pass`) ---
source ~/.variables.env
