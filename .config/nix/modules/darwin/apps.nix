{pkgs, ...}: {
  # Add system packages
  environment.systemPackages = with pkgs; [
    pngpaste # Example of a potentially darwin-specific addition
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [
      "homebrew/services"
      "FelixKratz/formulae" # for jankyborders
      "nao1215/tap" # for sqly
      "pomdtr/tap" # for sunbeam
    ];

    brews = [
      "borders" # jankyborders
      "huggingface-cli"
      "mas" # Mac App Store CLI
      "npm"
      "keith/formulae/reminders-cli"
      "ollama"
      "python@3.11"
      "rename"
      "sunbeam"
      "sqly"
      "wget"
    ];

    casks = [
      "appcleaner" # remove macOS apps
      "betterdisplay" # display tweaks
      "bettermouse" # mouse tweaks
      "chatgpt"
      "claude" #
      "dropbox"
      "ghostty" # Terminal emulator
      "google-drive"
      "kap" # screen recording
      "memory-cleaner"
      "obsidian"
      "orbstack" # Docker alternative
      "parallels" # virtualization
      "protonvpn"
      "raycast"
      "rectangle"
      "rocket" # emoji picker
      "signal" # messaging
      "transcribe"
      "transmission"
      "visual-studio-code"
      "yaak" # API client
      "zen" # browser
      "zoom"
      "zotero@beta"
    ];

    masApps = {
      GarageBand = 682658836;
      # iMovie = 408981434;
      # Adblock_Plus = 1432731683;
      # AudioBookBinder = 413969927;
      Bitwarden = 1352778147;
      # Dark_Reader_for_Safari = 1438243180;
      IPA_Keyboard = 1461264628;
      # JustFocus = 1142151959;
      # LittleSnitchMini = 1629008763;
      # Kagi_for_Safari = 1622835804;
      Keynote = 409183694;
      Numbers = 409203825;
      Pages = 409201541;
      # Suggester = 1106482294;
      Triode = 1450027401;
      # Vimari = 1480933944;
      # Vinegar_for_Safari = 1591303229;
      # VoiceType = 6736525125;
      iPreview = 1519213509;
      windows-app = 1295203466;
    };
  };
}
