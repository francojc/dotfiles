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

  # Define general home packages (excluding Neovim and its associated packages)
  generalPackages = with pkgs; [
    _7zz
    aerc # Email client
    # aider-chat-full # includes, playwright, browser, help, etc.
    atuin # Shell history manager
    bat # Often used by fzf previews, etc. but also standalone
    cachix # Nix package cache
    codex # CLI tool (openai)
    drawio # Diagramming tool
    duf # Disk usage utility
    entr # Event notify tool
    eza # ls replacement
    fastfetch # System information tool
    fd # find replacement
    ffmpeg # Multimedia framework
    file # File type identification
    fzf # General fuzzy finder
    gh # GitHub CLI
    ghostscript # PostScript/PDF interpreter
    git # Version control system
    glances # System monitoring tool
    gnupg # GNU Privacy Guard
    gv # Ghostview - PostScript/PDF viewer
    haskellPackages.pandoc-crossref # Pandoc filter
    home-manager # Essential for this config
    htop # Interactive process viewer
    imagemagick # Image manipulation
    jq # JSON processor
    khal # Calendar
    kitty # Terminal emulator
    lazygit # TUI Git client
    mdcat # Markdown cat
    mpv-unwrapped # Media player
    ncdu # Disk usage analyzer
    nix-prefetch-git
    nodejs-slim # was nodejs-slim_23
    pandoc # Document converter
    pass # Password manager
    pianobar # Pandora client
    poppler_utils # PDF utilities (pdftotext, etc.)
    procs # Process viewer
    qpdf # PDF manipulation tool
    quarto # Scientific publishing system
    repgrep # ripgrep across files
    ripgrep # grep replacement
    shunit2 # Shell testing
    speedtest-cli # Internet speed test
    sqlite # SQLite database engine
    starship # Shell prompt
    stow # Symlink manager
    tldr # Simplified man pages
    tmux # Terminal multiplexer
    tree # Directory listing tool
    unp # Archive unpacker
    vdirsyncer # CalDAV/CardDAV sync
    which # Command location utility
    xan # CLI tool for CSV files
    yazi-unwrapped # Terminal file manager
    yq-go # YAML processor
    yt-dlp # Video downloader
    zoxide # Smarter cd command
  ];
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
