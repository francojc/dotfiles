{ pkgs, ... }:

{
  home.packages = with pkgs; [
    atuin
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
    haskellPackages.pandoc-crossref
    helix
    helix-gpt
    home-manager
    htop
    imagemagick
    jq
    lazydocker
    lazygit
    lynx
    m-cli
    mas
    mdcat
    mpv-unwrapped
    ncdu
    neofetch
    nix-prefetch-git
    pandoc
    pass
    pngpaste
    pianobar
    pipx
    poppler_utils
    pyright
    qpdf
    quarto
    ripgrep
    silver-searcher
    sqlite
    starship
    stow
    tldr
    tree
    which
    xclip
    # xquartz # pulls in xorg-server for some reason
    yazi-unwrapped
    yt-dlp
    zoxide
  ];
}
