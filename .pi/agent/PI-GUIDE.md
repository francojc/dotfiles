# Pi Guide

Living guide for Jerid's Pi setup. Maintained by `/skill:pi-guide-maintainer`.

## Maintenance

- Canonical file: `~/.pi/agent/PI-GUIDE.md`
- Dotfiles file: `~/.dotfiles/.pi/agent/PI-GUIDE.md`
- Last updated: 2026-08-08
- Pi compatibility audit: `0.82.1`; `pi --list-models` completed cleanly and all configured `enabledModels` resolved.
- Compatibility cleanup completed 2026-08-08: custom footer now reads thinking level from `pi.getThinkingLevel()`; todo state relies on replacement-session `session_start`; local tools import current `typebox`; removed ignored `compat.reasoningEffortMap` config.
- Dynamic provider follow-up: `copilot-api-discovery.ts`, `openrouter-models.ts`, and `opencode-go-discovery.ts` replace built-in provider catalogs. Evaluate removing them or migrating them to `refreshModels`, which integrates with `/model` refresh, `models-store.json`, and `pi update --models`.
- Refresh after package or local-extension changes.
- Package and local-extension changes trigger background guide maintenance on next interactive Pi startup.
- Background guide update log: `~/.pi/agent/pi-guide-maintainer.log`
- Disable background guide updates with `PI_GUIDE_AUTOUPDATE=0`
- Override background guide model with `PI_GUIDE_MODEL=<provider/model>`
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
| `/codex-status [--refresh]` | Show ChatGPT plan, quota windows, reset times, credits, and model buckets. |
| `/opencode-go-status [--refresh]` | Show OpenCode Go five-hour, weekly, and monthly subscription usage. |
| `/opencode-go-costs [day\|week\|30d\|all]` | Show locally recorded OpenCode Go cost by day, model, and response. Defaults to `week`. |
| `/skill:ketch-research` | Research web pages, OSS code, and library docs with Ketch. |
| `/skill:hunk-review` | Inspect and guide live Hunk Git-diff review sessions. |
| `/skill:tuicr` | Launch and consume tuicr Git-diff review sessions. |
| `/skill:pi-guide-maintainer` | Update or extend this guide. |

## Installed packages

Loaded as Pi packages through `~/.pi/agent/settings.json` and installed under `~/.pi/agent/npm/`.

| Package | Version/config | What it adds |
| --- | --- | --- |
| `pi-caveman` | `1.0.7` | Terse output modes and status indicator. |
| `pi-btw` | `0.4.1` | Parallel side conversations in overlay, with handoff back to main session. |
| `@plannotator/pi-extension` | `0.25.0` | Plan mode, browser-based plan review/annotation, restricted planning phase. |
| `@ogulcancelik/pi-ghostty-theme-sync` | `0.1.2` | Sync Pi theme from active Ghostty palette. |
| `@narumitw/pi-usage` | `0.31.0` | `/usage` menu for current-provider usage. Covers OpenAI Codex subscription windows and OpenRouter API-key spend/credit limits. `/codex-status` is retained as a compatibility alias. |
| `@narumitw/pi-codex-usage` | `0.12.0` | `/codex-status` plus compact Codex statusline support. Shows plan, 5-hour and weekly windows, reset times, and credits. |
| `@github/copilot-sdk` | `0.2.1` (extension dependency) | Powers the Copilot usage dashboard, session browser, model billing view, and `copilot_usage` tool. Requires GitHub CLI auth for quota data. |
| `@earendil-works/pi-coding-agent` | runtime API | Needed by local extensions, including Copilot usage and dynamic model discovery. |

## Local extensions

Loaded from `~/.pi/agent/extensions/`.

