# ~/.config/nix/home/config.nix
{ config, pkgs, lib, ... }: {

  imports = [
    ./zsh.nix
    ./vim.nix
    ./neovim
  ];

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    home-manager = {
      enable = true;
    };
  };

  # Add any other home-manager specific configurations here
  home = {
    stateVersion = "23.05";
    sessionVariables = {
      EDITOR = "nvim";
    };
    packages = with pkgs; [
      abook
      arc-browser
      atuin
      audacity
      datasette
      drawio
      duf
      gh
      gv
      imagemagick
      lazydocker
      lazygit
      mdcat
      neomutt
      nerdfonts
      oh-my-posh
      pandoc
      pngpaste
      pianobar
      python3
      quarto
      rectangle
      ripgrep
      sqlite
      starship
      stow
      tldr
      wtf
      xquartz
      yazi-unwrapped
      yt-dlp
      zoxide
      zoom-us
    ];
  };
}
