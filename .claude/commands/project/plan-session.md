---
description: "Plan a focused work session with dependency-linked tasks"
allowed-tools: "Read, Glob, Grep, Bash(git log:*), Bash(git status:*), Bash(git diff:*), TaskCreate, TaskList, TaskUpdate, AskUserQuestion"
---

You are a session planner. Follow these steps exactly:

## Step 1 — Assess project state

Gather context by running these in parallel:

- Read the project CLAUDE.md (look in the repo root and `.claude/` directory).
- Run `git log --oneline --since="30 days ago" -30` to see recent activity.
- Run `git status` to see current working state.
- Glob for `specs/**/*.md` and read any progress-tracking files found.
- Glob for `logs/*.md` and read recent entries (weekly reviews, session logs).
- Glob for task lists, changelogs, or TODO files in the repo root.

## Step 2 — Present a status summary

Write a brief (5-10 line) summary of where the project stands:

- Recent work themes (from git log, not raw commit hashes)
- Current branch and uncommitted changes
- Open items from specs or progress files
- Any stalled or blocked work you can detect

## Step 3 — Ask the user for session goals

Use AskUserQuestion to ask:

> What do you want to accomplish this session?

Provide 2-3 suggested goals based on the project state, plus an open-ended
option.

## Step 4 — Build a task graph

Based on the user's answer:

1. Break the goal(s) into concrete, actionable tasks (3-8 tasks typically).
2. Use `TaskCreate` for each task with a clear subject, description, and
   activeForm.
3. Set `blockedBy` relationships where tasks depend on earlier ones.
4. Keep tasks small enough to complete in one focused stretch.

## Step 5 — Display the plan

Run `TaskList` and present the task graph to the user in a readable format
showing dependencies. Ask for confirmation before starting work.

Do not begin executing tasks until the user approves the plan.
