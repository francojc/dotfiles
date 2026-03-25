---
name: project-status
description: Generate a comprehensive project status report analyzing git activity, progress against planned milestones, and current state across research, teaching, grant, service, or development projects. Use to get a quick health check on a project or before a meeting, planning session, or weekly review.
allowed-tools: Read, Grep, Bash
---

# Project status report

Generate a comprehensive project status report by analyzing recent activity,
progress against goals, and current state.

## Step 1 — Project detection and context

Run these in parallel:

- Read CLAUDE.md (check repo root and `.claude/` directory).
- Read `specs/planning.md` to understand original objectives and timeline.
- Read `specs/progress.md` for latest status updates.
- `find . -path '*/logs/*.md'` and read recent weekly reviews and session logs.
- Identify project type from CLAUDE.md or specs/ structure
  (research / teaching / grant / service / development).

## Step 2 — Git activity analysis

```bash
# Recent commits (last 30 days)
git log --oneline --since="30 days ago" --author-date-order

# File change scope
git diff --stat HEAD~30..HEAD

# Contributor activity
git shortlog --since="30 days ago" --numbered --summary
```

Analyze:

- Key development themes from commit messages (not raw hashes)
- File change patterns and focus areas
- Branch structure and active work
- Collaboration activity

## Step 3 — Progress review

Compare current state against planned milestones:

- Extract milestone information from `specs/planning.md`
- Compare planned vs. actual completion dates
- Identify completed vs. pending tasks
- Flag overdue or at-risk milestones
- Note any stalled areas (items with no recent activity)

Focus areas by project type:

- **Research:** Literature review, data collection, analysis, writing phases
- **Teaching:** Course development stages, material creation, assessment design
- **Grant:** Proposal sections, budget development, submission timeline
- **Service:** Committee deliverables, meeting schedules, governance tasks
- **Development:** Feature development, testing phases, deployment milestones

## Step 4 — Generate the report

Output a structured status report:

```
PROJECT STATUS REPORT
Generated: [current date]

Project: [name from CLAUDE.md or directory]
Type: [research / teaching / grant / service / development]
Phase: [current project phase]

RECENT ACTIVITY (last 30 days)
- [N] commits by [N] contributors
- Key focus: [primary development themes]
- Notable: [significant changes or milestones]

PROGRESS SUMMARY
- Timeline status: [on track / behind / ahead]
- Milestones completed: [list]
- Milestones pending: [list with target dates]
- At-risk items: [any overdue or stalled items]

CURRENT STATE
- Active focus: [primary areas of current work]
- Open tasks: [summary of pending items from specs]
- Blockers: [anything preventing progress, if detectable]

RECOMMENDATIONS
- Immediate (next 2 weeks): [2-3 specific actions]
- Strategic: [longer-term adjustments if needed]

RISKS
- [Any identified risks and suggested mitigations]
```

Keep the report concise — one to two screens. Focus on what matters for
decision-making. No filler.
