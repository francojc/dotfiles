# ~/.config/nix/darwin/packages.nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bat
    eza
    fd
    fzf
    gettext
    git
    home-manager
    htop
    isync
    jq
    kitty
    lynx
    m-cli
    mas
    msmtp
    neofetch
    notmuch
    pass
    skhd
    tree
    urlscan
    vim
    wezterm
    xclip
    yabai
    zsh
  ];
}
