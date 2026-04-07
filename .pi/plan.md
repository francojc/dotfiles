# Cross-Session Memory System for Pi

## Context

Pi currently stores sessions as isolated JSONL files per working directory. Each session is self-contained with no awareness of previous sessions. The user wants a human-brain-inspired memory system with three types:

1. **Working Memory**: Key details from the *current* session (transient, high-resolution)
2. **Episodic Memory**: Main ideas from recent sessions (summarized, time-decaying)
3. **Semantic Memory**: General understanding of themes, preferences, project knowledge (long-term, abstracted)

## Current Architecture Understanding

### Session Storage
- Sessions stored in `agent/sessions/<encoded-path>/YYYY-MM-DDTHH-mm-ss-id.jsonl`
- Each session is append-only JSONL with entries: `session`, `model_change`, `message`, `toolResult`
- Working directory (`cwd`) is part of session metadata
- Extensions have lifecycle hooks: `session_start`, `session_switch`, `session_fork`, `session_tree`

### Extension System
- Extensions register via `ExtensionAPI` with tools (LLM-callable) and commands (user-callable)
- State can be stored in tool result `details` for proper branching behaviour
- Tools can access session history via `ctx.sessionManager.getBranch()`

### Existing State Examples
- `todo.ts`: Reconstructs state by scanning tool results in session history
- `vim-editor.ts`: Sets up custom editor on session events

---

## Proposed Approach: Extension-Based Memory System

A Pi extension that implements a tiered memory system using Pi's existing session infrastructure.

### Core Design Principles

1. **Working Memory**: Stored in tool result details (ephemeral, branch-aware)
2. **Episodic Memory**: Auto-generated summaries stored per session in a separate `.pi/memory/` directory
3. **Semantic Memory**: Aggregated, user-editable markdown files in `.pi/memory/` (themes, preferences, project knowledge)

### Memory Types Implementation

#### 1. Working Memory (Session-Scoped)

```typescript
// Stored in tool result details, reconstructed like todo.ts
interface WorkingMemory {
  keyFacts: string[];           // User stated facts: "My API key is..."
  currentGoals: string[];       // What we're working on right now
  temporaryContext: string[];   // "We're in the middle of refactoring..."
  lastNMessages: number;        // Keep last 10-20 message summaries
}
```

**When it's used**: Injected into the system prompt for the current session only.
**Lifetime**: Session duration, forks inherit from parent.

#### 2. Episodic Memory (Cross-Session, Recent)

```typescript
interface EpisodicMemory {
  sessionId: string;
  timestamp: string;
  cwd: string;
  summary: string;              // LLM-generated 1-2 paragraph summary
  keyTopics: string[];          // Extracted topics
  actionItems: string[];        // Things planned/started
  outcomes: string[];           // What was completed
}
```

**Storage**: `~/.pi/memory/episodes/<session-id>.json`

**When it's used**: 
- On `session_start`, extension presents a friendly greeting and asks if user wants to work with recent projects (shows 2-3 most relevant options)
- Create a `memory-recall` skill triggered by recall keywords ("remember", "recall", "like with", "similar to", "previous work", etc.)
- When triggered, pulls top 2-3 relevant episodic memories into context
- Summaries are brief, concise, and relevant (1-2 sentences max)

**Generation**: 
- Triggered automatically at session end via `pi -p` background process
- LLM call with session transcript generates brief summary
- User shouldn't notice this runs

#### 3. Semantic Memory (Long-term, Structured)

```typescript
interface SemanticMemory {
  // Stored as markdown files, user-editable
  themes: "themes.md";         // Recurring topics, interests
  preferences: "preferences.md"; // User preferences (coding style, etc.)
  projects: "projects/";         // Per-project knowledge
  relationships: "people.md";   // People, orgs mentioned
}
```

**Storage**: `~/.pi/memory/semantic/*.md`

**When it's used**:
- On session start, load relevant semantic memory based on cwd
- Injected into system prompt

**Update Mechanism**:
- **Self-organizing**: Session summaries and semantic consolidation triggered automatically at session end via `pi -p` background process
- `/consolidate` command available for manual trigger (rarely needed)
- Maintains only 4-5 most recent episodic memories; older ones folded into semantic memory progressively

---

## Implementation Approaches

### Approach A: Pure Extension (Recommended)

**How it works**:
1. Extension registers `memory` tool for LLM to record key facts
2. Extension registers `/memory` command for user to view/edit
3. Extension registers `/consolidate` command for manual consolidation
4. Create `memory-recall` skill that triggers on recall keywords ("remember", "recall", "like with")
5. On `session_start`, extension:
   - Loads working memory from session (reconstruct from tool results)
   - Shows friendly greeting with 2-3 recent project options
   - Only loads semantic memory relevant to cwd (no auto episodic injection)
6. On session end, triggers `pi -p` background process that:
   - Generates brief episodic summary
   - Runs semantic consolidation (merges similar memories, updates themes)
   - Prunes episodic buffer to keep only 4-5 most recent
7. When recall skill triggers:
   - Searches episodic memories
   - Pulls top 2-3 relevant projects into context

**Strengths**:
- Pure Pi extension - no core changes needed
- Uses existing session/tool infrastructure
- Branch-aware for working memory
- User can edit semantic memory directly (markdown files)
- Automatic background processing at session end
- Recall on-demand via skill + keywords

**Weaknesses**:
- No complex querying (use skill + keywords instead)
- Requires background process for summarization

### Approach B: Extension + Search Capability

**How it works**:
Same as Approach A, but also:
- Additional `recall` tool allows LLM to search: "What did I do with React last week?"
- Plain text markdown files for semantic storage (no database needed)
- Simple keyword + date filtering for search

