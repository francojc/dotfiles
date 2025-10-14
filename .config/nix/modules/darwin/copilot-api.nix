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
          hash = "sha256-H8z9K/6L+74AwapTX/uitxMfx7yR64MOPUx4v+TwYiA=";
        };

        nativeBuildInputs = [ pkgs.nodejs pkgs.makeWrapper ];

        # Skip build phase - use pre-built dist from npm package
        dontBuild = true;

        installPhase = ''
          mkdir -p $out/lib/node_modules/copilot-api

          # Extract the npm tarball directly
          cp -r package/* $out/lib/node_modules/copilot-api/ 2>/dev/null || \
            cp -r * $out/lib/node_modules/copilot-api/

          # Verify the pre-built dist exists
          if [ ! -f "$out/lib/node_modules/copilot-api/dist/index.js" ]; then
            echo "ERROR: Pre-built dist/index.js not found in npm package!"
            echo "The copilot-api npm package structure may have changed."
            echo "Please update the package definition in copilot-api.nix"
            echo "or switch to a full build approach with npm install."
            exit 1
          fi

          # Install runtime dependencies only (no build needed)
          cd $out/lib/node_modules/copilot-api
          export HOME=$TMPDIR
          ${pkgs.nodejs}/bin/npm install --production --no-fund --no-audit --ignore-scripts

          # Create wrapper script with error handling
          mkdir -p $out/bin
          cat > $out/bin/copilot-api <<'WRAPPER'
          #!/usr/bin/env bash
          NODE_BIN="${pkgs.nodejs}/bin/node"
          SCRIPT_PATH="$out/lib/node_modules/copilot-api/dist/index.js"

          if [ ! -f "$SCRIPT_PATH" ]; then
            echo "ERROR: copilot-api runtime files not found at $SCRIPT_PATH"
            echo "This may indicate a problem with the Nix package installation."
            echo "Try rebuilding your system configuration: darwin-rebuild switch"
            exit 1
          fi

          export NODE_PATH="$out/lib/node_modules"
          exec "$NODE_BIN" "$SCRIPT_PATH" "$@"
          WRAPPER

          chmod +x $out/bin/copilot-api

          # Replace template variables
          substituteInPlace $out/bin/copilot-api \
            --replace '$out' "$out"
        '';

        meta = {
          description = "A wrapper around GitHub Copilot API to make it OpenAI compatible";
          homepage = "https://github.com/ericc-ch/copilot-api";
          license = pkgs.lib.licenses.mit;
        };
      };
      defaultText = "copilot-api npm package (pre-built)";
      description = "The copilot-api package from npm (uses pre-built dist)";
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

    # Add to system profile for easier access
    environment.systemPackages = [
      pkgs.nodejs
      cfg.package
    ];

    # Create launchd agent for copilot-api using nix-darwin's interface
    launchd.user.agents.copilot-api = {
      serviceConfig = {
        Label = "com.github.copilot-api";
        ProgramArguments = [
          "${cfg.package}/bin/copilot-api"
          "start"
          "--host"
          cfg.host
          "--port"
          (toString cfg.port)
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/Users/${cfg.user}/.local/share/copilot-api.log";
        StandardErrorPath = "/Users/${cfg.user}/.local/share/copilot-api.error.log";
        WorkingDirectory = "/Users/${cfg.user}";
        EnvironmentVariables = {
          PATH = "${cfg.package}/bin:${pkgs.nodejs}/bin:/usr/local/bin:/usr/bin:/bin";
          NODE_PATH = "${cfg.package}/lib/node_modules:${pkgs.nodejs}/lib/node_modules";
        };
        SoftResourceLimits = {
          NumberOfFiles = 65536;
        };
      };
    };

    # Create log directory
    system.activationScripts.postActivation = {
      text = ''
        # Create log directory for copilot-api
        mkdir -p "/Users/${cfg.user}/.local/share"
        chown ${cfg.user}:staff "/Users/${cfg.user}/.local/share"
      '';
    };

    # Service information
    system.stateVersion = 4;
  };
}