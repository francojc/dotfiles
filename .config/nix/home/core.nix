{pkgs, ...}: let
  # Define packages primarily used with or by Neovim
  neovimPackages = with pkgs; [
    # Core dependencies
    tree-sitter # Parser generator, using `auto_install` in nvim-treesitter for language parsers

    # Language Servers (LSPs)
    bash-language-server # Bash LSP
    lua-language-server # Lua LSP
    marksman # Markdown LSP
    nix-doc # Nix documentation server
    nixd # Nix LSP
    pyright # Python LSP
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
  ];

  # Development and system tools
  developmentPackages = with pkgs; [
    cachix # Nix package cache
    gh # GitHub CLI
    git # Version control system
    home-manager # Essential for this config
    lazygit # TUI Git client
    nix-prefetch-git
    nodejs-slim # was nodejs-slim_23
    shunit2 # Shell testing
    stow # Symlink manager
  ];

  # Command-line utilities and system monitoring
  cliUtilities = with pkgs; [
    _7zz # Archive compression
    atuin # Shell history manager
    aider-chat # AI-powered shell assistant
    bat # Often used by fzf previews, etc. but also standalone
    duf # Disk usage utility
    entr # Event notify tool
    eza # ls replacement
    fastfetch # System information tool
    fd # find replacement
    file # File type identification
    fzf # General fuzzy finder
    glances # System monitoring tool
    gnupg # GNU Privacy Guard
    htop # Interactive process viewer
    jq # JSON processor
    ncdu # Disk usage analyzer
    pass # Password manager
    procs # Process viewer
    ripgrep # grep replacement
    repgrep # ripgrep across files
    speedtest-cli # Internet speed test
    sqlite # SQLite database engine
    starship # Shell prompt
    tldr # Simplified man pages
    tmux # Terminal multiplexer
    tree # Directory listing tool
    unp # Archive unpacker
    which # Command location utility
    xan # CLI tool for CSV files
    yazi-unwrapped # Terminal file manager
    yq-go # YAML processor
    zoxide # Smarter cd command
  ];

  # Media and document processing
  mediaDocumentPackages = with pkgs; [
    aerc # Email client
    codex # CLI tool (openai)
    drawio # Diagramming tool
    ffmpeg # Multimedia framework
    ghostscript # PostScript/PDF interpreter
    gv # Ghostview - PostScript/PDF viewer
    haskellPackages.pandoc-crossref # Pandoc filter
    imagemagick # Image manipulation
    khal # Calendar
    kitty # Terminal emulator
    mdcat # Markdown cat
    mpv-unwrapped # Media player
    pandoc # Document converter
    pianobar # Pandora client
    poppler_utils # PDF utilities (pdftotext, etc.)
    qpdf # PDF manipulation tool
    quarto # Scientific publishing system
    vdirsyncer # CalDAV/CardDAV sync
    yt-dlp # Video downloader
  ];

  # YouTube content creation and streaming
  youtubeContentPackages = with pkgs; [
    audacity # Audio editing and recording
  ];

  # Combined package list
  generalPackages = developmentPackages ++ cliUtilities ++ mediaDocumentPackages ++ youtubeContentPackages;
in {
  # Install general packages globally for the user
  home.packages = generalPackages;

  # Configure Neovim using the dedicated home-manager module
  programs.neovim = {
    enable = true;
    # Specify the unwrapped Neovim package. The home-manager module
    # should handle necessary wrapping steps itself, potentially avoiding
    # the issue in the default pkgs.neovim wrapper.
    package = pkgs.neovim-unwrapped;

    # Add packages that Neovim depends on or integrates with
    # This makes the dependency explicit and keeps the main packages list cleaner
    extraPackages = neovimPackages;

    # Your existing Neovim configuration (likely managed via home.file or similar
    # pointing to ~/.config/nvim) will be used.
    # No need for extraConfig or plugin management here unless you want to
    # migrate your Lua config fully into Nix.
  };
}
