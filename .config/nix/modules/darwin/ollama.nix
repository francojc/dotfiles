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

    # Create launchd agent for ollama
    environment.etc."launchd/user/ollama.plist".text = ''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama.server</string>

    <key>ProgramArguments</key>
    <array>
        <string>${cfg.package}/bin/ollama</string>
        <string>serve</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Users/${cfg.user}/.local/share/ollama.log</string>

    <key>StandardErrorPath</key>
    <string>/Users/${cfg.user}/.local/share/ollama.error.log</string>

    <key>UserName</key>
    <string>${cfg.user}</string>

    <key>WorkingDirectory</key>
    <string>/Users/${cfg.user}</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>OLLAMA_HOST</key>
        <string>${cfg.host}:${toString cfg.port}</string>
        <key>OLLAMA_MODELS</key>
        <string>${cfg.modelsPath}</string>
        ${optionalString cfg.flashAttention ''
        <key>OLLAMA_FLASH_ATTENTION</key>
        <string>1</string>
        ''}
        ${optionalString (cfg.kvCacheType != "") ''
        <key>OLLAMA_KV_CACHE_TYPE</key>
        <string>${cfg.kvCacheType}</string>
        ''}
        ${optionalString cfg.keepModelLoaded ''
        <key>OLLAMA_KEEP_ALIVE</key>
        <string>-1</string>
        ''}
        ${concatStringsSep "\n        " (mapAttrsToList (name: value: ''
        <key>${name}</key>
        <string>${value}</string>
        '') cfg.extraEnvironment)}
    </dict>

    <key>SoftResourceLimits</key>
    <dict>
        <key>NumberOfFiles</key>
        <integer>65536</integer>
    </dict>

    <key>LimitLoadToSessionType</key>
    <array>
        <string>Aqua</string>
        <string>Background</string>
        <string>LoginWindow</string>
        <string>StandardIO</string>
        <string>System</string>
    </array>
</dict>
</plist>
    '';

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
