# Host-specific configuration for Mac-Minicore
{
  # System configuration
  system = "aarch64-darwin";

  # User configuration
  username = "jeridf";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "gruvbox"; # options: arthur, autumn, ayu, gruvbox, onedark, vague, catppuccin, vscode, tokyonight, nightfox

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
      };

      custom.services = {
        # IMPORTANT: Hybrid Homebrew + Nix Ollama Setup
        #
        # The Ollama service runs from Homebrew (/opt/homebrew/bin/ollama)
        # via a manually-created LaunchAgent plist at:
        # ~/Library/LaunchAgents/com.github.ollama.plist
        #
        # This Nix config sets system environment variables but does NOT
        # manage the service itself. LaunchAgents run in isolated
        # environments and only see variables declared in their plist.
        #
        # MANUAL SYNC REQUIRED: When you change settings below, you must:
        # 1. Run: darwin-rebuild switch
        # 2. Update: ~/Library/LaunchAgents/com.github.ollama.plist
        #    Add/update EnvironmentVariables dict with all settings:
        #    - OLLAMA_HOST (from host:port)
        #    - OLLAMA_MODELS (from modelsPath, default: ~/.ollama/models)
        #    - OLLAMA_FLASH_ATTENTION (1 if flashAttention = true)
        #    - OLLAMA_KV_CACHE_TYPE (from kvCacheType)
        #    - All keys from extraEnvironment
        # 3. Reload service:
        #    launchctl unload ~/Library/LaunchAgents/com.github.ollama.plist
        #    launchctl load ~/Library/LaunchAgents/com.github.ollama.plist
        ollama = {
          enable = true;
          port = 11434;
          host = "0.0.0.0"; # Make accessible via Tailscale
          flashAttention = true;
          kvCacheType = "q8_0";
          # Optional: Additional settings
          # keepModelLoaded = true;
          extraEnvironment = {
            OLLAMA_NUM_PARALLEL = "4";
            OLLAMA_NUM_CTX = "8192"; # Increase context window to 8192 tokens
          };
        };
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
