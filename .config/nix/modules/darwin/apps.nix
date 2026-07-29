# Shared Homebrew packages for all Darwin hosts.
# Host-specific packages live in each host's default.nix.
{pkgs, ...}: {
  # Add system packages
  environment.systemPackages = with pkgs; [
    # nix-darwin specific apps on nixpkgs
    coreutils-prefixed # GNU coreutils with g-prefix (avoids shadowing BSD commands)
    terminal-notifier # macOS notifications from command line
    gcal # GNU cal command
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
      extraEnv = {
        HOMEBREW_NO_ANALYTICS = "1";
        HOMEBREW_NO_ENV_HINTS = "1";
      };
      extraFlags = [];
    };

    taps = [
      {
        name = "adembc/tap";
        trusted = true;
      } # lazyssh
      {
        name = "felixkratz/formulae";
        trusted = true;
      } # borders
      {
        name = "keith/formulae";
        trusted = true;
      } # reminders-cli
      {
        name = "librespeed/tap";
        trusted = true;
      } # librespeed-cli
      {
        name = "nao1215/tap";
        trusted = true;
      } # sqly
      {
        name = "radiosilence/koan";
        trusted = true;
      } # koan
      {
        name = "raine/workmux";
        trusted = true;
      } # workmux
      {
        name = "1broseidon/tap"; # ketch
        trusted = true;
      }
      {
        name = "westpoint-io/lazyrsync"; # lazyrsync
        trusted = true;
      }
    ];

    brews = [
      "borders" # jankyborders
      "git-filter-repo" # remove files/dirs from git history
      # "hunk" # git diff tool
      "ketch" # web search, library docs, scraping cli
      "koan" # Navidrome TUI player
      "lazyrsync" # tui for managing rsync
      "lazyssh" # lazyssh
      "librespeed-cli"
      "llm" # llm.dataset.io
      "mole" # terminal cleanup app for macOS
      "nmap" # network scanner
      "node" # Node.js
      "officecli" # AI-accessible office suite conversion/creation
      "pngpaste" # paste images
      "reminders-cli" # cli interface to macOS Reminders
      "rename" # file renaming utility
      "signal-cli" # Signal CLI
      "tree-sitter-cli" # tree-sitter CLI
      "workmux" # agentic ai multiplexer
      "yt-dlp" # YouTube video downloader
      # "cairo" # 2D graphics library
      # "gdk-pixbuf" # image loading library
      # "helix" # text editor
      # "libffi" # Foreign Function Interface library
      # "ninja" # build system
      # "pango" # text layout library
      # "sqly" # interactive SQL client
      # "vhs" # cli for programmable terminal gifs
      # "weasyprint" # HTML to PDF converter
    ];

    casks = [
      "anythingllm" # llm harness/desktop app
      "appcleaner" # remove macOS apps
      "betterdisplay" # display tweaks
      "bettermouse" # mouse tweaks
      "bettershot" # screenshot tool
      "dorso" # posture monitor
      "fluidvoice" # TTS on device
      "ghostty" # Terminal emulator
      "helium-browser" # browser (ungoogled-chromium)
      "kap" # screen recording
      "keycastr" # keystroke visualizer
      "kitty" # terminal emulator (moved to Nix)
      "obsidian" # note-taking
      "raycast" # productivity launcher
      "rectangle" # window management
      "signal" # messaging
      "telegram" # messaging (bot)
      "tidal" # music streaming
      "visual-studio-code" # code editor
      "zen" # browser
      "zoom" # video conferencing
      "zotero" # reference manager
      # "blackhole-2ch" # virtual audio driver
      # "chatgpt" # ChatGPT
      # "loopback" # audio routing
      # "obs" # OBS Studio for streaming and recording
      # "vlc" # media player
    ];
  };
}
