{pkgs, ...}: {
  home.packages = with pkgs; [
    # Terminal Enhancements
    atuin
    bat
    eza
    claude-code
    fd
    fzf
    glances
    # kitty
    papis
    starship

    # File Management
    duf
    entr
    ncdu
    tree
    yazi-unwrapped

    # Multimedia Tools
    ffmpeg
    mpv-unwrapped
    pianobar
    sttr
    yt-dlp

    # Development Tools
    datasette
    drawio
    fastfetch
    gnupg
    haskellPackages.pandoc-crossref
    helix-gpt
    jq
    lazydocker
    lazygit
    pandoc
    pass
    pipx
    quarto
    ripgrep
    tesseract # OCR
    silver-searcher

    # System Utilities
    file
    ghostscript
    gv
    home-manager
    htop
    imagemagick
    nix-prefetch-git
    poppler_utils
    qpdf
    sqlite
    stow
    searxng
    tldr
    which
    xclip

    # Version Control and Git Tools
    gh
    git
    lazygit

    # Networking and Communication
    aerc
    m-cli
    mas
    mdcat
    pngpaste
    zoxide
  ];
}
