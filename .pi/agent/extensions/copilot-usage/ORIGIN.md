# Origin

Vendored from <https://github.com/azs06/pi-copilot-usage> at commit `d10fe27`.

Local patches:

- Updated Pi imports from `@mariozechner/*` / `@sinclair/typebox` to `@earendil-works/*` / `typebox`.
- Added root `index.ts` for Pi global extension autodiscovery.
- Updated quota display for GitHub token-based Copilot billing and decimal `quota_remaining`.
- Updated model display for SDK `billing.token_prices` when legacy `billing.multiplier` is absent.
- Runs Copilot SDK calls in a child process to avoid SDK socket handles leaking into Pi.
