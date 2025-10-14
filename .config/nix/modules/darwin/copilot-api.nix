{ pkgs, config, lib, username, ... }:
with lib;
let
  cfg = config.services.copilot-api;
in {
  options.services.copilot-api = {
    enable = mkEnableOption "copilot-api service";

    package = mkOption {
      type = types.package;
      default = pkgs.writeShellScriptBin "copilot-api" ''
        # Path to npm global installation
        NPM_GLOBAL_LIB="$HOME/.npm-global/lib/node_modules/copilot-api"

        # Check if copilot-api is installed
        if [ ! -d "$NPM_GLOBAL_LIB" ]; then
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
          echo "ERROR: copilot-api is not installed in npm global packages" >&2
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
          echo "" >&2
          echo "Expected location: $NPM_GLOBAL_LIB" >&2
          echo "" >&2
          echo "To install copilot-api manually, run:" >&2
          echo "  npm install -g copilot-api" >&2
          echo "" >&2
          echo "Or if using a custom npm prefix (~/.npm-global):" >&2
          echo "  npm config set prefix ~/.npm-global" >&2
          echo "  npm install -g copilot-api" >&2
          echo "" >&2
          echo "After installation, rebuild your system:" >&2
          echo "  darwin-rebuild switch --flake ~/.dotfiles" >&2
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
          exit 1
        fi

        # Verify the executable exists
        if [ ! -f "$NPM_GLOBAL_LIB/dist/main.js" ]; then
          echo "ERROR: copilot-api installation appears corrupt" >&2
          echo "Expected: $NPM_GLOBAL_LIB/dist/main.js" >&2
          echo "Try reinstalling: npm install -g copilot-api" >&2
          exit 1
        fi

        # Execute copilot-api with all arguments
        exec ${pkgs.nodejs}/bin/node "$NPM_GLOBAL_LIB/dist/main.js" "$@"
      '';
      defaultText = "Wrapper script for manually installed copilot-api";
      description = "Wrapper for npm global copilot-api installation";
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

    # Ensure nodejs is available for the wrapper script
    environment.systemPackages = [ pkgs.nodejs ];

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