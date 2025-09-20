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
      '';
      profileExtra = ''
        # zprofile

        # --- Hombrew ---
        # Brew binary (Apple Silicon)
        if [[ -f "/opt/homebrew/bin/brew" ]] then
         eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        # --- NPM Global Directory ---
        export NPM_CONFIG_PREFIX="${config.home.homeDirectory}/.npm-global"
        mkdir -p "$NPM_CONFIG_PREFIX"

        # --- PATH ---
        export PATH="/usr/local/sbin:$PATH"
        export PATH="${config.home.homeDirectory}/.bin:$PATH" # custom scripts
        export PATH="${config.home.homeDirectory}/.local/bin:$PATH" # pipx
        export PATH="${config.home.homeDirectory}/.orbstack/bin:$PATH" # orbstack
        export PATH="${config.home.homeDirectory}/.npm-global/bin:$PATH" # npm global

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

        # --- FLATPAK INTEGRATION ---
        # Ensure Flatpak apps can find system fonts and themes
        export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:${config.home.homeDirectory}/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"


        # --- CLAUDE CODE ---
        # Install claude-code, if not already installed
        if ! command -v claude &> /dev/null; then
          if command -v npm &> /dev/null; then
            npm install -g @anthropic-ai/claude-code@latest
          else
            echo "npm not found. Please install Node.js and npm to use claude-code."
          fi
        fi

        # --- OPENCODE AI ---
        # Install opencode-ai, if not already installed
        if ! command -v opencode &> /dev/null; then
          if command -v npm &> /dev/null; then
            npm install -g opencode-ai@latest
          else
            echo "npm not found. Please install Node.js and npm to use opencode-ai."
          fi
        fi

        # --- CODEX AI ---
        # Install codex, if not already installed
        if ! command -v codex &> /dev/null; then
          if command -v npm &> /dev/null; then
            npm install -g @openai/codex@latest
          else
            echo "npm not found. Please install Node.js and npm to use codex."
          fi
        fi

        # --- GEMINI CLI ---
        # Install gemini-cli, if not already installed
        if ! command -v gemini &> /dev/null; then
          if command -v npm &> /dev/null; then
            npm install -g @google/gemini-cli@latest
          else
            echo "npm not found. Please install Node.js and npm to use gemini."
          fi
        fi

        # --- ZSH ---
        # ZSH plugins
        export ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
        export ZVM_KEYTIMEOUT=1 # 1 second
        export ZSH_AI_PROVIDER="gemini"
        export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#5c6370"

        # --- SECRETS (from `pass`) ---
        source ${config.home.homeDirectory}/.variables.env

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

        # Flatpak aliases (similar to brew workflow)
        flat = "flatpak";
        flat-install = "flatpak install flathub";
        flat-search = "flatpak search";
        flat-list = "flatpak list";
        flat-update = "flatpak update";
        flat-remove = "flatpak uninstall";
        flat-info = "flatpak info";
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
