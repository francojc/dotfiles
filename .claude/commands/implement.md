---
description: Execute an implementation plan directly, pausing only at key decision points
argument-hint: <plan file path or inline plan text>
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, LS, Task, AskUserQuestion
---

# Implement plan

Execute the plan provided via `$ARGUMENTS`. Skip exploration and planning loops — go straight to execution with checkpoints at decision points.

## Phase 1 — Parse the plan

1. **Read the plan**: If `$ARGUMENTS` is a file path that exists, read it with the Read tool. Otherwise treat `$ARGUMENTS` as the plan text itself.
2. **Break into steps**: Extract discrete, ordered implementation steps from the plan.
3. **Flag decision points**: Mark any step as `[DECISION NEEDED: reason]` when it matches these heuristics:
   - The plan uses "could", "might", "optionally", or presents alternatives
   - The step deletes files, drops data, or changes public APIs
   - The step affects shared state (pushing, deploying, publishing)
   - The implementation approach is underspecified (e.g., "add error handling" without saying what kind)
4. **Present step summary**: Print a numbered list of all steps. Annotate decision points with their flag. Example:

```
1. Update compliance language in sections/aims.md
2. [DECISION NEEDED: two citation formats mentioned] Add references to lit-review.md
3. Run /refine pass on edited sections
```

## Phase 2 — Resolve decision points

1. For each flagged step, use `AskUserQuestion` to present concrete options and get the user's choice. Batch related decisions (max 4 questions per ask).
2. After all decisions resolve, print the finalized execution sequence — no flags remaining, each step fully specified.
3. If there are zero decision points, skip this phase and say so.

## Phase 3 — Execute and verify

Work through steps sequentially. For each step:

1. **Apply**: Make the edits, create files, or run commands.
2. **Verify**: Re-read modified files to confirm correctness. Run build or test commands when the plan specifies them or when they are available in the project.
3. **Self-correct once**: If verification fails, attempt one fix. If that also fails, use `AskUserQuestion` to ask the user how to proceed before continuing.
4. **Report**: After each step, print a one-line status: step number, file(s) touched, pass/fail.

After all steps complete, print a summary table:

```
| # | File(s) changed          | What changed                    | Status |
|---|--------------------------|----------------------------------|--------|
| 1 | sections/aims.md         | Updated compliance language      | pass   |
| 2 | sections/lit-review.md   | Added references (APA format)    | pass   |
| 3 | providers/gemini.zsh     | Fixed JSON response parsing      | pass   |
| 4 | flake.nix                | Added platform-conditional pkg   | pass   |
```

## Rules

- Do not enter plan mode or re-explore code that the plan already specifies. Execute directly.
- Do not ask for confirmation on non-decision-point steps. Just do them.
- If the plan references files you haven't read, read them immediately before editing — but do not wander beyond what the step requires.
- If a step is trivial (single edit, clear target), execute it without commentary beyond the status line.
- For verification, prefer re-reading modified files and running project test suites (e.g., `cargo check`, `./test-api.sh`). Do not run `quarto render`, `nix build`, or `nix-darwin rebuild` — the user handles those builds manually. Report what you verified and flag anything the user should build-check themselves.
- If verification fails, read the full error output and fix the root cause — do not iterate on the same broken approach more than twice. Pivot to a different strategy.
