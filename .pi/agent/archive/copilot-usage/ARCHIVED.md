# Archived: copilot-usage

Archived 2026-11-02. Not loaded by Pi.

Reason: Pi's providers are now `bifrost` and `bifrost-auto` only. Copilot is reached through the Bifrost gateway, not as a direct provider, so a local Copilot quota dashboard and SDK session browser are no longer needed. No Codex tooling is used either.

## What it did

- `/copilot`, `/copilot-quota`, `/copilot-models`, `/copilot-sessions` commands.
- `copilot_usage` agent tool.
- Footer quota meter, polled every 60 s while a Copilot-capable provider was active.

## Restoring

Move the directory back:

```
mv ~/.pi/agent/archive/copilot-usage ~/.pi/agent/extensions/copilot-usage
```

Then `/reload`. Its `node_modules/` (about 563 MB, `@github/copilot-sdk`) stayed with it and is git-ignored.

## Why it is still on disk

Deleted from `extensions/` so Pi stops loading it. The directory remains for reference rather than being destroyed.

## Related, left untouched

- `~/.codex` was moved aside separately.
- The nix-darwin `copilot-api` launchd service is still enabled: something else on the host uses that loopback proxy, so it was not disabled.
