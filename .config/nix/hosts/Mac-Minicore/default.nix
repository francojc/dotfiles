# Host-specific configuration for Mac-Minicore
{
  # System configuration
  system = "aarch64-darwin";

  # User configuration
  username = "jeridf";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "ayu"; # options: arthur, ayu, blackmetal, catppuccin, gruvbox, kanso, nightfox, onedark, tokyonight, vague, vscode

  # Host-specific modules
  hostModules = [
    ../../profiles/darwin/configuration.nix
    ../../modules/darwin/llama-server.nix
    ../../modules/darwin/llama-embed-server.nix

    # Inline module for host-specific service configuration
    {
      custom.services = {
        # Local model router (OpenAI-compatible) on :8081
        llamaRouter = {
          enable = true;
          scriptPath = "/Users/jeridf/.llama.cpp/scripts/start-llama-general.sh";
        };

        # Dedicated embeddings endpoint on :8082
        llamaEmbed = {
          enable = true;
          scriptPath = "/Users/jeridf/.llama.cpp/scripts/start-llama-embed.sh";
        };
      };

      # Host-specific Homebrew packages (merged with shared apps.nix)
      homebrew = {
        brews = [
          # Mac-Minicore-only brews here
        ];
        casks = [
          # Mac-Minicore-only casks here
          "google-drive" # Google Drive sync
        ];
      };

      system.keyboard = {
        userKeyMapping = [
          {
            HIDKeyboardModifierMappingSrc = 1095216660483; # Fn key
            HIDKeyboardModifierMappingDst = 30064771302; # Right Option
          }
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
