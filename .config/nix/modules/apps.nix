{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alejandra
    age
    brave
    carapace
    codespell
    curl
    direnv
    git
    glow
    just
    lla
    lynx
    marksman
    nixd
    nurl
    oterm
    stylua
    vim
    viu
    w3m
  ];

  environment.variables.EDITOR = "nvim";

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
      # "bash-language-server"
      "borders" # jankyborders
      "dstask"
      "huggingface-cli"
      # "lua-language-server"
      "npm"
      "ollama"
      "python@3.11"
      "rename"
      "speedtest-cli"
      "sunbeam"
      "sqly"
      "wget"
    ];

    casks = [
      "appcleaner"
      "betterdisplay"
      "bettermouse"
      "claude"
      "docker"
      "dropbox"
      "ghostty@tip"
      "google-drive"
      "kap"
      "keycastr"
      "memory-cleaner"
      "mullvadvpn"
      "obsidian"
      "raycast"
      "rectangle"
      "rocket"
      "transcribe"
      "transmission"
      "visual-studio-code"
      "zen-browser"
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
    };
  };
}
