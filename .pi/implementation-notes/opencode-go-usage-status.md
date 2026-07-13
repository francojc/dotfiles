# OpenCode Go usage status implementation notes

- Feature branch: `feat/opencode-go-usage-status`
- Base branch: `main`
- Started: 2026-07-13
- Isolation: implementation remains on this feature branch pending review and explicit merge approval.
- Codex raw compact status grammar (package 0.12.0): `<prefix> <remaining>% 5h <remaining>% wk`; the footer recognizes `codex [variant] <remaining>% 5h <remaining>% wk` case-insensitively and turns it into glyph/bar output.
- Copilot baseline: `gh api /copilot_internal/user`, 60-second recursive quota poll after a 3-second delayed start; `session_start`, `model_select`, and `session_shutdown` gate `github-copilot`/`copilot-api` with a generation guard. Copilot currently owns equivalent local clamp/glyph/bar helpers.
- Verification: shared formatter exercised with Codex and Go raw forms, boundary values, and used-to-remaining conversion; all edited TypeScript passed `node --experimental-strip-types --check`; `git diff --check` passed. `pass` entries `USER/OPENCODE_GO_WORKSPACE_ID` and `COOKIE/OPENCODE_GO_AUTH_COOKIE` were confirmed available without displaying their contents. Interactive authenticated dashboard and Pi lifecycle verification should be performed after `/reload`.
