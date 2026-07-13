# OpenCode Go usage status runbook

## Context

Add an OpenCode Go subscription-usage status entry to the Pi configuration. It should be visually and behaviorally coherent with the existing GitHub Copilot and OpenAI Codex indicators, with the OpenCode Go compact display specifically following the Codex five-hour-bar plus weekly-percent convention.

Initial findings:

- `agent/extensions/git-branch-dirty-footer.ts` owns the shared extension-status footer row. It currently reformats only the `codex-usage` status into a glyph, ten-cell remaining bar, five-hour percentage, and weekly percentage.
- The existing provider policy is relevant-provider-only: Codex appears for `openai-codex/*`; Copilot appears for `github-copilot/*` and `copilot-api/*`; neither appears for unrelated models.
- `agent/extensions/opencode-go-discovery.ts` already registers and routes OpenCode Go models through `https://opencode.ai/zen/go/v1`, but that inference API has no supported usage/quota endpoint.
- OpenCode Go quota is available in the authenticated workspace dashboard HTML, not a stable public JSON API. Its serialized dashboard state currently supplies rolling (5-hour), weekly, and monthly `usagePercent` and `resetInSec` values.

## Approach

Create a local OpenCode Go usage extension that reads the authenticated workspace dashboard, normalizes its used percentages into remaining-quota windows, and publishes through the existing footer status row. Activate and poll only while an `opencode-go/*` model is selected. Add `/opencode-go-status` for a full current snapshot. Read `OPENCODE_GO_WORKSPACE_ID` and `OPENCODE_GO_AUTH_COOKIE` only from the runtime environment; do not add their values to tracked Pi or Nix configuration. Include explicit source, parsing, authentication, and regression breadcrumbs because this integration depends on a private dashboard representation.

Create one local shared subscription-status utility and use it from the custom footer, the new OpenCode Go extension, and the local Copilot extension. The installed Codex package cannot be refactored directly, so preserve its established raw status contract and have the shared footer adapter render both Codex and OpenCode Go through one formatter. This makes the visible Codex and Go layouts identical and brings Copilot's glyph/bar thresholds under the same utility without forking the npm package.

## Files to modify

Likely:

- `agent/extensions/subscription-usage-status.ts` – new provider-neutral quota types, percentage normalization, shared glyph/bar formatting, compact status parsing/formatting, reset-duration formatting, and safe error helpers.
- `agent/extensions/opencode-go-usage.ts` – new dashboard collector, cache/poll lifecycle, provider gating, `/opencode-go-status`, and status publishing.
- `agent/extensions/git-branch-dirty-footer.ts` – replace the Codex-only formatter with the shared compact-status adapter so Codex and OpenCode Go render identically.
- `agent/extensions/copilot-usage/src/index.ts` – import shared threshold glyph/bar helpers without changing Copilot's dashboard/data-source behavior.
- `agent/PI-GUIDE.md` – operational instructions, environment-variable credentials, command, display policy, and brittle-integration breadcrumb record.

## Reuse

- `agent/extensions/git-branch-dirty-footer.ts`: shared extension-status row, sanitization, and narrow-terminal truncation. Its current Codex parser establishes the raw Codex contract that must remain backward-compatible.
- Existing Codex package behavior documented in `plans/codex-usage-status-toggle.md` and `agent/PI-GUIDE.md`: active-provider-only visibility, raw `codex … <remaining>% 5h <remaining>% wk` status semantics, and rolling five-hour plus weekly compact form.
- `agent/extensions/copilot-usage/src/index.ts`: polling lifecycle, refresh/stop semantics, status clearing, generation guard, and current independent glyph/bar helpers to consolidate into the shared utility.
- `agent/extensions/opencode-go-discovery.ts`: OpenCode Go provider identity and active model namespace.
- `opencode-statusline` OpenCode Go collector: authenticated dashboard request and extraction pattern for `rollingUsage`, `weeklyUsage`, and `monthlyUsage`; treat as an external reference, not a runtime dependency.

## Phase overview

1. Establish contracts and preserve existing status behavior.
2. Extract the shared visual/status-formatting layer.
3. Build the OpenCode Go dashboard collector and normalized snapshot cache.
4. Wire provider-aware lifecycle, compact footer status, and detailed command.
5. Document the brittle integration and execute cross-provider verification.

