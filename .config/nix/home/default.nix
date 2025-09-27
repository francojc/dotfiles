{
  username,
  isDarwin,
  isLinux,
  ...
}: {
  # Accept standard HM args
  imports = [
    ./themes.nix
    ./core.nix
    ./git.nix
    ./ghostty.nix
    ./shell/default.nix
    ./tmux.nix
    ./vim.nix
    ./codex.nix
    ./syncthing.nix
  ] ++ (if isLinux then [
    ./i3/default.nix
  ] else []);

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
