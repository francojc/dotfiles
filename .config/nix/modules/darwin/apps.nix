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

    # Note: run `brew trust --tap <tap>` to trust the tap
    # This creates a ~/.homebrew/trust.json file entry
    taps = [
      {
        name = "acrogenesis/macchanger";
        trusted = true;
      } # macchanger
      {
        name = "adembc/tap";
        trusted = true;
      } # lazyssh
      {
        name = "felixkratz/formulae";
        trusted = true;
      } # borders
      {
        name = "herald-email/herald";
        trusted = true;
      } # herald
      {
        name = "keith/formulae";
        trusted = true;
      } # reminders-cli
      {
        name = "librespeed/tap";
        trusted = true;
      } # librespeed-cli
      {
        name = "modem-dev/tap";
        trusted = true;
      } # hunk
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
    ];

    brews = [
      "borders" # jankyborders
      "git-filter-repo" # remove files/dirs from git history
      "herald" # herald
      "hf" # huggingface cli
      "hunk" # git diff tool
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
      # "helix" # text editor
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
      "supacode" # Agentic harness session manager
      "tidal" # music streaming
      "zen" # browser
      "zoom" # video conferencing
      "zotero" # reference manager
      # "blackhole-2ch" # virtual audio driver
      # "chatgpt" # ChatGPT
      # "loopback" # audio routing
      # "obs" # OBS Studio for streaming and recording
      # "telegram" # messaging (bot)
      # "visual-studio-code" # code editor
      # "vlc" # media player
    ];
  };
}
