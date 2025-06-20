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
      "nao1215/tap" # for sqly
      "pomdtr/tap" # for sunbeam
    ];

    brews = [
      "borders" # jankyborders
      "huggingface-cli"
      "keith/formulae/reminders-cli"
      "mas" # Mac App Store CLI
      "npm"
      "ollama" # AI model management
      "pngpaste" # paste images
      "python@3.11"
      "rename"
      "sqly"
      "sunbeam"
      "uv"
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
      "obsidian"
      "orbstack" # Docker alternative
      "parallels" # virtualization
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
      "zotero@beta" # reference manager
    ];

    masApps = {
      # Adblock_Plus = 1432731683;
      # AudioBookBinder = 413969927;
      # Dark_Reader_for_Safari = 1438243180;
      # JustFocus = 1142151959;
      # Kagi_for_Safari = 1622835804;
      # LittleSnitchMini = 1629008763;
      # Suggester = 1106482294;
      # Vimari = 1480933944;
      # Vinegar_for_Safari = 1591303229;
      # VoiceType = 6736525125;
      # iMovie = 408981434;
      Bitwarden = 1352778147;
      GarageBand = 682658836;
      IPA_Keyboard = 1461264628;
      Keynote = 409183694;
      Numbers = 409203825;
      Pages = 409201541;
      Triode = 1450027401;
      iPreview = 1519213509;
      windows-app = 1295203466;
    };
  };
}
