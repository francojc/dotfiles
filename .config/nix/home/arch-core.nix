# Arch / Omarchy user packages.
#
# This mirrors home/core.nix but is curated for an Omarchy host so that Nix
# does not shadow the packages Omarchy already installs through pacman. Home
# Manager's profile comes before /usr/bin on PATH, so listing a package here
# would silently override the Omarchy build of the same tool.
#
# Intentionally omitted because Omarchy provides them (see
# /usr/share/omarchy/install/omarchy-base.packages):
#
#   bat btop eza fastfetch fd fzf git imagemagick jq lazygit mpv nvim
#   ripgrep starship tmux tldr zoxide
#
# Everything below is tooling Omarchy does not ship, most notably the Neovim
# LSP / formatter / build toolchain. Python CLI tools remain managed by UV
# (not Nix); see the note in home/core.nix.
{pkgs, ...}: let
  # TODO: remove override once nixpkgs glances tests stop racing/failing under Python 3.14.
  glancesNoCheck = pkgs.glances.overridePythonAttrs (_old: {
    doCheck = false;
  });

  # Define packages primarily used with or by Neovim
  neovimPackages = with pkgs; [
    # Language Servers (LSPs)
    bash-language-server # Bash LSP
    copilot-language-server # Copilot LSP for Next Edit Suggestions
    golangci-lint-langserver # Go linter
    gopls # Go LSP
    lua-language-server # Lua LSP
    marksman # Markdown LSP
    nix-doc # Nix documentation server
    nixd # Nix LSP
    pyright # Python LSP
    tinymist # Typst LSP
    typescript-language-server # TypeScript LSP
    vscode-json-languageserver # JSON LSP
    yaml-language-server # YAML LSP

    # Formatters & Linters commonly integrated with Neovim
    air-formatter # R LSP/Formatter
    alejandra # Nix formatter
    mdformat # Markdown formatter
    ruff # Python linter/formatter
    shfmt # Shell formatter
    stylua # Lua formatter

    # Build dependencies for Neovim plugins (e.g., blink.cmp)
    rustc # Rust compiler, needed for many Neovim plugins
    cargo # Rust package manager, needed for many Neovim plugins
    ghostscript # PostScript/PDF interpreter (used by Snacks.image)

    # Academic/document rendering (for Quarto, markdown, snacks.nvim)
    tectonic # LaTeX rendering for math expressions
    chafa # Terminal image viewer (optional, enhances image support)
    websocat # WebSocket client
  ];

  # Development and system tools
  developmentPackages = with pkgs; [
    # Note: Python CLI tools managed via UV, not nix
    age # Encryption
    bob-nvim # Neovim version manager (replaces Homebrew neovim HEAD)
    cachix # Nix package cache
    carapace # Command-line completion
    codespell # Spell checker
    direnv # Environment manager
    forgejo-cli # `fj` CLI for Forgejo
    gh # GitHub CLI
    go # Go programming language
    gnumake # Native Node addon builds, including Pi Plannotator's node-pty
    marp-cli # Markdown presentation tool
    nix-prefetch-git
    nodejs-slim # was nodejs-slim_23
    nurl # Nix URL fetcher helper
    typescript # TypeScript compiler (tsc)
    python312 # Python 3.12 for uv and general use
    stow # Symlink manager
    uv # Modern Python package and project manager
  ];

  # Command-line utilities and system monitoring
  cliUtilities = with pkgs; [
    _7zz # Archive compression
    atuin # Shell history manager
    codesnap # CLI code snippet screenshot tool
    duf # Disk usage utility
    entr # Event notify tool
    file # File type identification
    glancesNoCheck # System monitoring tool
    mpack # encoding/decoding MIME types
    ncdu # Disk usage analyzer
    pass # Password manager
    rclone # Cloud storage sync (Google Drive, S3, etc.)
    repgrep # ripgrep across files
    speedtest-cli # Internet speed test
    sqlite # SQLite database engine
    tirith # Terminal-based security for devs and AI
    tree # Directory listing tool
    tuicr # Git code review
    which # Command location utility
    whosthere # Local Area Network discovery tool
    xan # data visualization from CSV files
    yazi-unwrapped # Terminal file manager
    yq-go # YAML processor
  ];

  # Media and document processing
  mediaDocumentPackages = with pkgs; [
    aerc # Email client
    ffmpeg # Multimedia framework
    glow # Markdown renderer
    khal # Calendar
    pianobar # Pandora client
    poppler-utils # PDF utilities (pdftotext, etc.)
    typst # Document preparation system
    vdirsyncer # CalDAV/CardDAV sync
  ];

  # YouTube content creation and streaming
  youtubeContentPackages = with pkgs; [
    tenacity # Audacity fork, more actively maintained
  ];

  # Combined package list
  generalPackages = neovimPackages ++ developmentPackages ++ cliUtilities ++ mediaDocumentPackages ++ youtubeContentPackages;
in {
  # Install general packages for the user (not the system).
  home.packages = generalPackages;

  # GnuPG -- managed via home-manager for agent lifecycle control
  programs.gpg = {
    enable = false;
  };

  services.gpg-agent = {
    enable = false;
    defaultCacheTtl = 34560000;
    maxCacheTtl = 34560000;
    pinentry.package = pkgs.pinentry-tty;
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };
}
