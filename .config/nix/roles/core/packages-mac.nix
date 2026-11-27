# Minimal Nix package set for the Macs.
#
# Everything else (language servers, toolchains, media, mail, docs) lives on the
# Omarchy hosts. Several of these are also pulled in by Home Manager `programs.*`
# modules (fzf, starship, zoxide, atuin, direnv, carapace, tmux, git); they are
# listed here only when a shell alias or config calls them directly.
{pkgs, ...}: {
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
  ];
  # GUI apps (kitty, Caffeine) are Homebrew casks in profiles/darwin/minimal.nix:
  # they land in /Applications, which Spotlight indexes reliably.

  # Copy (not symlink) any Nix .app bundles into ~/Applications/Home Manager
  # Apps. No GUI apps come from Nix right now, so the directory stays empty;
  # copyApps (rsync --delete) also cleans out the old kitty/Caffeine copies.
  # HM only defaults to copyApps for stateVersion >= 25.11; ours is 24.05.
  targets.darwin.linkApps.enable = false;
  targets.darwin.copyApps.enable = true;
}
