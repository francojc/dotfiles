# Pi Guide

Living guide for Jerid's Pi setup. Maintained by `/skill:pi-guide-maintainer`.

## Maintenance

- Canonical file: `~/.pi/agent/PI-GUIDE.md`
- Dotfiles file: `~/.dotfiles/.pi/agent/PI-GUIDE.md`
- This file is shared, curated context. Update it only for durable behavior, commands, configuration, or gotchas.
- Machine-local package versions, model configuration, theme, and extension inventory live in ignored `~/.pi/agent/PI-INVENTORY.local.md`.
- `pi-guide-autoupdate.ts` refreshes local inventory at interactive startup. Set `PI_GUIDE_AUTOUPDATE=0` to disable it.
- Package or local-extension changes that alter user-facing behavior need a deliberate guide edit. Refresh Pi with `/reload` after config changes.
- Dynamic provider follow-up: `copilot-api-discovery.ts`, `openrouter-models.ts`, and `opencode-go-discovery.ts` replace built-in provider catalogs. Evaluate removing them or migrating them to `refreshModels`, which integrates with `/model` refresh, `models-store.json`, and `pi update --models`.

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
| `/usage` | Show current-provider Codex, Copilot, or OpenRouter usage. |
| `/opencode-go-status [--refresh]` | Show OpenCode Go five-hour, weekly, and monthly subscription usage. |
| `/opencode-go-costs [day\|week\|30d\|all]` | Show locally recorded OpenCode Go cost by day, model, and response. Defaults to `week`. |
| `/skill:ketch-research` | Research web pages, OSS code, and library docs with Ketch. |
| `/skill:hunk-review` | Inspect and guide live Hunk Git-diff review sessions. |
| `/skill:tuicr` | Launch and consume tuicr Git-diff review sessions. |
| `/skill:pi-guide-maintainer` | Update or extend this guide. |

## Installed packages

Package inventory and resolved versions are machine-local. See `~/.pi/agent/PI-INVENTORY.local.md`.

| Package | What it adds |
| --- | --- |
| `pi-caveman` | Terse output modes and status indicator. |
| `pi-btw` | Parallel side conversations in overlay, with handoff back to main session. |
| `@plannotator/pi-extension` | Plan mode, browser-based plan review/annotation, restricted planning phase. |
| `@ogulcancelik/pi-ghostty-theme-sync` | Sync Pi theme from active Ghostty palette. |
| `@narumitw/pi-usage` | `/usage` menu for current-provider usage, including Codex, Copilot, and OpenRouter usage data. |
| `@github/copilot-sdk` | Copilot usage dashboard, session browser, model billing view, and `copilot_usage` tool. Requires GitHub CLI auth. |
| `@earendil-works/pi-coding-agent` | Runtime API used by local extensions and dynamic model discovery. |

## Local extensions

Loaded from `~/.pi/agent/extensions/`.

