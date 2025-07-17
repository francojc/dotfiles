---
allowed-tools: Read, Grep, Edit, Bash, LS
description: |
  Analyze current project state including git history, progress tracking, and academic milestones with next-step recommendations.
---

Generate a comprehensive project status report analyzing recent activity, progress against goals, and current state.

## Status Analysis Process

### 1. Project Detection and Context

- Identify project type from existing CLAUDE.md or specs/ structure
- Determine academic context (research/teaching/grant/service)
- Assess project phase and timeline

### 2. Git Analysis and Recent Activity

- Analyze recent commits (last 30 days) for development patterns
- Identify key contributors and collaboration activity  
- Review file change patterns and development focus areas
- Assess branch structure and development workflow

### 3. Progress Review Against Goals

- Read specs/planning.md to understand original objectives
- Compare current state against planned milestones
- Identify completed vs. pending tasks
- Calculate progress percentages where applicable

### 4. Current State Assessment

- Review specs/progress.md for latest status updates
- Analyze project directory structure and organization
- Identify active areas of development
- Assess resource utilization and timeline adherence

### 5. Academic Milestone Tracking

- **Research Projects:** Literature review, data collection, analysis, writing phases
- **Teaching Projects:** Course development, content creation, assessment design
- **Grant Projects:** Proposal sections, budget development, submission timeline
- **Service Projects:** Committee deliverables, meeting schedules, governance tasks

## Report Generation

### Git Activity Summary

```bash
# Recent commit analysis
git log --oneline --since="30 days ago" --author-date-order

# File change patterns  
git diff --stat HEAD~30..HEAD

# Contributor activity
git shortlog --since="30 days ago" --numbered --summary
```

### Progress Metrics

- **Timeline Adherence:** [On track/Behind/Ahead] - [X]% complete
- **Milestone Achievement:** [N] of [M] milestones completed
- **Recent Productivity:** [N] commits, [N] files changed in last 30 days
- **Collaboration Level:** [N] contributors active

### Current Focus Areas

Based on recent git activity and file changes, identify:
- Primary areas of active development
- Emerging themes or new directions
- Potential bottlenecks or stalled areas
- Collaboration patterns and team dynamics

### Academic Context Assessment

- **Research:** Progress on data collection, analysis, writing
- **Teaching:** Course material development, assessment creation
- **Grant:** Proposal component completion, deadline tracking
- **Service:** Committee work progress, meeting preparation

## Recommendations and Next Steps

### Immediate Priorities (Next 2 Weeks)

Based on analysis, suggest 2-3 specific actions to maintain momentum

### Strategic Recommendations

- Timeline adjustments needed
- Resource reallocation suggestions  
- Collaboration opportunities
- Risk mitigation for identified issues

### Academic Best Practices

- Documentation improvements needed
- Methodology refinements suggested
- Quality assurance checkpoints
- Dissemination opportunities

## Output Format

**PROJECT STATUS REPORT**
Generated: [Current Date]

**Project:** [Name from CLAUDE.md or directory]
**Type:** [Research/Teaching/Grant/Service]
**Phase:** [Current project phase]

**RECENT ACTIVITY (Last 30 Days)**
- [N] commits by [N] contributors
- [Key areas of development]
- [Notable changes or milestones]

**PROGRESS SUMMARY**
- Overall Progress: [X]% complete
- Timeline Status: [On track/Behind/Ahead]
- Recent Milestones: [List completed items]
- Pending Milestones: [List upcoming items]

**CURRENT STATE**
- Active Focus: [Primary development areas]
- Team Activity: [Collaboration patterns]
- Resource Status: [Utilization assessment]

**RECOMMENDATIONS**
- Next Steps: [2-3 immediate actions]
- Strategic: [Longer-term suggestions]
- Academic: [Methodology/documentation improvements]

**RISK FACTORS**
- [Any identified risks or concerns]
- [Mitigation suggestions]

Use this analysis to inform project planning and maintain academic rigor while ensuring timely progress toward objectives.
