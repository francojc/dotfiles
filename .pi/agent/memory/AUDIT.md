# Memory System Audit

**Date:** 2026-04-07
**Status:** Partially functional – one critical bug fixed, several issues remain

## Architecture Overview

The memory system has three tiers, modeled loosely on human memory:

| Tier | Scope | Storage | Lifetime |
|------|-------|---------|----------|
| **Working** | Current session | In-memory (reconstructed from session history) | Session only |
| **Episodic** | Recent sessions (last 5) | `~/.pi/memory/episodes/*.json` | Rolling buffer, overflow consolidates to semantic |
| **Semantic** | Long-term knowledge | `~/.pi/memory/semantic/projects/*.md` | Persistent |

### Components

| File | Role |
|------|------|
| `agent/extensions/memory.ts` | Extension: tools, events, system prompt injection |
| `agent/session-end-processor.mjs` | Standalone Node script: parses session JSONL → episodic summary → semantic consolidation |
| `agent/skills/memory-recall/SKILL.md` | Skill: triggers `memory_recall` tool on keywords like "remember", "recall" |
| `agent/memory/README.md` | Documentation |
| `agent/memory/test-memory.sh` | Smoke test (checks file existence only) |

### Data flow

```
Session active
  └─► memory_working tool → in-memory state (keyFacts, currentGoals, temporaryContext)
  └─► before_agent_start → injects working memory + recent projects into system prompt

Session ends (Ctrl+C / Ctrl+D / switch / fork)
  └─► session_shutdown event fires
      └─► spawns: node session-end-processor.mjs <session.jsonl>
          ├─► Parses JSONL, extracts user/assistant messages
          ├─► Runs keyword heuristic summarizer
          ├─► Writes episodic JSON to ~/.pi/memory/episodes/
          └─► If >5 episodes, consolidates oldest to semantic .md files

Next session starts
  └─► session_start → reconstructs working memory from branch history
  └─► before_agent_start → builds memory context:
      ├─► Working memory (current session)
      ├─► Recent projects (from episode cwds)
      └─► Project semantic knowledge (if exists for current cwd)
```

---

## Component-by-Component Assessment

### 1. Working Memory – ✅ FUNCTIONAL

**What it does:** In-session scratch pad with three buckets (facts, goals, context). The LLM can add/remove/clear/list items. State is reconstructed from session history on reload/fork.

**How it works:**
- `memory_working` tool mutates in-memory `WorkingMemory` object
- Tool results include `details` field that persists in session JSONL
- On `session_start`, replays all `memory_working` tool results to reconstruct state
- Injected into system prompt via `before_agent_start`

**Verified:**
- Tool schema is correct
- Reconstruction logic replays add/remove/clear correctly
- System prompt injection works (the "Working Memory" and "Recent Projects" sections visible in my system prompt right now)

**Issues:** None found.

### 2. Episodic Memory – ⚠️ PARTIALLY FUNCTIONAL

**What it does:** After each session ends, a background process parses the session JSONL and saves a structured summary (JSON) to `~/.pi/memory/episodes/`.

**Critical findings:**

#### 2a. `session_shutdown` handler – ✅ fires correctly

The handler spawns `node session-end-processor.mjs <sessionFile>` as a detached child process. The path resolution (`import.meta.url` → dirname → `../session-end-processor.mjs`) resolves correctly to the existing file.

#### 2b. Episode generation rate – ⚠️ VERY LOW

- **52 session files** exist with user messages
- **2 episode files** exist on disk (one was manually created during this audit)
- The memory system was only created on 2026-04-06 ~23:00, so only sessions ending *after* that point would produce episodes
- Of ~8 post-creation sessions, only 1 auto-generated an episode
- Most of those 8 sessions were short/broken sessions during the memory system's own development, so the extension may not have been fully loaded

**Verdict:** Too early to tell if this is a systemic failure or just a timing artifact. The processor *does* work when invoked manually. Need more sessions to accumulate before this can be confirmed working at scale.

#### 2c. Summary quality – ⚠️ POOR (by design)

The `generateSummary()` function is a keyword-matching heuristic, not an LLM summarizer. Example output:

> Input: User debugging network connectivity issues (ping/dig hanging)
> Output: `"Fixed issues involving debugging"`

This is nearly useless for recall. The summary loses all specificity. The code acknowledges this with the comment: *"A proper LLM-based summarizer can replace this later."*

**Specific problems:**
- Only matches ~12 hardcoded keyword patterns
- `keyTopics` captures file basenames (e.g., `file:memory.ts`) but not conceptual topics
- `actionItems` is always empty (never populated)
- `outcomes` only captures tool names used (wrote/edited/ran), not what was accomplished

#### 2d. `memory_recall` tool – ✅ FUNCTIONAL (but limited by data)

