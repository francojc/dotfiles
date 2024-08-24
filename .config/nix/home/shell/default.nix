{ pkgs, ... }: {
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "viins";
      initExtra = ''
        ${builtins.readFile ./aliases.zsh}
      '';
      # Other ZSH plugins
      plugins = [
        # {
        #   name = "zsh-users/zsh-autosuggestions";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "zsh-users";
        #     repo = "zsh-autosuggestions";
        #     rev = "0.6.4";
        #     sha256 = "....";
        #   };
        # }
      ];
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    atuin = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}