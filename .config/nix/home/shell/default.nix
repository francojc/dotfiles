{config, ...}: {
  programs = {
    # Enable some useful shells
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "viins";
      initContent = ''
        ${builtins.readFile ./aliases.zsh}
        ${builtins.readFile ./fzf.zsh}
        source /opt/homebrew/share/zsh-ai/zsh-ai.plugin.zsh
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
        export PATH="${config.home.homeDirectory}/.bin:$PATH" # custom scripts
        export PATH="${config.home.homeDirectory}/.local/bin:$PATH" # pipx
        export PATH="${config.home.homeDirectory}/.orbstack/bin:$PATH" # orbstack
        export PATH="${config.home.homeDirectory}/.claude/local:$PATH" # claude-cli

        # --- ENVIRONMENT VARIABLES ---
        export EDITOR='nvim'
        export HOMEBREW_NO_ENV_HINTS=true
        export HOSTNAME=$(hostname)
        export LUA_CPATH=""
        export MANPAGER="less -R"
        export PAGER='bat'
        export USER=$(whoami)
        export VISUAL='nvim'

        # OLLAMA
        export OLLAMA_HOST="0.0.0.0"

        # --- ZSH ---
        # ZSH plugins
        export ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
        export ZVM_KEYTIMEOUT=1 # 1 second

        # --- SECRETS (from `pass`) ---
        source ${config.home.homeDirectory}/.variables.env

        # Xan completions
        function __xan {
          xan compgen "$1" "$2" "$3"
        }
        # Set 'pbcopy' if not on darwin
        if [[ "$OSTYPE" != "darwin"* ]]; then
          # Check if xclip is installed
          if command -v xclip &> /dev/null; then
            alias pbcopy='xclip -selection clipboard'
          else
            echo "xclip not found. Please install it to use pbcopy."
          fi
        fi
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
