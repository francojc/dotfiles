{ username, ... }: {

  imports = [
    ./core.nix
    ./git.nix
    ./neovim
    ./shell
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;

}
