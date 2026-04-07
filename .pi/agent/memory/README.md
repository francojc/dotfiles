# Pi Memory Extension

A cross-session memory system for Pi modeled on human memory.

## Memory Types

### 1. Working Memory (Session-Scoped)
- **Storage**: Tool result details (branch-aware)
- **Scope**: Current session only
- **Size**: Max 20 items
- **Lifetime**: Session duration, forks inherit parent working memory

**Commands:**
- `/memory` - View current working memory
- LLM tool: `memory_working({ action: "add|remove|clear|list", type?: "fact|goal|context", content?: string })`

### 2. Episodic Memory (Rolling Buffer)
- **Storage**: `~/.pi/memory/episodes/*.json`
- **Scope**: Recent sessions (last 5)
- **Lifetime**: Auto-consolidated to semantic memory when buffer is full
- **Generation**: Automatic at session end via `session_shutdown` → `session-end-processor.mjs`

**LLM Tool:**
- `memory_recall({ query: string, dateRange?: string, projectFilter?: string, limit?: number })`

**Skill:**
- `memory-recall` - Auto-triggered on keywords: "remember", "recall", "like with", "previous work", "similar to", etc.

### 3. Semantic Memory (Long-term)
- **Storage**: `~/.pi/memory/semantic/*.md`
- **Scope**: Project-specific and global knowledge
- **Lifetime**: Persistent, self-organizing
- **Update**: Automatic consolidation from episodic memories

## How It Works

### Session Start
1. Reconstruct working memory from session history
2. Show greeting with 2-3 recent projects
3. Load project-specific semantic memory into system prompt

### During Session
- `memory_working` tool updates session context
- `memory_recall` tool searches past sessions on demand
- `memory-recall` skill auto-triggers on recall keywords

### Session End (`session_shutdown`)
1. `memory.ts` spawns `session-end-processor.mjs` as a detached background process
2. Processor parses the session JSONL and generates an episodic summary
3. If >5 episodic memories, oldest are consolidated into project semantic files
4. Consolidated episode files are pruned

## File Structure

```
~/.pi/memory/
├── episodes/
│   ├── 2026-04-06T16-34-44-751Z_7e7e5892.json  # Session summaries
│   └── ...
└── semantic/
    ├── preferences.md    # User preferences
    ├── themes.md         # Recurring topics
    └── projects/
        ├── dotfiles.md   # Project-specific knowledge
        └── ...
```

## Configuration

Currently hardcoded in the source files:

| Setting | Value | Location |
|---------|-------|----------|
| Episode buffer size | 5 | `memory.ts`, `session-end-processor.mjs` |
| Memory directory | `~/.pi/memory/` | Both files |
| Recall keywords | see `SKILL.md` | `memory-recall` skill |

## Manual Commands

- `/memory` - Show working memory
- `/consolidate` - Manually trigger consolidation

## Example Usage

```
# Add to working memory
[Tool: memory_working] action: add, type: goal, content: "Refactoring auth system"

# Recall relevant past sessions
[Tool: memory_recall] query: "React components", projectFilter: "dotfiles", limit: 2

# Or trigger via natural language
"Remember when we set up the nix config?"
→ Triggers memory-recall skill → Loads relevant sessions
```

## File Layout

```
agent/
├── extensions/
│   └── memory.ts              # Extension: tools, events, system prompt
├── session-end-processor.mjs  # Standalone: episodic generation + consolidation
├── memory/
│   ├── README.md              # This file
│   └── test-memory.sh         # Smoke test
└── skills/
    └── memory-recall/
        └── SKILL.md           # Auto-recall skill
```

## First Use

1. Restart Pi (extension auto-loads from `agent/extensions/`)
2. Working memory starts empty
3. After first session ends, `session_shutdown` spawns the processor
4. Processor writes an episodic JSON to `~/.pi/memory/episodes/`
5. After 5 episodes, oldest are consolidated to `~/.pi/memory/semantic/projects/`
