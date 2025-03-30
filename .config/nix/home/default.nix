{username, ...}: {
  imports = [
    ./core.nix
    ./git.nix
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
