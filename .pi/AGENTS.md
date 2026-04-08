# Pi Memory System Fixes — Project Scope

## Overview

Bug-fix and polish sprint for the three-tier memory system (`~/.pi/agent/extensions/memory.ts` + `session-end-processor.mjs`). The system currently works but has 7 identified issues ranging from dead code to efficiency problems to missing features.

## Success Criteria

✅ **All 9 steps completed and verified** (see `specs/implementation.md`)

1. Extension loads without errors
2. `/memory` command shows working memory state
3. `/consolidate` command actually triggers consolidation
4. Working memory enforces 20-item cap per type (drops oldest on overflow)
5. `memory-recall` skill loads and LLM uses it correctly
6. Session processor generates episodes with `context` field (first user message)
7. Dead code removed from `memory.ts`
8. Semantic file size cap enforced (last 50 entries per project)
9. All documentation updated

## Files in Scope

- `~/.pi/agent/extensions/memory.ts` — main extension
- `~/.pi/agent/session-end-processor.mjs` — session processor
- `~/.pi/agent/skills/memory-recall/SKILL.md` — skill definition
- `~/.pi/agent/memory/README.md` — documentation

## Implementation Plan

See `specs/implementation.md` for detailed audit findings, issue explanations, and step-by-step fixes.

## Effort Estimate

**Medium complexity**:
- Steps 1–3, 8: Documentation/config fixes (30 min total)
- Steps 4–7: Code changes (45 min total)
- Step 9: Testing & verification (30 min)

**Total**: ~2 hours of focused work

## Notes

- No external dependencies — purely internal Pi extension cleanup
- No breaking changes — all fixes are backwards-compatible
- No impact on daily Pi usage during development
