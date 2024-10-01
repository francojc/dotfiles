{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    just
  ];

  environment.variables.EDITOR = "nvim";

  # INFO: To make this work, homebrew need to be installed manually,
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
      # "nikitabobko/tap" # for aerospace
      "FelixKratz/formulae" # for jankyborders
    ];

    brews = [
      "aicommits" # not on nixpkgs
      "llm" # permission to install models
      "borders" # jankyborders
      "gnu-sed" # spectre
      "wget" # download tool
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!
    ];

    casks = [
      "appcleaner"
      "bettermouse"
      "calibre"
      "chromium"
      "docker"
      "dropbox"
      "fantastical"
      "google-drive"
      "kap"
      "mullvadvpn"
      "obsidian" # (only on nix linux)
      "praat"
      "raycast"
      "rio"
      "sequel-ace"
      "transcribe"
      "transmission"
      "visual-studio-code"
      "zen-browser"
      "zotero@beta"
    ];

    masApps = {
      # Xcode = 497799835;
      IPA_Keyboard = 1461264628;
      AudioBookBinder = 413969927;
      iMovie = 408981434;
      Keynote = 409183694;
      Adblock_Plus = 1432731683;
      iPreview = 1519213509;
      Dark_Reader_for_Safari = 1438243180;
      Pages = 409201541;
      Vimari = 1480933944;
      GarageBand = 682658836;
      Triode = 1450027401;
      Bitwarden = 1352778147;
      Numbers = 409203825;
    };
  };
}