**Strengths**:
- Queryable memory - LLM can explore past sessions
- Plain text markdown keeps overhead low
- More scalable than loading all into prompt

**Weaknesses**:
- Simple text search (no embeddings/semantic similarity)

---

## Recommended Implementation: Approach A (Pure Extension)

### File Structure

```
~/.pi/agent/extensions/memory.ts          # Extension code
~/.pi/memory/episodes/                      # Session summaries
~/.pi/memory/semantic/themes.md             # Recurring topics
~/.pi/memory/semantic/preferences.md        # User preferences  
~/.pi/memory/semantic/projects/             # Project-specific knowledge
~/.pi/memory/semantic/people.md             # People/orgs
```

### Extension Capabilities

**Skill (triggered by keywords)**:
- `memory-recall` - Triggered by recall keywords ("remember", "recall", "like with", "similar to", "previous work"). Searches episodic memories and adds top 2-3 relevant summaries to context.

**Tools (LLM-callable)**:
1. `memory_working_add({type: "fact"|"goal"|"context", content: string})` - Add to working memory
2. `memory_working_clear()` - Clear working memory
3. `memory_episodic_summarize()` - Trigger episodic summary now (rarely needed - auto at session end)
4. `memory_semantic_suggest({section: string, content: string})` - Suggest addition to semantic memory
5. `memory_recall({query: string})` - Search past sessions for relevant context

**Commands (user-callable)**:
1. `/memory` - Show current memory state (working + recent episodic options)
2. `/memory-edit [section]` - Open semantic memory file in editor
3. `/memory-forget [pattern]` - Remove matching memories
4. `/consolidate` - Manually trigger consolidation of episodic → semantic

### System Prompt Injection

**On Session Start:**
```
## Working Memory (Current Session)
- Current goal: {goal}
- Key facts: {facts}

## Recent Projects (Available on request)
1. {project} - {brief summary}
2. {project} - {brief summary}
3. {project} - {brief summary}

"Say 'recall {project}' or use 'remember/like with/previous work' to load details."
```

**When Recall Skill Triggers:**
```
## Relevant Past Sessions (Episodic)
- {timestamp} ({project}): {brief summary}
- {timestamp} ({project}): {brief summary}
```

**Background Knowledge (Semantic):**
```
{content from ~/.pi/memory/semantic/projects/{current-project}.md}
```

---

## Configuration Options

The following can be configured in `~/.pi/settings.json` or via commands:

| Setting | Default | Description |
|---------|---------|-------------|
| `memory.episodes.keep` | 4-5 | Episodic memory buffer size (older ones consolidated) |
| `memory.working.maxItems` | 20 | Max working memory entries per session |
| `memory.recall.keywords` | `["remember", "recall", "like with", "previous work", "similar to"]` | Keywords that trigger recall skill |
| `memory.autoSummarize` | `true` | Auto-generate summary at session end |

---

## Open Design Decisions

1. **Working Memory Inheritance**: Should forks inherit working memory?
   - Option 1: Yes (inherited)
   - Option 2: No (fork starts fresh)  
   - Option 3: Selective (some keys inherited, marked as "persistent")

2. **Episodic Query Method**: For the recall tool, how should search work?
   - Option A: Simple keyword matching on summaries
   - Option B: Date range filtering (e.g., "last week")
   - Option C: Combined keyword + date + project filter

---

## Implementation Phases

### Phase 1: Working Memory (MVP) [DONE:1]
- [x] Create `memory` extension scaffold
- [x] Implement working memory storage (tool result details)
- [x] Add system prompt injection on session start
- [x] Add `/memory` command to view working memory
- [x] Add `memory_working` tool
- [x] Add `memory_recall` tool for searching
- [x] Create `memory-recall` skill with trigger keywords

### Phase 2: Episodic Memory [DONE:2]
- [x] Add episodic memory storage (JSON files in ~/.pi/memory/episodes/)
- [x] Add session-end background processor (session-end-processor.js)
- [x] Episodic summaries auto-generated at session end
- [x] Create `memory-recall` skill with trigger keywords
- [x] Add `memory_recall` tool for LLM search
- [x] Consolidation prunes to 4-5 episodes, folds older into semantic
- [x] `/consolidate` command for manual trigger

### Phase 3: Semantic Memory
- [x] Create semantic memory markdown files (created structure in ~/.pi/memory/semantic/)
- [x] Add project-scoped semantic loading (projects/*.md loaded based on cwd)
- [x] Add `memory_semantic_suggest` tool (via session-end-processor auto-consolidation)
- [x] Auto-extract themes (background consolidation in session-end-processor)

---

## Strengths of This Approach

1. **Fits Pi's Architecture**: Uses existing extension system, no core changes
2. **User Controllable**: User can clear working memory, trigger `/consolidate`
3. **Transparent**: Memory is visible and manageable
4. **Branch-Friendly**: Working memory respects Pi's branching model
5. **Incremental**: Can build MVP with just working memory
6. **Background Processing**: Session end uses `pi -p` (invisible to user)
7. **On-Demand Recall**: Skill-based recall with keywords only loads relevant context
8. **Self-Organizing**: Limited episodic buffer (4-5) auto-consolidates to semantic memory

## Weaknesses

1. **Simple Search**: Plain text search without embeddings
2. **Background Dependency**: Uses `pi -p` at session end (invisible to user)
3. **Limited Episodic Buffer**: Only 4-5 recent episodes available (older consolidated to semantic)

## Alternatives Considered

- **SQLite Database**: Rejected - plain text markdown is sufficient and lower overhead
- **Vector DB + Embeddings**: Would enable semantic similarity, but too heavyweight for Pi
- **Single Large Memory File**: Simpler, but no branch awareness
