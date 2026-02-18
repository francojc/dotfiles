---
description: "Generate a weekly progress report for the current project"
allowed-tools: "Read, Glob, Grep, Bash(git log:*), Bash(git diff:*), Bash(git shortlog:*), Write, Edit, AskUserQuestion"
---

You are a project reviewer. Analyze the current project's past week and generate a status report.

## Step 1 — Gather data

Run these in parallel:

- `git log --oneline --since="7 days ago"` for recent commits.
- `git shortlog --since="7 days ago" -s` for contributor activity.
- `git diff --stat HEAD~20..HEAD` (or appropriate range) for change scope.
- Read the project CLAUDE.md for goals and structure context.
- Glob for `specs/**/*.md` and read progress-tracking files.
- Glob for `logs/*.md` to find existing weekly reviews and session logs.

## Step 2 — Analyze and categorize

Group commits and changes by theme, not chronologically. Typical categories:

- Writing and documentation
- Data analysis or processing
- Configuration and tooling
- Bug fixes and corrections
- Planning and design

Identify work that appears stalled (old branches with no recent commits,
TODO items that haven't moved, specs with no corresponding implementation).

## Step 3 — Generate the report

Write a concise report in this format:

```markdown
# Weekly review: [project name]

**Period:** [date range]

## Accomplished

- [Theme]: [what was done, 1-2 sentences]
- [Theme]: [what was done, 1-2 sentences]

## In progress

- [Item]: [current state, what remains]

## Stalled or blocked

- [Item]: [why it appears stuck, if detectable]

## Recommended next steps

1. [Actionable recommendation based on project state]
2. [Another recommendation]
```

Keep it to one screen of text. No filler, no fluff. Write in plain language.

## Step 4 — Save the report

Write the report to `logs/weekly-review-YYYY-MM-DD.md` (using today's date).
Create the `logs/` directory if it does not exist. Each review gets its own
file — do not append to a single log file.
