# Pi Guide

Living guide for Jerid's Pi setup. Maintained by `/skill:pi-guide-maintainer`.

## Maintenance

- Canonical file: `~/.pi/agent/PI-GUIDE.md`
- Dotfiles file: `/Users/francojc/.dotfiles/.pi/agent/PI-GUIDE.md`
- Last updated: 2026-06-29
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
| `/skill:pi-guide-maintainer` | Update or extend this guide. |

## Installed packages

Configured in `~/.pi/agent/settings.json` and installed under `~/.pi/agent/npm/`.

| Package | Version/config | What it adds |
| --- | --- | --- |
| `pi-caveman` | `1.0.7` | Terse output modes and status indicator. |
| `pi-btw` | `0.4.1` | Parallel side conversations in overlay, with handoff back to main session. |
| `@plannotator/pi-extension` | npm range in package: `^0.21.3` | Plan mode, browser-based plan review/annotation, restricted planning phase. |
| `@ogulcancelik/pi-ghostty-theme-sync` | `0.1.2` | Sync Pi theme from active Ghostty palette. |

## Local extensions

Loaded from `~/.pi/agent/extensions/`.

| Extension | What it does | User-facing controls |
| --- | --- | --- |
| `git-branch-dirty-footer.ts` | Custom footer with cwd, git branch/dirty counts, token usage, context usage, model, and extension statuses. | Automatic. |
| `working-indicator.ts` | Custom animated working indicator and rotating status words. | `/indicator [schwa|eye|pulse|bounce|spinner|none|default]` |
| `vim-editor.ts` | Vim-like normal/insert mode for Pi input editor. | `Esc`, `i`, `a`, `h/j/k/l`, `w`, `b`, `d`, `c`, `p`, `u` in normal mode. |
| `opencode-go-discovery.ts` | Registers dynamic `opencode-go` provider models from OpenCode/model metadata. | Requires `OPENCODE_API_KEY` for actual use. |
| `openrouter-models.ts` | Registers dynamic OpenRouter models from API/cache. | Requires `OPENROUTER_API_KEY`. |
| `searxng.ts` | Adds `web_search` tool via self-hosted SearXNG. | Agent tool. `SEARXNG_URL` optional. |
| `questionnaire.ts` | Adds interactive questionnaire tool for clarifying choices. | Agent tool. |
| `todo.ts` | Adds persistent todo tool and `/todos` viewer for current branch. | `/todos`, agent `todo` tool. |
| `supacode/index.ts` | Emits Supacode OSC lifecycle/notification signals when running inside Supacode. | Automatic inside Supacode surfaces. |
| `pi-guide-autoupdate.ts` | Detects package/local-extension changes and runs guide maintenance in background on interactive startup. | Automatic. Footer status only. |
| `tui-utils.ts` | Shared helper module for local TUI extensions. | No direct user controls. |

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

- Kitty and Ghostty configs map `Cmd+Shift+↑` / `Cmd+Shift+↓` to literal PageUp/PageDown escape sequences for Pi page scroll consistency.
- Pi also binds `super+shift+up` / `super+shift+down` directly for page scroll when terminal protocols pass those keys through.
- Ghostty has `macos-option-as-alt = right`, so right Option behaves as Alt. Some left Option chords may still work depending on macOS/layout handling.
- Current `/btw` focus fallback works as `Ctrl+LeftOption+W` on this keyboard.
- Current `/btw` scroll works with `↑` and `↓`, plus mouse/trackpad wheel.

## Extension notes

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
- Package uses `node-pty`; install scripts are approved in `~/.pi/agent/npm/package.json` via `allowScripts`.

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

### Working indicator

What it does:

- Replaces Pi's default spinner and working message with custom modes.

Commands:

- `/indicator` shows current indicator.
- `/indicator schwa` uses breathing schwa default.
- `/indicator eye`, `pulse`, `bounce`, `spinner`, `none`, `default` switch modes.

Source checked:

- `~/.pi/agent/extensions/working-indicator.ts`

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
- Default model: `github-copilot/claude-haiku-4.5` with thinking off.
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
