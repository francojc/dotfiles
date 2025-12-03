{ pkgs, config, lib, username, ... }:
with lib;
let
  cfg = config.custom.services.ollama;
in {
  options.custom.services.ollama = {
    enable = mkEnableOption "ollama environment configuration (Homebrew-based)";

    port = mkOption {
      type = types.int;
      default = 11434;
      description = "Port to bind the service to";
    };

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Host to bind the service to (0.0.0.0 for all interfaces)";
    };

    modelsPath = mkOption {
      type = types.str;
      default = "/Users/${username}/.ollama/models";
      description = "Path to store ollama models";
    };

    flashAttention = mkOption {
      type = types.bool;
      default = true;
      description = "Enable flash attention for faster inference";
    };

    kvCacheType = mkOption {
      type = types.str;
      default = "q8_0";
      description = "KV cache quantization type (q8_0, q4_0, f16, etc.)";
    };

    keepModelLoaded = mkOption {
      type = types.bool;
      default = false;
      description = "Keep models loaded in memory";
    };

    extraEnvironment = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional environment variables to pass to ollama";
      example = {
        OLLAMA_NUM_PARALLEL = "4";
        OLLAMA_MAX_LOADED_MODELS = "2";
      };
    };
  };

  config = mkIf cfg.enable {
    # Set system-wide environment variables for Ollama (Homebrew-based)
    # These will be available to the brew services ollama process
    environment.variables = {
      OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
      OLLAMA_MODELS = cfg.modelsPath;
    }
    // optionalAttrs cfg.flashAttention {
      OLLAMA_FLASH_ATTENTION = "1";
    }
    // optionalAttrs (cfg.kvCacheType != "") {
      OLLAMA_KV_CACHE_TYPE = cfg.kvCacheType;
    }
    // optionalAttrs cfg.keepModelLoaded {
      OLLAMA_KEEP_ALIVE = "-1";
    }
    // cfg.extraEnvironment;

    # MANUAL SETUP REQUIRED AFTER SWITCHING TO HOMEBREW:
    # ===================================================
    #
    # 1. Install Ollama via Homebrew (if not already done):
    #    brew install ollama
    #
    # 2. Start the Ollama service:
    #    brew services start ollama
    #
    # 3. Verify the service is running:
    #    brew services list | grep ollama
    #    ollama --version
    #    curl http://localhost:${toString cfg.port}
    #
    # 4. Configure launchd environment for Homebrew service:
    #    The environment variables above are set system-wide, but if they
    #    don't take effect for the brew service, you may need to:
    #
    #    a. Stop the service: brew services stop ollama
    #    b. Set per-user launchd environment:
    #       launchctl setenv OLLAMA_HOST "${cfg.host}:${toString cfg.port}"
    #       launchctl setenv OLLAMA_MODELS "${cfg.modelsPath}"
    #       ${if cfg.flashAttention then ''launchctl setenv OLLAMA_FLASH_ATTENTION "1"'' else ""}
    #       ${if cfg.kvCacheType != "" then ''launchctl setenv OLLAMA_KV_CACHE_TYPE "${cfg.kvCacheType}"'' else ""}
    #       ${if cfg.keepModelLoaded then ''launchctl setenv OLLAMA_KEEP_ALIVE "-1"'' else ""}
    #    c. Restart the service: brew services restart ollama
    #
    # 5. Test Tailscale access (if host is 0.0.0.0):
    #    From another device on your Tailscale network:
    #    curl http://<mac-minicore-tailscale-ip>:${toString cfg.port}
    #
    # 6. Check logs if issues occur:
    #    brew services info ollama
    #    tail -f $(brew --prefix)/var/log/ollama.log
    #
    # DIFFERENCES FROM NIX-MANAGED VERSION:
    # ======================================
    # - Service is managed by 'brew services' instead of nix-darwin's launchd
    # - No automatic log file creation at ~/.local/share/ollama.log
    # - No automatic models directory creation (but Ollama creates it on first use)
    # - Updates managed via 'brew upgrade ollama' instead of 'nix flake update'
    # - Service config at: ~/Library/LaunchAgents/homebrew.mxcl.ollama.plist
    #
    # TO MIGRATE BACK TO NIX IN THE FUTURE:
    # ======================================
    # 1. Disable this module in hosts/Mac-Minicore/default.nix
    # 2. Restore from backup: cp ollama-back.nix ollama.nix
    # 3. Update imports in hosts/Mac-Minicore/default.nix
    # 4. Remove 'ollama' from the homebrew.brews list in apps.nix
    # 5. Stop and uninstall: brew services stop ollama && brew uninstall ollama
    # 6. Rebuild: darwin-rebuild switch --flake ~/.dotfiles/.config/nix
    #
    # Your models at ~/.ollama/models will be preserved during migration.

    # Create necessary directories (even for Homebrew version)
    system.activationScripts.postActivation = {
      text = ''
        # Create models directory if it doesn't exist
        mkdir -p "${cfg.modelsPath}"
        chown ${username}:staff "${cfg.modelsPath}"
      '';
    };
  };
}
