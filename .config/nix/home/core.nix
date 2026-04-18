# Python Tools Managed by UV (not nix)
#
# Intentionally NOT in home.packages because UV provides:
# - Faster updates (no waiting for nixpkgs)
# - Isolated environments per tool
# - Consistent Python version (nix 3.12)
#
# Current UV tools:
# - aider-chat    (AI code assistant)
# - marker-pdf    (PDF/DOCX converter)
# - mlx           ( )
# - mlx-lm        (Apple MLX language models)
# - termaid       (Create mermaid diagrams in the terminal)
# - pyzotero      (Zotero API)
# - repoindex     (git repository index)
# My tools (on PyPi) -------
# - dauber        (Canvas management cli tool)
# - orbitr        (Academic lit search and management)
# Update: uv tool upgrade --all
{pkgs, ...}: let
  # Define packages primarily used with or by Neovim
  neovimPackages = with pkgs; [
    # Core dependencies

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
    gh # GitHub CLI
    git # Version control system
    go # Go programming language
    home-manager # Essential for this config
    lazygit # TUI Git client
    neovim # Stable Neovim 0.12+
    nix-prefetch-git
    nodejs-slim # was nodejs-slim_23
    nurl # Nix URL fetcher helper
    python312 # Python 3.12 for uv and general use
    stow # Symlink manager
    uv # Modern Python package and project manager
  ];

  # Command-line utilities and system monitoring
  cliUtilities = with pkgs; [
    _7zz # Archive compression
    atuin # Shell history manager
    bat # Often used by fzf previews, etc. but also standalone
    codesnap # CLI code snippet screenshot tool
    duf # Disk usage utility
    entr # Event notify tool
    eza # ls replacement
    fastfetch # System information tool
    onefetch # Git repository information tool
    fd # find replacement
    file # File type identification
    fzf # General fuzzy finder
    glances # System monitoring tool
    jq # JSON processor
    ncdu # Disk usage analyzer
    pass # Password manager
    rclone # Cloud storage sync (Google Drive, S3, etc.)
    repgrep # ripgrep across files
    ripgrep # grep replacement
    speedtest-cli # Internet speed test
    sqlite # SQLite database engine
    starship # Shell prompt
    tldr # Simplified man pages
    tmux # Terminal multiplexer
    tree # Directory listing tool
    tt # CLI typing test (my fork: ~/.local/bin/tt)
    which # Command location utility
    whosthere # Local Area Network discovery tool
    xan # data visualization from CSV files
    yazi-unwrapped # Terminal file manager
    yq-go # YAML processor
    zoxide # Smarter cd command
  ];

  # Media and document processing
  mediaDocumentPackages = with pkgs; [
    aerc # Email client
    ffmpeg # Multimedia framework
    ghostscript # PostScript/PDF interpreter (used by Snacks.image)
    imagemagick # Image manipulation
    glow # Markdown renderer
    khal # Calendar
    mpv-unwrapped # Media player
    nicotine-plus # p2p file sharing/discovery client
    pandoc # Document converter
    pianobar # Pandora client
    poppler-utils # PDF utilities (pdftotext, etc.)
    quarto # Scientific publishing system
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
  # Install general packages globally for the user
  home.packages = generalPackages;

  # GnuPG — managed via home-manager for agent lifecycle control
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 34560000;
    maxCacheTtl = 34560000;
  };
}
