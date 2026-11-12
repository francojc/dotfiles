# --- INTEGRATIONS: tool init lines (interactive shells only) ---
# Sourced from ~/.bashrc after Omarchy's rc, so starship, zoxide, mise and fzf
# key bindings are already set up there. Don't duplicate them here.

# Under ble.sh, skip atuin's bundled bash-preexec (~40-70 ms) and let ble's
# integration drive precmd_functions/preexec_functions instead. ble only
# auto-loads that integration when bash-preexec is present, so import it here.
if command -v atuin &>/dev/null; then
  if [[ ${BLE_VERSION-} ]]; then
    ATUIN_NO_BUILTIN_PREEXEC=1
    ble-import contrib/integration/bash-preexec
  fi
  eval "$(atuin init bash --disable-up-arrow)"
  unset ATUIN_NO_BUILTIN_PREEXEC
fi
command -v carapace &>/dev/null && source <(carapace _carapace bash)
command -v direnv &>/dev/null && eval "$(direnv hook bash)"

# tirith: under ble.sh, checks run from the PREEXEC hook in ~/.config/bash/blerc instead.
# Its DEBUG trap clashes with ble.sh and scans ble.sh internals, so skip it here.
if [[ -z ${BLE_VERSION-} ]] && command -v tirith &>/dev/null; then
  eval "$(tirith init --shell bash)"
fi
