{
  username,
  isDarwin,
  ...
}: {
  # Host-specific tooling is chosen by each host through `homeModules` (see
  # roles/default.nix). Only truly universal modules live here.
  imports = [
    ./themes/themes.nix
    ./ssh-aliases.nix
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
      LANG = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
      TZ = "America/New_York";
      PI_MEMORY_DIR = "~/.local/share/pi-memory";
    };
    stateVersion = "24.05"; # Keep consistent
  };

  programs.home-manager.enable = true;

  # HM's manpage build pulls in options.json, which triggers a nixpkgs
  # store-path-without-context warning. Not used here.
  manual.manpages.enable = false;
  programs.zsh.enable = true;
}
