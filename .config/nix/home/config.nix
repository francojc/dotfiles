# ~/.config/nix/home/config.nix
{ config, pkgs, lib, ... }: {

  imports = [
    ./zsh.nix
    ./vim.nix
    ./neovim
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;

  # Add any other home-manager specific configurations here
  home = {
    stateVersion = "23.05";
    sessionVariables = {
      EDITOR = "nvim";
    };
    packages = with pkgs; [
      abook
      atuin
      datasette
      duf
      gh
      gv
      lazydocker
      lazygit
      mdcat
      neomutt
      oh-my-posh
      pandoc
      pianobar
      python3
      ripgrep
      skhd
      sqlite
      tldr
      wtf
      xquartz
      yabai
      yazi-unwrapped
      zoxide
      zoom-us
    ];
  };
}
