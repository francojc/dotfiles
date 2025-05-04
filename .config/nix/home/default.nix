{ pkgs, lib, config, username, useremail, inputs, isLinux, isDarwin, ... }: { # Accept standard HM args
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
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    sessionVariables = {
      # Define preferred editor here for consistency across systems via HM
      EDITOR = "nvim"; # Or "vim" if preferred
      VISUAL = "nvim";
    };
    stateVersion = "24.05"; # Keep consistent
  };

  programs.home-manager.enable = true;

  # Ensure Zsh is configured via Home Manager for both systems
  programs.zsh.enable = true;
}
