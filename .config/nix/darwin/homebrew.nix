# ~/.config/nix/darwin/homebrew.nix
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [
      "nikitabobko/tap" # for aerospace
      "FelixKratz/formulae" # for jankyborders
    ];
    brews = [
      "llm" # permission to install models
      "borders" # jankyborders
      "gnu-sed" # spectre
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
    masApps = {
      # need to add bitwarden here (safari extension)

    };
  };
}
