# Pi Guide

Living guide for Jerid's Pi setup. Maintained by `/skill:pi-guide-maintainer`.

## Maintenance

- Canonical file: `~/.pi/agent/PI-GUIDE.md`
- Dotfiles file: `~/.dotfiles/.pi/agent/PI-GUIDE.md`
- This file is shared, curated context. Update it only for durable behavior, commands, configuration, or gotchas.
- Machine-local package versions, model configuration, theme, and extension inventory live in ignored `~/.pi/agent/PI-INVENTORY.local.md`.
- `pi-guide-autoupdate.ts` refreshes local inventory at interactive startup. Set `PI_GUIDE_AUTOUPDATE=0` to disable it.
- Package or local-extension changes that alter user-facing behavior need a deliberate guide edit. Refresh Pi with `/reload` after config changes.
- Model providers are managed through the `pi-bifrost` gateway package. The former `copilot-api-discovery.ts`, `openrouter-models.ts`, and `copilot-usage/` extensions were removed in favor of it, or archived; the `pi-bifrost` pattern (discover through `refreshModels`, cache to disk, ship metadata baseline, never block startup) is the reference for any future dynamic provider.
- One credential serves every model: the Bifrost virtual key from `pass show API/BIFROST_VK`. Direct providers (opencode, openrouter, github-copilot, typesafe) are not configured and hold no keys. `~/.pi/agent/auth.json` is not used; Pi may recreate it as an empty `{}`, which is harmless.
- Two providers are registered: `bifrost` exposes the full gateway catalog, and `bifrost-auto` exposes only `auto` for the complexity router. Default is `bifrost-auto/auto`, because the router picks the model.

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
| `/bifrost-context` | Show the routed model, its real window, and the declared window comparison. |
| `/bifrost-clear` | Clear the Bifrost route status line. |
| `/typesafe status` | Show TypeSafe consent, auth, usage, spend estimate, and caps. |
| `/typesafe enable` | Allow agent `typesafe_evaluate` calls for current session after data notice. |
| `/typesafe playground` | Edit and run Jev request without adding result to model context. |
| `/skill:typesafe-ai` | Design TypeSafe System One judgments and integrations using live docs. |
| `/websearch [query]` | Open the pi-web-access curator window. |
| `/search` | Browse stored web search results. |
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
| `pi-typesafe` | Jev `typesafe_evaluate` tool, `/typesafe` playground/auth/status commands, and typed API for other extensions. |
| `@earendil-works/pi-coding-agent` | Runtime API used by local extensions and dynamic model discovery. |
| `pi-bifrost` | Bifrost gateway provider with disk-cached model discovery and a packaged metadata baseline. Installed from the `jeridf/pi-bifrost` Forgejo repo. |
| `pi-web-access` | Web search, URL fetching, PDF extraction, GitHub repo reading, and video understanding. Four agent tools plus the web curator. | `web_search`, `source_check`, `fetch_content`, `get_search_content`; `/websearch`, `/search`, `/curator`. Configured in `~/.pi/agent/web-search.json`. |

## Local extensions

Loaded from `~/.pi/agent/extensions/`.

| Extension | What it does | User-facing controls |
| --- | --- | --- |
| `git-branch-dirty-footer.ts` | Custom footer with cwd, git branch/dirty counts, token usage, context usage, model, and extension statuses. | Automatic. |
| `atuin.ts` | Tracks bash tool commands in Atuin history with author `pi`, via `tool_call`/`tool_execution_end` events. | Requires Atuin; check with `atuin search --author pi`. |
| `pi-guide-autoupdate.ts` | Writes ignored local package, model, and extension inventory. It never edits this shared guide. | Automatic on interactive session start; set `PI_GUIDE_AUTOUPDATE=0` to disable. |
| `working-indicator.ts` | Custom animated working indicator and rotating status words. | `/indicator [schwa|eye|pulse|bounce|spinner|none|default]` |
| `pi-notify-switch.ts` | Sends native terminal notifications when Pi is waiting and records TMUX panes for quick switching. | `/waiting`, TMUX `prefix N`, TMUX `prefix C-n` |
| `vim-editor.ts` | Vim-like normal/insert mode for Pi input editor. | `Esc`, `i`, `a`, `h/j/k/l`, `w`, `b`, `d`, `c`, `p`, `u` in normal mode. |
| `session-sync/` | Checks trusted SSH destinations and pulls new Pi session transcripts. | `/session-sync-status`, `/session-sync-pull [host]` |
| `session-sync.json` | Trusted SSH source/destination registry roots for session-sync extension. | Config only. No session data is tracked. |
| `auto-session-name.ts` | Sets content-derived session display names, then refreshes them with a cheap title model. | `/autoname` |

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

