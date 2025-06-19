{pkgs, ...}: {
  # Simple Neovim configuration without nixCats
  home.packages = with pkgs; [
    neovim
  ];

  # Copy Neovim configuration files
  xdg.configFile = {
    "nvim/init.lua".source = ./init.lua;
    "nvim/plugin".source = ./plugin;
    "nvim/snippets".source = ./snippets;
  };
}