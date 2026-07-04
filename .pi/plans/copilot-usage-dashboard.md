# Copilot usage dashboard implementation plan

## Context

The `copilot-usage` extension is a local Pi extension under `agent/extensions/copilot-usage/`. It currently exposes several commands (`/copilot`, `/copilot-quota`, `/copilot-models`, `/copilot-sessions`), a `copilot_usage` tool, and a footer status string like `Copilot: XXX/YYYY premium units left`.

The desired direction is to make this feel like one coherent Pi-native dashboard:

- A compact footer status using threshold glyphs and a remaining-quota bar.
- A single canonical `/copilot` command that presents quota, included buckets, model billing/cost metadata, and compact session context without top repository/directory noise.
- Documentation that keeps the Pi config logical and maintainable by making `/copilot` the obvious user-facing entry point while preserving lower-level code organization.

## Approach

Refactor the extension around shared visual formatting helpers, then route both the footer and `/copilot` command through those helpers. Keep the existing data-fetching architecture intact: lightweight `gh api /copilot_internal/user` polling for footer quota, full `fetchAllCached()` for the command dashboard, and the Copilot SDK child process for sessions/model metadata.

For maintainability in the broader Pi config, keep all Copilot-specific behavior contained in `agent/extensions/copilot-usage/src/index.ts`, update only the extension README and the central `agent/PI-GUIDE.md`, and avoid adding new global config files or separate visual utility modules unless the file becomes unwieldy later.

## Files to modify

- `agent/extensions/copilot-usage/src/index.ts`
- `agent/extensions/copilot-usage/README.md`
- `agent/PI-GUIDE.md`

## Reuse

Existing code to preserve and build on:

- `fetchCopilotUserInfo()` in `agent/extensions/copilot-usage/src/index.ts` for lightweight quota polling.
- `fetchCopilotSdkSnapshot()` in `agent/extensions/copilot-usage/src/index.ts` for SDK session/model metadata via a short-lived child process.
- `fetchAllCached()` in `agent/extensions/copilot-usage/src/index.ts` for shared 30-second command cache.
- `computeStats()` in `agent/extensions/copilot-usage/src/index.ts` for normalized quota/session/model statistics.
- `quotaValue()` and `modelCostLabel()` in `agent/extensions/copilot-usage/src/index.ts` as starting points for quota decimal handling and GitHub billing metadata labels.
- Existing Pi UI pattern `ctx.ui.setStatus()` for footer status and `ctx.ui.select()` for command output.

## Big-picture fit in the Pi config

This should remain a self-contained global Pi extension, not a general Pi UI framework change. The config stays easy to reason about if:

- `/copilot` becomes the canonical human-facing command for Copilot usage.
- The LLM-facing `copilot_usage` tool remains structured JSON for agent reasoning rather than copying the visual dashboard.
- Legacy focused commands are either kept as compatibility commands or clearly documented as secondary/legacy, not advertised as the main interface.
- The central `PI-GUIDE.md` describes the extension in terms of purpose, dependencies, gotchas, and the single dashboard command.
- The extension README gives the deeper local-maintenance details.

## Implementation phases

### Phase 1 – Shared visual primitives

- [ ] Add constants for glyphs:
  - loading/fetching: ``
  - healthy/connected: ``
  - warning: ``
  - critical/error: ``
- [ ] Add a threshold helper based on percent remaining:
  - healthy: `> 25%`
  - warning: `> 10%` and `<= 25%`
  - critical: `<= 10%`
- [ ] Replace or supplement the current `progressBar(percent)` with a remaining-oriented bar helper for the footer and dashboard.
- [ ] Keep any old used-oriented progress behavior only if needed internally, but make the new user-facing meaning consistent: full bar means more quota left.

### Phase 2 – Footer status refactor

- [ ] Replace `statusLabel(stats)` output with threshold glyph format, for example ` Copilot [████████░░] 55%`.
- [ ] Update `refreshQuotaStatus()` to use the same formatter instead of duplicating footer string construction.
- [ ] Update loading/fetching status strings to use ``.
- [ ] Update error status strings to use ``.
- [ ] Decide how non-quota fallbacks should look, likely compact forms such as ` Copilot 12 sessions` only when quota data is unavailable.

### Phase 3 – Canonical `/copilot` dashboard

- [ ] Replace `overviewLines(stats)` with a dashboard-oriented renderer that includes:
  - Quota hero with threshold glyph, remaining bar, percent remaining, plan, billing mode, units left/total, used, reset date, and overage status.
  - Included buckets such as chat and completions.
  - Model billing/cost section using available SDK metadata: multiplier when present, `token-priced` plus token price details when present, and `included`/`0×` where appropriate.
  - Compact session summary: total, today, this week, this month, active now, average duration.
  - Recent sessions, limited to a small number, with compact status glyphs and short summaries.
- [ ] Remove top repositories and top directories from the `/copilot` dashboard output.
- [ ] Favor visual tables and bars over long prose so the command does not become a wall of text.

### Phase 4 – Secondary command strategy

- [ ] Keep `/copilot` as the primary command and update its description accordingly.
- [ ] Preserve `/copilot-quota`, `/copilot-models`, and `/copilot-sessions` initially for compatibility unless we explicitly choose to remove them later.
- [ ] For maintainability, either:
  - make `/copilot-quota` and `/copilot-models` thin wrappers around shared dashboard/model section helpers, or
  - mark them as secondary focused views while keeping docs centered on `/copilot`.
- [ ] Keep `/copilot-sessions` if interactive session detail browsing is still useful; it is different enough from the dashboard to remain a focused utility.

### Phase 5 – Tool and docs alignment

- [ ] Keep the `copilot_usage` tool structured and machine-readable.
- [ ] Consider updating the tool description if it still emphasizes top repositories more than quota/model billing.
- [ ] Update `agent/extensions/copilot-usage/README.md`:
  - New footer format and glyph meanings.
  - `/copilot` as the main all-in-one dashboard.
  - Model billing section notes, including token-priced fallback.
  - Legacy/secondary command status.
- [ ] Update `agent/PI-GUIDE.md`:
  - Replace old footer example.
  - Update command list and gotchas.
  - Remove or de-emphasize top repositories/directories.

### Phase 6 – Verification

- [ ] Search for stale strings with `rg "Copilot:|premium units left|Top repositories|Top directories" agent/extensions/copilot-usage agent/PI-GUIDE.md`.
- [ ] Run a TypeScript syntax/type check if practical from the extension package without installing dependencies.
- [ ] Reload Pi with `/reload`.
- [ ] Manually check footer states after startup and after invoking `/copilot`.
- [ ] Run `/copilot` and confirm the dashboard shows quota, models, compact sessions, and recent sessions without top repo/directory sections.
- [ ] Optionally run legacy commands once to confirm they still work if preserved.

## Risks and notes

- GitHub's internal `/copilot_internal/user` endpoint may change, so visual helpers should tolerate missing quota fields.
- GitHub model billing metadata may use either old multipliers or token prices. The display should not assume multipliers always exist.
- Nerd Font glyphs are intentional here, but they depend on the terminal font. The existing Pi config already uses glyph-heavy UI, so this fits the current aesthetic.
- The extension currently uses `ctx.ui.select()` to display static line arrays. This plan stays within that pattern rather than introducing custom TUI components, keeping the change smaller and easier to maintain.
