---
name: aside-mode
description: Enter temporary off-record aside mode for exploratory chat, conceptual questions, brainstorming, or learning detours that should stay read-only and out of memory consolidation. Use when user wants to think aloud, ask side questions, probe ideas, or go incognito without changing files.
---

# Aside Mode

Use aside mode when user wants temporary exploratory chat outside main workflow.

## What aside mode does

- Enables read-only chat inside current session
- Hard-locks write-capable tools
- Allows read access via `read`, read-only `bash`, and `web_search`
- Excludes aside content from episodic and semantic memory consolidation
- Suppresses memory-context injection while aside mode is active

## Commands

- `/aside` – enter aside mode
- `/aside <question>` – enter aside mode and ask question immediately
- `/aside off` – exit aside mode
- `/main` – exit aside mode

## Behavior

While aside mode active:

- Do not edit files
- Do not write files
- Do not run mutating shell commands
- Keep focus on explanation, exploration, comparison, brainstorming, and learning
- If user asks for implementation, tell user to exit aside mode first

## Examples

```text
/aside Help me think through whether tree-based session summaries make sense here
```

```text
/aside What would be cleanest design for command-scoped incognito chat?
```

```text
/main
```
