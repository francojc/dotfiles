{
  config,
  ...
}: let
  # Get the user's home directory dynamically
  homeDir = config.home.homeDirectory;

  # Define the Claude configuration
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
        "command" = "sh";
        "args" = [
          "-c"
          "export KARAKEEP_API_KEY=\"$KARAKEEP_API_KEY\" && export KARAKEEP_API_ADDR=\"$KARAKEEP_API_ADDR\" && exec npx @karakeep/mcp"
        ];
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
        "command" = "sh";
        "args" = [
          "-c"
          "export AIRTABLE_API_KEY=\"$AIRTABLE_API_KEY\" && exec npx @felores/airtable-mcp-server"
        ];
      };
      "google_workspace" = {
        "command" = "uvx";
        "args" = [
          "workspace-mcp"
        ];
        "env" = {
          "OAUTHLIB_INSECURE_TRANSPORT" = "1";
          "GOOGLE_CLIENT_SECRETS" = "${homeDir}/.google/workspace_client_secret.json";
          "HOME" = "${homeDir}";
        };
      };
      "zen" = {
        "command" = "sh";
        "args" = [
          "-c"
          "export CUSTOM_API_URL=\"https://api.githubcopilot.com\" && export CUSTOM_API_KEY=\"$GITHUB_COPILOT_API_KEY\" && export DEFAULT_MODEL=\"auto\" && exec $(which uvx || echo uvx) --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server"
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
  # Generate the claude config file directly
  home.file.".claude.json" = {
    text = builtins.toJSON claudeConfig;
  };
}

