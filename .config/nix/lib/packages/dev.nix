# Developer tools shared by every host. gh and lazygit are pacman-owned on
# Omarchy, so they are not here.
pkgs:
with pkgs; [
  age # Encryption
  cachix # Nix package cache
  carapace # Command-line completion
  codespell # Spell checker
  direnv # Environment manager (per-project shells)
  forgejo-cli # `fj` CLI for Forgejo
  nurl # Nix URL fetcher helper
  stow # Symlink manager
]