| Extension | What it does | User-facing controls |
| --- | --- | --- |
| `git-branch-dirty-footer.ts` | Custom footer with cwd, git branch/dirty counts, token usage, context usage, model, and extension statuses. | Automatic. |
| `copilot-usage/` | Shows GitHub Copilot quota, threshold footer meter, token-based billing state, model billing metadata, and Copilot SDK sessions. Footer polls quota every 60 s while a Copilot or `copilot-api` provider is active. | Primary: `/copilot`; secondary: `/copilot-quota`, `/copilot-models`, `/copilot-sessions`; agent `copilot_usage` tool. Requires `gh auth login` and active Copilot access for quota. |
| `copilot-api-discovery.ts` | Registers `copilot-api` models from GitHub's raw Copilot `/models` endpoint and caches them locally. | Requires `GITHUB_COPILOT_API_KEY`; optional `GITHUB_COPILOT_BASE_URL`; `pi --list-models copilot-api`. |
| `opencode-go-discovery.ts` | Registers `opencode-go` models from OpenCode + models.dev metadata and caches them locally. | Requires `OPENCODE_API_KEY` for actual use; `pi --list-models opencode-go`. |
| `openrouter-models.ts` | Registers `openrouter` models from the OpenRouter API and caches them locally. | Requires `OPENROUTER_API_KEY`; `pi --list-models openrouter`. |
| `subscription-usage-status.ts` | Shared formatter/parser helpers for compact subscription status. | Used by `opencode-go-usage.ts`. |
| `pi-guide-autoupdate.ts` | Writes ignored local package, model, and extension inventory. It never edits this shared guide. | Automatic on interactive session start; set `PI_GUIDE_AUTOUPDATE=0` to disable. |
| `working-indicator.ts` | Custom animated working indicator and rotating status words. | `/indicator [schwa|eye|pulse|bounce|spinner|none|default]` |
| `pi-notify-switch.ts` | Sends native terminal notifications when Pi is waiting and records TMUX panes for quick switching. | `/waiting`, TMUX `prefix N`, TMUX `prefix C-n` |
| `vim-editor.ts` | Vim-like normal/insert mode for Pi input editor. | `Esc`, `i`, `a`, `h/j/k/l`, `w`, `b`, `d`, `c`, `p`, `u` in normal mode. |
| `session-sync/` | Checks trusted SSH destinations and pulls new Pi session transcripts. | `/session-sync-status`, `/session-sync-pull [host]` |
| `session-sync.json` | Trusted SSH source/destination registry roots for session-sync extension. | Config only. No session data is tracked. |
| `auto-session-name.ts` | Sets content-derived session display names, then refreshes them with a cheap title model. | `/autoname` |
| `google-workspace/` | Google Drive, Docs, Sheets, and Slides tools with OAuth token refresh. Vendored from `Geun-Oh/pi-google-workspace`, adapted so client credentials stay in `pass`/env and only tokens touch disk. | `/gws-setup`, `/gws-logout`; 15 `google_*` agent tools. |

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

### SSH alias management

What it does:

- Home Manager generates `~/.ssh/config.d/nix-managed.conf` from `.config/nix/home/ssh-aliases.nix` for stable cross-machine aliases: `forgejo`, `codeberg.org`, `rover`, `minicore`, and `airborne`.
- `/session-sync-status` reads the explicit `~/.pi/agent/session-sync.json` source/destination allowlist. Targets are `minicore` and `airborne`; it omits current machine, then checks each remote target for noninteractive SSH, remote `$HOME`, remote `rsync`, remote Pi session-registry presence, and registry session count.
- `/session-sync-pull [host]` opens a 12-row, scrolling picker of new remote `*.jsonl` session transcripts. Type to filter, use `↑`/`↓` to select one, then preview and confirm its pull. It uses `rsync --ignore-existing`, so it never overwrites existing local session files. Omit `host` to use configured default or only remote target.
- Main `~/.ssh/config` remains app/user-managed dispatcher. It includes OrbStack first, then Nix fragment. Nix does not replace main SSH config.

Gotchas:

- Do not edit generated fragment. Change `.config/nix/home/ssh-aliases.nix`, then apply normal Nix/Home Manager deployment for host.
- Keep OrbStack include first. Its `orb` host requires placement before host blocks.
- SSH usually uses first obtained value. Keep alias definitions out of later main-config blocks.
- Private keys stay outside Nix and Git. `IdentityFile` values only name local key paths.
- `forgejo` relies on Tailscale MagicDNS, not tracked tailnet domain.
- Run `/reload` after session-sync extension edits.

Sources checked:

- `.config/nix/home/default.nix`
- `.config/nix/home/ssh-aliases.nix`
- `~/.ssh/config`

### Google Workspace

What it does:

- Vendored from `Geun-Oh/pi-google-workspace` (MIT) into `agent/extensions/google-workspace/`. 15 `google_*` tools: Drive list/download/upload/create-folder, Docs read/create/append/replace/download (incl. `md` export via built-in Docs-to-Markdown converter), Sheets create/read/update, Slides read/replace-text, plus status.
- OAuth: `/gws-setup` runs browser consent via local callback server on `http://127.0.0.1:53682/oauth2callback` (manual code paste fallback). `/gws-logout` deletes tokens.

