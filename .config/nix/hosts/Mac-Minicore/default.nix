# Host-specific configuration for Mac-Minicore
{
  # System configuration
  system = "aarch64-darwin";

  # User configuration
  username = "jeridf";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "gruvbox"; # options: arthur, ayu, blackmetal, catppuccin, gruvbox, kanso, nightfox, onedark, tokyonight, vague, vscode

  # Host-specific modules
  hostModules = [
    ../../profiles/darwin/configuration.nix
    ../../modules/darwin/llama-qwen-server.nix
    ../../modules/darwin/llama-embed-server.nix
    ../../modules/darwin/llama-fim-server.nix
    ../../modules/darwin/copilot-api.nix

    # Inline module for host-specific service configuration
    {
      custom.services = {
        copilotApi.enable = true;

        # Fixed Qwen3.5 9B chat endpoint on :8081
        llamaQwen = {
          enable = true;
          scriptPath = "/Users/jeridf/.llama.cpp/scripts/start-llama-qwen.sh";
        };

        # Dedicated embeddings endpoint on :8082
        llamaEmbed = {
          enable = true;
          scriptPath = "/Users/jeridf/.llama.cpp/scripts/start-llama-embed.sh";
        };

        # Fill-in-the-middle code completion endpoint on :8080
        llamaFim = {
          enable = true;
          scriptPath = "/Users/jeridf/.llama.cpp/scripts/start-llama-fim.sh";
        };
      };

      # Host-specific Homebrew packages (merged with shared apps.nix)
      homebrew = {
        # taps = [
        #   {
        #     name = "jundot/omlx";
        #     trusted = true;
        #   } # omlx
        # ];
        brews = [
          # Mac-Minicore-only brews here
          "llama.cpp" # LLaMA model inference
          "ollama" # Ollama
          # "omlx"
          "hf" # huggingface cli
          "llmfit" # LLM system fit
        ];
        casks = [
          # Mac-Minicore-only casks here
          "google-drive" # Google Drive sync
          "lm-studio" # LLM interface
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
