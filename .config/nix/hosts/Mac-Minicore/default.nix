# Host-specific configuration for Mac-Minicore
{
  # System configuration
  system = "aarch64-darwin";

  # User configuration
  username = "jeridf";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "vague"; # options: arthur, autumn, gruvbox, onedark, vague

  # Host-specific modules
  hostModules = [
    ../../profiles/darwin/configuration.nix
    ../../modules/darwin/copilot-api.nix
    ../../modules/darwin/ollama.nix
  ];

  # Home Manager host-specific modules (if any)
  homeModules = [
    # Add host-specific home manager modules here if needed
    # ./home.nix
  ];

  # Enable services specific to this host
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
