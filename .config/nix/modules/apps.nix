{ pkgs, ... }: {

  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  INFO: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are
  # reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    git
    just # use Justfile to simplify nix-darwin's commands
    neovim
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
      "nikitabobko/tap" # for aerospace
      "FelixKratz/formulae" # for jankyborders
    ];

    brews = [
      "llm" # permission to install models
      "borders" # jankyborders
      "gnu-sed" # spectre
      "wget" # download tool
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!
    ];

    casks = [
      "aerospace" # have not tested this (possible replacement for yabai/skhd)
      "appcleaner"
      "balenaetcher"
      "bettermouse"
      "calibre"
      "chromium"
      "docker"
      "dropbox"
      "espanso"
      "fantastical"
      "firefox" # (only on nix linux)
      "google-drive"
      "jordanbaird-ice"
      "kap"
      "mullvadvpn"
      "obsidian" # (only on nix linux)
      "praat"
      "raycast"
      "sequel-ace"
      "transcribe"
      "transmission"
      "zotero@beta"
    ];

    # INFO: Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple
    # account have records for them. Otherwise Apple Store will refuse to
    # install them. For details, see https://github.com/mas-cli/mas
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
