# Pi Feature Backlog

Register of Pi changelog features worth exploring, with relevance notes and a status per item. Use it to park interesting updates instead of trying them the moment they land.

## Purpose and usage

- Canonical file: `~/.pi/agent/PI-FEATURE-BACKLOG.md`
- Dotfiles file: `~/.dotfiles/.pi/agent/PI-FEATURE-BACKLOG.md`
- Source of truth for changes: `~/.npm-global/lib/node_modules/@earendil-works/pi-coding-agent/CHANGELOG.md` (path depends on the install method).
- Companion docs: `~/.pi/agent/PI-GUIDE.md` covers adopted behavior, this file covers candidates and experiments.
- Add a new section per release, newest first, when a changelog is reviewed.
- Move an item to `adopted` only after it is configured and verified; then reflect durable behavior in `PI-GUIDE.md`.
- Keep entries short: what it does, why it may matter here, next action, status.
- Do not paste whole changelog text; summarize with a pointer to the release version.

## Status legend

| Status | Meaning |
| --- | --- |
| `new` | Not reviewed in practice yet. |
| `exploring` | Tested once or partially configured. |
| `adopted` | In use; behavior documented in `PI-GUIDE.md` if durable. |
| `skipped` | Reviewed and rejected; keep the reason. |

## Baseline

- Pi version at last review: 0.99.2.
- Local context: many local extensions under `~/.pi/agent/extensions/`, packages installed via `~/.pi/agent/npm/`, TypeSafe, Ketch, worktree and coordinator workflows, course repos (Quarto, R, Spanish pedagogy).

## 1.0.0 (2026-10-01)

| Item | What it does | Why it may matter here | Status | Next action |
| --- | --- | --- | --- | --- |
| Fullscreen TUI default | Starts Pi in fullscreen mode; `tuiMode: "regular"` restores normal scrollback. | Current terminal workflow may rely on regular scrollback; this is a behavior-changing default. | `new` | Test fullscreen and set explicit mode if needed. |
| Leaner codemode | Cuts prompt tokens by about 40% and improves recovery guidance in script errors. | We use codemode heavily; lower overhead and clearer failures matter. | `new` | Compare prompt size and error recovery in a real script. |
| Image generation in codemode | Scripts can call `models.generateImages()` using session credentials. | Useful for course materials and vocabulary assets; cost is tracked in session. | `new` | Prototype one course asset. |
| Radius login and MCP setup | `/login` supports Radius login and can configure its MCP server. | Potentially useful if Radius becomes part of the provider/MCP workflow. | `new` | Try only if using Radius. |
| Anthropic copy-code login | Supports headless login when browser runs on another machine. | Useful for remote or SSH-based environments. | `new` | Use if browser callback is unavailable. |
| MCP OAuth hardening | Supports explicit auth-server metadata, issuer checks, per-server credentials, and scope-preserving step-up auth. | Relevant to existing MCP setup; improves correctness and account isolation. | `new` | Review current MCP auth and test multi-server credentials. |
| Header-only quiet startup | `quietStartup: "header"` keeps version and key hints while hiding other startup details. | Could reduce startup noise without hiding useful orientation. | `adopted` | Try if startup output feels excessive. |

## 0.99.2 (2026-09-30)

| Item | What it does | Why it may matter here | Status | Next action |
| --- | --- | --- | --- | --- |
| MCP background connection | Servers with default `codemode` exposure no longer block the first prompt and are listed in a short `mcp_servers` system prompt section. | Removes the main reason to avoid MCP servers with slow startup. Makes casual MCP use viable. | `new` | Add one small server, confirm startup is unaffected. |
| `searchTools()` and `describeNamespace()` | Codemode helpers to find tools and read server instructions or namespaces. | Needed to actually use codemode-exposed MCP tools without declaring them all. | `new` | Test in a scratch session with one server. |
| MCP `description` field | One-line server description, used in the system prompt and to rank tool search. | Cheap improvement to tool discovery accuracy. | `new` | Add descriptions when adding servers. |
| MCP `oauth.clientName` | Sends a different client name during OAuth registration for servers that only accept known clients. | Unblocks servers like Figma that reject unknown clients. | `new` | Only if a needed server rejects registration. |
| MCP `"auth": { "provider": "..." }` | Uses a provider's `/login` token as the bearer token for an HTTP MCP server. | Could reuse existing provider auth for internal or vendor MCP endpoints. Global config only, requires https outside loopback. | `new` | Check whether any planned server overlaps a logged-in provider. |
| Anthropic workload identity federation | Auth via `ANTHROPIC_FEDERATION_RULE_ID`, `ANTHROPIC_ORGANIZATION_ID`, `ANTHROPIC_IDENTITY_TOKEN_FILE`. | Relevant only for institutional or CI setups with federation. | `skipped` | No current federation provider. |
| `/reload` picks up new `defaultTools` | Newly added tools from the setting are enabled on reload. | Removes restarts when enabling built-in extensions like `codemode` or `tool_search`. | `new` | Verify with one tool add and `/reload`. |
| Prompt and model lookup speed fixes | Prompt submission no longer slows with session length; remote catalog merge no longer quadratic. | Direct benefit given the number of dynamic provider extensions and long sessions. | `new` | Nothing to configure; confirm the perceived speedup. |
| Collapsed tool result preview limit | Long single-line output, such as minified JSON, no longer fills the screen. | Quality-of-life for MCP and codemode results. | `new` | Nothing to configure. |

