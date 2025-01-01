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
      plugins = [];
    };
    nushell = {
      enable = false;
      extraConfig = ''
          # -- Configuration for Nu shell --
          $env.config.show_banner = false
          $env.config.edit_mode = "vi"
          $env.config.rm.always_trash = false

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


          def --env y [...args] {
            let tmp = (mktemp -t "yazi-cwd.XXXXXX")
            yazi ...$args --cwd-file $tmp
            let cwd = (open $tmp)
            if $cwd != "" and $cwd != $env.PWD {
              cd $cwd
            }
          rm -fp $tmp
        }
      '';
      shellAliases = {
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
