# Minimal Nix package set for the Macs.
#
# Everything else (language servers, toolchains, media, mail, docs) lives on the
# Omarchy hosts. Several of these are also pulled in by Home Manager `programs.*`
# modules (fzf, starship, zoxide, atuin, direnv, carapace, tmux, git); they are
# listed here only when a shell alias or config calls them directly.
{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    bat
    bob-nvim # Neovim version manager (nvim itself comes from bob)
    duf # used by aliases.zsh
    eza
    fd
    fzf
    gh
    git
    home-manager
    jq
    just
    lazygit
    python312 # UV_PYTHON target (home/shell/default.nix)
    ripgrep
    tirith # shell init in zprofile calls it
    uv
    viu # ~/.bin/am album art
    # kitty.app (Home Manager Apps). lowPrio so the software-GL wrapper in
    # home/kitty.nix keeps owning bin/kitty.
    (lib.lowPrio kitty)
  ];
}
