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
    };

    taps = [
      "Adembc/homebrew-tap" # lazyssh
      "FelixKratz/formulae" # borders
      "acrogenesis/macchanger" # macchanger
      "floatpane/matcha" # matcha
      "keith/formulae" # reminders-cli
      "librespeed/tap" # librespeed-cli
      "raine/workmux" # workmux
    ];

    brews = [
      "borders" # jankyborders
      "cairo" # 2D graphics library
      "gdk-pixbuf" # image loading library
      "git-filter-repo" # remove files/dirs from git history
      "lazyssh" # lazyssh
      "libffi" # Foreign Function Interface library
      "librespeed-cli"
      "llama.cpp" # LLaMA model inference
      "llm" # llm.dataset.io
      "llmfit" # LLM system fit
      "macchanger" # MAC address changer
      # "floatpane/matcha/matcha" # matcha (tui email client)
      "mole" # terminal cleanup app for macOS
      "ninja" # build system
      "nmap" # network scanner
      "node" # Node.js
      "ollama" # Ollama
      "pango" # text layout library
      "pngpaste" # paste images
      "reminders-cli"
      "rename" # file renaming utility
      "signal-cli" # Signal CLI
      "sqly" # interactive SQL client
      "tree-sitter-cli" # tree-sitter CLI
      "vhs" # cli for programmable terminal gifs
      "weasyprint" # HTML to PDF converter
      "workmux" # agentic ai multiplexer
      "yt-dlp" # YouTube video downloader
    ];

    casks = [
      "appcleaner" # remove macOS apps
      "betterdisplay" # display tweaks
      "bettermouse" # mouse tweaks
      "bettershot" # screenshot tool
      "claude" # Claude Desktop
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
      "visual-studio-code" # code editor
      "vlc" # media player
      "zen" # browser
      "zoom" # video conferencing
      "zotero" # reference manager
      # "blackhole-2ch" # virtual audio driver
      # "loopback" # audio routing
      # "obs" # OBS Studio for streaming and recording
    ];
  };
}
