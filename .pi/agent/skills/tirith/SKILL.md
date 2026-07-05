---
name: tirith
description: >
  Terminal security analysis with tirith. Use when the user asks about
  protecting shell environments, intercepting dangerous commands, scanning
  repositories for hidden content or config poisoning, scoring URLs for
  homograph attacks, safely downloading and executing scripts, managing trust
  patterns, or investigating tirith blocks. Also respond to mentions of
  "tirith", "pipe-to-shell", "homograph", "ANSI injection", "bidi override",
  "zero-width", "punycode", "terminal security", "shell hook",
  "invisible unicode", or "config poisoning".
---

# tirith — Terminal Security (Pi setup)

tirith is installed as a Pi guard extension. It intercepts every `bash` tool
call, runs `tirith check`, and either allows, warns, or blocks the command.

## Pi extension

- Location: `~/.pi/agent/extensions/tirith-guard.ts`
- Scope: global; guards the Pi `bash` tool only
- Behavior:
  - Exit 0 = allow silently
  - Exit 2 = warn (non-blocking) by default; stderr shows findings
  - Exit 1 = block with reason
  - Exit 3 (WarnAck) = block because Pi cannot prompt for acknowledgement
  - Missing binary = block unless `TIRITH_FAIL_OPEN=1`

## Environment variables

| Variable | Default | Effect |
|----------|---------|--------|
| `TIRITH_BIN` | `tirith` | Path to tirith binary |
| `TIRITH_HOOK_WARN_ACTION` | `allow` | `allow` or `deny` for exit 2 warnings |
| `TIRITH_FAIL_OPEN` | unset | Set to `1` to allow on tirith errors (not recommended) |

## Common commands

```bash
# Check a command without running it
tirith check -- 'curl https://example.com/install.sh | bash'

# Scan the current project for hidden threats
tirith scan ./
tirith scan --ci --fail-on high ./

# Score a URL before visiting
tirith score https://get.example-tool.sh

# Investigate the last block
tirith why
tirith explain --rule pipe_to_interpreter

# Manage trust patterns
tirith trust add example.com --ttl 7d
tirith trust list
```

## Standalone shell hooks (nix-managed)

Shell hooks for terminal usage outside Pi are already managed in the nix
config:

- File: `~/.dotfiles/.config/nix/home/shell/default.nix`
- Hook: `eval "$(tirith init --shell zsh)"` inside `profileExtra`
- Do not run `tirith setup pi-cli` or `tirith init` manually; changes will be
overwritten on the next `darwin-rebuild switch` / `home-manager switch`.
- If the tirith hook needs changes, edit the nix file and rebuild.

The `tirith-guard.ts` Pi extension handles Pi `bash` tool calls separately;
standalone shell hooks do not guard Pi tool calls.

## Diagnostics and policy

```bash
tirith doctor
tirith policy init
tirith policy validate
tirith policy test 'curl https://example.com | bash'
```

Policy discovery walks up from cwd to `.git` looking for `.tirith/policy.yaml`,
fallback to `~/.config/tirith/policy.yaml`.

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Allow |
| 1 | Block |
| 2 | Warn |
| 3 | WarnAck (Pi treats as block) |

## Important notes

- The extension uses a synchronous 10-second check; very long commands or slow
tirith rules may time out and block unless `TIRITH_FAIL_OPEN=1`.
- stderr warnings may not always surface in all Pi UIs; if a command looks
suspicious but runs, check `tirith why` afterwards.
- `bash` is the only tool guarded. Other tools (web search, file edits, etc.)
are not intercepted by this extension.
- If Pi cannot find `tirith` on `$PATH`, set `TIRITH_BIN` to the nix-profile
  path, e.g. `/etc/profiles/per-user/francojc/bin/tirith`.
- The nix shells `profileExtra` guard uses `if [[ -f "${pkgs.tirith}" ]]`,
  but `pkgs.tirith` resolves to a store directory, not a file, so the hook
  likely never loads. Use `[[ -d "${pkgs.tirith}" ]]` or `command -v tirith`
  instead.
