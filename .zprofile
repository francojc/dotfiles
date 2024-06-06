# Z profile file

# --- Hombrew ---
# Brew binary (Apple Silicon)
if [[ -f "/opt/homebrew/bin/brew" ]] then
 eval "$(/opt/homebrew/bin/brew shellenv)"
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

# --- SECRETS (from `pass`) ---
source ~/.variables.env
