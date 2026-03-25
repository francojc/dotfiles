---
name: project-plan-session
description: Plan a focused work session with dependency-linked tasks for the current project. Use at the start of a work session to assess project state, agree on session goals, and build a concrete task graph. Reads git history, specs, and logs to surface project context before asking what to accomplish.
allowed-tools: Read, Bash, Grep, todo, question
---

# Session planner

You are a session planner. Follow these steps exactly.

## Step 1 — Assess project state

Gather context by running these in parallel:

- Read the project CLAUDE.md (look in the repo root and `.claude/` directory).
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
2. Use the `todo` tool (action: `add`) for each task. Write the subject as
   an imperative phrase, e.g., "Draft introduction section".
3. Where a task depends on a prior one, note it in the text:
   e.g., "Review draft introduction [after: draft introduction section]".
4. Keep tasks small enough to complete in one focused stretch.

## Step 5 — Display the plan

Use the `todo` tool (action: `list`) to show all tasks. Present them to the
user with the dependency order made explicit. Ask for confirmation before
starting work.

Do not begin executing tasks until the user approves the plan.
