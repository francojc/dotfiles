{ pkgs, ... }:

{
  home.packages = with pkgs; [
    abook
    atuin
    audacity
    bat
    datasette
    drawio
    duf
    eza
    fd
    file
    fzf
    gh
    ghostscript
    gnupg
    gv
    home-manager
    htop
    imagemagick
    jq
    kitty
    lazydocker
    lazygit
    m-cli
    mas
    mdcat
    msmtp
    ncdu
    neofetch
    neomutt
    nix-prefetch-git
    notmuch
    pandoc
    pass
    pngpaste
    pianobar
    qpdf
    quarto
    rectangle
    ripgrep
    sqlite
    starship
    stow
    tldr
    tree
    urlscan
    vim
    which
    wtf
    xclip
    xquartz
    yazi-unwrapped
    yt-dlp
    zoxide
    zoom-us
  ];

  # programs = {
  #   # modern vim
  #   neovim = {
  #     enable = true;
  #     defaultEditor = true;
  #     vimAlias = true;
  #   };
  #
  # };
}
