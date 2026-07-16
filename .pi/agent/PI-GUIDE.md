# Pi Guide

Living guide for Jerid's Pi setup. Maintained by `/skill:pi-guide-maintainer`.

## Maintenance

- Canonical file: `~/.pi/agent/PI-GUIDE.md`
- Dotfiles file: `~/.dotfiles/.pi/agent/PI-GUIDE.md`
- Last updated: 2026-07-15
- Refresh after package, extension, skill, or keybinding changes.
- Package and local-extension changes trigger background guide maintenance on next interactive Pi startup.
- Background guide update log: `~/.pi/agent/pi-guide-maintainer.log`.
- Disable background guide updates with `PI_GUIDE_AUTOUPDATE=0`.
- Override background guide model with `PI_GUIDE_MODEL=<provider/model>`.
- After config changes, run `/reload` in Pi when possible.

## Quick commands

| Command | Use |
| --- | --- |
| `/reload` | Reload keybindings, extensions, skills, prompts, and context files. |
| `/hotkeys` | Show active keyboard shortcuts. |
| `/caveman` | Toggle terse response mode from `pi-caveman`. |
| `/btw` | Open side conversation overlay from `pi-btw`. |
| `/plannotator` | Toggle Plannotator plan mode. |
| `/indicator` | Switch custom working indicator. |
| `/todos` | Show current branch todo list. |
| `/waiting` | List Pi agents awaiting attention and jump via TMUX. |
| `/copilot` | Show visual GitHub Copilot dashboard: quota, model billing, sessions. |
| `/copilot-quota` | Secondary focused Copilot quota/model view. |
| `/copilot-models` | Secondary focused Copilot model billing view. |
| `/copilot-sessions` | Browse Copilot SDK sessions. |
| `/codex-status [--refresh]` | Show ChatGPT Codex plan, quota windows, reset times, credits, and model buckets. |
| `/opencode-go-status [--refresh]` | Show OpenCode Go five-hour, weekly, and monthly subscription usage. |
| `/skill:ketch-research` | Research web pages, OSS code, and library docs with Ketch. |
| `/skill:hunk-review` | Inspect and guide live Hunk Git-diff review sessions. |
| `/skill:pi-guide-maintainer` | Update or extend this guide. |

## Installed packages

Loaded as Pi packages through `~/.pi/agent/settings.json` and installed under `~/.pi/agent/npm/`.

| Package | Version/config | What it adds |
| --- | --- | --- |
| `pi-caveman` | `1.0.7` | Terse output modes and status indicator. |
| `pi-btw` | `0.4.1` | Parallel side conversations in overlay, with handoff back to main session. |
| `@plannotator/pi-extension` | npm range in package: `^0.23.1` | Plan mode, browser-based plan review/annotation, restricted planning phase. |
| `@ogulcancelik/pi-ghostty-theme-sync` | `0.1.2` | Sync Pi theme from active Ghostty palette. |
| `@narumitw/pi-codex-usage` | `0.12.0` | ChatGPT Codex plan, 5-hour and weekly windows, credits, cached `/codex-status`, and provider-aware footer status. |

## Local extensions

Loaded from `~/.pi/agent/extensions/`.

