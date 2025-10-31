# Reddix Wrapper with pass Integration
#
# This module provides a wrapper for the reddix Reddit terminal client that
# automatically populates Reddit API credentials from the pass password manager.
#
# AUTHENTICATION APPROACH:
# ========================
# Reddit API credentials (client_id and client_secret) are sensitive and should
# not be stored in the Nix store. This wrapper implements runtime secret injection
# using the pass password manager.
#
# SOLUTION: Runtime Secret Population
# ------------------------------------
# Instead of baking secrets into the Nix configuration, this module:
# 1. Generates a base config template with empty credential fields
# 2. Wraps the reddix binary to check for missing credentials on startup
# 3. Retrieves credentials from pass and updates the config if needed
# 4. Then executes the actual reddix command
#
# SETUP REQUIREMENTS:
# -------------------
# Store your Reddit API credentials in pass before first use:
#   pass insert USER/REDDIT_CLIENT_ID
#   pass insert SECRET/REDDIT_CLIENT_SECRET
#
# To obtain Reddit API credentials:
# 1. Go to https://www.reddit.com/prefs/apps
# 2. Click "create another app..." or "are you a developer? create an app..."
# 3. Select "script" as the app type
# 4. Set redirect URI to: http://127.0.0.1:65010/reddix/callback
# 5. Copy the client_id (string under app name) and client_secret
#
# WORKFLOW:
# ---------
# 1. Store credentials in pass (one-time setup)
# 2. Rebuild your Darwin configuration
# 3. Run reddix - the wrapper will auto-populate credentials on first use
# 4. Credentials persist in ~/.config/reddix/config.yaml until changed
#
{
  pkgs,
  username,
  ...
}: {
  # Create wrapper script that injects credentials from pass
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "reddix" ''
      REDDIX_CONFIG="$HOME/.config/reddix/config.yaml"
      REAL_REDDIX="$HOME/.cargo/bin/reddix"

      # Check if the real reddix binary exists
      if [ ! -f "$REAL_REDDIX" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
        echo "ERROR: reddix binary not found" >&2
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
        echo "" >&2
        echo "Expected location: $REAL_REDDIX" >&2
        echo "" >&2
        echo "To install reddix, run:" >&2
        echo "  cargo install reddix" >&2
        echo "" >&2
        echo "After installation, the wrapper will work automatically." >&2
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
        exit 1
      fi

      # Check if config exists and has empty credentials
      if [ -f "$REDDIX_CONFIG" ]; then
        CLIENT_ID=$(${pkgs.yq-go}/bin/yq eval '.reddit.client_id' "$REDDIX_CONFIG" 2>/dev/null)
        CLIENT_SECRET=$(${pkgs.yq-go}/bin/yq eval '.reddit.client_secret' "$REDDIX_CONFIG" 2>/dev/null)

        # If credentials are empty or placeholder values, fetch from pass
        if [ -z "$CLIENT_ID" ] || [ "$CLIENT_ID" = '""' ] || [ "$CLIENT_ID" = "null" ] || \
           [ -z "$CLIENT_SECRET" ] || [ "$CLIENT_SECRET" = '""' ] || [ "$CLIENT_SECRET" = "null" ]; then

          echo "Fetching Reddit credentials from pass..." >&2

          # Check if pass is available
          if ! command -v pass &> /dev/null; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
            echo "ERROR: pass password manager not found in PATH" >&2
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
            echo "" >&2
            echo "pass is required to retrieve Reddit API credentials." >&2
            echo "It should be available via your Nix configuration." >&2
            echo "" >&2
            echo "Please check your Nix configuration and rebuild." >&2
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
            exit 1
          fi

          # Retrieve credentials from pass
          PASS_CLIENT_ID=$(pass USER/REDDIT_CLIENT_ID 2>/dev/null | head -n1)
          PASS_CLIENT_SECRET=$(pass SECRET/REDDIT_CLIENT_SECRET 2>/dev/null | head -n1)

          if [ -z "$PASS_CLIENT_ID" ] || [ -z "$PASS_CLIENT_SECRET" ]; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
            echo "ERROR: Could not retrieve Reddit credentials from pass" >&2
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
            echo "" >&2
            echo "Please store your Reddit API credentials in pass:" >&2
            echo "  pass insert reddit/client_id" >&2
            echo "  pass insert reddit/client_secret" >&2
            echo "" >&2
            echo "To obtain Reddit API credentials:" >&2
            echo "  1. Go to https://www.reddit.com/prefs/apps" >&2
            echo "  2. Click 'create another app...' or 'are you a developer? create an app...'" >&2
            echo "  3. Select 'script' as the app type" >&2
            echo "  4. Set redirect URI to: http://127.0.0.1:65010/reddix/callback" >&2
            echo "  5. Copy the client_id (string under app name) and client_secret" >&2
            echo "" >&2
            echo "After storing credentials, run reddix again." >&2
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
            exit 1
          fi

          # Update the config with credentials from pass
          echo "Updating config with credentials from pass..." >&2
          ${pkgs.yq-go}/bin/yq eval ".reddit.client_id = \"$PASS_CLIENT_ID\"" -i "$REDDIX_CONFIG"
          ${pkgs.yq-go}/bin/yq eval ".reddit.client_secret = \"$PASS_CLIENT_SECRET\"" -i "$REDDIX_CONFIG"
          echo "Credentials updated successfully." >&2
        fi
      fi

      # Execute the real reddix binary with all arguments
      exec "$REAL_REDDIX" "$@"
    '')
  ];
}
