{config, ...}: let
  # Get the user's home directory dynamically
  homeDir = config.home.homeDirectory;

  # Define the Claude configuration with dynamic paths and environment variables
  claudeConfig = {
    "numStartups" = 0;
    "installMethod" = "global";
    "autoUpdates" = true;
    "editorMode" = "vim";
    "customApiKeyResponses" = {
      "approved" = [];
      "rejected" = [];
    };
    "tipsHistory" = {};
    "autoUpdaterStatus" = "enabled";
    "firstStartTime" = "2025-01-01T00:00:00.000Z";
    "userID" = "";
    "isQualifiedForDataSharing" = false;
    "claudeMaxTier" = "not_max";
    "hasCompletedOnboarding" = true;
    "lastOnboardingVersion" = "1.0.64";
    "projects" = {};
    "statsigModel" = {
      "bedrock" = "us.anthropic.claude-3-7-sonnet-20250219-v1:0";
      "vertex" = "claude-3-7-sonnet@20250219";
      "firstParty" = "claude-3-7-sonnet-20250219";
    };
    "cachedChangelog" = "";
    "changelogLastFetched" = 0;
    "maxSubscriptionNoticeCount" = 0;
    "hasAvailableMaxSubscription" = false;
    "recommendedSubscription" = "";
    "lastReleaseNotesSeen" = "1.0.64";
    "subscriptionUpsellShownCount" = 0;
    "subscriptionNoticeCount" = 0;
    "hasAvailableSubscription" = false;
    "fallbackAvailableWarningThreshold" = 0.5;
    "oauthAccount" = null;
    "mcpServers" = {
      "filesystem" = {
        "command" = "npx";
        "args" = [
          "-y"
          "@modelcontextprotocol/server-filesystem"
        ];
      };
      "puppeteer" = {
        "command" = "npx";
        "args" = [
          "-y"
          "@modelcontextprotocol/server-puppeteer"
        ];
      };
      "playwright" = {
        "command" = "npx";
        "args" = [
          "@playwright/mcp@latest"
        ];
      };
      "fetch" = {
        "command" = "uvx";
        "args" = [
          "mcp-server-fetch"
        ];
      };
      "memory" = {
        "command" = "npx";
        "args" = [
          "-y"
          "@modelcontextprotocol/server-memory"
        ];
      };
      "sequential-thinking" = {
        "command" = "npx";
        "args" = [
          "-y"
          "@modelcontextprotocol/server-sequential-thinking"
        ];
      };
      "mcp-scholarly" = {
        "command" = "uvx";
        "args" = [
          "mcp-scholarly"
        ];
      };
      "karakeep" = {
        "command" = "npx";
        "args" = [
          "@karakeep/mcp"
        ];
        "env" = {
          "KARAKEEP_API_KEY" = builtins.getEnv "KARAKEEP_API_KEY";
          "KARAKEEP_API_ADDR" = builtins.getEnv "KARAKEEP_API_ADDR";
        };
      };
      "Context7" = {
        "command" = "npx";
        "args" = [
          "-y"
          "@upstash/context7-mcp"
        ];
      };
      "obsidian" = {
        "command" = "uvx";
        "args" = [
          "-y"
          "obsidian-mcp"
          "${homeDir}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes"
        ];
      };
      "airtable" = {
        "command" = "npx";
        "args" = [
          "@felores/airtable-mcp-server"
        ];
        "env" = {
          "AIRTABLE_API_KEY" = builtins.getEnv "AIRTABLE_API_KEY";
        };
      };
      "google_workspace" = {
        "command" = "uvx";
        "args" = [
          "workspace-mcp"
        ];
        "env" = {
          "OAUTHLIB_INSECURE_TRANSPORT" = "1";
          "GOOGLE_CLIENT_SECRETS" = "${homeDir}.google/workspace_client_secret.json";
          "HOME" = "${homeDir}";
        };
      };
      "zen" = {
        "command" = "${homeDir}/.local/mcp/zen-mcp-server/.zen_venv/bin/python";
        "args" = [
          "${homeDir}/.local/mcp/zen-mcp-server/server.py"
        ];
      };
      "zotero" = {
        "command" = "${homeDir}/.local/bin/zotero-mcp";
        "args" = [];
        "env" = {
          "ZOTERO_LOCAL" = "true";
        };
      };
    };
  };
in {
  # Use home.activation to create a mutable copy of .claude.json
  home.activation.claudeConfig = config.lib.dag.entryAfter ["writeBoundary"] ''
    claude_config="${config.home.homeDirectory}/.claude.json"
    
    # Remove any existing symlink or file
    if [ -L "$claude_config" ] || [ ! -f "$claude_config" ]; then
      $DRY_RUN_CMD rm -f "$claude_config"
      
      # Create the mutable config file
      $DRY_RUN_CMD cat > "$claude_config" << 'EOF'
${builtins.toJSON claudeConfig}
EOF
      $DRY_RUN_CMD chmod 644 "$claude_config"
      echo "Created mutable .claude.json configuration"
    fi
  '';
}