| Extension | What it does | User-facing controls |
| --- | --- | --- |
| `git-branch-dirty-footer.ts` | Custom footer with cwd, git branch/dirty counts, token usage, context usage, model, and extension statuses. | Automatic. |
| `copilot-usage/` | Shows GitHub Copilot quota, threshold footer meter, token-based billing state, model billing metadata, and Copilot SDK sessions. Footer polls quota every 60 s while a Copilot provider is active. | Primary: `/copilot`; secondary: `/copilot-quota`, `/copilot-models`, `/copilot-sessions`; agent `copilot_usage` tool. Requires `gh auth login` and active Copilot access for quota. |
| `copilot-api-discovery.ts` | Registers `copilot-api` models from GitHub's raw Copilot `/models` endpoint and caches them locally. | Requires `GITHUB_COPILOT_API_KEY`; optional `GITHUB_COPILOT_BASE_URL`; `pi --list-models copilot-api`. |
| `opencode-go-discovery.ts` | Registers `opencode-go` models from OpenCode + models.dev metadata and caches them locally. | Requires `OPENCODE_API_KEY` for actual use; `pi --list-models opencode-go`. |
| `openrouter-models.ts` | Registers `openrouter` models from the OpenRouter API and caches them locally. | Requires `OPENROUTER_API_KEY`; `pi --list-models openrouter`. |
| `pi-guide-autoupdate.ts` | Fingerprints packages and local TS/JS/MJS/CJS extensions, then spawns a background `/skill:pi-guide-maintainer` run when they change. | Automatic on interactive session start; status only. |
| `working-indicator.ts` | Custom animated working indicator and rotating status words. | `/indicator [schwa|eye|pulse|bounce|spinner|none|default]` |
| `pi-notify-switch.ts` | Sends native terminal notifications when Pi is waiting and records TMUX panes for quick switching. | `/waiting`, TMUX `prefix N`, TMUX `prefix C-n` |
| `vim-editor.ts` | Vim-like normal/insert mode for Pi input editor. | `Esc`, `i`, `a`, `h/j/k/l`, `w`, `b`, `d`, `c`, `p`, `u` in normal mode. |
| `copilot-api-discovery.ts` | Registers dynamic `copilot-api` provider from the raw GitHub Copilot OpenAI-compatible API and caches discovered models locally. | Requires `GITHUB_COPILOT_API_KEY`; optional `GITHUB_COPILOT_BASE_URL`; use `pi --list-models copilot-api`. |
| `opencode-go-discovery.ts` | Registers dynamic `opencode-go` provider from OpenCode/model metadata and caches discovered models locally. | Requires `OPENCODE_API_KEY` for actual use. |
| `opencode-go-usage.ts` | Shows provider-gated OpenCode Go subscription usage in the custom footer. | `/opencode-go-status [--refresh]`; credentials from `pass` or environment. |
| `opencode-go-costs.ts` | Reports local OpenCode Go response costs across persisted Pi sessions. | `/opencode-go-costs [day\|week\|30d\|all]`; defaults to `week`. |
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

### tuicr review skill

What it does:

- Opens `tuicr` in a detached tmux pane, so Pi remains available while you review.
- Reads persisted, user-authored line, range, file, and review comments through `tuicr review comments` JSON.
- Treats `issue`, `suggestion`, `note`, and `praise` according to their configured intent. Pi never writes or impersonates your review comments during user-led review.

Use:

- Ask Pi to review its changes with tuicr, or run `/skill:tuicr` explicitly.
- Start a direct review: `~/.pi/agent/skills/tuicr/scripts/tuicr-tmux.sh . -w`.
- Review a range: `~/.pi/agent/skills/tuicr/scripts/tuicr-tmux.sh . -r main..HEAD`.
- Add comments in tuicr, then tell Pi “comments ready.”

Recommendation:

- Make tuicr default review workflow. Its persisted JSON comments map directly to Pi fixes and it can later submit GitHub/GitLab reviews.
- Keep Hunk during a short trial for its existing live-session navigation. Retire it after several tuicr reviews if no workflow remains unique to Hunk.

Gotchas:

