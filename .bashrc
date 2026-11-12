# ~/.bashrc -- managed by stow from ~/.dotfiles (edit it there).
#
# Phase-ordered loader. Order matters; don't reshuffle without reading the notes.
#   1. Omarchy env + PATH        (non-interactive safe)
#   2. ~/.config/bash/env.bash   (PATH pin, exports)
#   3. Interactive guard
#   4. Omarchy inputrc, then ble.sh --attach=none (ble before Omarchy so Starship hooks in;
#      inputrc before ble because ble's readline emulation makes `bind -f` ~200x slower)
#   5. Omarchy rc, ble-aware copy (~/.config/bash/omarchy.bash)
#   6. Personal aliases/functions/tools
#   7. Integrations (atuin, carapace, direnv, tirith)
#   8. Re-pin PATH, then ble-attach last (wraps the final prompt setup)

# --- 1. Omarchy environment (needed even for non-interactive shells) ---
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# --- 2. Personal env and PATH ---
source "$HOME/.config/bash/env.bash"

# --- 3. Stop here for non-interactive shells ---
[[ $- != *i* ]] && return

# --- 4. ble.sh line editor (AUR blesh-git 0.4+; Starship needs _ble_version >= 400) ---
# Hooks (tirith PREEXEC, vi cursor) live in ~/.config/bash/blerc.
bind -f "$OMARCHY_PATH/default/bash/inputrc"
if [[ -r /usr/share/blesh/ble.sh ]]; then
  source /usr/share/blesh/ble.sh --attach=none --rcfile="$HOME/.config/bash/blerc"
fi

# --- 5. Omarchy's aliases, functions and defaults. Don't edit those; override below. ---
# Local copy of $OMARCHY_PATH/default/bash/rc tuned for ble.sh; see its header.
source "$HOME/.config/bash/omarchy.bash"

# --- 6. Interactive options and personal modules ---
set -o vi

for _f in aliases functions ai repo fzf; do
  [[ -r $HOME/.config/bash/$_f.bash ]] && source "$HOME/.config/bash/$_f.bash"
done
unset _f

# --- 7. Tool integrations ---
[[ -r $HOME/.config/bash/integrations.bash ]] && source "$HOME/.config/bash/integrations.bash"

# --- 8. Final PATH pin, then attach ble.sh ---
_pin_bob_nvim
_path_dedupe
unset -f _pin_bob_nvim _path_front _path_dedupe
if [[ ${BLE_VERSION-} ]]; then
  ble-attach
fi