## Detailed implementation by phase

### Phase 1 – Establish contracts and baselines

Create a dedicated feature branch from the current `~/.dotfiles` repository state before changing configuration or extension code. Record the branch name in the implementation notes and keep all work for this runbook isolated there until review/approval. Then record the exact current Codex raw status grammar and Copilot display behavior before refactoring. Treat Codex as an external producer: its npm package remains untouched. Define a local `SubscriptionUsageSnapshot` with optional five-hour, weekly, and monthly windows, each represented as **remaining percent** plus an optional reset timestamp. Convert OpenCode dashboard `usagePercent` from used to remaining (`100 - used`) at the collector boundary, clamp all values, and keep the original reset seconds only long enough to derive a timestamp. Define the Go extension's raw status text in a documented, parseable grammar compatible with the shared formatter. Use separate status key `opencode-go-usage`.

### Phase 2 – Shared visual/status-formatting layer

Add `agent/extensions/subscription-usage-status.ts` as the sole home for percentage clamping, remaining-quota thresholds, Nerd Font glyph selection, ten-cell bar rendering, compact line construction, reset-duration display, and parsing of raw Codex and Go status values. Adapt the footer to delegate only recognized `codex-usage` and `opencode-go-usage` entries to this utility, leaving all other extension statuses unchanged. Replace Copilot's local glyph/bar implementations with imports from the same utility while retaining Copilot's label and its independent dashboard layout. The visual contract is: full bar means healthy remaining capacity; Go compact status is exactly Codex-shaped except for its `OpenCode Go` label, for example ` OpenCode Go [███████░░░] 71% · wk 93%`.

### Phase 3 – OpenCode Go collector and cache

Implement an isolated fetch/parser module in the Go extension. Validate both required environment variables before any request; call the workspace dashboard with `Accept: text/html`, `Cookie: auth=<runtime-cookie>`, a browser-like user agent, an abortable short timeout, and no credential-bearing error text. Parse the known hydration representation defensively for rolling, weekly, and monthly `usagePercent`/`resetInSec`; validate ranges and reject a response containing no usable window. Maintain a short fresh cache, bounded stale fallback, and one in-flight request shared by polling and `/opencode-go-status`. Never call the inference endpoint or estimate quota from model calls. Preserve monthly data for the detail command even though the compact line follows Codex and shows only 5-hour/weekly values.

### Phase 4 – Lifecycle, UI, and runtime configuration

Mirror Copilot's `session_start`, `model_select`, and `session_shutdown` pattern. Start after a short delay only for `opencode-go`; use recursive completed-request polling, a generation token, and timer disposal so switching providers or shutting down clears `opencode-go-usage` and prevents late writes/rescheduling. Publish a loading state only while Go is active, then publish the normalized compact raw status for the footer. Register `/opencode-go-status` with optional refresh behavior; render plan-independent five-hour, weekly, and monthly usage plus human reset times through Pi's existing UI selection/display convention. Document the two environment variables and expected browser-cookie renewal process, but do not introduce any value-bearing configuration file.

### Phase 5 – Breadcrumbs and verification

Add a durable OpenCode Go section to `PI-GUIDE.md` naming the exact private dashboard URL, required variables, current parser fields, percent conversion, polling/cache policy, command, display policy, known breakage symptoms, and repair procedure. Link the discovery extension's inference endpoint separately to prevent future maintainers from confusing it with usage retrieval. Validate successful, stale, unauthorized, malformed, timeout, and provider-switch paths; then compare Go/Codex/Copilot visual output and confirm no secret appears in status, command output, errors, logs, cache, Git diff, or Nix store.

## Steps