The recall tool does keyword matching against episode summaries, topics, and outcomes. It supports date range filtering and project path filtering. The logic is correct, but with only 2 low-quality episodes in the store, it returns essentially nothing useful.

#### 2e. Recall skill (`memory-recall/SKILL.md`) – ✅ FUNCTIONAL

The skill is correctly structured with trigger keywords. It instructs the LLM to call `memory_recall` with extracted parameters. This works as designed.

### 3. Semantic Memory – ❌ NEVER TRIGGERED

**What it does:** When the episodic buffer exceeds 5 entries, the oldest episodes are consolidated into per-project Markdown files under `~/.pi/memory/semantic/projects/`.

**Current state:**
- `~/.pi/memory/semantic/projects/` directory exists but is empty
- Only 2 episodes exist, well under the threshold of 5
- Consolidation has never fired

**The consolidation logic itself looks correct:**
- Groups episodes by project (last path component of cwd)
- Appends to existing project `.md` files under a "Consolidated Sessions" heading
- Deletes consolidated episode files

**Issues with the design:**
- Project name extraction uses `cwd.split("/").pop()` which gives the leaf directory name. For `/Users/francojc/.dotfiles/.pi`, the project name would be `.pi`, not `dotfiles`. Multiple different projects could collide or produce unclear names.
- The semantic files are just chronological logs of episode summaries – no actual knowledge synthesis occurs.

### 4. System Prompt Injection – ✅ FUNCTIONAL

**What it does:** `before_agent_start` builds a memory context string and appends it to the system prompt.

**What gets injected:**
1. Working memory (facts/goals/context from current session)
2. Recent projects (cwds from the last 3 episodes)
3. Project semantic knowledge (if a `.md` file exists for current project)

**Verified:** The injection is active right now – my system prompt includes the `# Memory Context` section with "Working Memory" and "Recent Projects" subsections.

### 5. TUI Rendering – 🔴 FIXED (was crashing)

**What was wrong:** Both `renderCall` and `renderResult` for `memory_working` and `memory_recall` tools returned raw strings. Pi's TUI requires these to return `Component` instances (specifically `Text` objects from `@mariozechner/pi-tui`).

**The crash:**
```
TypeError: child.render is not a function
    at Box.render (box.js:62:33)
    at ToolExecutionComponent.render (tui.js:64:33)
```

**Fix applied:** All four render methods now return `new Text(...)` instead of raw strings. Added `import { Text } from "@mariozechner/pi-tui"` to the imports.

---

## Summary of Issues

### 🔴 Fixed

| # | Issue | Fix |
|---|-------|-----|
| 1 | `renderCall`/`renderResult` return strings instead of `Text` components → TUI crash | Changed all 4 methods to return `new Text(...)` |

### 🟡 Needs Attention

| # | Issue | Impact | Suggested Fix |
|---|-------|--------|---------------|
| 2 | Keyword heuristic summarizer produces near-useless summaries | Recall is ineffective | Replace with LLM-based summarization (call an API in the processor, or use a local model) |
| 3 | `actionItems` field is never populated | Dead data field | Either populate it from the session or remove it from the schema |
| 4 | Project name uses leaf directory name (`cwd.split("/").pop()`) | `.pi`, `.config`, `src` collisions | Use a more specific identifier (e.g., last 2-3 path segments, or a hash) |
| 5 | Only 1 auto-generated episode out of ~8 eligible sessions | Unclear if systemic | Monitor over next several sessions; add logging to `session_shutdown` handler |
| 6 | Semantic consolidation is just a chronological log dump | No knowledge synthesis | Acceptable as v1; future: use LLM to synthesize patterns |
| 7 | No backfill mechanism for the 50 pre-existing sessions | Lost history | One-time script to run `session-end-processor.mjs` against all existing session files |
| 8 | `test-memory.sh` only checks file existence | No functional testing | Add a test that processes a real session file and validates the output JSON |

### ✅ Working

| Component | Status |
|-----------|--------|
| Working memory tool (`memory_working`) | Fully functional |
| Working memory reconstruction on session start | Functional |
| System prompt injection (`before_agent_start`) | Functional |
| `memory_recall` tool (search logic) | Functional (limited by data quality) |
| `memory-recall` skill (trigger keywords) | Functional |
| `session-end-processor.mjs` (when invoked) | Functional (produces output, consolidation logic correct) |
| Directory structure and initialization | Functional |
| `/memory` command | Functional |

---

## Recommended Priority Actions

1. **Monitor episode generation** over the next 5-10 sessions to confirm `session_shutdown` → processor pipeline is reliable
2. **Backfill existing sessions** with a one-time script to build up the episode store
3. **Improve summarizer** – even a simple template like `"User asked about {first_user_message_truncated}. Tools used: {tools}. Files touched: {files}"` would be 10x better than the current keyword matcher
4. **Add error logging** to the `session_shutdown` handler (currently `stdio: "ignore"` on the spawned process – errors are silently lost)
