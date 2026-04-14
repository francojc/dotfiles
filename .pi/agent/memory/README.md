# Pi Memory Extension

A cross-session memory system for Pi modeled on human memory.

## Memory Types

### 1. Working Memory (Session-Scoped)

- **Storage**: Tool result details (branch-aware)
- **Scope**: Current session only
- **Lifetime**: Session duration, forks inherit parent working memory

**Commands:**

- `/memory` – View current working memory

**Limits:**

- Max 20 items per type (fact/goal/context); oldest dropped on overflow
- Example: adding 21st fact drops the oldest fact

**LLM tool:**

- `memory_working({ action: "add|remove|clear|list", type?: "fact|goal|context", content?: string })`

### 2. Episodic Memory (Rolling Buffer)

- **Storage**: `~/.pi/memory/episodes/*.json`
- **Scope**: 5 most recent sessions
- **Lifetime**: Oldest auto-consolidated to semantic memory when buffer exceeds 5
- **Generation**: Automatic at session end via `session_shutdown` → `session-end-processor.mjs`

Each episode contains:

- `summary` – The user's opening request plus files touched and tools used
- `context` – First user message (up to 300 chars) for search matching
- `keyTopics` – Keyword-extracted topics (debugging, configuration, etc.)
- `actionItems` – Forward-looking statements extracted from conversation (TODOs, "next time", "still need to")
- `outcomes` – Tool-based outcomes (wrote files, edited files, ran commands)

**LLM tool:**

- `memory_recall({ query: string, dateRange?: string, projectFilter?: string, limit?: number })`

**Skill:**

- `memory-recall` – Auto-triggered on keywords: "remember", "recall", "like with", "previous work", "similar to", etc.

### 3. Semantic Memory (Long-term)

- **Storage**: `~/.pi/memory/semantic/projects/*.md`
- **Scope**: Project-specific consolidated knowledge
- **Lifetime**: Persistent, self-organizing
- **Update**: Automatic consolidation from episodic overflow
- **Cap**: 50 entries per project file (rolling window, oldest dropped)
- **Dedup**: Episodes with >80% topic overlap with existing entries are skipped

Project names are derived from the last 2 path segments of the working directory (e.g., `/Users/you/.dotfiles/.config/nix` → `config/nix`, stored as `config--nix.md`).

## How It Works

### Session Start

1. Reconstruct working memory from session history (replays `memory_working` tool results)
2. Show notification with 2-3 recent projects
3. Load project-specific semantic memory based on cwd

### During Session

- `memory_working` tool updates session context (facts, goals, temporary context)
- `memory_recall` tool searches past sessions on demand
- `memory-recall` skill auto-triggers on recall keywords
- Working memory + recent projects + project semantic knowledge injected into system prompt on every turn
- If `aside-mode` is active, memory context injection is skipped for that turn

### Session End (`session_shutdown`)

1. `memory.ts` spawns `session-end-processor.mjs` as a detached background process
2. Processor parses the session JSONL
3. Filters out any entries recorded while `aside-mode` was active
4. Generates a structured summary (first user message + files + tools + keyword topics + action items)
5. Writes episodic JSON to `~/.pi/memory/episodes/`
6. If >5 episodes, consolidates oldest to semantic project files (with dedup and rolling cap)
7. Consolidated episode files are pruned
8. Errors logged to `~/.pi/memory/processor.log`

## File Structure

```
~/.pi/memory/
├── episodes/                          # Rolling buffer of 5 recent session summaries
│   └── <session-id>.json
├── semantic/
│   └── projects/
│       ├── config--nix.md             # Consolidated from .config/nix sessions
│       ├── dotfiles--pi.md            # Consolidated from .dotfiles/.pi sessions
│       └── ...
└── processor.log                      # Error/output log from background processor
```

## Commands

| Command | Description |
|---------|-------------|
| `/memory` | Show current working memory state |
| `/memory-status` | Show system health: episode count, semantic files, recent log |
| `/consolidate` | Manually trigger memory consolidation for current session (runs processor in background) |

## Aside Mode Interaction

If you enter `/aside`, Pi records start and stop markers in session state. `session-end-processor.mjs` drops all entries between those markers before building episodic or semantic memory. Result: aside chat stays out of durable memory.

## Troubleshooting

**No episodes appearing after sessions?**

1. Check `~/.pi/memory/processor.log` for errors
2. Run `/memory-status` to see current state
3. Manually test: `node ~/.pi/agent/session-end-processor.mjs <path-to-session.jsonl>`

**Summaries are too generic?**

The summarizer extracts the first user message, files from tool calls, and keyword topics. It does not use an LLM. Summaries are only as specific as the user's opening message.

**Backfill past sessions:**

```bash
for f in $(find ~/.pi/agent/sessions -name "*.jsonl" -type f | sort); do
  node ~/.pi/agent/session-end-processor.mjs "$f"
done
```
