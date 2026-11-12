# --- ENV: PATH and exports (all shells, sourced before the interactive guard) ---
# Sourced from ~/.bashrc. Interactive-only settings belong in .bashrc, not here.

# Move (or add) a directory to the front of PATH without duplicating it, so
# nested shells (tmux, subshells) don't keep growing PATH.
_path_front() {
  local p=":$PATH:"
  p=${p//:"$1":/:}
  p=${p#:}; p=${p%:}
  PATH="$1${p:+:$p}"
  export PATH
}

# Drop repeated PATH entries, keeping the first (highest-priority) occurrence.
# `mise activate --shims` prepends without checking, so run this last.
_path_dedupe() {
  local -A seen=()
  local out= dir dirs
  IFS=: read -ra dirs <<<"$PATH"
  for dir in "${dirs[@]}"; do
    [[ -z $dir || -n ${seen[$dir]-} ]] && continue
    seen[$dir]=1
    out+=${out:+:}$dir
  done
  PATH=$out
  export PATH
}

# bob-managed Neovim (0.13) must precede /usr/bin/nvim (pacman 0.12).
# Called twice from .bashrc: before Omarchy's rc and again at the end, because
# Omarchy's rc and mise activation can reorder PATH.
_pin_bob_nvim() {
  _path_front "$HOME/.local/share/bob/nvim-bin"
}
_pin_bob_nvim

export GCAL='-s 1 --iso-week-number=yes'
export KETCH_CONFIG="$HOME/.config/ketch/config.json"
export FZF_DEFAULT_COMMAND="rg --files"

_path_front "$HOME/.bin"
