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
  # TODO: remove override once nixpkgs glances tests stop racing/failing under Python 3.14.
  glancesNoCheck = pkgs.glances.overridePythonAttrs (_old: {
    doCheck = false;
  });

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
    obsidian # Note-taking
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
    git # Version control system
    go # Go programming language
    gnumake # Native Node addon builds, including Pi Plannotator's node-pty
    home-manager # Essential for this config
    lazygit # TUI Git client
    neovim # Stable Neovim 0.12+
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
    glancesNoCheck # System monitoring tool
    jq # JSON processor
    ncdu # Disk usage analyzer
    pass # Password manager
    rclone # Cloud storage sync (Google Drive, S3, etc.)
    repgrep # ripgrep across files
    ripgrep # grep replacement
    speedtest-cli # Internet speed test
    sqlite # SQLite database engine
    starship # Shell prompt
    tirith # Terminal-based security for devs and AI
    tldr # Simplified man pages
    tmux # Terminal multiplexer
    tree # Directory listing tool
    tuicr # Git code review
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
    imagemagick # Image manipulation
    glow # Markdown renderer
    isync # IMAP/maildir sync (mbsync)
    khal # Calendar
    notmuch # Mail indexer/search engine
    mpv-unwrapped # Media player
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
