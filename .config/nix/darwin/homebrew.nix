# ~/.config/nix/darwin/homebrew.nix
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [];
    brews = [
      "coreutils"
      "gettext" # for radian
    ];
    casks = [
      "appcleaner"
      "arc"
      "audacity"
      "bettermouse"
      "bitwarden"
      "calibre"
      "datasette"
      "docker"
      "drawio"
      "dropbox"
      "espanso"
      "font-hack"
      "font-hack-nerd-font"
      "font-meslo-lg-nerd-font"
      "font-symbols-only-nerd-font"
      "google-drive"
      "jordanbaird-ice"
      "kap"
      "mullvadvpn"
      "obsidian"
      "praat"
      "quarto"
      "raycast"
      "rectangle"
      "sequel-ace"
      "stolendata-mpv"
      "transcribe"
      "xquartz"
      "zoom"
      "zotero@beta"
    ];
    masApps = {};
  };
}
