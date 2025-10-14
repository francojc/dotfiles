{ pkgs, config, lib, username, ... }:
with lib;
let
  cfg = config.services.copilot-api;
in {
  options.services.copilot-api = {
    enable = mkEnableOption "copilot-api service";

    package = mkOption {
      type = types.package;
      default = pkgs.stdenv.mkDerivation {
        pname = "copilot-api";
        version = "0.7.0";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/copilot-api/-/copilot-api-0.7.0.tgz";
          hash = "sha256-Y3LqJvJkR7kHv2lFzWqGzJvNqXqMqJqNqMqJqNqMqJqNqMqJqNqMqJqNqMqJqNqMqJqNq";
        };

        nativeBuildInputs = [ pkgs.nodejs ];
        buildInputs = [ pkgs.nodejs ];

        buildPhase = ''
          export HOME=$TMPDIR
          tar -xzf $src
          cd package
          npm install --production --prefix=$out
        '';

        installPhase = ''
          mkdir -p $out/bin
          cat > $out/bin/copilot-api << 'EOF'
          #!/bin/sh
          export NODE_PATH="$out/lib/node_modules:$NODE_PATH"
          exec ${pkgs.nodejs}/bin/node $out/lib/node_modules/copilot-api/dist/index.js "$@"
          EOF
          chmod +x $out/bin/copilot-api
        '';

        meta = {
          description = "A wrapper around GitHub Copilot API to make it OpenAI compatible";
          homepage = "https://github.com/ericc-ch/copilot-api";
          license = pkgs.lib.licenses.mit;
        };
      };
      defaultText = "copilot-api npm package";
      description = "The copilot-api package from npm";
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
        <string>${cfg.package}/bin/copilot-api</string>
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
        <string>${cfg.package}/bin:${pkgs.nodejs}/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>NODE_PATH</key>
        <string>${cfg.package}/lib/node_modules:${pkgs.nodejs}/lib/node_modules</string>
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
      cfg.package
    ];

    # Service information
    system.stateVersion = 4;
  };
}