### TypeSafe System One

What it does:

- `pi-typesafe` exposes Jev as a sidecar judgment tool, not a selectable Pi chat model. It evaluates supplied state with typed Choice, Score, and Noul questions and returns probabilities rather than prose.
- `/typesafe test` and `/typesafe playground` keep results out of main model context. `typesafe_evaluate` returns results to agent context.
- `typesafe-ai` skill guides integration design and requires reading current TypeSafe docs and relevant cookbooks before implementation.

Use:

- Run `/typesafe enable` each session before agent tool calls. Consent is session-local; use `/typesafe disable` to stop future calls.
- Use Jev for narrow semantic judgments: routing, triage, ranking, extraction from known candidates, answer checks, and rubric scoring. Keep calculations, exact lookups, policy, and actions in code.
- Batch independent questions over same state. Include `other` or `unclear` when Choice candidates may not cover input. Treat probability and confidence as uncertainty signals, never authorization.
- For this setup, `TYPESAFE_API_KEY` comes from `pass` entry `API/TYPESAFE_API_KEY` through generated `~/.variables.env`. Run `pass-to-env`, then start new Pi process after key changes.

Limits and gotchas:

- Only explicitly submitted state and questions go to TypeSafe. Do not send secrets, sensitive student data, unpublished review material, or protected institutional data without authorization.
- Bundled extension targets direct `https://api.typesafe.ai` with `jev-latest`. OpenCode Zen also offers Jev through `/zen/v1/systemone`, but bundled extension does not expose Zen backend. Do not add Jev to Pi `models.json`: Pi chat-provider APIs do not support System One response shape.
- Default limits: 32 questions and 64 KiB JSON per request, 20 attempts per session, 15 s timeout, no retries. Daily caps are unset unless `PI_TYPESAFE_MAX_REQUESTS_PER_DAY`, `PI_TYPESAFE_MAX_INPUT_TOKENS_PER_DAY`, or `PI_TYPESAFE_MAX_USD_PER_DAY` is set.
- Session limit resets on session start or reload. Daily counters persist in `~/.pi/agent/pi-typesafe/usage.json`.
- Direct TypeSafe and OpenCode Zen use separate keys, routing, model IDs, billing, and usage ledgers. Prefer direct key for bundled extension; consider Zen adapter only after concrete need.

Sources checked:

