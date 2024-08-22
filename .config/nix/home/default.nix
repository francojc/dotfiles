{ username, ... }:

{
  # import sub modules
  imports = [
    ./shell/default.nix
    ./core.nix
    # ./neovim/default.nix # TODO: fix neovim
    ./git.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