## 0.99.1 (2026-09-29)

| Item | What it does | Why it may matter here | Status | Next action |
| --- | --- | --- | --- | --- |
| GPT-6.1 Sol | New model on OpenAI, Azure OpenAI, and OpenAI Codex; now the default Codex model. | Current default model is `gpt-6-luna` on `openai-codex`. Worth a comparison for coding and long-context work. | `new` | Compare against Luna on a real task before switching. |

## 0.99.0 (2026-09-29)

| Item | What it does | Why it may matter here | Status | Next action |
| --- | --- | --- | --- | --- |
| Codemode and MCP | Built-in extensions for MCP servers plus JavaScript scripts that call Pi tools, including in parallel. | Biggest feature of the release. Enables external tools, batched calls, and filtering large output before it reaches the model. | `new` | Start with `"defaultTools": ["+codemode"]` and no MCP server. |
| `codemode` as a plain orchestration tool | Scripts can run several tools in parallel, trim output, and store values across calls with `store()` and `load()`. | Useful for repo-wide searches, multi-file edits, and course data builds without flooding context. | `new` | Write one script that batches reads and returns a summary. |
| Classifier models from codemode | `models.classify()` runs Jev or another classifier with session credentials. | Pairs with the existing `pi-typesafe` setup; lets scripts make small semantic decisions without a full model turn. | `exploring` | Confirm the existing TypeSafe consent and caps cover script use. |
| `tool_search` | Finds and declares tools that are not yet exposed to the model. | Complements codemode for servers that should be called directly after discovery. | `new` | Enable alongside codemode and test with one deferred server. |
| Virtual models | Extensions register a selectable model that routes each request to a physical model and thinking level. | Overlaps with the local `pi-model-router.ts` extension. Candidate for consolidation or replacement. | `exploring` | Read `docs/virtual-models.md` and compare with the current router logic. |
| `pi.registerVirtualModel()` plus footer routing display | Shows the routed model in the footer and cost per physical model in `/session`. | Improves visibility into what the router actually does. | `new` | Evaluate once routing behavior is understood. |
| Sign in with ChatGPT | OpenAI provider can use a ChatGPT subscription via `/login openai`. | Logged in using the new system. | `adopted` | None. |
| System theme | Colors derive from terminal palette and follow light or dark switches. | Replaces Ghostty theme sync; enabled as `"theme": "system"`, and sync package plus generated theme removed. Verified working. | `adopted` | None. |
| Tool exposure API for extensions | `exposure`, `namespace`, `annotations`, `outputSchema` with `structuredContent`, `prepareLoadout()`, `ctx.executeTool()`. | Relevant for the local extension collection and for any custom course tooling. | `new` | Note which local extensions could adopt `exposure` or structured output. |
| Nested tool calls and `parentToolCallId` | Extension-initiated tool calls are recorded on the calling result as bounded `nestedCalls`. | Helps debugging and cost accounting for router and orchestrator extensions. | `new` | Inspect one existing extension that calls tools indirectly. |
| `defaultTools` with `+name` and `-name` | Adds or removes tools without repeating the full default list. | Simplifies enabling `codemode` or `tool_search` in settings. | `new` | Adopt the form when enabling codemode. |
| Built-in section in `pi config` | Built-in extensions can be disabled globally or per project as `-builtin:<name>`. | Useful to trim unused built-ins such as llama.cpp. | `new` | Review built-in list and disable unused entries. |
| `builtin:<name>` naming and `-e builtin:<name>` | `--no-extensions` now also disables built-ins; load one explicitly. | Matters for reproducible runs and troubleshooting. | `new` | Note in `PI-GUIDE.md` if used in scripts. |
| Codemode structured bash results | `bash` resolves to `{ output, truncated, full_output_path, exit_code, wall_time_seconds }` with up to 1 MiB output. | Better handling of large command output inside scripts. | `new` | Use when a script must inspect full output. |
| `provider_stream_event` extension event | Observe parsed provider events before normalization, with a `/debug-provider` example viewer. | Useful for the dynamic provider discovery extensions. | `new` | Consider when debugging provider quirks. |
| Image generation in `ModelRuntime` | `generateImages()` with runtime-resolved auth and model-type accessors. | Possible use for course materials and vocabulary assets. | `new` | Prototype one image for a course asset. |
| HTML export show/hide toggle | `H` reveals custom messages marked `display: false`. | Minor, but useful when reviewing exported sessions. | `new` | None until needed. |
| `fullscreenWheelScrollLines` setting | Controls fullscreen mouse-wheel scrolling, `"auto"` accelerates fast spins. | Terminal comfort preference. | `new` | Set only if scrolling feels off. |
| Tool call argument display | Tools without a custom renderer show `key=value` arguments; MCP calls are titled `server/tool`. | Improves readability of MCP and custom tool calls. | `new` | Nothing to configure. |
| Session file created on first user message | Prevents losing a new session when Pi exits before the first response. | Reliability fix for short or interrupted sessions. | `new` | Nothing to configure. |