| Extension | What it does | User-facing controls |
| --- | --- | --- |
| `git-branch-dirty-footer.ts` | Custom footer with cwd, git branch/dirty counts, token usage, context usage, model, and extension statuses. | Automatic. |
| `copilot-usage/` | Shows GitHub Copilot quota, threshold footer meter, token-based billing state, model billing metadata, and Copilot SDK sessions. Footer polls quota every 60 s while a Copilot provider is active. | Primary: `/copilot`; secondary: `/copilot-quota`, `/copilot-models`, `/copilot-sessions`; agent `copilot_usage` tool. |
| `working-indicator.ts` | Custom animated working indicator and rotating status words. | `/indicator [schwa|eye|pulse|bounce|spinner|none|default]` |
| `pi-notify-switch.ts` | Sends native terminal notifications when Pi is waiting and records TMUX panes for quick switching. | `/waiting`, TMUX `prefix N`, TMUX `prefix C-n` |
| `vim-editor.ts` | Vim-like normal/insert mode for Pi input editor. | `Esc`, `i`, `a`, `h/j/k/l`, `w`, `b`, `d`, `c`, `p`, `u` in normal mode. |
| `copilot-api-discovery.ts` | Registers dynamic `copilot-api` provider models from the raw GitHub Copilot OpenAI-compatible API. | Requires `GITHUB_COPILOT_API_KEY`; optional `GITHUB_COPILOT_BASE_URL`; use `pi --list-models copilot-api`. |
| `opencode-go-discovery.ts` | Registers dynamic `opencode-go` provider models from OpenCode/model metadata. | Requires `OPENCODE_API_KEY` for actual use. |
| `opencode-go-usage.ts` | Shows provider-gated OpenCode Go subscription usage in the custom footer. | `/opencode-go-status [--refresh]`; credentials from `pass` or environment. |
| `openrouter-models.ts` | Registers dynamic OpenRouter models from API/cache. | Requires `OPENROUTER_API_KEY`. |
| `searxng.ts` | Adds `web_search` tool via self-hosted SearXNG. | Agent tool. `SEARXNG_URL` optional. |
| `questionnaire.ts` | Adds interactive questionnaire tool for clarifying choices. | Agent tool. |
| `todo.ts` | Adds persistent todo tool and `/todos` viewer for current branch. | `/todos`, agent `todo` tool. |
| `supacode/index.ts` | Emits Supacode OSC lifecycle/notification signals when running inside Supacode. | Automatic inside Supacode surfaces. |
| `pi-guide-autoupdate.ts` | Detects package/local-extension changes and runs guide maintenance in background on interactive startup. | Automatic. Footer status only. |
| `tui-utils.ts` | Shared helper module for local TUI extensions. | No direct user controls. |
| `subscription-usage-status.ts` | Shared quota/glyph/bar utility for Codex, Copilot, and OpenCode Go compact footer status. No-op extension factory so Pi's auto-discovery accepts it as a utility module. | No direct user controls. |
| `tirith-guard.ts` | Intercepts every `bash` tool call and runs `tirith check` before execution. | Automatic. Control via `TIRITH_BIN`, `TIRITH_HOOK_WARN_ACTION`, `TIRITH_FAIL_OPEN`. |

## Keybindings and terminal notes

Custom keybindings in `~/.pi/agent/keybindings.json`:

```json
{
  "tui.input.newLine": ["alt+enter", "shift+enter"],
  "tui.editor.pageUp": ["pageUp", "super+shift+up"],
  "tui.editor.pageDown": ["pageDown", "super+shift+down"],
  "tui.select.pageUp": ["pageUp", "super+shift+up"],
  "tui.select.pageDown": ["pageDown", "super+shift+down"],
  "app.message.followUp": ["ctrl+shift+enter"]
}
```

Terminal notes:

- TMUX `prefix N` jumps to the most recent Pi agent awaiting attention.
- TMUX `prefix C-n` opens the awaiting Pi agent chooser in a popup.
- Kitty and Ghostty configs map `Cmd+Shift+↑` / `Cmd+Shift+↓` to literal PageUp/PageDown escape sequences for Pi page scroll consistency.
- Pi also binds `super+shift+up` / `super+shift+down` directly for page scroll when terminal protocols pass those keys through.
- Ghostty has `macos-option-as-alt = right`, so right Option behaves as Alt. Some left Option chords may still work depending on macOS/layout handling.
- Current `/btw` focus fallback works as `Ctrl+LeftOption+W` on this keyboard.
- Current `/btw` scroll works with `↑` and `↓`, plus mouse/trackpad wheel.

## Extension notes

### Ketch research skill

What it does:

- Directs agents to Ketch's narrowest research surface: external web search, known-page scraping, public OSS code search, library documentation, or bounded site crawls.
- Uses stateless CLI by default. If Pi exposes Ketch MCP research tools, agents use those for research calls and reserve CLI for configuration and operator actions.
- Keeps local repository inspection with local CLI tools and academic literature/citation work with `orbitr`.

Use:

- `/skill:ketch-research <research task>` loads it explicitly. Pi also loads it automatically when task matches its description.
- `ketch config` shows active and available backends.
- `ketch doctor` checks configured search, code, docs, browser, and cache surfaces without writing.

Gotchas:

