# --- INTEGRATIONS: tool init lines (interactive shells only) ---
# Sourced from ~/.bashrc after Omarchy's rc, so starship, zoxide, mise and fzf
# key bindings are already set up there. Don't duplicate them here.

command -v atuin &>/dev/null && eval "$(atuin init bash --disable-up-arrow)"
command -v carapace &>/dev/null && source <(carapace _carapace bash)
command -v direnv &>/dev/null && eval "$(direnv hook bash)"

# tirith: under ble.sh, checks run from the PREEXEC hook in ~/.config/bash/blerc instead.
# Its DEBUG trap clashes with ble.sh and scans ble.sh internals, so skip it here.
if [[ -z ${BLE_VERSION-} ]] && command -v tirith &>/dev/null; then
  eval "$(tirith init --shell bash)"
fi
