{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    just
    nixd
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
      "nikitabobko/tap" # for aerospace
    ];

    brews = [
      "borders" # jankyborders
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!
      "gnu-sed" # spectre
      "mas"
      "rename"
      "wget" # download tool
    ];

    casks = [
      "aerospace"
      "appcleaner"
      "bettermouse"
      # "calibre"
      "chatgpt"
      "docker"
      "dropbox"
      "fantastical"
      "google-chrome"
      "google-drive"
      "kap"
      "kitty"
      "mullvadvpn"
      "obsidian"
      "praat"
      "raycast"
      "rectangle"
      "sequel-ace"
      "transcribe"
      "transmission"
      "visual-studio-code"
      "wezterm@nightly"
      "zen-browser"
      "zoom"
      "zotero@beta"
    ];

    masApps = {
      Adblock_Plus = 1432731683;
      AudioBookBinder = 413969927;
      Bitwarden = 1352778147;
      Dark_Reader_for_Safari = 1438243180;
      # GarageBand = 682658836;
      # iMovie = 408981434;
      IPA_Keyboard = 1461264628;
      iPreview = 1519213509;
      JustFocus = 1142151959;
      Kagi_for_Safari = 1622835804;
      Keynote = 409183694;
      Numbers = 409203825;
      Pages = 409201541;
      Suggester = 1106482294;
      Triode = 1450027401;
      Vimari = 1480933944;
      Vinegar_for_Safari = 1591303229;
      # Xcode = 497799835;
    };
  };
}