Credentials:

- Client ID/Secret resolve from `GOOGLE_CLIENT_ID`/`GOOGLE_CLIENT_SECRET` env or `pass show GWS/GOOGLE_CLIENT_ID` / `GWS/GOOGLE_CLIENT_SECRET`. Never written to disk.
- Tokens only in `~/.pi/agent/google-workspace/oauth.json` (0600, outside repo).

Gotchas:

- First consent must return a `refresh_token`; if missing or scopes changed, re-run `/gws-setup`.
- Google Cloud project needs Drive, Docs, Sheets, Slides APIs enabled; account must be a test user while consent screen is in Testing.
- No session footer status by design; check `google_workspace_status` tool instead.

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
- [Official Ketch skill](https://raw.githubusercontent.com/1broseidon/ketch/refs/heads/main/skills/ketch/SKILL.md).
- `ketch --help` and command help.

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
- [tuicr review CLI](https://github.com/agavra/tuicr/blob/main/docs/REVIEW_CLI.md).

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

- Overlay placement and hide-on-unfocus are not configurable in current `pi-btw`.
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
- Package uses `node-pty`; on NixOS, `make` must be on `PATH` for package installs or updates. Use `nix shell nixpkgs#gnumake -c pi install ...` if it is not. Verify the native module loads after npm reinstalls or platform changes.

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
- `~/.pi/agent/extensions/opencode-go-usage.ts`
- `~/.pi/agent/extensions/opencode-go-costs.ts`
- `~/.pi/agent/extensions/subscription-usage-status.ts`

### OpenAI/OpenRouter usage

What it does:

- The global `@narumitw/pi-usage` package adds `/usage` as the main usage menu.
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
- **Sources:** [OpenCode Go docs](https://opencode.ai/docs/go/), [OpenCode Go console routes](https://github.com/anomalyco/opencode/tree/dev/packages/console/app/src/routes/zen/go/v1), and [`opencode-statusline` OpenCode Go collector](https://github.com/kalcohol/opencode-statusline/blob/main/src/lib/providers.ts).

### Automatic session names

What it does:

- Gives persistent sessions a fallback title from first substantive prompt before first assistant response writes JSONL.
- Generates a short content title after first settled turn, then every four user turns. The current default is OpenRouter's paid `openai/gpt-oss-20b` model.
- Treats `/name <title>` as a manual pin. Auto-refresh stops until `/autoname auto` or `/autoname refresh --force`.
- Stores per-session auto/manual state in session custom entries, so reload, resume, and fork flows retain naming behavior.

Commands and configuration:

- `/autoname` shows mode, model, and refresh interval.
- `/autoname off` pins current title.
- `/autoname auto` unpins and refreshes title.
- `/autoname refresh` refreshes unpinned title. Add `--force` to replace a manual title.
- `/autoname model <provider/model>` changes and persists title model.
- `~/.pi/agent/auto-session-name.json` configures enabled state, title model, refresh interval, and transcript bound.

Gotchas:

- Pi session JSONL filenames remain timestamp plus UUID. This extension changes Pi session display names in footer and `/resume`, not physical filenames.
- Each refresh sends at most `maxTranscriptChars` conversation text to configured title provider. Switch model or disable extension for sensitive conversations.
- Model price and availability can change. Set another configured paid model with `/autoname model <provider/model>` when needed.
- Run `/reload` after extension edits. Config changes apply to new or resumed session runtimes.

Sources checked:

- `~/.pi/agent/extensions/auto-session-name.ts`
- `~/.pi/agent/auto-session-name.json`
- `@earendil-works/pi-coding-agent/docs/extensions.md`
- `@earendil-works/pi-coding-agent/docs/session-format.md`

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
