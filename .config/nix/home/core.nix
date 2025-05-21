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
    rustc
    cargo
  ];

  # Define general home packages (excluding Neovim and its associated packages)
  generalPackages = with pkgs; [
    _7zz
    aider-chat
    aerc
    atuin
    bat # Often used by fzf previews, etc. but also standalone
    cachix # Nix package cache
    # claude-code # CLI tool
    clipse # Clipboard manager
    datasette
    drawio
    duf
    entr
    eza # ls replacement
    fastfetch
    fd # find replacement
    ffmpeg
    file
    fzf # General fuzzy finder
    gh # GitHub CLI
    ghostscript
    git
    gnupg
    gv # Ghostview - PostScript/PDF viewer
    haskellPackages.pandoc-crossref # Pandoc filter
    home-manager # Essential for this config
    htop
    imagemagick
    jq # JSON processor
    khal # Calendar
    kitty # Terminal emulator
    lazygit # TUI Git client
    (pkgs.python3.withPackages (ps: [
      ps.llm
      ps.llm-anthropic # Anthropic plugin
      ps.llm-gemini # Gemini plugin
      ps.llm-ollama # Ollama plugin
      ps.llm-openai-plugin # OpenAI plugin
    ])) # AI CLI tool with plugins
    mdcat # Markdown cat
    mpv-unwrapped # Media player
    ncdu # Disk usage analyzer
    nix-prefetch-git
    nodejs-slim # was nodejs-slim_23
    pandoc
    pass # Password manager
    pianobar
    pipx # Python executable installer
    poppler_utils # PDF utilities (pdftotext, etc.)
    qpdf # PDF manipulation tool
    quarto # Scientific publishing system
    repgrep # ripgrep across files
    ripgrep # grep replacement
    searxng # Metasearch engine (assuming local instance tools)
    shunit2 # Shell testing
    speedtest-cli # Internet speed test
    sqlite
    starship # Shell prompt
    stow # Symlink manager
    tldr # Simplified man pages
    tmux # Terminal multiplexer
    tree # Directory listing tool
    vdirsyncer # CalDAV/CardDAV sync
    which
    wiper # Secure deletion?
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
