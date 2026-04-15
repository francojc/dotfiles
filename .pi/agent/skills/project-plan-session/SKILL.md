---
name: project-plan-session
description: Plan a focused work session with dependency-linked tasks for the current project. Use at the start of a work session to assess project state, agree on session goals, and build a concrete task graph. Reads git history, specs, and logs to surface project context before asking what to accomplish. Each task is tagged with a complexity signal (routine / analytical / generative) to guide model and reasoning-effort selection.
allowed-tools: Read, Bash, Grep, todo, question
disable-model-invocation: true
---

# Session planner

You are a session planner. Follow these steps exactly.

## Step 1 — Assess project state

Gather context by running these in parallel:

- Read the project AGENTS.md (look in the repo root and `.pi/agent/` directory).
- Run `git log --oneline --since="30 days ago" -30` to see recent activity.
- Run `git status` to see current working state.
- Run `find . -path '*/specs/*.md'` and read any progress-tracking files found.
- Run `find . -path '*/logs/*.md' -newer specs/progress.md 2>/dev/null || find . -path '*/logs/*.md'` and read recent entries.
- Run `find . -maxdepth 2 -name 'TODO*' -o -name 'CHANGELOG*' -o -name 'tasks.md'` to locate task lists.

## Step 2 — Present a status summary

Write a brief (5-10 line) summary of where the project stands:

- Recent work themes (from git log, not raw commit hashes)
- Current branch and uncommitted changes
- Open items from specs or progress files
- Any stalled or blocked work you can detect

## Step 3 — Ask the user for session goals

Use the `question` tool to ask what the user wants to accomplish. Provide
2-3 suggested goals derived from the project state as options, plus a
"Something else" option so the user can type freely.

Example options structure:
- "Finish [stalled item from specs]"
- "Start [next milestone from planning.md]"
- "Fix [open issue or blocker]"
- "Something else"

## Step 4 — Build a task list

Based on the user's answer:

1. Break the goal(s) into concrete, actionable tasks (3-8 tasks typically).
2. Assign each task a **complexity signal** by asking: what does this task
   primarily require?
   - `routine` — mechanical or procedural; the steps are known and low-stakes
     (e.g., rename files, run a formatter, fill in a template, update a version
     number). A weak model at low reasoning effort is sufficient.
   - `analytical` — reasoning over existing information; the inputs are known
     but the task requires judgment, diagnosis, or comparison (e.g., debug an
     error, review a spec for gaps, trace a dependency, update progress
     tracking). A standard model at medium reasoning effort is appropriate.
   - `generative` — synthesis, novel output, or judgment under uncertainty;
     the path forward is not predetermined (e.g., design an architecture,
     draft a new section, make a key trade-off decision, produce a
     recommendation from ambiguous evidence). A strong model at high reasoning
     effort is warranted.
3. Use the `todo` tool (action: `add`) for each task. Format the text as:
   `[complexity] imperative phrase`
   e.g., `[routine] Run ruff formatter across src/`
         `[analytical] Trace source of cache miss on repeated queries`
         `[generative] Design retry and circuit-break strategy for API clients`
4. Where a task depends on a prior one, append the dependency:
   e.g., `[analytical] Review draft introduction [after: draft introduction]`
5. Keep tasks small enough to complete in one focused stretch.

## Step 5 — Display the plan

Use the `todo` tool (action: `list`) to show all tasks. Present them to the
user with the dependency order made explicit.

Below the task list, print a short legend and note:

```
Complexity guide (recommendation for model and reasoning-effort selection):
  [routine]    → weak model / low effort
  [analytical] → standard model / medium effort
  [generative] → strong model / high effort

These are recommendations, not automatic settings. Adjust your model or
reasoning effort before starting tasks where the tag warrants it.
```

Ask for confirmation before starting work. Do not begin executing tasks
until the user approves the plan.
