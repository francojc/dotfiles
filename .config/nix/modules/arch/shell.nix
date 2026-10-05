# Arch / Omarchy-adjusted shell configuration.
#
# This is the Arch counterpart to home/shell/default.nix. It keeps the portable
# parts (zsh plugins, completions, aliases, functions, TUI integrations) and
# drops the macOS-only pieces: Homebrew `shellenv`, `launchctl`, DYLD fallback
# paths, `pbcopy`/`pbpaste`, and the Flatpak XDG_DATA_DIRS hack.
#
# The Omarchy environment bootstrap is added to `profileExtra` by
# profiles/arch/configuration.nix; this module only adds the user tool paths.
{
  config,
  pkgs,
  ...
}: {
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      # Cache compinit: only re-audit fpath once per day
      # Skips compaudit on subsequent starts (~1.3s saved per shell)
      completionInit = ''
        autoload -U compinit
        if [[ -n ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
          compinit
        else
          compinit -C
        fi
      '';
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "viins";
      initContent = ''
        ${builtins.readFile ../../home/shell/aliases.zsh}
        ${builtins.readFile ../../home/shell/functions.zsh}
        ${builtins.readFile ../../home/shell/ai.zsh}
        ${builtins.readFile ../../home/shell/repo.zsh}
        ${builtins.readFile ../../home/shell/fzf.zsh}

        # aliases.zsh shadows the Omarchy CLI with an SSH helper of the same
        # name. Restore the CLI on an actual Omarchy host.
        unalias omarchy 2>/dev/null

        # Custom tool completions (not in carapace registry)
        # Wrapped in functions so zsh-defer can schedule them safely --
        # process substitutions must not be evaluated at parse time
        _comp_koan()   { source <(COMPLETE=zsh koan); }
        _comp_dauber() { command -v dauber &>/dev/null && eval "$(_DAUBER_COMPLETE=source_zsh dauber)"; }
        zsh-defer _comp_koan
        zsh-defer _comp_dauber

        bindkey '^F' autosuggest-accept # Ctrl+F to accept full suggestion
      '';
      profileExtra = ''
        # zprofile
        ulimit -n 10240 # Increase max open files

        # tirith (pkgs.tirith) if present on PATH
        if command -v tirith &>/dev/null; then
          eval "$(tirith init --shell zsh)"
        fi

        # --- NPM Global Directory ---
        export NPM_CONFIG_PREFIX="${config.home.homeDirectory}/.npm-global"
        mkdir -p "$NPM_CONFIG_PREFIX"

        # --- PATH ---
        export PATH="${config.home.homeDirectory}/.bin:$PATH" # custom scripts
        export PATH="${config.home.homeDirectory}/.cargo/bin:$PATH" # rust cargo
        export PATH="${config.home.homeDirectory}/.local/bin:$PATH" # pipx python
        export PATH="${config.home.homeDirectory}/.npm-global/bin:$PATH" # npm global
        export PATH="${config.home.homeDirectory}/go/bin:$PATH" # go
        export PATH="${config.home.homeDirectory}/.local/share/bob/nvim-bin:$PATH" # bob-managed Neovim
        export PATH="/usr/local/sbin:$PATH"

        # --- ENVIRONMENT VARIABLES ---
        export EDITOR='nvim'
        export HOSTNAME=$(hostname)
        export LUA_CPATH=""
        export MANPAGER="less -R"
        export PAGER='bat'
        export USER=$(whoami)
        export VISUAL='nvim'
        export GCAL='-s 1 --iso-week-number=yes'

        # --- CLI TOOLS ---
        export KETCH_CONFIG="${config.home.homeDirectory}/.config/ketch/config.json"

        # --- PI ENV VARIABLES ---
        # update provider/model with subscription changes
        export PI_PROVIDER="openai-codex"
        export PI_MODEL="gpt-5.6-luna"
        export PI_FALLBACK_PROVIDER="ollama"
        export PI_FALLBACK_MODEL="gemma4:31b-cloud"

        # --- PYTHON/UV CONFIGURATION ---
        # Point UV at the Home Manager profile Python. On generic Linux the
        # profile is linked at ~/.nix-profile and is on PATH.
        export UV_PYTHON="${config.home.profileDirectory}/bin/python3"

        # --- SECRETS (from `pass`) ---
        [ -r "${config.home.homeDirectory}/.variables.env" ] && \
          source "${config.home.homeDirectory}/.variables.env"

        # --- WAYLAND CLIPBOARD ---
        # The shared aliases/functions assume macOS `pbcopy`/`pbpaste`.
        if command -v wl-copy &>/dev/null; then
          alias pbcopy='wl-copy'
          alias pbpaste='wl-paste'
        fi

        # --- ZSH ---
        export ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
        export ZVM_KEYTIMEOUT=1 # 1 second

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
            echo "$CUTBUFFER" | wl-copy
        }
        zle -N vi-yank-clipboard
        bindkey -M vicmd y vi-yank-clipboard
      '';
      plugins = [
        {
          # Defer slow completions until ZLE is idle (fires after first prompt)
          # Prevents custom tool completions from blocking shell startup
          name = "zsh-defer";
          src = pkgs.zsh-defer;
          file = "share/zsh-defer/zsh-defer.plugin.zsh";
        }
      ];
      shellAliases = {
        # Switch the Omarchy Home Manager configuration
        hms = "home-manager switch --flake ${config.home.homeDirectory}/.dotfiles/.config/nix#omarchy";
      };
    };

    # Enable some useful tools
    fzf = {
      enable = true;
      enableZshIntegration = true;
      historyWidget.command = ""; # avoid conflict with atuin
    };
    atuin = {
      enable = true;
      enableZshIntegration = true;
      flags = [
        "--disable-up-arrow" # Disable up arrow to search history, conflicts with zsh-autosuggestions
      ];
    };
    carapace = {
      enable = true; # covers 1000+ standard tools; custom tools handled via zsh-defer
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
