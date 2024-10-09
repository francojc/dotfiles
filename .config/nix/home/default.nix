{ username, ... }: {

  imports = [
    ./shell
    ./core.nix
    ./neovim
    ./git.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };
  programs.home-manager.enable = true;

}
