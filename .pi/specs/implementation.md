# Memory System Audit & Fix Plan

## Context

The Pi memory extension (`~/.pi/agent/extensions/memory.ts`) plus its companion processor (`~/.pi/agent/session-end-processor.mjs`) implement a three-tier memory system: working, episodic, and semantic. Several bugs have been fixed already (invalid event names, missing shutdown hook, unrunnable .ts processor, TUI crash from invalid content blocks). This plan addresses the remaining issues found during a full audit.

## Audit Summary

### What Works
- **Working memory** tool (`memory_working`): add/remove/clear/list all function correctly, state reconstructs from session history including branch awareness
- **Episodic recall** tool (`memory_recall`): keyword+date+project search over episode files works
- **Session shutdown hook**: correctly spawns `session-end-processor.mjs` as detached background process
- **Processor**: parses JSONL, generates episode JSON, consolidates overflow to semantic markdown
- **System prompt injection**: `before_agent_start` correctly appends memory context per turn
- **Skill file**: lives in the right auto-discovered path (`~/.pi/agent/skills/memory-recall/`)

### Issues to Fix

#### 1. Skill frontmatter uses nonexistent `triggers` field (Medium)
**Problem**: `SKILL.md` includes `triggers: keywords: [...]` in its YAML frontmatter. Pi's skill system has no `triggers` mechanism — unknown fields are silently ignored. The skill loads fine (it has `name` + `description`), but the `triggers` block is dead weight that implies a feature that doesn't exist. The skill works only because the LLM reads the description and body text.

**Fix**: Remove the `triggers` block. Move the keyword list into the description and body where the LLM can actually see it.

#### 2. `getEpisodicPaths()` reads & parses every file just to sort (Low)
**Problem**: The sort function reads the full JSON content of each episode file, parses it, and extracts the timestamp — just to sort. Episode filenames already contain ISO timestamps from the session ID (e.g., `2026-04-06T13-59-13-132Z_uuid.json`), so they sort lexicographically.

**Fix**: Sort by filename (reverse lexicographic) instead of reading file contents. Eliminates redundant I/O on every session start and every recall.

#### 3. `/consolidate` command is a no-op stub (Medium)
**Problem**: The command just prints a message. It doesn't actually trigger consolidation.

**Fix**: Have it spawn the processor against the current session file (same as `session_shutdown` does), or run consolidation logic inline.

#### 4. Dead code: `MemoryState`, `SemanticSuggestParams`, `RECALL_KEYWORDS`, `formatEpisodesForPrompt` (Low)
**Problem**: Several types, schemas, and functions are defined but never used:
- `MemoryState` interface — unused
- `SemanticSuggestParams` schema — registered but no tool uses it
- `RECALL_KEYWORDS` array — the skill handles recall triggering; extension doesn't use these
- `formatEpisodesForPrompt()` — called nowhere (episodes aren't auto-injected into prompts)

**Fix**: Remove all dead code.

#### 5. Working memory has no size cap (Low)
**Problem**: README says "Max 20 items" but no enforcement exists. Unbounded working memory could bloat the system prompt over a long session.

**Fix**: Add a cap (e.g., 20 items per type) in the `add` action, dropping the oldest when exceeded.

#### 6. Episodic summarizer is keyword-only — no user message capture (Medium)
**Problem**: The `generateSummary()` function in `session-end-processor.mjs` relies purely on keyword pattern matching. It doesn't capture the user's actual first message or the concrete topic discussed. A session about "migrating from webpack to vite" would just produce "Worked on configuration" if no keywords match perfectly. The plan's original design called for LLM-generated summaries.

**Fix**: Include a truncated excerpt of the first user message (first ~200 chars) as a `context` field in the episode JSON. This gives recall something concrete to search against without requiring an LLM call.

#### 7. Semantic consolidation grows monotonically without dedup (Low)
**Problem**: Each consolidation appends `### date` entries to the project markdown. Over time, the same topics appear repeatedly with no deduplication or summarization. The file grows without bound.

**Fix**: For now, add a size cap comment. A proper fix would use an LLM to merge/deduplicate, which is out of scope for this plan. Alternatively, keep only the last N consolidated entries per project.

## Files to Modify

| File | Changes |
|------|---------|
| `~/.pi/agent/extensions/memory.ts` | Remove dead code, fix `getEpisodicPaths` sort, implement `/consolidate`, add working memory cap |
| `~/.pi/agent/session-end-processor.mjs` | Add first-message excerpt to episodes, cap semantic file size |
| `~/.pi/agent/skills/memory-recall/SKILL.md` | Remove invalid `triggers` frontmatter, improve description |
| `~/.pi/agent/memory/README.md` | Update to reflect actual behavior after fixes |

## Reuse

- **`todo.ts` pattern**: Working memory reconstruction already follows the same `getBranch()` → scan `toolResult` details pattern as `todo.ts`. No changes needed.
- **`session-end-processor.mjs`**: Already exists and works. Only needs the first-message excerpt enhancement.
- **Pi's `before_agent_start` event**: Already correctly used for system prompt injection.

## Steps

- [ ] **Step 1**: Clean `SKILL.md` — remove `triggers` block, fold keyword examples into description
- [ ] **Step 2**: Remove dead code from `memory.ts` — `MemoryState`, `SemanticSuggestParams`, `RECALL_KEYWORDS`, `formatEpisodesForPrompt`
- [ ] **Step 3**: Fix `getEpisodicPaths()` to sort by filename instead of parsing file contents
- [ ] **Step 4**: Implement `/consolidate` command — spawn the processor against the current session
- [ ] **Step 5**: Add working memory size cap (20 items per type, drop oldest on overflow)
- [ ] **Step 6**: Enhance `session-end-processor.mjs` — capture first user message excerpt in episode JSON, add `context` field
- [ ] **Step 7**: Add semantic file size cap in `consolidateEpisodes()` — keep last 50 entries max per project file
- [ ] **Step 8**: Update `README.md` to match final behavior
- [ ] **Step 9**: Run `test-memory.sh`, manually test processor against a real session, verify Pi loads without errors

## Verification

1. **Extension loads cleanly**: `pi` starts with no errors in the extension
2. **`/memory` command**: Shows working memory state
3. **`/consolidate` command**: Actually runs the processor (check `~/.pi/memory/episodes/` for new file)
4. **Working memory cap**: Add >20 facts, verify oldest are dropped
5. **Skill loads**: Check that `memory-recall` appears in skill list and the LLM uses `memory_recall` tool when asked "remember when..."
6. **Processor test**: `node ~/.pi/agent/session-end-processor.mjs <session-path>` produces an episode with a `context` field containing the first user message
7. **Exit test**: Start a session, do some work, exit — verify a new episode JSON appears in `~/.pi/memory/episodes/`
