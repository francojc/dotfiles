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
# - mlx-lm        (Apple MLX language models)
# - zotero-mcp    (Zotero MCP server)
#
# Update: uv tool upgrade --all
{pkgs, ...}: let
  # Define packages primarily used with or by Neovim
  neovimPackages = with pkgs; [
    # Core dependencies
    tree-sitter # Parser generator, using `auto_install` in nvim-treesitter for language parsers

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
    nodePackages.prettier # General purpose formatter
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
    # shunit2 # Shell testing
    bob-nvim # Neovim version manager (replaces Homebrew neovim HEAD)
    cachix # Nix package cache
    gh # GitHub CLI
    git # Version control system
    go # Go programming language
    home-manager # Essential for this config
    kitty # Terminal emulator
    lazygit # TUI Git client
    neovim # Stable Neovim 0.11+
    nix-prefetch-git
    nodejs-slim # was nodejs-slim_23
    python312 # Python 3.12 for uv and general use
    stow # Symlink manager
    uv # Modern Python package and project manager
  ];

  # Command-line utilities and system monitoring
  cliUtilities = with pkgs; [
    # _7zz # Archive compression
    # ruby # Programming language
    # unp # Archive unpacker
    atuin # Shell history manager
    bat # Often used by fzf previews, etc. but also standalone
    codesnap # CLI code snippet screenshot tool
    duf # Disk usage utility
    entr # Event notify tool
    eza # ls replacement
    fastfetch # System information tool
    fd # find replacement
    file # File type identification
    fzf # General fuzzy finder
    glances # System monitoring tool
    gnupg # GNU Privacy Guard
    jq # JSON processor
    ncdu # Disk usage analyzer
    pass # Password manager
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
    xan # data visualization from CSV files
    yazi-unwrapped # Terminal file manager
    yq-go # YAML processor
    zoxide # Smarter cd command
  ];

  # Media and document processing
  mediaDocumentPackages = with pkgs; [
    aerc # Email client
    # drawio # Diagramming tool
    ffmpeg # Multimedia framework
    ghostscript # PostScript/PDF interpreter (used by Snacks.image)
    # gv # Ghostview - PostScript/PDF viewer
    # haskellPackages.pandoc-crossref # Pandoc filter
    imagemagick # Image manipulation
    khal # Calendar
    mpv-unwrapped # Media player
    # ncspot # Spotify TUI client
    pandoc # Document converter
    pianobar # Pandora client
    poppler-utils # PDF utilities (pdftotext, etc.)
    # qpdf # PDF manipulation tool
    quarto # Scientific publishing system
    typst # Document preparation system
    vdirsyncer # CalDAV/CardDAV sync
  ];

  # YouTube content creation and streaming
  youtubeContentPackages = with pkgs; [
    # audacity # Audio editing and recording
    yt-dlp # Video downloader
  ];

  # Combined package list
  generalPackages = neovimPackages ++ developmentPackages ++ cliUtilities ++ mediaDocumentPackages ++ youtubeContentPackages;
in {
  # Install general packages globally for the user
  home.packages = generalPackages;
}
