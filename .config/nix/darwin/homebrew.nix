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
    ];
    casks = [
      "aerospace" # have not tested this (possible replacement for yabai/skhd)
      "appcleaner"
      "balenaetcher"
      "bettermouse"
      "bitwarden" # (only on nix linux)
      "calibre"
      "chromium"
      "docker"
      "dropbox"
      "espanso"
      "fantastical"
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
    masApps = { };
  };
}
