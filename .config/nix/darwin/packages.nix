# ~/.config/nix/darwin/packages.nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bat
    eza
    fd
    fzf
    git
    ghostscript
    home-manager
    htop
    isync
    jq
    kitty
    lynx
    m-cli
    mas
    msmtp
    ncdu
    neofetch
    notmuch
    pass
    poppler
    tree
    urlscan
    vim
    wezterm
    xclip
    zsh
  ];
}
