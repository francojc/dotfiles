{ pkgs, config, lib, username, ... }:
with lib;
let
  cfg = config.services.copilot-api;
in {
  options.services.copilot-api = {
    enable = mkEnableOption "copilot-api service";

    package = mkOption {
      type = types.package;
      default = pkgs.nodePackages.copilot-api or (pkgs.writeShellScriptBin "copilot-api" "exec ${pkgs.nodejs}/bin/node ${pkgs.npm}/bin/npm global exec copilot-api \"$@\"");
      defaultText = "copilot-api from npm";
      description = "The copilot-api package to use";
    };

    user = mkOption {
      type = types.str;
      default = username;
      description = "User to run the service as";
    };

    port = mkOption {
      type = types.int;
      default = 4141;
      description = "Port to bind the service to";
    };

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Host to bind the service to (0.0.0.0 for all interfaces)";
    };
  };

  config = mkIf cfg.enable {
    # Ensure the user exists
    users.users.${cfg.user} = {
      name = cfg.user;
      home = "/Users/${cfg.user}";
    };

    # Create launchd agent for copilot-api
    environment.etc."launchd/user/copilot-api.plist".text = ''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.github.copilot-api</string>

    <key>ProgramArguments</key>
    <array>
        <string>${pkgs.nodejs}/bin/node</string>
        <string>${pkgs.npm}/bin/npm</string>
        <string>global</string>
        <string>exec</string>
        <string>copilot-api</string>
        <string>start</string>
        <string>--host</string>
        <string>${cfg.host}</string>
        <string>--port</string>
        <string>${toString cfg.port}</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Users/${cfg.user}/.local/share/copilot-api.log</string>

    <key>StandardErrorPath</key>
    <string>/Users/${cfg.user}/.local/share/copilot-api.error.log</string>

    <key>UserName</key>
    <string>${cfg.user}</string>

    <key>WorkingDirectory</key>
    <string>/Users/${cfg.user}</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${pkgs.nodejs}/bin:${pkgs.npm}/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>NODE_PATH</key>
        <string>${pkgs.nodejs}/lib/node_modules</string>
    </dict>

    <key>SoftResourceLimits</key>
    <dict>
        <key>NumberOfFiles</key>
        <integer>65536</integer>
    </dict>
</dict>
</plist>
    '';

    # Create log directory
    system.activationScripts.postActivation = {
      text = ''
        # Create log directory for copilot-api
        mkdir -p "/Users/${cfg.user}/.local/share"
        chown ${cfg.user}:staff "/Users/${cfg.user}/.local/share"
      '';
    };

    # Add to system profile for easier access
    environment.systemPackages = with pkgs; [
      nodejs
      npm
    ];

    # Service information
    system.stateVersion = 4;
  };
}