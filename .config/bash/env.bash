# --- ENV: PATH and exports (all shells, sourced before the interactive guard) ---
# Sourced from ~/.bashrc. Interactive-only settings belong in .bashrc, not here.

# bob-managed Neovim (0.13) must precede /usr/bin/nvim (pacman 0.12).
# Called twice from .bashrc: before Omarchy's rc and again at the end, because
# Omarchy's rc and mise activation can reorder PATH.
_pin_bob_nvim() {
  export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
}
_pin_bob_nvim

export GCAL='-s 1 --iso-week-number=yes'
export KETCH_CONFIG="$HOME/.config/ketch/config.json"
export FZF_DEFAULT_COMMAND="rg --files"
