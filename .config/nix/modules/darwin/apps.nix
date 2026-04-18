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
    ];

    brews = [
      "Adembc/homebrew-tap/lazyssh" # lazyssh
      "FelixKratz/formulae/borders" # jankyborders
      "acrogenesis/macchanger/macchanger" # MAC address changer
      "git-filter-repo" # remove files/dirs from git history
      "keith/formulae/reminders-cli"
      "librespeed/tap/librespeed-cli"
      "llama.cpp" # LLaMA model inference
      "llm" # llm.dataset.io
      "llmfit" # LLM system fit
      "mole" # terminal cleanup app for macOS
      "ninja" # build system
      "nmap" # network scanner
      "node" # Node.js
      "ollama" # LLM inference server (temporary replacement for nixpkgs version)
      "oronbz/tap/nag" # Reminders TUI
      "pngpaste" # paste images
      "raine/workmux/workmux" # agentic ai multiplexer
      "rename" # file renaming utility
      "signal-cli" # Signal CLI
      "sqly" # interactive SQL client
      "tree-sitter-cli" # tree-sitter CLI
      # "waynehoover/tap/pbrich" # pbcopy for multiple formats (text, html, rtf, images)

      # WeasyPrint/Cairo dependencies for marker-pdf DOCX/PPTX support
      # Installed via Homebrew because UV-installed marker-pdf needs
      # system-level C libraries via DYLD_FALLBACK_LIBRARY_PATH.
      # Nix's library isolation makes this difficult for UV tools.
      "cairo" # 2D graphics library
      "pango" # text layout library
      "gdk-pixbuf" # image loading library
      "libffi" # Foreign Function Interface library
      "weasyprint" # HTML to PDF converter
      "yt-dlp" # YouTube video downloader
    ];

    casks = [
      "appcleaner" # remove macOS apps
      "betterdisplay" # display tweaks
      "bettermouse" # mouse tweaks
      "bettershot" # screenshot tool
      "claude" # Claude Desktop
      "ghostty" # Terminal emulator
      # "google-chrome"
      "ungoogled-chromium" # Chromium without Google tracking
      "kap" # screen recording
      "kitty" # terminal emulator (moved to Nix)
      "obsidian" # note-taking
      "opencode-desktop" # opencode desktop app
      "raycast" # productivity launcher
      "rectangle" # window management
      "signal" # messaging
      "telegram" # messaging (bot)
      "visual-studio-code" # code editor
      "vlc" # media player
      "zen" # browser
      "zoom" # video conferencing
      "zotero" # reference manager
      "keycastr" # keystroke visualizer
      # "blackhole-2ch" # virtual audio driver
      # "loopback" # audio routing
      # "obs" # OBS Studio for streaming and recording
    ];
  };
}
