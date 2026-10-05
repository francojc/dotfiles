{
  username,
  isDarwin,
  isArch ? false,
  ...
}: {
  # Accept standard HM args
  imports =
    [
      ./themes/themes.nix
      # ./syncthing.nix
      ./document-tools.nix
      ./ssh-aliases.nix
    ]
    ++ (
      if isArch
      then [
        # Arch / Omarchy: Nix manages only the user environment. The package
        # list and app configs are curated to avoid shadowing Omarchy's pacman
        # packages and fighting its theme engine. See docs/arch-omarchy.md.
        #
        # Deliberately excluded on Arch: core.nix (use arch-core.nix), git.nix
        # and kitty.nix (Omarchy/themes own them), shell/default.nix and
        # tmux.nix (macOS/theme-coupled; see modules/arch/).
        ./arch-core.nix
        ../modules/arch/shell.nix
        ../modules/arch/tmux.nix
        ./wezterm.nix
        ./vim.nix
      ]
      else [
        ./core.nix
        ./git.nix
        ./kitty.nix
        ./wezterm.nix
        ./shell/default.nix
        ./tmux.nix
        ./vim.nix
      ]
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

  custom.documentTools.enable = true;
}
