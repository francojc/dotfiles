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
      cleanup = "none";
      upgrade = true;
      extraFlags = ["--force-cleanup" "--zap"];
    };

    taps = [
      # Note: run `brew trust --tap <tap>` to trust the tap
      # This creates a ~/.homebrew/trust.json file entry
      "Adembc/homebrew-tap" # lazyssh
      "FelixKratz/formulae" # borders
      "acrogenesis/macchanger" # macchanger
      "keith/formulae" # reminders-cli
      "librespeed/tap" # librespeed-cli
      "nao1215/tap" # sqly
      "radiosilence/koan" # koan
      "raine/workmux" # workmux
    ];

    brews = [
      "borders" # jankyborders
      "git-filter-repo" # remove files/dirs from git history
      "helix" # text editor
      "hf" # huggingface cli
      "koan" # Navidrome TUI player
      "lazyssh" # lazyssh
      "librespeed-cli"
      "llm" # llm.dataset.io
      "llmfit" # LLM system fit
      "macchanger" # MAC address changer
      "mole" # terminal cleanup app for macOS
      "nmap" # network scanner
      "node" # Node.js
      "pngpaste" # paste images
      "reminders-cli" # cli interface to macOS Reminders
      "rename" # file renaming utility
      "signal-cli" # Signal CLI
      "sqly" # interactive SQL client
      "tree-sitter-cli" # tree-sitter CLI
      "vhs" # cli for programmable terminal gifs
      "workmux" # agentic ai multiplexer
      "yt-dlp" # YouTube video downloader
      # "cairo" # 2D graphics library
      # "gdk-pixbuf" # image loading library
      # "libffi" # Foreign Function Interface library
      # "ninja" # build system
      # "pango" # text layout library
      # "weasyprint" # HTML to PDF converter
    ];

    casks = [
      "appcleaner" # remove macOS apps
      "betterdisplay" # display tweaks
      "bettermouse" # mouse tweaks
      "bettershot" # screenshot tool
      "chatgpt" # ChatGPT
      "claude" # Claude Desktop
      "dorso" # posture monitor
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
