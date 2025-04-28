{username, ...}: {
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
        ${builtins.readFile ./fzf.zsh}
      '';
      profileExtra = ''
        # zprofile

        # --- Hombrew ---
        # Brew binary (Apple Silicon)
        if [[ -f "/opt/homebrew/bin/brew" ]] then
         eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        # --- PATH ---
        export PATH="/usr/local/sbin:$PATH"
        export PATH="/Users/${username}/.bin:$PATH" # custom scripts
        export PATH="/Users/${username}/.local/bin:$PATH" # pipx

        # --- ENVIRONMENT VARIABLES ---
        export EDITOR='nvim'
        export HOMEBREW_NO_ENV_HINTS=true
        export HOSTNAME=$(hostname)
        export LUA_CPATH=""
        export MANPAGER="less -R"
        export PAGER='bat'
        export USER=$(whoami)
        export VISUAL='nvim'

        # --- ZSH ---
        # ZSH plugins
        export ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
        export ZVM_KEYTIMEOUT=1 # 1 second

        # --- SECRETS (from `pass`) ---
        source /Users/${username}/.variables.env

        # Xan completions
        function __xan {
          xan compgen "$1" "$2" "$3"
        }
      '';
      # Other ZSH plugins
      plugins = [];
      shellAliases = {
        ls = "eza --almost-all --icons=auto --dereference --no-quotes --ignore-glob='.DS_Store'";
        ll = "ls --long --time-style=relative --ignore-glob='.git|.DS_Store'";
        lt = "ll --tree --level=2 --ignore-glob='.git|.DS_Store'";
        lg = "lazygit";
      };
    };

    # Enable some useful tools
    atuin = {
      enable = true;
      enableZshIntegration = true;
    };
    carapace = {
      enable = true;
      enableZshIntegration = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
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
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
