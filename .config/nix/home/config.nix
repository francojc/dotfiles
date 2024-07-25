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
    datasette
    duf
    lazydocker
    lazygit
    llm
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
    R
    ripgrep
    sqlite
    stow
    taskwarrior3
    taskwarrior-tui
    tldr
    yazi-unwrapped
    zoxide
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Add any other home-manager specific configurations here
}
