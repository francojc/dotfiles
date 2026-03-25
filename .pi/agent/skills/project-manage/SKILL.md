---
name: project-manage
description: "Unified project management interface for research, teaching, grant, service, and development projects. Supports four operations: update (sync docs and get AI recommendations), track (milestones, tasks, deadlines), address (analyze and fix a GitHub issue), and create (generate specs/ documentation). Use when managing ongoing project work in a structured project directory."
allowed-tools: Read, Grep, Edit, Bash, Write, question, todo
---

# Project management

Unified project management for academic and professional workflows.

## Step 1 — Determine the operation

Check the user's message for a sub-command:

| Sub-command | Aliases | Purpose |
|-------------|---------|---------|
| `update` | `sync` | Sync docs and get AI-powered next-step recommendations |
| `track` | `progress` | Track milestones, tasks, and deadlines |
| `address` | `issue` | Analyze and fix a GitHub issue |
| `create` | `new`, `spec` | Generate specs/ documentation |

If no sub-command is provided, run `update` by default.

If the sub-command is unrecognized, list the available options and ask the
user to clarify using the `question` tool.

## Step 2 — Validate project context

Check that the current directory looks like a managed project:

- Is there a `CLAUDE.md` or `.claude/CLAUDE.md`?
- Is there a `specs/` directory?
- Is there a `.git` directory?

If none of these exist, warn the user that this doesn't appear to be a
project directory and suggest running `project-setup` first.

---

## update — Synchronize documentation and get recommendations

### Documentation sync process

1. **Current state analysis**
   - Scan project files for recent changes
   - Review git history: `git log --oneline --since="30 days ago"`
   - Assess completeness and freshness of existing documentation
   - Identify gaps or outdated information

2. **specs/ updates**
   - Update `specs/progress.md` with current status and recent accomplishments
   - Sync `specs/implementation.md` with actual methodologies and procedures
   - Revise `specs/planning.md` if objectives or timelines have shifted
   - Ensure consistency across all documentation files

3. **CLAUDE.md maintenance**
   - Verify the project description still accurately reflects current work
   - Update methodology sections based on implementation changes
   - Refresh timeline and milestone information

4. **Context integration**
   When editing documentation, apply project-type-specific standards:
   - **Research:** Align with research lifecycle and methodology
   - **Teaching:** Integrate pedagogical best practices and course design
   - **Grant:** Ensure compliance with proposal requirements
   - **Service:** Maintain institutional alignment and governance standards
   - **Development:** Follow software development lifecycle best practices

### AI-powered recommendations

Generate project-type-specific guidance after syncing:

- **Research:** Literature integration, analysis approaches, dissemination
- **Teaching:** Pedagogical enhancements, assessment alignment, accessibility
- **Grant:** Proposal strengthening, compliance, collaboration opportunities
- **Service:** Efficiency improvements, stakeholder engagement, deliverables
- **Development:** Architecture decisions, testing strategy, deployment

---

## track — Track progress, milestones, and tasks

### Progress analysis

1. Read `specs/planning.md` to understand project objectives and timeline
2. Parse `specs/progress.md` for current status and completed milestones
3. Read recent `logs/` entries: `find . -path '*/logs/*.md'`
4. Analyze git commit history for development activity patterns
5. Identify areas of high productivity vs. areas needing attention

### Milestone tracking

- Extract milestone information from planning documents
- Compare planned vs. actual completion dates
- Calculate progress for major project phases
- Flag overdue or at-risk milestones

### Task management

Use the `todo` tool to surface and manage active tasks:

- Use `todo` (action: `list`) to show the current task list
- Use `todo` (action: `add`) to register newly identified tasks
- Use `todo` (action: `toggle`) to mark completed tasks done

### Output

Present a prioritized view of:

1. Overdue and at-risk milestones (with context)
2. Active tasks from the `todo` list
3. Recommended priority order for the next two weeks
4. Any blockers that need resolution

---

## address — Analyze and fix a GitHub issue

The issue number or identifier appears in the user's message
(e.g., `address 123` or `address bug-login`).

If no issue is specified, use the `question` tool to ask for one.

### Issue workflow

1. **Issue analysis**
   - Run `gh issue view <number>` to get issue details
   - Parse description, labels, and comments
   - Identify issue type (bug, feature, enhancement, documentation)
   - Extract reproduction steps and expected behavior

2. **Codebase investigation**
   - Search relevant files based on issue description
   - Identify affected components and dependencies
   - Review recent changes that might be related
   - Analyze related tests and documentation

3. **Solution implementation**
   - Implement necessary changes to address the issue
   - Follow project coding standards from CLAUDE.md
   - Add or update tests to verify the fix
   - Update documentation if needed

4. **Quality assurance**
   - Run existing tests to check for regressions
   - Test the fix against the issue's reproduction steps
   - Verify edge cases and error handling

5. **Submission**
   - Create a descriptive commit message linking to the issue
   - Push changes to a feature branch
   - Create a pull request with detailed description
   - Link the PR to the original issue for automatic closure

---

## create — Generate specs/ documentation

The document type appears in the user's message
(e.g., `create planning` or `create specs`).

If no type is specified, use the `question` tool to ask:

> Which document(s) do you want to create?

With options:
- planning — project objectives and timeline
- progress — milestone and task tracking
- implementation — methodology and technical details
- specs — complete specs/ directory (all three)

### Creation process

1. **Project analysis**
   - Read existing README.md and CLAUDE.md
   - Determine project type (research / teaching / grant / service / development)
   - Identify documentation gaps

2. **Content generation**
   - Generate the requested document(s) with content from project context
   - Use the project's own goals, questions, and methodology
   - Replace generic placeholders with specific, contextually accurate content
   - Ensure consistency with existing documentation

3. **Write files**
   - Create `specs/` directory if it does not exist
   - Write requested files to `specs/<type>.md`
   - Confirm each file created

Do not overwrite existing files without asking first.
