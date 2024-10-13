{ pkgs, ... }: {
  home.packages = with pkgs; [
    atuin
    audacity
    bat
    datasette
    drawio
    duf
    entr
    eza
    fd
    ffmpeg
    file
    fzf
    gh
    ghostscript
    glow
    gnupg
    gh
    gv
    helix
    helix-gpt
    home-manager
    htop
    imagemagick
    jq
    kitty
    lazydocker
    lazygit
    lynx
    m-cli
    mas
    mdcat
    ncdu
    neofetch
    nix-prefetch-git
    nodejs_22
    pandoc
    pass
    pngpaste
    pianobar
    poppler_utils
    qpdf
    quarto
    rectangle
    ripgrep
    silver-searcher
    sqlite
    starship
    stow
    tldr
    tree
    vim
    which
    xclip
    xquartz
    yazi-unwrapped
    yt-dlp
    zoxide
    zoom-us
  ];
}
