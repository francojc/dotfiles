# ~/.config/nix/home-manager/home.nix
{ config, pkgs, ... }: {

  imports = [
    ./zsh.nix
    # ./git.nix
    # ./neovim.nix
  ];

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    abook
    atuin
    # calcure
    datasette
    duf
    gettext
    lazydocker
    lazygit
    # llm # moved to brew (for model installs)
    luajit
    luajitPackages.luarocks
    mdcat
    neomutt
    neovim
    nodejs
    oh-my-posh
    pandoc
    pianobar
    python3
    radianWrapper
    # R
    ripgrep
    skhd
    sqlite
    stow
    taskwarrior
    taskwarrior-tui
    tldr
    viu
    yabai
    yazi-unwrapped
    zoxide
    zoom-us
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Add any other home-manager specific configurations here
}
