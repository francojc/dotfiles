{
  config,
  ...
}: let
  # Get the user's home directory dynamically
  homeDir = config.home.homeDirectory;

  # Define the opencode configuration with dynamic paths
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    theme = "system";
    instructions = ["AGENTS.md"];
    layout = "stretch";
    share = "manual";
    autoupdate = false;
    small_model = "github-copilot/o4-mini";
    disabled_providers = ["deepseek" "openai"];
    mode = {
      diagnose = {
        model = "github-copilot/gemini-2.5-pro";
        temperature = 0.1;
        tools = {
          write = false;
          edit = false;
          bash = true;
          read = true;
          grep = true;
          glob = true;
        };
      };
      plan = {
        model = "github-copilot/gemini-2.5-pro";
        temperature = 0.2;
        tools = {
          write = false;
          edit = false;
          bash = false;
          read = true;
          grep = true;
          glob = true;
        };
      };
      build = {
        model = "github-copilot/claude-sonnet-4";
        temperature = 0.3;
        tools = {
          write = true;
          edit = true;
          bash = true;
          read = true;
          grep = true;
          glob = true;
        };
      };
      review = {
        model = "github-copilot/o4-mini";
        temperature = 0.1;
        tools = {
          write = false;
          edit = false;
          bash = false;
          read = true;
          grep = true;
          glob = true;
        };
      };
    };

    keybinds = {
      leader = "ctrl+o";
      app_help = "<leader>h";
      switch_mode = "tab";
      editor_open = "<leader>e";
      session_new = "<leader>n";
      session_list = "<leader>l";
      session_share = "<leader>s";
      session_unshare = "<leader>u";
      session_interrupt = "esc";
      session_compact = "<leader>c";
      tool_details = "<leader>d";
      model_list = "<leader>m";
      theme_list = "<leader>t";
      project_init = "<leader>i";
      file_list = "<leader>f";
      file_close = "esc";
      file_diff_toggle = "<leader>v";
      input_clear = "ctrl+c";
      input_paste = "ctrl+v";
      input_submit = "enter";
      input_newline = "alt+enter";
      messages_page_up = "pgup";
      messages_page_down = "pgdown";
      messages_half_page_up = "ctrl+alt+u";
      messages_half_page_down = "ctrl+alt+d";
      messages_previous = "ctrl+up";
      messages_next = "ctrl+down";
      messages_first = "ctrl+g";
      messages_last = "ctrl+alt+g";
      messages_layout_toggle = "<leader>p";
      messages_copy = "<leader>y";
      messages_revert = "<leader>r";
      app_exit = "ctrl+c,<leader>q";
    };

    mcp = {
      dalle-image-generator = {
        enabled = true;
        type = "local";
        command = [
          "node"
          "${homeDir}/.bin/dalle-mcp-server/server.js"
        ];
      };
      sequential-thinking = {
        enabled = true;
        type = "local";
        command = [
          "npx"
          "-y"
          "@modelcontextprotocol/server-sequential-thinking"
        ];
      };
      mcp-scholarly = {
        enabled = true;
        type = "local";
        command = [
          "uvx"
          "mcp-server-scholarly"
        ];
      };
      fetch = {
        enabled = true;
        type = "local";
        command = [
          "uvx"
          "mcp-server-fetch"
        ];
      };
      zen = {
        enabled = true;
        type = "local";
        command = [
          "sh"
          "-c"
          "export CUSTOM_API_URL=\"https://api.githubcopilot.com\" && export CUSTOM_API_KEY=\"$GITHUB_COPILOT_API_KEY\" && export DEFAULT_MODEL=\"auto\" && exec $(which uvx || echo uvx) --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server"
        ];
      };
      zotero = {
        enabled = true;
        type = "local";
        command = [
          "${homeDir}/.local/bin/zotero-mcp"
        ];
        environment = {
          ZOTERO_LOCAL = "true";
        };
      };
    };
  };
in {
  # Generate the opencode.json file with dynamic paths
  home.file.".config/opencode/opencode.json" = {
    text = builtins.toJSON opencodeConfig;
  };
}
