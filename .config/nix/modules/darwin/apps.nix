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

    taps = [
      "FelixKratz/formulae" # for jankyborders
    ];

    brews = [
      "Adembc/homebrew-tap/lazyssh" # lazyssh
      "acrogenesis/macchanger/macchanger" # MAC address changer
      "borders" # jankyborders
      "huggingface-cli"
      "keith/formulae/reminders-cli"
      "ncspot" # ncurses Spotify client
      {
        name = "neovim";
        args = ["HEAD"];
      }
      "nmap"
      "node" # Node.js
      "pngpaste" # paste images
      "python@3.11" # Python 3
      "rename" # file renaming utility
      "sqly" #
      "transmission-cli" # command-line torrent client
      "uv"
    ];

    casks = [
      "vladdoster/formulae/vimari" # Vimari browser extension
      "appcleaner" # remove macOS apps
      "betterdisplay" # display tweaks
      "bettermouse" # mouse tweaks
      # "blackhole-2ch" # virtual audio driver
      "calibre" # eBook management
      "camo-studio" # webcam software
      "chatgpt"
      "claude" # Claude Desktop
      "dropbox"
      "ghostty" # Terminal emulator
      "google-drive"
      "kap" # screen recording
      "kitty" # terminal emulator
      # "keycastr" # keystroke visualizer
      # "loopback" # audio routing
      # "obs" # OBS Studio for streaming and recording
      "obsidian"
      "orbstack" # Docker alternative
      "parallels" # virtualization
      "raycast"
      "rectangle"
      "signal" # messaging
      "spotify" # music streaming
      "transcribe"
      "transmission"
      "wezterm@nightly" # terminal emulator
      "zen" # browser
      "zoom"
      "zotero@beta" # reference manager
    ];

    masApps = {
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
