{username, ...}: {
  imports = [
    ./core.nix
    ./git.nix
    ./shell/default.nix
    ./neovim/default.nix
    ./vim.nix
  ];

  home = {
    homeDirectory = "/Users/${username}";
    inherit username;
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
