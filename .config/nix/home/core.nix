{pkgs, ...}: let
  # Shared groups (also used by hosts/omarchy/packages.nix).
  lsp = import ../lib/packages/lsp.nix pkgs;
  cli = import ../lib/packages/cli.nix pkgs;
  dev = import ../lib/packages/dev.nix pkgs;
  media = import ../lib/packages/media.nix pkgs;

  # macOS-only extras. Omarchy must not install these through Nix (see
  # PLAN-nix-lite.md §4c): build toolchains, runtimes, GUI apps, and tools
  # Omarchy ships through pacman.
  macOnly = with pkgs; [
    # Neovim build dependencies and toolchains
    rustc # Rust compiler, needed for many Neovim plugins
    cargo # Rust package manager
    ghostscript # PostScript/PDF interpreter (used by Snacks.image)
    go # Go programming language
    gnumake # Native Node addon builds, including Pi Plannotator's node-pty
    nodejs-slim # was nodejs-slim_23
    python312 # Python 3.12 for uv and general use
    typescript # TypeScript compiler (tsc)
    uv # Modern Python package and project manager

    # Dev tools
    bob-nvim # Neovim version manager (replaces Homebrew neovim HEAD)
    gh # GitHub CLI
    git # Version control system
    home-manager # Essential for this config
    lazygit # TUI Git client

    # CLI utilities that Omarchy ships via pacman
    bat
    eza
    fastfetch
    fd
    fzf
    jq
    onefetch # Git repository information tool
    ripgrep
    starship
    tldr
    tmux
    zoxide

    # Packages Omarchy already provides through pacman (see
    # hosts/omarchy/packages.nix): these would shadow pacman copies on Omarchy.
    file
    pass
    sqlite
    tree
    which
    ffmpeg
    poppler-utils

    # Media and documents
    imagemagick # Image manipulation
    mpv-unwrapped # Media player
    typst # Document preparation system

    # YouTube content creation
    tenacity # Audacity fork, more actively maintained
  ];
in {
  # Install general packages globally for the user
  home.packages = lsp ++ cli ++ dev ++ media ++ macOnly;

  # GnuPG — managed via home-manager for agent lifecycle control
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 34560000;
    maxCacheTtl = 34560000;
    pinentry.package = pkgs.pinentry-tty;
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };
}
