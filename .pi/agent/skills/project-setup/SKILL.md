---
name: project-setup
description: Scaffold a complete project structure for research, teaching, grant, service, or development projects. Creates AGENTS.md, specs/ (planning, progress, implementation), logs/, flake.nix, and .gitignore from context-aware templates. Requires a project description document (README.md or equivalent) before running. Supports fork-contribution mode for development projects.
allowed-tools: Read, Grep, Edit, Bash, Write, question
disable-model-invocation: true
---

# Project setup

Scaffold a complete project structure with documentation, planning files,
and development environment from a context-aware template.

## Prerequisites

This skill requires a project description document before running. Check for
one of: `README.md`, `PROJECT.md`, `CONCEPT.md`, or `PROPOSAL.md`.

If none exists, stop and tell the user:

> Please create a project description file first (README.md is recommended).
> It should include: project overview, objectives or research questions,
> expected outcomes, and timeline or scope. A meaningful description produces
> better scaffolding.

If the file exists but is fewer than 5 lines, stop and tell the user to add
more detail before running setup.

## Step 1 — Read project description and get type

Read the project description document (README.md or equivalent) in full.

Then check the user's message for the project type and optional project name.

**Supported types:** `research`, `teaching`, `grant`, `service`, `development`

If the type is not in the message, use the `question` tool to ask:

> What type of project is this?

With options:
- research — corpus, experiment, analysis, publication
- teaching — course design, curriculum, educational materials
- grant — funding proposal, compliance tracking
- service — committee work, governance, institutional service
- development — software, tool, API, library

If no project name is given, try to extract the name from the first heading
of the description file. Fall back to the current directory name.

## Step 2 — Confirm project details

After reading the description, present a brief summary of what you understood
and confirm with the user before generating anything. Use the `question` tool:

> I'll set up a **[type]** project named **"[name]"** with this focus:
> [1-sentence summary from the description].
>
> Proceed?

With options: "Yes, proceed" / "No, let me adjust the description first"

## Step 3 — Fork detection (development projects only)

When the type is `development`, check for fork indicators:

- Is there an existing root `AGENTS.md`?
- Does a git remote named `upstream` exist (`git remote get-url upstream`)?
- Does the `origin` remote URL not contain the user's usual identity?

If any indicators are found, use the `question` tool:

> Fork indicators detected: [list signals found].
> Is this a fork you plan to contribute to upstream?

With options:
- Yes — fork mode: infrastructure files stay local, invisible to git
- No — standard setup

If no indicators are found, still ask as part of the development setup flow:

> Will you be contributing upstream from this repo?

With options:
- No — standard setup (recommended)
- Yes — fork mode

Set `FORK_MODE = true` if the user selects fork mode.

## Step 4 — Create directory structure

```bash
mkdir -p specs logs
```

**Fork mode:** After creating them, add both to `.git/info/exclude` so they
are invisible to git without modifying `.gitignore`:

```
# project-setup fork mode — local planning infrastructure
specs/
logs/
```

## Step 5 — Generate specs/ files from templates

Templates are located relative to this skill's directory:

```
templates/specs/<type>-planning.md
templates/specs/<type>-progress.md
templates/specs/<type>-implementation.md
```

For each file:

1. Read the template using its path relative to this skill's directory.
2. Replace `{PROJECT_NAME}` with the project name.
3. Replace `{DATE}` with today's date (YYYY-MM-DD).
4. Replace `{STATUS}` with `Planning`.
5. **Enrich the content** — go beyond placeholder replacement. Use the
   project description to populate sections with actual content:
   - Research questions, objectives, and hypotheses (not generic placeholders)
   - Specific methods or pedagogical approaches from the description
   - Realistic timelines based on the project scope
   - Project-specific risks and mitigation strategies
6. Write the enriched file to `specs/<type>.md`.

Do not overwrite existing specs files without asking first.

## Step 6 — Generate AGENTS.md

**Standard mode:** Write to `AGENTS.md` in the repo root.

**Fork mode:** Write to `.pi/agent/AGENTS.md` (create `.pi/agent/` if needed).
A fork-mode AGENTS.md is additive — it documents the contribution scope,
build/test commands, and development workflow. It does not duplicate any
upstream root AGENTS.md content.

### AGENTS.md sections by project type

**Research:**
- Research question(s) and significance
- Methodology and data collection overview
- Analysis approach and tools
- Publication and dissemination strategy
- Timeline and milestones
- Ethical considerations and IRB status
- Directory structure and file conventions
- How to use Claude effectively on this project

**Teaching:**
- Course overview and learning outcomes
- Pedagogical approach and teaching philosophy
- Assessment strategy
- Technology integration
- Accessibility and inclusive design considerations
- Directory structure
- How to use Claude effectively on this project

**Grant:**
- Grant opportunity overview and funder information
- Proposal abstract and project concept
- Principal investigators and collaborators
- Budget and compliance requirements
- Timeline and submission plan
- Directory structure
- How to use Claude effectively on this project

**Service:**
- Committee overview, scope, and charge
- Goals, deliverables, and membership
- Meeting structure and documentation
- Communication and collaboration methods
- Directory structure
- How to use Claude effectively on this project

**Development (standard):**
- Software purpose and target users
- Architecture overview and key components
- Build, test, and run commands (exact commands)
- Language, framework, and dependency management
- Directory structure with source, test, and config locations
- Development workflow and contribution guidelines

**Development (fork mode):**
- Fork context (upstream URL, contribution scope)
- Build and test commands
- Development workflow (branch strategy, PR process)
- Areas of focus and contribution goals
- Location of local specs and logs

## Step 7 — Environment setup (standard mode only)

**Skip this step in fork mode.**

### flake.nix

If no `flake.nix` exists, read the template from `templates/flake.nix`
(relative to this skill's directory) and write it to the repo root.

### .gitignore

Append project-type-appropriate patterns to `.gitignore` (create if needed):

**Research:**
```
data/raw/participants/
data/confidential/
surveys/responses/
analysis/exploratory/
manuscripts/drafts/
reviews/peer_review/
.DS_Store
```

**Teaching:**
```
roster/personal_info/
grades/individual/
feedback/private/
exams/answers/
assignments/solutions/
videos/raw_recordings/
.DS_Store
```

**Grant:**
```
budgets/internal/
personnel/private/
reviews/confidential/
narrative/drafts/
final_submission/
.DS_Store
```

**Service:**
```
personnel_files/
evaluations/private/
executive_sessions/
minutes/drafts/
recordings/
.DS_Store
```

**Development:**
```
dist/
build/
target/
*.egg-info/
__pycache__/
node_modules/
.venv/
.env
.env.local
*.pem
credentials.json
.DS_Store
.idea/
.vscode/
*.swp
```

## Step 8 — Confirm setup completion

Report what was created:

```
✓ Project description read: README.md
✓ specs/planning.md — generated with project context
✓ specs/progress.md — generated with project context
✓ specs/implementation.md — generated with project context
✓ logs/ — ready for weekly reviews and session logs
✓ AGENTS.md — project-specific content generated
✓ flake.nix — development environment template
✓ .gitignore — project-specific patterns added
```

Or for fork mode:
```
✓ specs/ and logs/ created (excluded via .git/info/exclude)
✓ .pi/agent/AGENTS.md — fork contribution context generated
✓ No changes to .gitignore or flake.nix
✓ git status remains clean
```

Remind the user to review and customize the generated files, particularly
the specs/ content and AGENTS.md, which are starting points rather than
finished documents.
