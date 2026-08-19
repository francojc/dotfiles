# Host-specific configuration for Macbook-Airborne
{
  # System configuration
  system = "aarch64-darwin";

  # User configuration
  username = "francojc";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "ayu"; # options: arthur, ayu, blackmetal, catppuccin, gruvbox, kanso, nightfox, onedark, tokyonight, vague, vscode

  # Host-specific modules
  hostModules = [
    ../../profiles/darwin/configuration.nix
    ../../modules/darwin/copilot-api.nix
    {
      custom.services.copilotApi.enable = true;
    }

    # Host-specific Homebrew packages (merged with shared apps.nix)
    {
      homebrew = {
        taps = [
          {
            name = "acrogenesis/macchanger";
            trusted = true;
          } # macchanger
        ];
        brews = [
          # Macbook-Airborne-only brews here
          "transmission-cli" # command-line torrent client
          "macchanger" # MAC address changer
        ];
        casks = [
          "dropbox" # cloud storage
          "orbstack" # Docker alternative
          "transmission" # torrent client
          # "android-platform-tools" # ADB and Fastboot (for TVs)
          # "balenaetcher" # disk image writer
          # "calibre" # eBook management
          # "transcribe"
        ];
      };
    }
  ];

  # Home Manager host-specific modules (if any)
  homeModules = [
    # Add host-specific home manager modules here if needed
    # ./home.nix
  ];
}
