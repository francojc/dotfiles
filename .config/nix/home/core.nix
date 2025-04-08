{pkgs, ...}: {
  home.packages = with pkgs; [
    aerc
    atuin
    bat
    claude-code
    datasette
    drawio
    duf
    entr
    eza
    fastfetch
    fd
    ffmpeg
    file
    fzf
    gh
    ghostscript
    git
    gnupg
    gv
    haskellPackages.pandoc-crossref
    home-manager
    htop
    imagemagick
    jq
    khal
    kitty
    lazydocker
    lazygit
    mas
    mdcat
    mpv-unwrapped
    ncdu
    neovim
    nix-prefetch-git
    nodejs_22
    pandoc
    pass
    pianobar
    pipx
    pngpaste
    poppler_utils
    qpdf
    quarto
    ripgrep
    searxng
    silver-searcher
    sqlite
    starship
    stow
    tldr
    tree
    vdirsyncer
    which
    wiper
    yazi-unwrapped
    yt-dlp
    zoxide
  ];
}
