# Google Workspace extension plan

## Context

Add Google Workspace support (Drive, Docs, Sheets, Slides) as a hand-rolled local extension, adapted from `Geun-Oh/pi-google-workspace` (MIT, v1.0.1). Upstream ships one ~1350-line `index.ts` with OAuth setup commands (`/gws-setup`, `/gws-logout`) and 15 tools. Goal: vendor it into this repo's extension conventions so it is maintainable here and fits existing secret-handling patterns, rather than installing the npm package.

### Upstream findings

- Source: https://github.com/Geun-Oh/pi-google-workspace - files: `index.ts`, `google-workspace.md` (skill doc), `package.json`.
- Imports `@mariozechner/pi-coding-agent` and `@sinclair/typebox`; this repo's extensions import `@earendil-works/pi-coding-agent` and use `Type` from typebox already available via pi.
- Stores `clientId`, `clientSecret`, and tokens together in `~/.pi/agent/google-workspace/oauth.json` (mode 0600).
- OAuth flow: local HTTP callback server on `http://127.0.0.1:53682/oauth2callback`, state validation, browser open, manual-code fallback. Scopes: `drive`, `documents`, `presentations`, `spreadsheets`.
- Token refresh handled centrally in `googleRequest()` with 401 retry; refresh persists back to `oauth.json`.
- Includes a hand-rolled Docs JSON -> Markdown converter (headings, lists w/ nesting, tables, inline bold/italic/strike/links) used by `google_docs_download` format `md`.

### Repo conventions observed

- Extensions are flat `.ts` files or single directories under `agent/extensions/`, tab-indented, no build step; pi loads them directly.
- Secrets fetched from `pass` at runtime (`pass show ...`) with env-var override, e.g. `opencode-go-usage.ts` `readPassSecret()`.
- User docs live in `agent/PI-GUIDE.md`; per-feature notes in `plans/`.
- Dotfiles repo must never contain OAuth tokens or client secrets.

## Approach

Vendor upstream `index.ts` into `agent/extensions/google-workspace/index.ts`, then adapt:

1. Import path: `@mariozechner/pi-coding-agent` -> `@earendil-works/pi-coding-agent`. Verify `registerTool` / `registerCommand` / `ctx.ui` signatures match current pi API (0.84.x) before porting wholesale.
2. Formatting: convert to tab indentation to match sibling extensions.
3. Secrets split:
   - `clientId` + `clientSecret`: read from `pass` entries (`GWS/GOOGLE_CLIENT_ID`, `GWS/GOOGLE_CLIENT_SECRET`) with `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` env fallbacks. No client secret written to disk by `/gws-setup`.
   - Tokens only in `~/.pi/agent/google-workspace/oauth.json` (0600, already outside the dotfiles tree). Confirm `.gitignore` covers nothing needed since path is outside repo.
4. `/gws-setup` flow adjusted: pull credentials from pass/env first; prompt only if missing. Keep callback-server flow unchanged (it is solid: state check, timeout, manual-code fallback).
5. Keep all 15 tools and tool names identical to upstream so the upstream skill doc stays accurate. Copy `google-workspace.md` into the extension dir or fold its content into PI-GUIDE.md.
6. Possible trims (flag, decide during implementation):
   - Slides tools if unused - keep unless Jerid says drop; low cost.
   - `session_start` status line conflicts with existing footer extensions - use sparingly or skip.

## Files

- New: `agent/extensions/google-workspace/index.ts` (vendored + adapted)
- New or folded: `google-workspace.md` skill doc
- Edit: `agent/PI-GUIDE.md` - document `/gws-setup`, `/gws-logout`, tools, token location, pass entries
- Edit: `~/.pi/agent/settings.json` only if pi requires explicit registration (flat-dir extensions under `extensions/` auto-load; verify)

## Prerequisites (user side)

- Google Cloud project with Drive/Docs/Sheets/Slides APIs enabled
- OAuth Desktop client created; ID + secret stored in `pass`
- First consent grants `refresh_token` (prompt=consent forces it)

## Risks / tradeoffs

- Vendored copy means we own maintenance; upstream is small and stable, acceptable tradeoff for secret handling we trust.
- **Caught during implementation:** `~/.pi` is a symlink into this repo, so upstream's token path would place `oauth.json` inside the git tree. Added `.pi/agent/google-workspace/` to `.gitignore`.
- Restricted scopes (`drive` full scope) may trigger Google verification warnings in Testing mode - expected, personal use OK as test user.
- API drift risk on pi extension API - mitigate by checking `docs/extensions.md` signatures against vendored calls before first run.

## Verification checklist

- [x] Type-check clean: `tsc --strict --noEmit` against pi 0.84 `dist/index.d.ts` + `typebox` (fixed: upstream uses invalid `"success"` notify level; annotated status tool return type)
- [x] Token dir gitignored (`.pi/agent/google-workspace/`)
- [x] PI-GUIDE updated (extension table row + notes section)
- [x] Extension README written with upstream-diff documentation
- [ ] `/reload` loads extension without errors
- [ ] `pass insert GWS/GOOGLE_CLIENT_ID` + `GWS/GOOGLE_CLIENT_SECRET` (user)
- [ ] `/gws-setup` reads creds from pass, completes browser OAuth, writes token-only oauth.json
- [ ] `google_workspace_status` reports configured + refresh available
- [ ] Round-trip: drive list -> upload file -> download file
- [ ] Docs read + `md` download preserves headings/lists/tables
- [ ] Sheets create/read/update round-trip
- [ ] `grep GOCSPX ~/.pi/agent/google-workspace/oauth.json` finds no client secret
