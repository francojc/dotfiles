{ pkgs, ... }:
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
           edit_mode: vi,
         }

         # -- Configure path for Nu shell --
         $env.PATH = ($env.PATH | split row ":"
           | prepend "/usr/local/sbin"
           | prepend "/nix/var/nix/profiles/default/bin"
           | prepend "/run/current-system/sw/bin"
           | prepend "/etc/profiles/per-user/francojc/bin"
           | prepend "/Users/francojc/.nix-profile/bin"
           | prepend "/opt/homebrew/sbin"
           | prepend "/opt/homebrew/bin"
           | prepend "/Users/francojc/.bin"
           | prepend "/Users/francojc/.local/bin"
           | uniq
           )

         $env.PROMPT_INDICATOR_VI_NORMAL = '❮ ';

         $env.EDITOR = 'nvim'
         $env.VISUAL = 'nvim'
         $env.HOMEBREW_NO_ENV_HINTS = 'true'

        open ~/.variables.env
        | lines
        | each { |line|
            let parts = ($line | str replace "export " "" | split row "=" | take 2)
            let key = ($parts.0 | str trim)
            let value = ($parts.1 | str trim)
            {$key: $value}
        }
        | reduce -f {} { |it, acc| $acc | merge $it }
        | load-env

         alias .. = cd ..
         alias ... = cd ../..

        plugin add ${pkgs.nushellPlugins.polars}/bin/nu_plugin_polars
        plugin add ${pkgs.nushellPlugins.query}/bin/nu_plugin_query

        plugin use polars
        plugin use query
      '';
      shellAliases = {
        # -- Shell aliases for Nu shell --
        c = "clear";
        v = "nvim";
        cd = "z";

        # Open files in the default application
        nu-open = "open";
        open = "^open";
        # Nix-related aliases
        switch = "darwin-rebuild switch --flake ~/.dotfiles/.config/nix";

        # Files
        ls = "ls";
        la = "ls -a";
        ll = "ls -l";
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
        gl = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
        gp = "git push";
        gpl = "git pull";
        gf = "git fetch";
        gba = "git branch --all";
        gsw = "git switch";
        ghb = "gh browse";
        ghc = "gh repo create";

        # Quarto aliases
        q = "quarto";
        qp = "quarto preview";
        qph = "quarto preview --to html";
        qpp = "quarto preview --to pdf";
        qrh = "quarto render --to html";
        qrp = "quarto render --to pdf";
        qpub = "quarto publish gh-pages";

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
      enableNushellIntegration = true;
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
