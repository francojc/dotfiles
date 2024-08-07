# ~/.config/nix/darwin/homebrew.nix
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [ ];
    brews = [
      "llm" # permission to install models
    ];
    casks = [
      "appcleaner"
      "arc"
      "audacity"
      "bettermouse"
      "bitwarden"
      "calibre"
      "chromium"
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
      "raycast"
      "rectangle"
      "sequel-ace"
      "transcribe"
      "zotero@beta"
    ];
    masApps = { };
  };
}
