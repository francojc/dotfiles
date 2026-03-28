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
    ../../modules/darwin/reddix.nix

    # Host-specific Homebrew packages (merged with shared apps.nix)
    {
      homebrew = {
        brews = [
          # Macbook-Airborne-only brews here
          "transmission-cli" # command-line torrent client
        ];
        casks = [
          # Macbook-Airborne-only casks here
          # "calibre" # eBook management
          "android-platform-tools" # ADB and Fastboot (for TVs)
          "dropbox" # cloud storage
          "lm-studio" # LLM model gui/cli
          "orbstack" # Docker alternative
          "parallels" # virtualization
          "transmission" # torrent client
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