- [ ] Create a dedicated feature branch from the current `~/.dotfiles` repository state before making any implementation changes; record its name in implementation notes and keep the change isolated pending review.
- [ ] Capture a pre-change Codex compact status sample and confirm its raw status grammar; record the existing Copilot lifecycle/data-source baseline.
- [ ] Add `subscription-usage-status.ts` with the normalized remaining-quota types, clamp/convert helpers, shared glyph/bar renderer, reset formatter, and compatible raw Codex/Go parser.
- [ ] Refactor `git-branch-dirty-footer.ts` to use the shared adapter for Codex and OpenCode Go while preserving all unrelated status entries and width behavior.
- [ ] Refactor local Copilot glyph/bar helpers to use the new shared utility, without changing its API, polling cadence, dashboard commands, or raw quota semantics.
- [ ] Implement `opencode-go-usage.ts` with environment validation, abortable authenticated dashboard fetch, defensive hydration parsing, used-to-remaining conversion, and credential-safe errors.
- [ ] Add a short fresh cache, bounded stale fallback, single-flight request sharing, and explicit forced refresh path used by `/opencode-go-status`.
- [ ] Implement Go-only delayed recursive polling and generation-based stop/clear behavior for session start, model selection, and shutdown.
- [ ] Register `/opencode-go-status` and render five-hour, weekly, and monthly percentage/reset detail from the same snapshot source; do not show or persist the auth cookie.
- [ ] Document `OPENCODE_GO_WORKSPACE_ID` and `OPENCODE_GO_AUTH_COOKIE` as runtime environment inputs, including cookie renewal, without committing values or placing them in the Nix store.
- [ ] Add the maintained brittle-integration breadcrumb section identifying the undocumented endpoint, auth-cookie dependency, serialized-state parser signature, percent conversion, failure display, source links, and update procedure.
- [ ] Run manual lifecycle, visual-width, failure, command, and secret-leak verification across OpenCode Go, Codex, Copilot, and unrelated providers.

## Verification

- With `OPENCODE_GO_WORKSPACE_ID` and `OPENCODE_GO_AUTH_COOKIE` supplied only at runtime, select an `opencode-go/*` model and confirm a Codex-shaped OpenCode Go footer entry from current dashboard data.
- Confirm 5-hour, weekly, and monthly used percentages are converted to the correct remaining capacity; compact footer shows 5-hour/weekly while `/opencode-go-status` shows all three windows and resets.
- Snapshot-test or directly test the shared formatter with Codex raw input, Go raw input, percentages at 0/10/25/26/100, malformed input, and narrow widths; confirm output labels differ but glyph/bar/percentage layout is identical for Codex and Go.
- Confirm Copilot imports the shared glyph/bar logic and retains its existing quota interpretation, command dashboards, and 60-second active-provider-only polling behavior.
- Switch repeatedly among OpenCode Go, Codex, Copilot, and an unrelated provider; verify exactly the matching indicator is visible, background polling stops for inactive providers, and late responses cannot restore stale text.
- Exercise missing/expired cookie, workspace unauthorized, network timeout, changed HTML, and malformed data cases; footer remains responsive, follows the agreed clear/unavailable state, and secrets never appear.
- Run `/opencode-go-status` normally and with forced refresh; verify it shares cache correctly and never surfaces credential-bearing request details.
- Review tracked changes and secret scans before committing the feature branch; merge into the main branch only after user approval.

## Brittle integration breadcrumbs

This is intentionally a first-class maintenance section, to be expanded during implementation:

- **Data contract:** OpenCode Go does not publish a supported quota API. The collector reads `GET https://opencode.ai/workspace/<workspace-id>/go` and requires the authenticated dashboard session.
- **Authentication:** browser `auth` cookie plus workspace ID. Cookie rotation/expiry and multi-workspace selection can break collection.
- **Parser contract:** dashboard hydration currently exposes `rollingUsage`, `weeklyUsage`, and `monthlyUsage` objects containing `usagePercent` and `resetInSec`. The exact serialization is undocumented and can change independently of OpenCode Go inference endpoints.
- **API distinction:** `https://opencode.ai/zen/go/v1` is the model-inference endpoint already used by discovery. It must not be treated as a quota API; it has no supported account-usage route.
- **Response behavior:** failure must be contained to this widget. Never infer quota by issuing model calls, and never log cookie/header contents.
- **Reference sources:** OpenCode Go docs; OpenCode console Go route/source; `kalcohol/opencode-statusline` provider collector and query-method documentation. Record checked versions/dates when implementation begins.
