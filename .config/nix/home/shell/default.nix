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
      environmentVariables = {
        SHELL = "${pkgs.nushell}/bin/nu";
        EDITOR = "nvim";
        PAGER = "bat";
        MANPAGER = "less -R";
        VISUAL = "nvim";
        HOMEBREW_NO_ENV_HINTS = "true";
        LUA_CPATH = "";
        USER = "francojc";
        HOSTNAME = "MacBook-Airborne";
        ZVM_VI_INSERT_ESCAPE_BINDKEY = "jj";
        ZVM_KEYTIMEOUT = "1";
      };
      extraConfig = ''
        # Define carapace completer
        def create_left_prompt [] {
            starship prompt
        }

        # Path configuration
        let path_dirs = [
            "/opt/homebrew/bin"
            "/usr/local/sbin"
            "~/.bin"
            "~/.local/bin"
        ]

        # Get existing PATH entries
        let existing_path = if ($env | get -i PATH | is-empty) { [] } else { $env.PATH | split row (char esep) }

        # Combine and set PATH
        let-env PATH = (
            $path_dirs
            | append $existing_path
            | each { |it| if ($it | path exists) { $it | path expand } else { $it } }
            | flatten
            | uniq
            | str join (char esep)
        )

        # Use carapace
        let carapace_completer = {|spans|
            carapace $spans.0 nushell $spans | from json
        }

        # Load Homebrew environment if it exists
        if ("/opt/homebrew/bin/brew" | path exists) {
          let brew_env = (^/opt/homebrew/bin/brew shellenv | lines | parse "{key}={value}")
          let-env = ($brew_env | reduce -f $env { |it, acc| $acc | upsert $it.key $it.value })
        }

        # Load secrets from variables.env if it exists
        if ("~/.variables.env" | path expand | path exists) {
          let env_contents = (open ~/.variables.env
            | lines
            | parse "export {key}={value}"
            | update value { |it| $it.value | str replace '"' "" }
          )
          let-env = ($env_contents | reduce -f $env { |it, acc| $acc | upsert $it.key $it.value })
        }

        # Configure completion behavior
        $env.config = {
         show_banner: false,
         completions: {
           case_sensitive: false
           quick: true
           partial: true
           algorithm: "fuzzy"
           external: {
               enable: true
               max_results: 100
               completer: $carapace_completer # check 'carapace_completer'
             }
         }
        }
      '';
    };

    # Enable some useful tools
    atuin = {
      enable = true;
      enableZshIntegration = true;
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
      # enableNushellIntegration = true;
    };
  };
}