## 0.87.1 (2026-09-22)

| Item | What it does | Why it may matter here | Status | Next action |
| --- | --- | --- | --- | --- |
| Claude Opus 5.5, GPT-6 Sol, GPT-6 Luna | Adds frontier models across supported providers, including GitHub Copilot; xAI defaults to Grok 4.7. | Model availability may affect quality and cost comparisons across configured providers. | `new` | Check provider availability and compare only against current models. |

## Earlier releases still worth revisiting

Reviewed from the same changelog file, listed here because they remain unexplored rather than because they are new.

| Item | Release | Why it may matter here | Status | Next action |
| --- | --- | --- | --- | --- |
| Prompt cache warming | 0.86.0 | Keeps provider caches alive during long tool runs and idle periods with cost-aware refreshes. Relevant for long sessions. | `new` | Read `docs/settings.md#cache-warming`, try one mode. |
| `/bug` reporting | 0.86.0 | Bundles redacted diagnostics, optional transcript, or a zip export. Useful for extension issues. | `new` | Check what a report contains before uploading. |
| Per-model compaction budgets | 0.86.0 | `compaction.modelOverrides` with `reserveTokens` and `keepRecentTokens`. | `new` | Tune only if compaction misbehaves on a specific model. |
| Transcript-aware prompt and tool updates | 0.86.0 | `before_agent_start` changes survive resume and branch navigation. | `new` | Relevant when editing extensions that change prompts. |
| Canonical session context and extension boundaries | 0.87.0 | Append-only context edits, `turn_end`, `agent_before_settle`, `context_with_system`. | `new` | Relevant for advanced extension work. |
| Per-model image input limits | 0.87.0 | Cache-safe image resizing per model for attachments, reads, and tool results. | `new` | Consider if image-heavy course work grows. |

## Candidate experiments shortlist

Pick from here when there is time for hands-on work.

1. Enable `codemode` without MCP and write one script that batches tool calls and filters output.
2. Add one small MCP server, confirm background connection behavior, and try `searchTools()` and `describeNamespace()`.
3. Compare virtual models against the local `pi-model-router.ts` extension and decide on one approach.
4. Try prompt cache warming on a long working session and check `/session` cost effects.

## Future changelog template

Copy this block when reviewing a new release.

```markdown
## X.Y.Z (YYYY-MM-DD)

Reviewed: YYYY-MM-DD.

| Item | What it does | Why it may matter here | Status | Next action |
| --- | --- | --- | --- | --- |
|  |  |  | `new` |  |

Notes:
```

## Maintenance

- Review the changelog after `pi update` and add a section for each new release, newest first.
- Keep the baseline version current.
- Promote adopted items into `PI-GUIDE.md` and mark them `adopted` here.
- Delete nothing; mark items `skipped` with a one-line reason instead.
- Do not record secrets, tokens, or private endpoint URLs in this file.
