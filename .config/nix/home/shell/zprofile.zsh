# zprofile

# --- Hombrew ---
# Brew binary (Apple Silicon)
if [[ -f "/opt/homebrew/bin/brew" ]] then
 eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- PATH ---
export PATH="/usr/local/sbin:$PATH"
export PATH="/Users/jeridf/.bin:$PATH" # custom scripts
export PATH="/Users/jeridf/.local/bin:$PATH" # pipx

# --- ENVIRONMENT VARIABLES ---
export EDITOR='nvim'
export HOMEBREW_NO_ENV_HINTS=true
export HOSTNAME=$(hostname)
export LUA_CPATH=""
export MANPAGER="less -R"
export PAGER='bat'
export USER=$(whoami)
export VISUAL='nvim'
# export XDG_CONFIG_HOME="$HOME/.config"

# --- ZSH ---
# ZSH plugins
export ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
export ZVM_KEYTIMEOUT=1 # 1 second

# --- SECRETS (from `pass`) ---
source ~/.variables.env

