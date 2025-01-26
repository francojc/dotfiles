{username, ...}: {
  imports = [
    ./core.nix
    ./git.nix
    ./neovim/default.nix
    ./shell/default.nix
    ./vim.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
