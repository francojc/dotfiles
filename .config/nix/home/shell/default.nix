{
  config,
  username,
  ...
}: {
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

        # Source zsh-ai-cmd plugin
        source ${config.home.homeDirectory}/.dotfiles/.config/zsh/zsh-ai-cmd/zsh-ai-cmd.plugin.zsh

        bindkey '^F' autosuggest-accept # Ctrl+F to accept full suggestion
      '';
      profileExtra = ''
        # zprofile
        ulimit -n 10240 # Increase max open files

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
        export PATH="${config.home.homeDirectory}/.cargo/bin:$PATH" # rust cargo
        export PATH="${config.home.homeDirectory}/.local/share/bob/nvim-bin:$PATH" # bob-managed neovim

        # --- ENVIRONMENT VARIABLES ---
        export EDITOR='nvim'
        export HOMEBREW_NO_ENV_HINTS=true
        export HOSTNAME=$(hostname)
        export LUA_CPATH=""
        export MANPAGER="less -R"
        export PAGER='bat'
        export USER=$(whoami)
        export VISUAL='nvim'
        export GCAL='-s 1 --iso-week-number=yes'

        # --- PYTHON/UV CONFIGURATION ---
        # Hybrid setup: nix (base) + UV (tools) + homebrew (C libs)
        #
        # UV_PYTHON points to nix Python 3.12 for consistent tool installations
        # Ensures all UV tools use same Python version managed by nix
        export UV_PYTHON="/etc/profiles/per-user/${username}/bin/python3"
        # Set for GUI apps (like Claude Desktop with MCP servers)
        launchctl setenv UV_PYTHON "/etc/profiles/per-user/${username}/bin/python3" 2>/dev/null || true

        # --- MARKER-PDF C LIBRARY PATHS ---
        # WeasyPrint/Cairo library paths for marker-pdf DOCX/PPTX support
        # Includes both Homebrew and nix libraries
        # Note: Homebrew C libs necessary because UV-installed marker-pdf
        # cannot find nix-isolated libraries due to DYLD security on macOS
        export DYLD_FALLBACK_LIBRARY_PATH="/opt/homebrew/lib:/etc/profiles/per-user/${username}/lib:$DYLD_FALLBACK_LIBRARY_PATH"
        # Set for GUI apps
        launchctl setenv DYLD_FALLBACK_LIBRARY_PATH "/opt/homebrew/lib:/etc/profiles/per-user/${username}/lib" 2>/dev/null || true

        # OLLAMA
        export OLLAMA_HOST="0.0.0.0"

        # --- FLATPAK INTEGRATION ---
        # Ensure Flatpak apps can find system fonts and themes
        export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:${config.home.homeDirectory}/.local/share/flatpak/exports/share:/usr/share:$XDG_DATA_DIRS"

        # --- OPENCODE AI ---
        # Install opencode-ai, if not already installed
        if ! command -v opencode &> /dev/null; then
          if command -v npm &> /dev/null; then
            npm install -g opencode-ai@latest
          else
            echo "npm not found. Please install Node.js and npm to use opencode-ai."
          fi
        fi

        # --- ZSH ---
        # ZSH plugins
        export ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
        export ZVM_KEYTIMEOUT=1 # 1 second
        export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#5c6370"

        # zsh-ai-cmd configuration
        export ZSH_AI_CMD_PROVIDER='copilot'
        # Uncomment and customize if needed:
        export ZSH_AI_CMD_COPILOT_MODEL='claude-haiku-4.5'
        export ZSH_AI_CMD_COPILOT_HOST='mac-minicore.gerbil-matrix.ts.net:4141'

        # Press 'v' in normal mode to open current file in $EDITOR

        autoload edit-command-line
        zle -N edit-command-line
        bindkey -M vicmd v edit-command-line
        export VI_MODE_SET_CURSOR=true

        function zle-keymap-select {
          if [[ $KEYMAP == vicmd ]]; then
            echo -ne '\e[2 q' # block cursor
          else
            echo -ne '\e[6 q' # beam cursor
          fi
        }
        zle -N zle-keymap-select

        # Yank to system clipboard
        function vi-yank-clipboard {
            zli vi-yank
            echo "$CUTBUFFER" | pbcopy -i
          }
        zle -N vi-yank-clipboard
        bindkey -M vicmd y vi-yank-clipboard

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
        # Neovim - stable nix version (0.11.x) using full path to avoid bob's nvim
        nv = "NVIM_APPNAME=nvim-nix /etc/profiles/per-user/${username}/bin/nvim";

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
      flags = [
        "--disable-up-arrow" # Disable up arrow to search history, conflicts with zsh-autosuggestions
      ];
    };
    carapace = {
      enable = false;
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
