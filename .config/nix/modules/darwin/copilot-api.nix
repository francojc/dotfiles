# GitHub Copilot API Service
#
# This module provides a launchd service for copilot-api, an OpenAI-compatible
# proxy for GitHub Copilot. It enables use of Copilot with tools like Claude
# Code, Aider, and other AI agents that support OpenAI-style APIs.
#
# AUTHENTICATION APPROACH:
# ========================
# This module implements **token sharing** to prevent OAuth conflicts between
# copilot.vim and copilot-api. Both tools authenticate using the same GitHub
# OAuth application, and GitHub only allows ONE active token per OAuth app per
# user. When one tool re-authenticates, it invalidates the other's token.
#
# SOLUTION: Single Source of Truth
# ---------------------------------
# Instead of maintaining separate authentication for copilot-api, this module:
# 1. Reads the OAuth token from copilot.vim's config (~/.config/github-copilot/apps.json)
# 2. Passes it to copilot-api via the --github-token flag
# 3. Eliminates the need to run `copilot-api auth` separately
#
# WORKFLOW:
# ---------
# 1. Authenticate ONLY via `:Copilot setup` in Neovim
# 2. The copilot-api service automatically reads and uses the same token
# 3. Both services stay authenticated together
# 4. No more "Bad credentials" conflicts!
#
# If authentication fails, the service will provide clear instructions to
# authenticate via Neovim first, then restart the service with:
#   launchctl kickstart -k gui/$(id -u)/com.github.copilot-api
#
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
        COPILOT_TOKEN_FILE="$HOME/.config/github-copilot/apps.json"

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

        # Extract GitHub Copilot token from copilot.vim's config
        # This enables token sharing between copilot.vim and copilot-api
        if [ -f "$COPILOT_TOKEN_FILE" ]; then
          GITHUB_TOKEN=$(${pkgs.jq}/bin/jq -r '.[].oauth_token' "$COPILOT_TOKEN_FILE" 2>/dev/null | head -n1)

          if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "null" ]; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
            echo "ERROR: Could not extract GitHub Copilot token" >&2
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
            echo "" >&2
            echo "Please authenticate GitHub Copilot in Neovim first:" >&2
            echo "  1. Open Neovim" >&2
            echo "  2. Run :Copilot setup" >&2
            echo "  3. Follow the authentication flow" >&2
            echo "" >&2
            echo "After authenticating, restart the copilot-api service:" >&2
            echo "  launchctl kickstart -k gui/\$(id -u)/com.github.copilot-api" >&2
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
            exit 1
          fi

          # Pass the token to copilot-api via --github-token flag
          exec ${pkgs.nodejs}/bin/node "$NPM_GLOBAL_LIB/dist/main.js" --github-token "$GITHUB_TOKEN" "$@"
        else
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
          echo "ERROR: GitHub Copilot token file not found" >&2
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
          echo "" >&2
          echo "Expected: $COPILOT_TOKEN_FILE" >&2
          echo "" >&2
          echo "Please authenticate GitHub Copilot in Neovim first:" >&2
          echo "  1. Open Neovim" >&2
          echo "  2. Run :Copilot setup" >&2
          echo "  3. Follow the authentication flow" >&2
          echo "" >&2
          echo "After authenticating, restart the copilot-api service:" >&2
          echo "  launchctl kickstart -k gui/\$(id -u)/com.github.copilot-api" >&2
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
          exit 1
        fi
      '';
      defaultText = "Wrapper script for manually installed copilot-api";
      description = "Wrapper for npm global copilot-api installation with token sharing from copilot.vim";
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