- `~/.pi/agent/npm/node_modules/pi-typesafe/README.md`
- `~/.pi/agent/npm/node_modules/pi-typesafe/dist/extension.js`
- `~/.pi/agent/npm/node_modules/pi-typesafe/dist/client.js`
- `~/.pi/agent/skills/typesafe-ai/SKILL.md`
- [TypeSafe documentation index](https://docs.typesafe.ai/llms.txt)
- [OpenCode Zen endpoints](https://opencode.ai/docs/zen/)

### pi-web-access

What it does:

- Registers four agent tools: `web_search`, `source_check`, `fetch_content`, and `get_search_content`.
- Routes search through a configured provider chain. This setup puts self-hosted `degoog` first, then Brave, then DuckDuckGo, falling back on transient, quota, network, invalid-response, empty, and domain-miss failures.
- Fetches URLs as readable Markdown, extracts PDFs, clones GitHub repos, and handles YouTube/local video via Gemini.
- Caches fetched content in `~/.pi/agent/web-search-cache/` for one hour (128 entries / 128 MiB cap), shared across Pi processes.

Use:

- Ask Pi to research or read a page; it selects the tool. `/websearch [query]` opens the curator window, `/search` browses stored results, and `/curator` toggles the summary workflow.
- `provider` accepts `auto`, `all`, a single name, or a comma-separated list. Configured default is the `searchRouting` chain: `degoog` → `brave` → `duckduckgo`.
- Config lives in `~/.pi/agent/web-search.json`. Reload Pi after editing it.

Gotchas:

- `degoog` is explicit-only: never chosen by `auto` and never part of `provider: "all"`. It appears here only because it is listed in `searchRouting.providers`.
- `ssrf.allowRanges` carries `100.69.188.50/32` so the Tailscale-hosted degoog instance is reachable. Remove it if that host changes.
- `fetchRouting.allowRemoteHostedProviders` is off, so `fetch_content` cannot fall back to Jina, Firecrawl, Parallel, or other hosted extractors. JS-heavy or bot-walled pages fail with a fallback hint instead.
- `source_check` always reports `status: "unclear"` at 0.30 confidence. `assessClaim()` in `source-check.ts` is hardcoded and performs no semantic support/contradiction assessment; it only gathers passages for manual review.
- `braveApiKey` resolves through `!pass show API/KETCH_BRAVE_API_KEY`. A credential command must exit non-zero to signal absence, so a stale `pass` entry surfaces as a request failure, not as a skipped provider.
- DuckDuckGo is keyless and rate-limits hard: bursts trigger a bot check for 10–15 minutes, after which it reports `quota` and pauses.

Sources checked:

- `~/.pi/agent/npm/node_modules/pi-web-access/README.md`
- `~/.pi/agent/npm/node_modules/pi-web-access/index.ts`, `source-check.ts`, `storage.ts`
- `~/.pi/agent/web-search.json`
- Live checks: degoog `/api/search`, Brave API, `fetch_content`, `get_search_content`

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

### Copilot usage (archived)

Not loaded. The `copilot-usage` extension moved to `~/.pi/agent/archive/copilot-usage/` on 2026-11-02, with a note in its `ARCHIVED.md`.

Why: Pi's providers are now `bifrost` and `bifrost-auto` only. Copilot is reached through the Bifrost gateway rather than as a direct provider, so a local quota dashboard and Copilot SDK session browser have nothing to monitor. No Codex tooling is used either. `~/.codex` was moved to `~/.codex.archived-20261102`.

What it used to add, for the record:

- `/copilot`, `/copilot-quota`, `/copilot-models`, `/copilot-sessions`, and the `copilot_usage` agent tool.
- A threshold footer quota meter, refreshed on a 60 s poll while a Copilot-capable provider was selected.
- Copilot SDK session and model billing views, fetched in a short-lived child process to avoid SDK socket leaks.

Restoring:

```
mv ~/.pi/agent/archive/copilot-usage ~/.pi/agent/extensions/copilot-usage
```

Then `/reload`. Its git-ignored `node_modules/` moved with it.

Left untouched: the nix-darwin `copilot-api` launchd service stays enabled, because something other than Pi on this host uses that loopback proxy.

### Bifrost gateway models

What it does:

- Registers a `bifrost` provider from a Bifrost LLM gateway's `GET /v1/models`, so Pi reaches every upstream the gateway fronts through one credential and one base URL. Model IDs keep the gateway's provider prefix, such as `opencode-zen/glm-5.3`, which is the string Bifrost routes on.
- Bifrost owns routing, fallbacks, retries, load balancing, caching, governance, and guardrails. Pi owns only the model catalog, prompt caching hints, and cost display.
- Discovery runs through `refreshModels`, so it participates in startup refresh and `/model`. A disk cache keeps the provider usable offline and when the gateway is down, so only the first fetch on a new host needs the gateway reachable.
- The gateway payload is thinner than Bifrost's docs describe: `id`, `normalized_name`, `created`, `owned_by`, `pricing`, and `context_length` / `max_output_tokens` on only a few entries. It omits names, modalities, reasoning efforts, protocol support, and per-model tool support.
- The gap is filled by a generated patch file derived from models.dev, and by a probe that hides models the gateway refuses.

Configuration:

| Item | Value |
| --- | --- |
| Package | `pi-bifrost`, installed from the `jeridf/pi-bifrost` Forgejo repo as a pinned git source. Ships the extension plus its metadata baseline, so a host needs only the package and a virtual key. |
| Virtual key | `pass show API/BIFROST_VK` by default, resolved at request time |
| `BIFROST_BASE_URL` | Base URL including `/v1`, defaults to the gateway hostname in the extension |
| `BIFROST_VK`, `BIFROST_VK_FILE`, `BIFROST_VK_PASS` | Credential overrides for other keys or hosts |
| `BIFROST_MODEL_OVERRIDES` | Patch file path override, taking precedence over a host-regenerated file and the packaged baseline |
| `pi --list-models bifrost` | Inspect the discovered catalog. Cache-only: it never fetches, so a fresh host shows nothing until the first interactive start. |
| First interactive start or `/model` | Fetches the catalog past the 6-hour freshness window and writes the cache |

Files:

- Package `index.ts`: discovery, patch application, unreachable filter.
- Patch file precedence: `BIFROST_MODEL_OVERRIDES`, then `~/.config/bifrost-gateway/model-overrides.json` on a host that regenerates it, then `model-overrides.json` shipped inside the package. Keys are bare model names, so they survive a gateway provider-prefix change.
- Package `scripts/gen-model-overrides.py` regenerates the patch file. A plain run uses models.dev only, `--probe` also probes each model, `--reprobe` ignores cached verdicts, `--out` relocates the result, `--tiers` relocates the tier file, `--sync-models` writes computed limits into `models.json`. It needs `BIFROST_VK` or the pass entry.
- Package `config/auto-tiers.json` mirrors the gateway's routing rules: the tier pools a routing provider can reach, targets and fallbacks. The generator resolves every member and reports the intersection as the limits that provider should declare, plus a `stale` line when `models.json` disagrees. Keeping this file in sync with the dashboard rules is what makes the declared window honest.
- Limits prefer each gateway provider's own models.dev catalog, because they disagree: `glm-5.3` is 1,000,000 on opencode and 1,048,576 on openrouter, and `minimax-m3` is 512,000 against 1,048,576. Patches stay keyed by bare name except where one bare name resolves differently through two gateway providers; those are keyed by full gateway ID.
- `.pi/agent/extensions/bifrost-context-guard.ts` reads `x-bifrost-routing-info-model` and compares the routed model's patched window against what the routing provider declares. Warns once per route on an over-send, and again on each new 90%-of-window high-water mark. `/bifrost-context` prints the current comparison.
- `~/.cache/pi/bifrost-probe-cache.json` probe verdicts, 7-day TTL. Re-runs only probe models new to the catalog.
- `~/.cache/pi/bifrost-models.json` raw gateway catalog, 6-hour TTL, stored pre-patch so patch edits apply without a refetch.

Gotchas:

- Check the gateway before blaming Pi: Bifrost's `/v1/models` is authoritative for existence, not for usability. Verify a model with `curl` against `POST <base>/chat/completions` when something 400s.
- Reasoning models need an explicit `thinkingLevelMap`. Without it Pi sends its default effort, and upstreams that accept only a subset reject the request with `medium reasoning effort is not supported`. Levels the upstream rejects are `null` in the map, and Pi clamps upward, which is why a gap in the middle degrades instead of failing.
- Pi sends the `developer` role for reasoning models when compatibility allows it. Several upstreams behind the gateway reject that role, so every patch sets `supportsDeveloperRole: false` and Pi sends `system` instead.
- Provider-level `compat` is not inherited by extension-defined models, only `api` and `baseUrl` are. Compatibility flags therefore live in the patch file, one entry per model.
- Pi computes context usage, compaction, and cost display from the patch metadata, not from the gateway. A model missing `contextWindow` silently falls back to 128K, which corrupts compaction decisions for long-context models.
- A routing provider's `contextWindow` is an estimate about what the gateway will pick, so it is derived from the tier pools rather than set by hand: minimum over every model the pools can reach. It changes when the pools change, which is why `gen-model-overrides.py` reports drift instead of trusting one value. The `bifrost-auto` routing rules are opencode-zen-scoped, so the copilot and openrouter routes the gateway does without a matching rule are not covered by that declaration — `bifrost-context-guard.ts` is what catches them at runtime.
- Bifrost provider entries are protocol specific. A provider configured for OpenAI chat completions answers `ModelProtocolUnsupported` for the Responses, Anthropic, and Google routes even when the upstream model exists. That is a gateway configuration fix, not a Pi fix.
- A gateway provider can accept a catalog entry and still refuse the route it is configured for. `typesafe/jev-latest` lists under `bifrost` but answers `400 unsupported_operation: chat_completion is not supported by typesafe provider`. Use the `typesafe_evaluate` tool for Jev, not a Pi chat model. Confirm any suspect model with a direct `POST /v1/chat/completions` before assuming Pi is at fault.
- `auto` can fail without Pi being involved. When a routing rule targets a backend whose upstream credential is dead, the router still selects it and the request returns that backend's error, for example `401 github copilot: GitHub rejected the token`. Multi-request testing is the only way to see it, because `auto` succeeds whenever the router picks a live backend. Keep the gateway's routing rules pointed at backends whose credentials are current, or drop the dead backend from the eligible set. `bifrost-context-guard.ts` cannot catch this: it checks window size, not upstream auth.
- Remote upstream keys live in the gateway, not on the host. Re-authenticating a fronted provider (Copilot, OpenRouter) happens in the Bifrost dashboard; `pass` and `auth.json` are not involved.
- Gateway virtual keys are scoped to providers, so one key can expose a subset of the catalog. Model IDs from a narrow key keep that provider prefix.
- Some upstreams reject free-tier models for non-vendor clients with `403 FreeTierError`, and a dead upstream endpoint answers `410`. The probe treats `400`, `403`, `404`, and `422` as permanent refusals and leaves transient statuses visible.
- Re-probing spends one token per model, so do not put `--probe` or `--reprobe` in a loop. Verdicts cache for a week and ordinary re-runs cost nothing.
- Regenerating the shipped baseline requires `--probe`. The script consults the verdict cache only while probing, so a metadata-only run silently drops every `unreachable` flag and re-exposes models the gateway refuses.
- `pi update --models` does not load extension packages at all. Only interactive startup, `/model`, and RPC mode refresh an extension's catalog, and every other path runs cache-only.
- JSON has no comment syntax, so the patch file records provenance under a `//` key. The extension ignores any key starting with `//` and any non-object value.

Sources checked:

- `pi-bifrost` package `index.ts`, `model-overrides.json`, `scripts/gen-model-overrides.py`, `README.md`
- `@earendil-works/pi-coding-agent/docs/models.md`, `models-configuration.md`, `custom-provider.md`, `virtual-models.md`, `packages.md`
- Bifrost docs: `integrations/openai-sdk/overview`, `integrations/anthropic-sdk/overview`, `quickstart/gateway/setting-up`, `api-reference/models`
- `https://models.dev/api.json` opencode catalog entries, including `reasoning_options` and `provider.api`

### Automatic session names

What it does:

- Gives persistent sessions a fallback title from first substantive prompt before first assistant response writes JSONL.
- Generates a short content title after first settled turn, then every four user turns. Configured model lives in `~/.pi/agent/auto-session-name.json` (currently `bifrost-auto/auto`, so the complexity router picks the title model).
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

- Replaces Pi's default spinner and working message with custom modes in TUI sessions.
- Custom frames use active Pi theme's accent color and refresh after theme changes; message timers stop on session shutdown.

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
