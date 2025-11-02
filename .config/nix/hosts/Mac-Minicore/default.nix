# Host-specific configuration for Mac-Minicore
{
  # System configuration
  system = "aarch64-darwin";

  # User configuration
  username = "jeridf";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "tokyonight"; # options: arthur, autumn, gruvbox, onedark, vague, catppuccin, vscode, tokyonight, nightfox

  # Host-specific modules
  hostModules = [
    ../../profiles/darwin/configuration.nix
    ../../modules/darwin/copilot-api.nix
    ../../modules/darwin/ollama.nix
    ../../modules/darwin/reddix.nix

    # Inline module for host-specific service configuration
    {
      services = {
        copilot-api = {
          enable = true;
          port = 4141;
          host = "0.0.0.0"; # Make accessible via Tailscale
        };

        ollama = {
          enable = true;
          port = 11434;
          host = "0.0.0.0"; # Make accessible via Tailscale
          flashAttention = true;
          kvCacheType = "q8_0";
          # Optional: Additional settings
          # keepModelLoaded = true;
          # extraEnvironment = {
          #   OLLAMA_NUM_PARALLEL = "4";
          # };
        };
      };
    }
  ];

  # Home Manager host-specific modules (if any)
  homeModules = [
    # Add host-specific home manager modules here if needed
    # ./home.nix
  ];
}
