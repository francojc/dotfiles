# --- OMARCHY RC, ble.sh-aware (replaces `source $OMARCHY_PATH/default/bash/rc`) ---
# Mirrors /usr/share/omarchy/default/bash/rc and its `init`, with three changes
# that matter under ble.sh. After Omarchy updates, re-check upstream for drift:
#   cat $OMARCHY_PATH/default/bash/{rc,init}
#
#   1. inputrc is NOT bound here; .bashrc binds it before ble.sh loads, where
#      it costs ~0.2 ms instead of ~40 ms of ble readline emulation.
#   2. fzf key bindings use ble's native integration (~1 ms vs ~50-90 ms).
#   3. mise uses shims mode: no per-prompt `mise hook-env` (~15-25 ms/prompt).
#      Fine while no project uses mise.toml/.tool-versions; switch back to plain
#      `mise activate bash` if you start relying on per-directory versions or env.

: "${OMARCHY_PATH:=/usr/share/omarchy}"
_om=$OMARCHY_PATH/default/bash

source "$_om/envs"
source "$_om/shell"
source "$_om/aliases"
source "$_om/functions"

# --- init (adapted from $_om/init) ---
if command -v mise &>/dev/null; then
  eval "$(mise activate bash --shims)"
fi

if [[ ${TERM:-} != "dumb" ]] && command -v starship &>/dev/null; then
  eval "$(starship init bash --print-full-init)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

if command -v try &>/dev/null; then
  try() {
    unset -f try
    eval "$(SHELL=/bin/bash command try init ~/Work/tries)"
    try "$@"
  }
fi

# Key bindings only (Ctrl-T, Alt-C; atuin takes Ctrl-R later).
if command -v fzf &>/dev/null; then
  if [[ ${BLE_VERSION-} ]]; then
    ble-import -d integration/fzf-key-bindings
  elif [[ -f /usr/share/fzf/key-bindings.bash ]]; then
    source /usr/share/fzf/key-bindings.bash
  fi
fi

source "$_om/completions"

unset _om
