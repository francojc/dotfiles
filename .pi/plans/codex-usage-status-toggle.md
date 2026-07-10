# Codex usage status and provider-aware footer plan

## Context

Add an OpenAI Codex subscription-usage extension to this global Pi configuration, using the existing `openai-codex` OAuth login. The result should show the ChatGPT/Codex plan and rolling rate-limit windows on demand and expose a compact footer status in the same extension-status row already used by the local GitHub Copilot dashboard.

The user also wants provider-aware visibility: determine and implement when Copilot and Codex quota indicators should appear as models change. Work will be isolated on a dedicated Git branch before merging to `main`.

### Initial findings

- Working tree is clean on `main`; this repository already has `agent/extensions/copilot-usage/` and `agent/extensions/git-branch-dirty-footer.ts`.
- The current default provider/model is `openai-codex/gpt-5.6-terra`; Pi auth has an `openai-codex` credential configured.
- The custom footer renders all `ctx.ui.setStatus()` entries in a dedicated final line, so another extension can appear beside Copilot without replacing the footer.
- Copilot currently starts polling and displays status for every Pi session, regardless of selected model.
- Recommended third-party package: `npm:@narumitw/pi-codex-usage` (MIT, Pi 0.80-compatible). It provides `/codex-status`, plan/rate-limit/credit reporting, calls Pi OAuth before a Codex CLI fallback, and writes its compact value through `ctx.ui.setStatus()`.
- Unmodified, that package automatically displays only when the selected provider is `openai-codex`; it clears on another provider/model. Its `/codex-status` command can show a temporary status on demand.

## Approach

Create a feature branch, install the maintained Codex usage package as a global Pi package, and verify its direct OAuth path and footer integration. Use **relevant-provider-only** visibility: Codex for `openai-codex/*`, Copilot for both `github-copilot/*` and `copilot-api/*`, and clear the inactive provider status. The upstream Codex package already has the required `openai-codex` lifecycle, so do not fork it. Adapt only the local Copilot extension to start/stop its quota polling on model changes, with a generation/active-state guard so an in-flight prior poll cannot restore a cleared status. Do not replace the existing custom footer.

## Files to modify

Likely:

- `agent/settings.json` — global package registration produced by `pi install npm:@narumitw/pi-codex-usage@0.12.0`.
- `agent/extensions/copilot-usage/src/index.ts` — provider-aware Copilot status lifecycle and polling-race guard.
- `agent/PI-GUIDE.md` — document the Codex command, status meaning, auth/current-data caveats, and provider-visibility policy.

## Reuse

- `agent/extensions/git-branch-dirty-footer.ts`: consumes extension statuses and already makes a separate footer row.
- `agent/extensions/copilot-usage/src/index.ts`: `startPolling`, `stopPolling`, `refreshQuotaStatus`, and `session_start` lifecycle are the existing Copilot polling implementation.
- Upstream `@narumitw/pi-codex-usage`: `/codex-status`, `ctx.ui.setStatus`, 5-minute cache, `session_start`, `model_select`, and `session_shutdown` lifecycle.

## Provider-status policy

**Selected policy — relevant provider only**

- `openai-codex/*`: show the upstream Codex status (`/codex-status` remains available); stop and clear Copilot status.
- `github-copilot/*` and `copilot-api/*`: show Copilot quota; the upstream Codex extension clears its own status.
- Any other provider: show neither subscription indicator.

This prevents unnecessary account polling, avoids presenting a stale inactive quota as live, and keeps the existing extension-status footer row compact.

## Steps

- [x] Confirm the provider-status policy: relevant provider only; include both `github-copilot/*` and `copilot-api/*` as Copilot-relevant.
- [x] Create a dedicated branch from up-to-date `main`: `feat/codex-usage-status`.
- [x] Install the reviewed current release, `npm:@narumitw/pi-codex-usage@0.12.0`, as a global Pi package; this updates `agent/settings.json` with a reproducible pin. Avoid copying credentials or logging tokens.
- [x] Reload Pi and validate `/codex-status --refresh` returns plan, 5-hour/weekly reset windows, and any available credits/model buckets.
- [x] Verify the package's status entry appears in the existing custom footer when an `openai-codex/*` model is selected, then clears on a non-Codex model.
- [x] In `copilot-usage`, add a provider predicate for `github-copilot` and `copilot-api`, then centralize status synchronization for session start and `model_select`.
- [x] Start the existing Copilot polling only for a relevant model; on every other model switch, cancel its timer, invalidate its cache, and call `ctx.ui.setStatus("copilot-usage", undefined)`.
- [x] Guard polling with a monotonically increasing generation or equivalent active-state token, so a completed request begun before a model switch cannot write status or schedule another poll afterward.
- [x] On session shutdown, stop polling and clear the Copilot status. Never modify or replace the custom footer renderer.
- [x] Update `agent/PI-GUIDE.md` with installation source, commands, current-data caveat, auth behavior, and status visibility rules.
- [x] Review changed files and commit the feature branch only after verification; merge into `main` only after user approval.

## Verification

- Run `pi --version` and confirm package discovery after reload.
- Run `/codex-status --refresh` using `openai-codex/gpt-5.6-terra`; confirm no OAuth token is shown in output/errors.
- Switch among `openai-codex`, `github-copilot`, `copilot-api` (if available), and another provider; verify exactly one matching subscription entry appears, then neither appears for the unrelated provider.
- Confirm only the matching polling loop is active after repeated model switches, session reloads, and session shutdown; specifically verify a late Copilot request cannot repopulate its status after switching to Codex.
- Confirm the Git/context/model footer remains intact and status strings are legible at normal and narrow terminal widths.
- Run the existing Copilot dashboard commands (`/copilot`, `/copilot-quota`) to ensure their command behavior still works.
