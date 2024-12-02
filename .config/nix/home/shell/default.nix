{
  programs = {
    # Enable some useful shells
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "viins";
      initExtra = ''
        ${builtins.readFile ./aliases.zsh}
        ${builtins.readFile ./zprofile.zsh}
      '';
      # Other ZSH plugins
      plugins = [ ];
    };
    nushell = {
      enable = true;
      extraConfig = ''
          # -- Configuration for Nu shell --
          $env.config = {
            show_banner: false,

          }

        alias .. = cd ..
        alias ... = cd ../..

      '';
      shellAliases = {
        # -- Shell aliases for Nu shell --
        # Open files in the default application
        nu-open = "open";
        open = "^open";
        # Nix-related aliases
        switch = "darwin-rebuild switch --flake ~/.dotfiles/.config/nix";

        # Files
        ls = "ls";
        la = "ls -al";
        lt = "eza --almost-all --icons=auto --long --tree --level=2 --ignore-glob='.git|.DS_Store'";
        fd = "fd --hidden --exclude '.git'";
        tree = "tree -C";
        cat = "bat";
        less = "bat --paging=always";
        more = "bat --paging=always";
        cp = "cp -iv";
        mv = "mv -iv";
        rm = "rm -iv";

        # Git aliases
        gss = "git status";
        ga = "git add";
        gaa = "git add --all";
        gc = "git commit --message";
        gp = "git push";
        gpl = "git pull";
        gf = "git fetch";
        gba = "git branch --all";
        gsw = "git switch";
      };
    };

    # Enable some useful tools
    atuin = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    carapace = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };
    eza = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