- Requires Pi inside tmux. Wrapper returns pane ID without switching focus; use `Ctrl-b` then arrow keys to enter review pane.
- Local Git reviews work with Codeberg/Forgejo remotes. Tuicr remote submission supports GitHub and GitLab, not Forgejo.
- Multiple active sessions require a specific slug. Check with `tuicr review list --repo .`.
- Reload Pi once to discover new skill: `/reload`.

Sources checked:

- `~/.pi/agent/skills/tuicr/SKILL.md`
- `~/.pi/agent/skills/tuicr/scripts/tuicr-tmux.sh`
- [tuicr review CLI](https://github.com/agavra/tuicr/blob/main/docs/REVIEW_CLI.md), checked 2026-07-29.

### pi-caveman

What it does:

- Compresses assistant prose while keeping technical substance.
- Hooks system prompt before agent turns.
- Stores default config in `~/.pi/agent/caveman.json`.
- Shows an animated footer status while active, unless disabled in config.

Commands:

- `/caveman` toggles caveman mode.
- `/caveman lite`, `full`, `ultra`, `wenyan-lite`, `wenyan`, `wenyan-ultra`, `micro` choose compression style.
- `/caveman off`, `stop`, or `quit` disables it.
- `/caveman config` opens settings dialog.

Best practices:

- Use `lite` for professional concise prose.
- Use `full` or `micro` for token thrift during coding.
- Temporarily disable for delicate writing, policy nuance, or student-facing text.

Sources checked:

- `~/.pi/agent/npm/node_modules/pi-caveman/README.md`
- `~/.pi/agent/npm/node_modules/pi-caveman/package.json`

### pi-btw

What it does:

- Opens a parallel side-agent thread while main agent can continue working.
- Contextual `/btw` inherits current main session context.
- `/btw:tangent` starts a contextless side thread.
- Hidden thread state stays out of main LLM context until handed off.
- The overlay keeps the current main session visible underneath.

Commands:

- `/btw [--save] <question>` asks side question.
- `/btw:new [question]` clears current BTW thread and starts fresh contextual one.
- `/btw:tangent [--save] <question>` uses contextless side thread.
- `/btw:clear` dismisses overlay and clears thread.
- `/btw:inject [instructions]` sends full side thread to main agent.
- `/btw:summarize [instructions]` summarizes side thread, then sends summary to main agent.
- `/btw:model ...` and `/btw:thinking ...` manage BTW-only model/thinking overrides.

Overlay controls:

- `Alt+/` toggles focus on most terminals.
- `Ctrl+Alt+W` is the fallback focus toggle.
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
- `~/.pi/agent/npm/node_modules/pi-btw/package.json`
- `~/.pi/agent/npm/node_modules/pi-btw/extensions/btw.ts`

### Plannotator

What it does:

- Adds plan mode with a browser UI for reviewing, annotating, approving, or denying plans.
- Planning phase restricts destructive behavior and focuses the agent on producing checklist plans.
- Approved plans move into execution with full tool access.
- Supports code review, markdown annotation, and last-message annotation in the browser UI.

Commands and shortcuts:

- `pi --plan` starts Pi in plan mode.
- `/plannotator` toggles plan mode during a session.
- `/plannotator-review` opens the code review UI for current changes.
- `/plannotator-annotate <file>` opens a markdown file in the annotation UI.
- `/plannotator-last` annotates the last assistant message.
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
- `~/.pi/agent/npm/node_modules/@plannotator/pi-extension/package.json`

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

- Shows GitHub Copilot quota from `gh api /copilot_internal/user`.
- Adds a threshold footer meter like ` Copilot [██████░░░░] 60%`, where the bar means remaining quota.
- Detects token-based Copilot billing and uses `quota_remaining` decimals when GitHub reports them.
- Fetches Copilot SDK session and model metadata in a short-lived child process, avoiding SDK socket leaks in the main Pi process.
- Shows current Copilot model billing metadata. GitHub may return old-style `billing.multiplier` values or newer `token_prices`, so the dashboard displays whichever metadata is available, compares metered models relative to the cheapest metered model, compacts large raw token-price integers, and treats all-zero token prices as included.
- The footer only stays active while a GitHub Copilot or `copilot-api` model is selected, and it refreshes on a 60 s polling loop after a short startup delay.

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
- The local extension is split between `extensions/copilot-usage/index.ts` and `extensions/copilot-usage/src/index.ts`; the package entrypoint re-exports the main source file.
- Run `/reload` after edits or dependency updates.

Sources checked:

- `~/.pi/agent/extensions/copilot-usage/README.md`
- `~/.pi/agent/extensions/copilot-usage/src/index.ts`
- `~/.pi/agent/extensions/copilot-usage/index.ts`
- `~/.pi/agent/extensions/copilot-usage/package.json`

### OpenAI Codex usage

What it does:

- The global package `npm:@narumitw/pi-codex-usage@0.12.0` adds `/codex-status` as the main Codex usage command.
- Shows Codex plan, 5-hour and weekly usage windows, reset times, extra buckets when available, and credits.
- Adds a compact statusline item automatically while the selected model uses `openai-codex`.
- Uses Pi auth first, then falls back to `codex app-server --listen stdio://` when needed.
- Supports `--refresh`, `--no-statusline`, and `--clear-statusline`.

Auth and data caveats:

- It resolves credentials through Pi first and does not read Pi or Codex auth files directly.
- OpenAI API keys are not ChatGPT Codex subscription auth.
- Usage snapshots are cached briefly unless refreshed.
- Reload Pi after installing or updating the package.

Sources checked:

- `~/.pi/agent/npm/node_modules/@narumitw/pi-codex-usage/README.md`
- `~/.pi/agent/npm/node_modules/@narumitw/pi-codex-usage/package.json`

### OpenAI/OpenRouter usage

What it does:

- The global package `npm:@narumitw/pi-usage@0.31.0` adds `/usage` as the main usage menu.
- `/codex-status` is retained as a compatibility alias.
- The menu covers OpenAI Codex subscription windows, resets, credits, model buckets, and OpenRouter per-key spend/credit limits.
- It keeps the compact statusline scoped to the currently selected supported provider and runtime account.
- Cross-provider queries are explicit menu actions, not slash-command flags.

Auth and data caveats:

- It resolves credentials through Pi and does not read Pi auth files, Codex CLI auth, or provider auth files directly.
- OpenAI Codex usage is subscription usage, not API billing. OpenRouter usage is API-key spend/credit tracking, not consumer subscription quota.
- The package does not pretend those limits have the same semantics.
- Reload Pi after installing or updating the package.

Sources checked:

- `~/.pi/agent/npm/node_modules/@narumitw/pi-usage/README.md`
- `~/.pi/agent/npm/node_modules/@narumitw/pi-usage/package.json`

### OpenCode Go usage

What it does:

- Shows a Codex-shaped remaining-quota footer meter only while an `opencode-go/*` model is selected.
- `/opencode-go-status` shows five-hour, weekly, and monthly remaining percentage plus reset time. Use `/opencode-go-status --refresh` to bypass its short fresh cache.
- Uses a 60-second fresh cache, a 10-minute stale fallback, and 60-second recursive polling after a short startup delay. Switching away from OpenCode Go or shutting down clears its status and invalidates late poll results.
- `/opencode-go-costs [day|week|30d|all]` scans persisted Pi session JSONL files and reports daily spend bars, spend by model, and highest/lowest-cost responses. It defaults to `week`.
- Cost values are Pi's per-response provider-price records, not a Go dashboard ledger. Forked/copied history is deduplicated by provider response ID. It only reports usage made through Pi on this machine, and `lowest-cost` means cheapest response, not quality-adjusted value.

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

[235 more lines in file. Use offset=401 to continue.]
