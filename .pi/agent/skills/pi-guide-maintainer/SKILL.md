---
name: pi-guide-maintainer
description: Maintain Jerid's user-facing Pi Guide markdown document for installed Pi packages, global/local extensions, skills, shortcuts, commands, configuration, best practices, and gotchas. Use when Pi extensions or packages are installed, removed, updated, diagnosed, or when the user asks to document Pi behavior.
---

# Pi Guide Maintainer

## Purpose

Maintain the living Pi Guide at:

- `~/.pi/agent/PI-GUIDE.md`
- Dotfiles path: `/Users/francojc/.dotfiles/.pi/agent/PI-GUIDE.md`

The guide is user-facing. It should explain what Jerid can do with current Pi setup, not merely list implementation details.

## When to use

Use this skill when:

- User installs, removes, updates, or diagnoses Pi packages or extensions.
- User asks how a Pi extension, skill, theme, keybinding, or package works.
- User wants best practices, shortcuts, commands, configuration notes, or gotchas documented.
- You change files under `~/.pi/agent/extensions`, `~/.pi/agent/skills`, `~/.pi/agent/settings.json`, or `~/.pi/agent/keybindings.json`.

## Required workflow

1. Read current guide first if it exists.
2. Inventory current Pi setup:
  - `~/.pi/agent/settings.json`
  - `~/.pi/agent/keybindings.json`
  - `~/.pi/agent/npm/package.json`
  - `~/.pi/agent/extensions/`
  - `~/.pi/agent/skills/`
3. For each relevant package, read package docs before writing:
  - `~/.pi/agent/npm/node_modules/<package>/README.md`
  - `~/.pi/agent/npm/node_modules/<package>/package.json`
  - Extension entrypoint source when docs do not answer behavior questions.
4. For local extensions, inspect source enough to document commands, tools, shortcuts, UI changes, environment variables, and persistence.
5. Update `PI-GUIDE.md` with concise user-facing notes.
6. Keep guide accurate to installed/current config. Remove stale entries when packages/extensions are removed.
7. Report changed sections and any uncertainty.

## Optional inventory helper

Run from skill directory or repo root:

```bash
~/.pi/agent/skills/pi-guide-maintainer/scripts/inventory.mjs
```

This prints packages, local extensions, skills, and keybindings as a quick starting point. Still inspect docs/source before making behavioral claims.

## Guide structure

Preserve this broad structure unless user asks otherwise:

1. `# Pi Guide`
2. `## Maintenance`
3. `## Quick commands`
4. `## Installed packages`
5. `## Local extensions`
6. `## Keybindings and terminal notes`
7. `## Extension notes`
8. `## Maintenance checklist`

For each extension/package note:

- What it does
- User commands
- Keyboard shortcuts
- Configuration files and environment variables
- Best practices
- Gotchas or limitations
- Source/docs paths checked

## Writing rules

- User-facing, terse, practical.
- Prefer bullets and small tables.
- No em dashes. Use en dashes or commas.
- Put one blank line between headings and body text.
- Use 2 spaces for nested list indentation.
- Do not hard-wrap lines.
- Do not expose secrets. Reference environment variable names only.

## Safety rules

- Treat third-party packages in `node_modules` as read-only unless user explicitly asks for a patch.
- Do not invent behavior. If unclear, mark `TODO: verify` and cite file path needing inspection.
- When package docs conflict with source, prefer source and note mismatch.
- If guide update follows install/remove/update, remind user to run `/reload` when needed.
