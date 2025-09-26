{config, ...}: {
  xdg.configFile."codex/config.toml".text = ''
    # =========================
    # Codex CLI config.toml
    # =========================
    # Rule: In each "CHOOSE ONE" block, uncomment EXACTLY ONE line.

    # -------------------------
    # Model (string)
    # -------------------------
    # CHOOSE ONE:
    model = "gpt-5"
    # model = "o3"
    # model = "o4-mini"

    # -------------------------
    # Model provider (string)
    # -------------------------
    # CHOOSE ONE:
    model_provider = "openai"
    # model_reasoning_effort = "low"
    # model_reasoning_effort = "minimal"

    # -------------------------
    # Reasoning summaries (string)
    # -------------------------
    # CHOOSE ONE:
    model_reasoning_summary = "auto"
    # model_reasoning_summary = "concise"
    # model_reasoning_summary = "detailed"
    # model_reasoning_summary = "none"

    # -------------------------
    # Verbosity (string)
    # -------------------------
    # CHOOSE ONE:
    model_verbosity = "medium"
    # model_verbosity = "low"
    # model_verbosity = "high"

    # -------------------------
    # Force reasoning summaries on non-default combos (bool)
    # -------------------------
    # CHOOSE ONE:
    model_supports_reasoning_summaries = true
    # model_supports_reasoning_summaries = false

    # -------------------------
    # Approval policy (string)
    # -------------------------
    # CHOOSE ONE:
    approval_policy = "on-request"
    # approval_policy = "untrusted"
    # approval_policy = "on-failure"
    # approval_policy = "never"

    # -------------------------
    # Sandbox mode (string)
    # -------------------------
    # CHOOSE ONE:
    # sandbox_mode = "danger-full-access"   # no sandbox
    sandbox_mode = "workspace-write"     # writes allowed in cwd/tmp only
    # sandbox_mode = "read-only"           # default in docs: no writes, no network

    # If you select "workspace-write", you may also configure:
    # [sandbox_workspace_write]
    # # Writable roots (bool/array) — CHOOSE ONE for each:
    # # exclude_tmpdir_env_var = true
    # exclude_tmpdir_env_var = false
    # # exclude_slash_tmp = true
    # exclude_slash_tmp = false
    # # Optional additional writable roots:
    # # writable_roots = ["${config.home.homeDirectory}/.pyenv/shims"]
    # # Network inside sandbox — CHOOSE ONE:
    # # network_access = true
    # # network_access = false

    # -------------------------
    # Response storage (bool)
    # -------------------------
    # CHOOSE ONE:
    disable_response_storage = false
    model_reasoning_effort = "medium"
    # disable_response_storage = true   # use for ZDR / no caching

    # -------------------------
    # Shell environment policy
    # -------------------------
    [shell_environment_policy]
    # inherit — CHOOSE ONE:
    inherit = "core"
    # inherit = "all"
    # inherit = "none"

    # Keep default secret filtering?
    ignore_default_excludes = false

    # Drop patterns (array of globs); keep empty if not needed
    exclude = ["AWS_*", "AZURE_*"]
    # exclude = []

    # Force-set environment vars (table); keep empty if not needed
    set = { }
    # set = { CI = "1" }

    # Whitelist patterns (array of globs); empty means no whitelist
    include_only = []
    # include_only = ["PATH", "HOME"]

    # -------------------------
    # Providers (optional — define only what you use)
    # -------------------------
    # [model_providers.openai]
    # name = "OpenAI"
    # base_url = "https://api.openai.com/v1"
    # env_key = "OPENAI_API_KEY"
    # # Per-provider network tuning (optional):
    # # request_max_retries = 4
    # # stream_max_retries = 10
    # # stream_idle_timeout_ms = 300000

    # [model_providers.openai-chat-completions]
    # name = "OpenAI using Chat Completions"
    # base_url = "https://api.openai.com/v1"
    # env_key = "OPENAI_API_KEY"
    # wire_api = "chat"

    # [model_providers.azure]
    # name = "Azure"
    # base_url = "https://YOUR_PROJECT_NAME.openai.azure.com/openai"
    # env_key = "AZURE_OPENAI_API_KEY"
    # query_params = { api-version = "2025-04-01-preview" }

    # [model_providers.ollama]
    # name = "Ollama"
    # base_url = "http://localhost:11434/v1"

    # -------------------------
    # MCP servers (optional)
    # -------------------------

    # -------------------------
    # Profiles (optional)
    # -------------------------
    # [profiles.default]
    # model = "gpt-5"
    # model_provider = "openai"
    # approval_policy = "on-request"
    # model_reasoning_effort = "high"
    # model_reasoning_summary = "auto"
    # model_verbosity = "medium"

    # -------------------------
    # Tools (optional)
    # -------------------------
    [tools]
    web_search = true

    # -------------------------
    # MCP servers (optional)
    # -------------------------
    # Zotero ---
    [mcp_servers.zotero]
    command = "${config.home.homeDirectory}/.local/bin/zotero-mcp"
    [mcp_servers.zotero.env]
    ZOTERO_LOCAL = "true"
    ZOTERO_EMBEDDING_MODEL = "gemini"
    GEMINI_EMBEDDING_MODEL = "models/text-embedding-004"

    [mcp_servers.sequential-thinking]
    command = "npx"
    # Pin version to reduce surprise updates. Replace `@1` with an exact
    # version (e.g., `@1.2.3`) when you decide which to lock to.
    args = ["-y", "@modelcontextprotocol/server-sequential-thinking@1"]

    # Zen ---
    [mcp_servers.zen]
    command = "bash"
    args = ["-c", "for p in $(which uvx 2>/dev/null) ${config.home.homeDirectory}/.local/bin/uvx /opt/homebrew/bin/uvx /usr/local/bin/uvx uvx; do [ -x \"$p\" ] && exec \"$p\" --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server; done; echo 'uvx not found' >&2; exit 1"]

    [mcp_servers.zen.env]
    PATH = "/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin:${config.home.homeDirectory}/.local/bin:${config.home.homeDirectory}/.cargo/bin:${config.home.homeDirectory}/bin"
    DEFAULT_MODEL = "auto"
    DEFAULT_THINKING_MODE_THINKDEEP = "high"
    CONVERSATION_TIMEOUT_HOURS = "3"
    MAX_CONVERSATION_TURNS = "20"
    LOG_LEVEL = "DEBUG"
    DISABLED_TOOLS = "analyze,refactor,testgen,secaudit,docgen,tracer"
    COMPOSE_PROJECT_NAME = "zen-mcp"
    TZ = "UTC"
    LOG_MAX_SIZE = "10MB"

    # Research
    [mcp_servers.research]
    command = "uv"
    args = ["run", "--directory", "${config.home.homeDirectory}/.local/mcp/mcp-research", "server.py"]

    # Obsidian ---
    [mcp_servers.obsidian]
    command = "npx"
    args = ["-y", "obsidian-mcp", "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes", "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal"]
  '';
}