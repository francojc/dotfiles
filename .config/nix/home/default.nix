{
  pkgs,
  lib,
  config,
  username,
  useremail,
  inputs,
  isLinux,
  isDarwin,
  ...
}: {
  # Accept standard HM args
  imports = [
    ./core.nix
    ./git.nix
    ./shell/default.nix
    ./neovim/default.nix
    ./vim.nix
  ];

  home = {
    # Use args passed by Home Manager
    inherit username;
    homeDirectory =
      if isDarwin
      then "/Users/${username}"
      else "/home/${username}";
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SHELL = "${pkgs.zsh}/bin/zsh";
    };
    stateVersion = "24.05"; # Keep consistent
  };

  programs.home-manager.enable = true;
  programs.zsh.enable = true;
}
