# zprofile

# --- Hombrew ---
# Brew binary (Apple Silicon)
if [[ -f "/opt/homebrew/bin/brew" ]] then
 eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- PATH ---
export PATH="/usr/local/sbin:$PATH"
export PATH="/Users/francojc/.bin:$PATH" # custom scripts
export PATH="/Users/francojc/.local/bin:$PATH" # pipx

# --- ENVIRONMENT VARIABLES ---
export USER=$(whoami)
export HOSTNAME=$(hostname)
export EDITOR='nvim'
export PAGER='bat'
export MANPAGER="less -R"
export VISUAL='nvim'
export HOMEBREW_NO_ENV_HINTS=true
export LUA_CPATH=""

# --- ZSH ---
# ZSH plugins
export ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
export ZVM_KEYTIMEOUT=1 # 1 second

# --- SECRETS (from `pass`) ---
source ~/.variables.env

