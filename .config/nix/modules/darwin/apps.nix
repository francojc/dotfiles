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
        name = "adembc/tap"; # lazyssh
        trusted = true;
      }
      {
        name = "felixkratz/formulae"; # borders
        trusted = true;
      }
      {
        name = "keith/formulae"; # reminders-cli
        trusted = true;
      }
      {
        name = "librespeed/tap"; # librespeed-cli
        trusted = true;
      }
      {
        name = "nao1215/tap"; # sqly
        trusted = true;
      }
      {
        name = "radiosilence/koan"; # koan
        trusted = true;
      }
      {
        name = "raine/workmux"; # workmux
        trusted = true;
      }
      {
        name = "1broseidon/tap"; # ketch
        trusted = true;
      }
      {
        name = "westpoint-io/lazyrsync"; # lazyrsync
        trusted = true;
      }
      {
        name = "shobhit99/tap"; # supercmd
        trusted = true;
      }
    ];

    brews = [
      "borders" # jankyborders
      "git-filter-repo" # remove files/dirs from git history
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
      # "hunk" # git diff tool
      # "libffi" # Foreign Function Interface library
      # "ninja" # build system
      # "pango" # text layout library
      # "sqly" # interactive SQL client
      # "vhs" # cli for programmable terminal gifs
      # "weasyprint" # HTML to PDF converter
    ];

    casks = [
      "appcleaner" # remove macOS apps
      "betterdisplay" # display tweaks
      "bettermouse" # mouse tweaks
      "bettershot" # screenshot tool
      "fluidvoice" # TTS on device
      "ghostty" # Terminal emulator
      "helium-browser" # browser (ungoogled-chromium)
      "kap" # screen recording
      "kitty" # terminal emulator (moved to Nix)
      # "obsidian" # note-taking
      "raycast" # productivity launcher
      "rectangle" # window management
      "signal" # messaging
      "supercmd" # raycast alternative in swift
      "telegram" # messaging (bot)
      "zen" # browser
      "zoom" # video conferencing
      "zotero" # reference manager
      # "anythingllm" # llm harness/desktop app
      # "blackhole-2ch" # virtual audio driver
      # "chatgpt" # ChatGPT
      # "dorso" # posture monitor
      # "keycastr" # keystroke visualizer
      # "loopback" # audio routing
      # "obs" # OBS Studio for streaming and recording
      # "tidal" # music streaming
      # "visual-studio-code" # code editor
      # "vlc" # media player
    ];
  };
}
