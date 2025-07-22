{
  username,
  isDarwin,
  ...
}: {
  # Accept standard HM args
  imports = [
    ./core.nix
    ./git.nix
    ./ghostty.nix
    ./shell/default.nix
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
    };
    stateVersion = "24.05"; # Keep consistent
  };

  programs.home-manager.enable = true;
  programs.zsh.enable = true;
}
