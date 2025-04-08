{ pkgs, ... }:

let
  # Define packages primarily used with or by Neovim
  neovimPackages = with pkgs; [
    # Core dependencies
    tree-sitter
    tree-sitter-grammars.tree-sitter-bash
    tree-sitter-grammars.tree-sitter-html
    tree-sitter-grammars.tree-sitter-latex
    tree-sitter-grammars.tree-sitter-lua
    tree-sitter-grammars.tree-sitter-markdown
    tree-sitter-grammars.tree-sitter-markdown-inline
    tree-sitter-grammars.tree-sitter-nix
    tree-sitter-grammars.tree-sitter-python
    tree-sitter-grammars.tree-sitter-r
    tree-sitter-grammars.tree-sitter-yaml
    tree-sitter-grammars.tree-sitter-toml
    tree-sitter-grammars.tree-sitter-scss
    tree-sitter-grammars.tree-sitter-json
    tree-sitter-grammars.tree-sitter-bibtex
    tree-sitter-grammars.tree-sitter-dockerfile
    tree-sitter-grammars.tree-sitter-javascript

    # Language Servers (LSPs)
    bash-language-server # Bash LSP
    lua-language-server # Lua LSP
    marksman # Markdown LSP
    nix-doc # Nix documentation server
    nixd # Nix LSP
    pyright # Python LSP
    yaml-language-server # YAML LSP

    # Formatters & Linters commonly integrated with Neovim
    alejandra # Nix formatter
    air-formatter # R LSP/Formatter
    mdformat # Markdown formatter
    nodePackages.prettier # General purpose formatter
    shfmt # Shell formatter
    stylua # Lua formatter

    # Build dependencies for Neovim plugins (e.g., blink.cmp)
    rustc
    cargo
  ];

  # Define general home packages (excluding Neovim and its associated packages)
  generalPackages = with pkgs; [
    aerc
    atuin
    bat # Often used by fzf previews, etc. but also standalone
    claude-code # CLI tool
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
    lazydocker
    lazygit # TUI Git client
    mas # Mac App Store CLI
    mdcat # Markdown cat
    mpv-unwrapped # Media player
    ncdu # Disk usage analyzer
    nix-prefetch-git
    nodejs-slim_23 # Needed for prettier, but potentially other tools too
    pandoc
    pass # Password manager
    pianobar
    pipx # Python executable installer
    pngpaste # Paste image from clipboard
    poppler_utils # PDF utilities (pdftotext, etc.)
    qpdf # PDF manipulation tool
    quarto # Scientific publishing system
    ripgrep # grep replacement
    searxng # Metasearch engine (assuming local instance tools)
    shunit2 # Shell testing
    silver-searcher # Code searching tool (ag)
    sqlite
    starship # Shell prompt
    stow # Symlink manager
    tldr # Simplified man pages
    tree # Directory listing tool
    vdirsyncer # CalDAV/CardDAV sync
    which
    wiper # Secure deletion?
    yazi-unwrapped # Terminal file manager
    yt-dlp # Video downloader
    zoxide # Smarter cd command
  ];

in
{
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
