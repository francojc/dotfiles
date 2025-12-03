{ pkgs, config, lib, username, ... }:
with lib;
let
  cfg = config.services.ollama;
in {
  options.services.ollama = {
    enable = mkEnableOption "ollama service";

    package = mkOption {
      type = types.package;
      default = pkgs.ollama;
      defaultText = "pkgs.ollama";
      description = "The ollama package to use";
    };

    user = mkOption {
      type = types.str;
      default = username;
      description = "User to run the service as";
    };

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
    # Ensure the user exists
    users.users.${cfg.user} = {
      name = cfg.user;
      home = "/Users/${cfg.user}";
    };

    # Add ollama to system packages
    environment.systemPackages = [ cfg.package ];

    # Create launchd agent for ollama using nix-darwin's interface
    launchd.user.agents.ollama = {
      serviceConfig = {
        Label = "com.ollama.server";
        ProgramArguments = [
          "${cfg.package}/bin/ollama"
          "serve"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/Users/${cfg.user}/.local/share/ollama.log";
        StandardErrorPath = "/Users/${cfg.user}/.local/share/ollama.error.log";
        WorkingDirectory = "/Users/${cfg.user}";
        EnvironmentVariables = {
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
        SoftResourceLimits = {
          NumberOfFiles = 65536;
        };
        LimitLoadToSessionType = [
          "Aqua"
          "Background"
          "LoginWindow"
          "StandardIO"
          "System"
        ];
      };
    };

    # Create necessary directories
    system.activationScripts.postActivation = {
      text = ''
        # Create log directory for ollama
        mkdir -p "/Users/${cfg.user}/.local/share"
        chown ${cfg.user}:staff "/Users/${cfg.user}/.local/share"

        # Create models directory if it doesn't exist
        mkdir -p "${cfg.modelsPath}"
        chown ${cfg.user}:staff "${cfg.modelsPath}"
      '';
    };

    # Service information
    system.stateVersion = 4;
  };
}