- `--scrape` fetches search-result content. Bound unknown pages with `--max-chars 4000` to `8000` plus `--trim`; verify source content and provenance rather than trusting snippets or result rank.
- `ketch extract` consumes supplied HTML only. It does not fetch, cache, render, or probe `/llms.txt`.
- Batch scrape can return per-URL failures in otherwise successful output. Check every result.
- Correct validation errors rather than retrying unchanged. Rotate configured backend once for upstream/rate-limit failures; reduce scope after timeout.
- `ketch config init`, `ketch config set`, and `ketch browser install` write or download. `ketch cache clear` deletes every cached page. Confirm before any.
- Default to `--json` for research and scripts. Do not expose credentials from `ketch config` output.

Sources checked:

- `~/.pi/agent/skills/ketch-research/SKILL.md`
- [Official Ketch skill](https://raw.githubusercontent.com/1broseidon/ketch/refs/heads/main/skills/ketch/SKILL.md), checked 2026-07-14.
- `ketch --help` and command help, checked 2026-07-14.

### Hunk review skill

What it does:

- Lets Pi inspect, navigate, reload, and annotate live Hunk review sessions through `hunk session *`.
- Keeps Hunk TUI user-owned. Pi does not run interactive `hunk diff`, `show`, `patch`, `pager`, or `difftool` commands.

Use:

- Start Hunk yourself, for example `hunk diff` or `hunk show`.
- Ask Pi to review or walk through the live diff, or load `/skill:hunk-review <task>` explicitly.
- Pi begins with `hunk session review --repo . --json`; raw patch text needs explicit `--include-patch`.
- Pi can navigate views, reload a session, and add inline comments with `hunk session comment add` or batched `comment apply`.

Gotchas:

- No active session means Pi asks you to open Hunk first.
- `--repo` matches loaded repo root. Use session ID when multiple windows share one repo.
- `hunk diff` includes untracked files. Reload with `hunk session reload --repo . -- diff --exclude-untracked` for tracked changes only.
- Skill is bundled with installed Homebrew `hunk 0.17.1`; refresh local copy after Hunk updates if its official skill changes.

Sources checked:

- `hunk skill path` → `/opt/homebrew/Cellar/hunk/0.17.1/libexec/skills/hunk-review/SKILL.md`
- `~/.pi/agent/skills/hunk-review/SKILL.md`
- `hunk --help`

### pi-caveman

What it does:

- Compresses assistant prose while keeping technical substance.
- Hooks system prompt before agent turns.
- Stores default config in `~/.pi/agent/caveman.json`.

Commands:

- `/caveman` toggles caveman mode.
- `/caveman lite`, `full`, `ultra`, `micro` choose compression style.
- `/caveman off`, `stop`, or `quit` disables it.
- `/caveman config` opens settings dialog.

Best practices:

- Use `lite` for professional concise prose.
- Use `full` or `micro` for token thrift during coding.
- Temporarily disable for delicate writing, policy nuance, or student-facing text.

Sources checked:

- `~/.pi/agent/npm/node_modules/pi-caveman/README.md`

### pi-btw

What it does:

- Opens a parallel side-agent thread while main agent can continue working.
- Contextual `/btw <question>` inherits current main session context.
- `/btw:tangent <question>` starts a contextless side thread.
- Hidden thread state stays out of main LLM context until handed off.

Commands:

- `/btw [--save] <question>` asks side question.
- `/btw:new [question]` clears current BTW thread and starts fresh contextual one.
- `/btw:tangent [--save] <question>` uses contextless side thread.
- `/btw:clear` dismisses overlay and clears thread.
- `/btw:inject [instructions]` sends full side thread to main agent.
- `/btw:summarize [instructions]` summarizes side thread, then sends summary to main agent.
- `/btw:model ...` and `/btw:thinking ...` manage BTW-only model/thinking overrides.

Overlay controls:

- `Ctrl+LeftOption+W` toggles focus on Jerid's Mac keyboard.
- `Alt+/` is documented default, but may fail on Mac layouts.
- `Esc` dismisses overlay when focused.
- `↑` / `↓` scroll transcript by line.
- Mouse/trackpad wheel scrolls transcript.
- `PgUp` / `PgDn` page scroll if terminal sends those keys.
- `Enter` submits from overlay composer.

Best practices:

- Use `/btw` for side questions that should not derail main agent.
- Use `/btw:tangent` for brainstorming without main-session context.
- Use `/btw:summarize` before handoff when thread is long.
- Use `/btw:inject` when the main agent needs exact side-thread detail.
- Use `--save` only when you want visible transcript note, not handoff.

Gotchas:

- Overlay placement and hide-on-unfocus are not configurable in `pi-btw@0.4.1`.
- Focus toggle intentionally keeps overlay visible. `Esc` dismisses it.
- Shortcuts and page-scroll bindings are hardcoded in extension source, not in `keybindings.json`.

Sources checked:

- `~/.pi/agent/npm/node_modules/pi-btw/README.md`
- `~/.pi/agent/npm/node_modules/pi-btw/extensions/btw.ts`

### Plannotator

What it does:

- Adds plan mode with a browser UI for reviewing, annotating, approving, or denying plans.
- Planning phase restricts destructive behavior and focuses the agent on producing checklist plans.
- Approved plans move into execution with full tool access.

Commands and shortcuts:

- `pi --plan` starts Pi in plan mode.
- `/plannotator` toggles plan mode during a session.
- `Ctrl+Alt+P` toggles plan mode.

Configuration:

- Built-in package config: `plannotator.json` inside package.
- Global config: `~/.pi/agent/plannotator.json`.
- Project config: `<cwd>/.pi/plannotator.json`.
- Package uses `node-pty`; verify its native module loads after npm reinstalls or platform changes.

Best practices:

- Use for multi-step risky edits, refactors, or tasks needing approval gates.
- Annotate denied plans rather than restarting from scratch.
- Keep plan files in project paths where they can be reviewed/versioned when useful.

Sources checked:

- `~/.pi/agent/npm/node_modules/@plannotator/pi-extension/README.md`

### Ghostty theme sync

What it does:

- Reads active Ghostty colors using `ghostty +show-config`.
- Writes `~/.pi/agent/themes/ghostty-sync-<hash>.json`.
- Sets Pi theme to matching generated theme.
- Removes older `ghostty-sync-*` generated themes.

Requirements:

- Ghostty installed and available in `PATH`.

Best practices:

- Let it run automatically at startup.
- If Ghostty theme changes, reload Pi or restart session to regenerate/switch theme.

Sources checked:

- `~/.pi/agent/npm/node_modules/@ogulcancelik/pi-ghostty-theme-sync/README.md`

### Copilot usage

What it does:

- Shows GitHub Copilot plan quota from `gh api /copilot_internal/user`.
- Adds a threshold footer meter like ` Copilot [██████░░░░] 60%`, where the bar means quota remaining.
- Detects token-based Copilot billing and uses `quota_remaining` decimals when GitHub reports them.
- Fetches Copilot SDK session and model metadata in a short-lived child process, avoiding SDK socket leaks in the main Pi process.
- Shows current Copilot model billing metadata. GitHub may return old-style `billing.multiplier` values or newer `token_prices`, so the dashboard displays whichever metadata is available, compares metered models relative to the cheapest metered model, compacts large raw token-price integers, and treats all-zero token prices as included.

Commands and tool:

- `/copilot` is the primary visual dashboard: quota, included buckets, model billing, compact session counts, and recent sessions.
- `/copilot-quota` is a secondary focused quota plus model billing view.
- `/copilot-models` is a secondary focused model billing view.
- `/copilot-sessions` browses Copilot SDK sessions.
- Agent tool: `copilot_usage`, with optional period `today`, `week`, `month`, or `all`.

Requirements:

- GitHub CLI must be installed and authenticated with `gh auth login`.
- GitHub Copilot access must be active for the authenticated GitHub account.
- Local dependency `@github/copilot-sdk` is installed under `~/.pi/agent/extensions/copilot-usage/node_modules`.

Gotchas:

- Uses GitHub's internal `/copilot_internal/user` endpoint. It works now but may change without notice.
- GitHub Copilot billing has shifted toward token-based billing. Old premium-request multipliers may not appear in SDK model data.
- Footer polling runs every 60 seconds after a short startup delay, but only while `github-copilot/*` or `copilot-api/*` is selected. Switching away cancels polling, invalidates its cache, and clears the status.
- This is a local patched copy of `https://github.com/azs06/pi-copilot-usage`, not an npm package install.
- Run `/reload` after edits or dependency updates.

Sources checked:

- `~/.pi/agent/extensions/copilot-usage/README.md`
- `~/.pi/agent/extensions/copilot-usage/src/index.ts`
- `~/.pi/agent/extensions/copilot-api-discovery.ts`
- `~/.pi/agent/extensions/tirith-guard.ts`
- `~/.pi/agent/extensions/subscription-usage-status.ts`

### OpenAI Codex usage

What it does:

- The global package `npm:@narumitw/pi-codex-usage@0.12.0` adds `/codex-status`; the custom footer renders its status as a Copilot-style five-hour bar plus compact weekly percentage, for example ` Codex [███████░░░] 71% · wk 93%`.
- `/codex-status` shows the ChatGPT/Codex plan, current five-hour and weekly rate-limit windows, reset times, credits, and any model-specific buckets returned by OpenAI. Use `/codex-status --refresh` to bypass its five-minute in-memory cache.
- The footer status appears only for `openai-codex/*` models and clears when another provider is selected. This complements Copilot's provider-specific status; only the active subscription provider's indicator is shown.

Auth and data caveats:

- It uses Pi's existing `openai-codex` OAuth subscription auth first; run `/login openai-codex` if that auth is unavailable. Codex CLI app-server is an optional fallback, not a requirement for the normal Pi-auth path.
- It does not read auth files directly or print bearer tokens. Do not copy credentials into settings, logs, or issue reports.
- The usage endpoint is current snapshot data, not a persistent consumption ledger, and is an undocumented backend endpoint that OpenAI may change. OpenAI API keys do not expose ChatGPT subscription quota.
- Reload Pi after installing or updating the package.

Sources checked:

- `~/.pi/agent/npm/node_modules/@narumitw/pi-codex-usage/README.md`
- `~/.pi/agent/npm/node_modules/@narumitw/pi-codex-usage/src/codex-usage.ts`

Sources checked:

- `~/.pi/agent/extensions/copilot-usage/README.md`
- `~/.pi/agent/extensions/copilot-usage/src/index.ts`
- `~/.pi/agent/extensions/copilot-usage/package.json`

### OpenAI Codex usage

What it does:

- The global package `npm:@narumitw/pi-codex-usage@0.12.0` adds `/codex-status`; the custom footer renders its status as a Copilot-style five-hour bar plus compact weekly percentage, for example ` Codex [███████░░░] 71% · wk 93%`.
- `/codex-status` shows the ChatGPT/Codex plan, current five-hour and weekly rate-limit windows, reset times, credits, and any model-specific buckets returned by OpenAI. Use `/codex-status --refresh` to bypass its five-minute in-memory cache.
- The footer status appears only for `openai-codex/*` models and clears when another provider is selected. This complements Copilot's provider-specific status; only the active subscription provider's indicator is shown.

Auth and data caveats:

- It uses Pi's existing `openai-codex` OAuth subscription auth first; run `/login openai-codex` if that auth is unavailable. Codex CLI app-server is an optional fallback, not a requirement for the normal Pi-auth path.
- It does not read auth files directly or print bearer tokens. Do not copy credentials into settings, logs, or issue reports.
- The usage endpoint is current snapshot data, not a persistent consumption ledger, and is an undocumented backend endpoint that OpenAI may change. OpenAI API keys do not expose ChatGPT subscription quota.
- Reload Pi after installing or updating the package.

Sources checked:

- `~/.pi/agent/npm/node_modules/@narumitw/pi-codex-usage/README.md`
- `~/.pi/agent/npm/node_modules/@narumitw/pi-codex-usage/src/codex-usage.ts`

### OpenCode Go usage

What it does:

- Shows a Codex-shaped remaining-quota footer meter only while an `opencode-go/*` model is selected, for example ` OpenCode Go [███████░░░] 71% · wk 93%`.
- `/opencode-go-status` shows five-hour, weekly, and monthly remaining percentage plus reset time. Use `/opencode-go-status --refresh` to bypass its short fresh cache.
- Uses a 60-second fresh cache, a 10-minute stale fallback, and 60-second recursive polling after a short startup delay. Switching away from OpenCode Go or shutting down clears its status and invalidates late poll results.

Runtime environment inputs:

- By default, the extension reads `pass show USER/OPENCODE_GO_WORKSPACE_ID` for the workspace ID and `pass show COOKIE/OPENCODE_GO_AUTH_COOKIE` for the logged-in browser's raw `auth` cookie value. Store only the cookie value, not Netscape `cookies.txt` metadata or an `auth=` prefix.
- `OPENCODE_GO_WORKSPACE_ID` and `OPENCODE_GO_AUTH_COOKIE` remain optional runtime-environment overrides, useful where `pass` is unavailable. Renew the cookie pass entry after dashboard authentication expires.
- Do not commit either value, place it in `settings.json`, write it to logs/cache/error reports, or put it in Nix expressions/store paths. Treat the cookie like a password.

#### Brittle integration breadcrumb

- **Undocumented source:** `GET https://opencode.ai/workspace/<workspace-id>/go`, authenticated with `Cookie: auth=<cookie>`. By default, credentials come from `pass` entries `USER/OPENCODE_GO_WORKSPACE_ID` and `COOKIE/OPENCODE_GO_AUTH_COOKIE`; runtime environment values override them. This is dashboard HTML, not a supported public usage API.
- **Parser signature:** dashboard hydration is currently expected to contain `rollingUsage:$R[n]={usagePercent:<number>,resetInSec:<number>}`, plus `weeklyUsage` and `monthlyUsage` equivalents in either property order. `usagePercent` is used quota, so the widget displays `100 - usagePercent` as remaining quota.
- **Failure display:** missing credentials, expired auth, request failure, or a changed hydration layout displays `OpenCode Go unavailable`; stale data may be shown for at most 10 minutes. Cookie/header values are intentionally omitted from all errors.
- **Do not confuse endpoints:** `https://opencode.ai/zen/go/v1` is the inference/model endpoint used by `opencode-go-discovery.ts`; it does not expose the subscription usage snapshot.
- **Update procedure:** if the command/footer becomes unavailable, first renew the browser auth cookie and verify the workspace ID. Then inspect authenticated dashboard HTML for changed hydration fields, update `parseWindow` in `opencode-go-usage.ts`, run the formatter/lifecycle checks, and update this section with the new parser signature and source date.
- **Sources:** [OpenCode Go docs](https://opencode.ai/docs/go/), [OpenCode Go console routes](https://github.com/anomalyco/opencode/tree/dev/packages/console/app/src/routes/zen/go/v1), and [`opencode-statusline` OpenCode Go collector](https://github.com/kalcohol/opencode-statusline/blob/main/src/lib/providers.ts). Checked 2026-07-13.

### Working indicator

What it does:

- Replaces Pi's default spinner and working message with custom modes.

Commands:

- `/indicator` shows current indicator.
- `/indicator schwa` uses breathing schwa default.
- `/indicator eye`, `pulse`, `bounce`, `spinner`, `none`, `default` switch modes.

Source checked:

- `~/.pi/agent/extensions/working-indicator.ts`

### Pi notify switch

What it does:

- Sends native terminal notifications when Pi finishes a turn and is ready for input.
- Records the current TMUX pane as awaiting attention.
- Clears the awaiting state when that Pi agent starts another turn or shuts down.
- Validates TMUX pane ids before showing or jumping, so stale crash leftovers are ignored.

Commands and shortcuts:

- `/waiting` lists awaiting Pi agents from inside Pi and jumps via TMUX.
- TMUX `prefix N` jumps to the most recent awaiting Pi agent.
- TMUX `prefix C-n` opens an FZF chooser in a TMUX popup.
- CLI helper: `pi-waiting --list`, `pi-waiting --last`, `pi-waiting --jump-id <pane-id>`.

State files:

- Event log: `~/.pi/agent/pi-waiting-events.jsonl`.
- Last notification: `~/.pi/agent/pi-last-notification.json`.

Gotchas:

- Switching requires running Pi inside TMUX.
- Native notification uses terminal OSC protocols: Kitty OSC 99, otherwise OSC 777 for Ghostty, iTerm2, WezTerm, and similar terminals.
- The event log is append-only. Stale entries are filtered at switch time by live TMUX pane id.

Sources checked:

- `~/.pi/agent/extensions/pi-notify-switch.ts`
- `~/.local/bin/pi-waiting`
- `~/.dotfiles/.config/nix/home/tmux.nix`

### Vim editor

What it does:

- Replaces main Pi input editor with modal Vim-like editing.

Normal-mode basics:

- `Esc` from insert enters normal mode.
- `i`, `I`, `a`, `A` enter insert at common Vim positions.
- `h/j/k/l`, `w`, `b`, `0`, `$` navigate.
- `x`, `d`, `D`, `c`, `C`, `p`, `u` edit.

Gotcha:

- This is a lightweight Vim emulation over Pi's editor, not full Vim.

Source checked:

- `~/.pi/agent/extensions/vim-editor.ts`

### SearXNG web search

What it does:

- Adds `web_search` tool using self-hosted SearXNG.

Configuration:

- Default URL: `https://search.gerbil-matrix.ts.net`
- Override with `SEARXNG_URL`.
- SearXNG server must support JSON format.

Supported categories:

- `general`
- `science`
- `news`

Source checked:

- `~/.pi/agent/extensions/searxng.ts`

### Todo tool

What it does:

- Gives agent a branch-aware todo list with actions: `list`, `add`, `toggle`, `clear`.
- `/todos` opens interactive todo viewer.

Best practices:

- Use for in-session task tracking when work has multiple steps.
- Clear when task branch is complete.

Source checked:

- `~/.pi/agent/extensions/todo.ts`

### Dynamic model providers

Copilot API:

- Extension: `copilot-api-discovery.ts`
- Registers `copilot-api` provider from the raw GitHub Copilot `/models` endpoint, separate from Pi's built-in `github-copilot` provider and separate from the Copilot SDK usage dashboard.
- Uses `GITHUB_COPILOT_API_KEY` for provider auth and discovery. `GITHUB_COPILOT_BASE_URL` is optional and defaults to `https://api.githubcopilot.com`.
- Caches model metadata at `~/.cache/pi/copilot-api-models.json`.
- Refreshes stale cache after 12 hours.
- Includes chat models that are not disabled and do not explicitly disable tool calls. It does not require `model_picker_enabled`, so API-usable models such as `gpt-4o` can appear even when Copilot Chat picker models differ.
- Registers models through Pi's `openai-completions` adapter with conservative compatibility flags: no reasoning controls, no developer role, no store support.
- Gotcha: this provider does not use Pi's built-in Copilot OAuth refresh path. If `GITHUB_COPILOT_API_KEY` expires, refresh that environment variable before using `copilot-api/*` models.
- Check models with `pi --list-models copilot-api`; use with `pi --model copilot-api/gpt-4o`.
- Startup model-discovery logs are quiet by default. Set `PI_MODEL_DISCOVERY_DEBUG=1` to show them in interactive runs.

OpenCode Go:

- Extension: `opencode-go-discovery.ts`
- Registers `opencode-go` provider.
- Caches model metadata at `~/.cache/pi/opencode-go-models.json`.
- Refreshes stale cache after 24 hours.
- Uses `OPENCODE_API_KEY` for provider auth.
- Startup model-discovery logs are quiet by default. Set `PI_MODEL_DISCOVERY_DEBUG=1` to show them in interactive runs.

OpenRouter:

- Extension: `openrouter-models.ts`
- Registers `openrouter` provider when `OPENROUTER_API_KEY` is set.
- Caches model metadata at `~/.cache/pi/openrouter-models.json`.
- Refreshes stale cache after 24 hours.
- Startup model-discovery logs are quiet by default. Set `PI_MODEL_DISCOVERY_DEBUG=1` to show them in interactive runs.

Sources checked:

- `~/.pi/agent/extensions/copilot-api-discovery.ts`
- `~/.pi/agent/extensions/opencode-go-discovery.ts`
- `~/.pi/agent/extensions/openrouter-models.ts`

### Questionnaire tool

What it does:

- Lets agent ask one or more structured questions with selectable options and optional typed responses.

Best practices:

- Use when requirements are ambiguous and choices matter.
- Prefer questionnaire over guessing when multiple valid directions exist.

Source checked:

- `~/.pi/agent/extensions/questionnaire.ts`

### Supacode integration

What it does:

- Emits OSC 3008 lifecycle and notification signals to Supacode when running inside a Supacode surface.
- No-op outside Supacode.

Environment gates:

- `SUPACODE_SURFACE_ID`
- `SUPACODE_SOCKET_PATH` optional for local pid tracking.

Source checked:

- `~/.pi/agent/extensions/supacode/index.ts`

### Tirith guard

What it does:

- Hooks `tool_call` events for the Pi `bash` tool.
- Runs `tirith check --json --non-interactive --shell posix -- <command>`.
- Allows exit 0, warns on exit 2, blocks on exit 1 or exit 3 (WarnAck).
- Emits `hook-event` telemetry to tirith for check results, timeouts, and blocks.

Configuration:

- `TIRITH_BIN` — path to tirith binary (default: `tirith`).
- `TIRITH_HOOK_WARN_ACTION` — `allow` or `deny` for exit 2 warnings (default: `allow`).
- `TIRITH_FAIL_OPEN` — set to `1` to allow commands when tirith itself errors or is missing (default: block).

Shell hooks outside Pi:

- Managed in nix: `~/.dotfiles/.config/nix/home/shell/default.nix` (`profileExtra`).
- Do not run `tirith setup pi-cli` or `tirith init` manually; nix rebuilds overwrite those changes.

Policy:

- User-level source: `~/.dotfiles/.config/tirith/policy.yaml` (stowed to `~/.config/tirith/policy.yaml`).
- Per-project override: `.tirith/policy.yaml` (walks up from cwd to `.git`).
- Installed `tirith 0.3.1` uses a simple policy format; newer Nixpkgs versions add templates, a `version` field, and extra sections.

Gotchas:

- Synchronous 10-second check blocks the tool-call pipeline.
- Missing tirith binary blocks all `bash` calls unless `TIRITH_FAIL_OPEN=1`.
- Exit 3 (WarnAck) is treated as block because Pi cannot prompt for acknowledgement.
- Only the `bash` tool is guarded; file edits, web search, and other tools are not intercepted.
- stderr warnings may not always be visible in every Pi UI mode.

Source checked:

- `~/.pi/agent/extensions/tirith-guard.ts`

### Pi Guide autoupdate

What it does:

- On interactive `session_start`, fingerprints installed packages and local extension source files.
- If fingerprint changed, spawns a detached `pi -p` background run using `/skill:pi-guide-maintainer`.
- Updates `PI-GUIDE.md` without cluttering the active session.
- Shows a tiny footer status like `guide: updating in background`, then clears it.
- Does nothing in non-interactive modes such as `pi -p`, JSON, or RPC.

Scope:

- Watches `settings.json` package list.
- Watches `npm/package.json` and `npm/package-lock.json`.
- Watches `extensions/**/*.ts|js|mjs|cjs`.
- Does not watch skills or standalone keybinding changes.

Configuration:

- Disable: `PI_GUIDE_AUTOUPDATE=0`.
- Model override: `PI_GUIDE_MODEL=<provider/model>`.
- Pi binary override: `PI_GUIDE_PI_BIN=/path/to/pi`.
- Default model: `openai-codex/gpt-5.4-mini` with thinking off.
- Successful runs update the state fingerprint; failed background runs leave it unchanged so the next interactive startup retries.
- State file: `~/.pi/agent/pi-guide-autoupdate-state.json`.
- Lock file: `~/.pi/agent/pi-guide-autoupdate.lock`.
- Log file: `~/.pi/agent/pi-guide-maintainer.log`.

Source checked:

- `~/.pi/agent/extensions/pi-guide-autoupdate.ts`

## Maintenance checklist

When package or extension state changes:

- Run `~/.pi/agent/skills/pi-guide-maintainer/scripts/inventory.mjs`.
- Compare `settings.json` package list to guide.
- Read relevant package README and package manifest.
- Inspect extension entrypoint source for commands, shortcuts, config, and gotchas.
- Update user-facing notes.
- Remove stale entries for removed packages/extensions.
- Tell user what changed and whether `/reload` is needed.
