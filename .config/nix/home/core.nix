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

    # Academic/document rendering (for Quarto, markdown, snacks.nvim)
    tectonic # LaTeX rendering for math expressions
    nodePackages.mermaid-cli # Mermaid diagram rendering (provides mmdc)
    chafa # Terminal image viewer (optional, enhances image support)

    # AI assistance (for sidekick.nvim)
    copilot-language-server # Copilot LSP for Next Edit Suggestions
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
    # shunit2 # Shell testing
    stow # Symlink manager
  ];

  llm_with_plugins = pkgs.python3.withPackages (ps:
    with ps; [
      llm
      llm-openrouter
    ]);

  # Command-line utilities and system monitoring
  cliUtilities = with pkgs; [
    # _7zz # Archive compression
    aider-chat # AI code assistant
    atuin # Shell history manager
    bat # Often used by fzf previews, etc. but also standalone
    coreutils # GNU core utilities (provides grealpath for yazi)
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
    llm_with_plugins # llm CLI bundled with OpenRouter plugin (see above)
    ncdu # Disk usage analyzer
    pass # Password manager
    repgrep # ripgrep across files
    ripgrep # grep replacement
    # ruby # Programming language
    speedtest-cli # Internet speed test
    sqlite # SQLite database engine
    starship # Shell prompt
    tldr # Simplified man pages
    tmux # Terminal multiplexer
    tree # Directory listing tool
    # typtea # Terminal-based typing test
    # unp # Archive unpacker
    which # Command location utility
    yazi-unwrapped # Terminal file manager
    yq-go # YAML processor
    zoxide # Smarter cd command
  ];

  # Media and document processing
  mediaDocumentPackages = with pkgs; [
    aerc # Email client
    # drawio # Diagramming tool
    ffmpeg # Multimedia framework
    # ghostscript # PostScript/PDF interpreter
    # gv # Ghostview - PostScript/PDF viewer
    # haskellPackages.pandoc-crossref # Pandoc filter
    imagemagick # Image manipulation
    khal # Calendar
    mpv-unwrapped # Media player
    pandoc # Document converter
    pianobar # Pandora client
    poppler_utils # PDF utilities (pdftotext, etc.)
    # qpdf # PDF manipulation tool
    quarto # Scientific publishing system
    vdirsyncer # CalDAV/CardDAV sync
    yt-dlp # Video downloader
  ];

  # YouTube content creation and streaming
  youtubeContentPackages = with pkgs; [
    # audacity # Audio editing and recording
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
