# pi-copilot-usage

A **pi** extension that surfaces GitHub Copilot quota, model billing metadata, and Copilot SDK session context directly inside pi.

## Features

| What | How |
|------|-----|
| `/copilot` | Primary visual dashboard: quota, included buckets, model billing, compact sessions, recent sessions |
| `/copilot-quota` | Secondary focused quota + model billing view, kept for compatibility |
| `/copilot-models` | Secondary focused model billing view, kept for compatibility |
| `/copilot-sessions` | Browse sessions newest-first and inspect full metadata |
| `copilot_usage` tool | LLM-callable structured JSON; supports `period` filter |
| Footer status | Live threshold meter like ` Copilot [██████░░░░] 60%`, refreshed every 60 s |

## Prerequisites

- [pi coding agent](https://www.npmjs.com/package/@mariozechner/pi-coding-agent) installed globally
- GitHub Copilot access for the authenticated GitHub account
- GitHub CLI authenticated with `gh auth login`
- Node.js ≥ 18

## How it works

Two data sources are used in parallel:

| Source | What it provides |
|--------|-----------------|
| `gh api /copilot_internal/user` | Quota snapshots, plan name, reset date, token-based billing flag |
| `@github/copilot-sdk` `CopilotClient` | Sessions, auth status, CLI status, model billing metadata |

The SDK work runs in a short-lived child process so the main Pi process does not keep Copilot SDK sockets around after commands finish.

## Caching and polling

- Commands share a 30-second TTL cache (`fetchAllCached`).
- Footer polling uses a lightweight quota-only `gh api` request every 60 seconds.
- The first footer poll is delayed by 3 seconds after session start so it does not slow Pi startup.

## Main command

### `/copilot` – visual dashboard

Shows one dashboard with compact sections:

- Quota hero with threshold glyph, remaining bar, percent remaining, plan, billing mode, reset date, usage, and overage status.
- Included buckets such as chat and completions.
- Model billing table, including free/included models and metered models sorted by a relative account-hit index, with compact token price details when available.
- Session counts: total, today, this week, this month, active now, average duration.
- Recent sessions, limited and compact.

Repository and directory leaderboards are intentionally not shown in the dashboard. Model availability and billing are more useful here.

## Secondary commands

These are preserved for compatibility and focused browsing:

| Command | Purpose |
|---------|---------|
| `/copilot-quota` | Focused quota and model billing view |
| `/copilot-models` | Focused model billing table |
| `/copilot-sessions` | Interactive session browser with detail drill-down |

## `copilot_usage` tool

The AI assistant can call this directly when it needs structured usage data. Useful prompts:

- *"How much Copilot quota do I have left?"*
- *"Which Copilot models are metered?"*
- *"How many Copilot sessions did I have this week?"*
- *"Show me my recent Copilot sessions."*

Accepts optional `period`: `today | week | month | all` (default `all`). Returns structured JSON with quota snapshots, model billing metadata, session counts, repository/directory counts for machine use, and recent session summaries.

## Footer status

The footer indicator auto-updates every 60 seconds:

| Glyph | Meaning |
|-------|---------|
| `` | Loading or fetching |
| `` | Healthy, > 25% quota remaining |
| `` | Warning, 10–25% quota remaining |
| `` | Critical, <= 10% remaining, or error |

The bar always means **remaining quota**: full is good, empty is bad. Tiny battery brain, no math goblin required.

## File layout

```text
pi-copilot-usage/
├── package.json
├── package-lock.json
├── node_modules/
├── src/
│   └── index.ts
└── README.md
```

## Gotchas

- Uses GitHub's internal `/copilot_internal/user` endpoint. It works now but may change without notice.
- GitHub Copilot billing metadata varies. Some models expose multipliers, others expose token prices. The dashboard compares metered models relative to the cheapest metered model, compacts large raw token-price integers into `K`/`M`/`B`/`T` labels, and treats all-zero token prices as included.
- Nerd Font glyphs are intentional for the footer/dashboard aesthetic and require a compatible terminal font.
- Run `/reload` after editing the extension.
