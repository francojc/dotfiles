{pkgs, ...}: {
  # Add system packages
  environment.systemPackages = with pkgs; [
    # nix-darwin specific apps on nixpkgs
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [];

    brews = [
      "Adembc/homebrew-tap/lazyssh" # lazyssh
      "acrogenesis/macchanger/macchanger" # MAC address changer
      "android-platform-tools" # ADB and Fastboot
      "FelixKratz/formulae/borders" # jankyborders
      "raine/workmux/workmux" # agentic ai multiplexer
      "llama.cpp" # LLaMA model inference
      "mole" # terminal cleanup app for macOS
      "ncspot" # spotify TUI client
      "ninja" # build system
      "nmap" # network scanner
      "node" # Node.js
      "ollama" # LLM inference server (temporary replacement for nixpkgs version)
      "pngpaste" # paste images
      "keith/formulae/reminders-cli"
      "rename" # file renaming utility
      "sqly" # interactive SQL client
      "transmission-cli" # command-line torrent client

      # WeasyPrint/Cairo dependencies for marker-pdf DOCX/PPTX support
      # Installed via Homebrew because UV-installed marker-pdf needs
      # system-level C libraries via DYLD_FALLBACK_LIBRARY_PATH.
      # Nix's library isolation makes this difficult for UV tools.
      "cairo" # 2D graphics library
      "pango" # text layout library
      "gdk-pixbuf" # image loading library
      "libffi" # Foreign Function Interface library
      "weasyprint" # HTML to PDF converter
    ];

    casks = [
      "appcleaner" # remove macOS apps
      "betterdisplay" # display tweaks
      "bettermouse" # mouse tweaks
      "bettershot" # screenshot tool
      "calibre" # eBook management
      "chatgpt"
      "claude" # Claude Desktop
      "dropbox"
      "fbreader" # eBook reader
      "ghostty" # Terminal emulator
      "google-chrome"
      "google-drive"
      "kap" # screen recording
      "kitty" # terminal emulator
      "lm-studio" # LLM model gui/cli
      "obsidian" # note-taking
      "orbstack" # Docker alternative
      "parallels" # virtualization
      "raycast" # productivity launcher
      "rectangle" # window management
      "signal" # messaging
      "spotify" # music streaming
      "transmission"
      "vlc" # media player
      "wezterm@nightly" # terminal emulator
      "zen" # browser
      "zoom" # video conferencing
      "zotero@beta" # reference manager
      # "blackhole-2ch" # virtual audio driver
      # "keycastr" # keystroke visualizer
      # "loopback" # audio routing
      # "obs" # OBS Studio for streaming and recording
      # "transcribe"
    ];

    masApps = {
      # `mas` is not currently compatible with my OS
      # memorydiag = 748212890;
      # JustFocus = 1142151959;
      # Suggester = 1106482294;
      # iMovie = 408981434;
      # Bitwarden = 1352778147;
      # GarageBand = 682658836;
      # IPA_Keyboard = 1461264628;
      # Keynote = 409183694;
      # Numbers = 409203825;
      # Pages = 409201541;
      # Triode = 1450027401;
      # iPreview = 1519213509;
      # windows-app = 1295203466;
    };
  };
}
