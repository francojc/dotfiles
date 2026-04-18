{
  username,
  isDarwin,
  isLinux,
  ...
}: {
  # Accept standard HM args
  imports =
    [
      ./themes/themes.nix
      ./core.nix
      ./git.nix
      ./ghostty.nix
      ./kitty.nix
      ./wezterm.nix
      ./shell/default.nix
      ./tmux.nix
      ./vim.nix
      ./syncthing.nix
    ]
    ++ (
      if isDarwin
      then [
        ./llm.nix
      ]
      else []
    );

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
      LANG = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
      TZ = "America/New_York";
      PI_MEMORY_DIR = "~/.local/share/pi-memory";
    };
    stateVersion = "24.05"; # Keep consistent
  };

  programs.home-manager.enable = true;
  programs.zsh.enable = true;
}
