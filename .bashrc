# ~/.bashrc -- managed by stow from ~/.dotfiles (edit it there).
#
# Omarchy's migrations leave a symlinked ~/.bashrc alone, so this file is safe
# to keep in the repo.

# Omarchy environment (OMARCHY_PATH + PATH). Needed even for non-interactive shells.
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# bob-managed Neovim (0.13) must precede /usr/bin/nvim (pacman 0.12).
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# If not running interactively, stop here.
[[ $- != *i* ]] && return

# Omarchy's aliases, functions and defaults. Don't edit those; override below.
source "$OMARCHY_PATH/default/bash/rc"

# --- Personal environment (does not override Omarchy's EDITOR, PAGER, BROWSER, ...) ---
export GCAL='-s 1 --iso-week-number=yes'
export KETCH_CONFIG="$HOME/.config/ketch/config.json"

# Vi editing mode, as in the zsh config (defaultKeymap viins).
set -o vi

# macOS clipboard names used by the shared aliases map to Wayland tools on Omarchy.
if command -v wl-copy &>/dev/null; then
  alias pbcopy='wl-copy'
  alias pbpaste='wl-paste'
fi

# --- Personal aliases, functions and helpers (~/.config/bash/*.bash, stowed from the repo) ---
for _f in aliases functions ai repo fzf; do
  [[ -r $HOME/.config/bash/$_f.bash ]] && source "$HOME/.config/bash/$_f.bash"
done
unset _f

# --- Shell integrations (bash equivalents of the zsh init lines) ---
# starship, zoxide, mise and fzf key bindings are initialised by Omarchy's rc.
command -v atuin &>/dev/null && eval "$(atuin init bash --disable-up-arrow)"
command -v carapace &>/dev/null && source <(carapace _carapace bash)
command -v direnv &>/dev/null && eval "$(direnv hook bash)"
command -v tirith &>/dev/null && eval "$(tirith init --shell bash)"

# Re-assert bob's Neovim first on PATH (Omarchy's rc and mise init can reorder PATH).
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
