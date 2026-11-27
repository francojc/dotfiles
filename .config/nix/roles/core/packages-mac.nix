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
    pass # password store (~/.password-store; gpg-agent via roles/core/gpg.nix)
    python312 # UV_PYTHON target (home/shell/default.nix)
    ripgrep
    tirith # shell init in zprofile calls it
    uv
    viu # ~/.bin/am album art
    yazi-unwrapped # file manager (same as Arch: lib/packages/cli.nix); config in ~/.config/yazi
    # kitty.app (Home Manager Apps). lowPrio so the software-GL wrapper in
    # home/kitty.nix keeps owning bin/kitty.
    (lib.lowPrio kitty)
  ];

  # Copy .app bundles into ~/Applications/Home Manager Apps instead of
  # symlinking them into /nix/store: Spotlight, Launchpad and Finder's
  # Applications view ignore symlinked apps. (HM only defaults to copyApps
  # for stateVersion >= 25.11; ours is 24.05.) First switch needs App
  # Management permission for the terminal running it.
  targets.darwin.linkApps.enable = false;
  targets.darwin.copyApps.enable = true;
}
