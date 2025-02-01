{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    age
    carapace
    curl
    direnv
    git
    just
    nixd
    nurl
    nushell
    vim
    zoxide
  ];

  environment.variables.EDITOR = "nvim";

  # see https://brew.sh
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
    ];

    brews = [
      "borders" # jankyborders
      "helix"
      "mas"
      "ollama"
      "podman"
      "rename"
      "wget"
    ];

    casks = [
      "appcleaner"
      "bettermouse"
      "chatgpt"
      "docker"
      "dropbox"
      "fantastical"
      "ghostty@tip"
      "google-chrome"
      "google-drive"
      "kap"
      "keycastr"
      "lm-studio"
      "mullvadvpn"
      "obsidian"
      "podman-desktop"
      "praat"
      "raycast"
      "rectangle"
      "rstudio"
      "sequel-ace"
      "superkey"
      "transcribe"
      "transmission"
      "visual-studio-code"
      "zen-browser"
      "zoom"
      "zotero@beta"
      # "calibre"
    ];

    masApps = {
      # GarageBand = 682658836;
      # iMovie = 408981434;
      Adblock_Plus = 1432731683;
      AudioBookBinder = 413969927;
      Bitwarden = 1352778147;
      Dark_Reader_for_Safari = 1438243180;
      IPA_Keyboard = 1461264628;
      JustFocus = 1142151959;
      # LittleSnitchMini = 1629008763;
      Kagi_for_Safari = 1622835804;
      Keynote = 409183694;
      Numbers = 409203825;
      Pages = 409201541;
      Suggester = 1106482294;
      Triode = 1450027401;
      Vimari = 1480933944;
      Vinegar_for_Safari = 1591303229;
      VoiceType = 6736525125;
      iPreview = 1519213509;
    };
  };
}
