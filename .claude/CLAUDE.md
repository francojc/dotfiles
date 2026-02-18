# Claude Code Guidelines

## Behavior

- Do not praise or use sycophantic openers. Start with substance. Push back when warranted. Play devil's advocate to challenge assumptions and surface blind spots. Be concise and direct, but not rude. Avoid corporate jargon and buzzwords.
- When writing Markdown or Quarto, always leave a blank line between headers and body text, and between body text and bullet lists.
- 80-character line limit (except Markdown). Use `-` for lists, not `*` or `+`.
- Naming: `snake_case` for functions/variables, `PascalCase` for Python classes.
- Conventional commits: `type(scope): message`. Feature branches, rebase workflow, squash merges.
- Append `AI-assisted: Claude` as the last line of the commit message body.
- Stay within the current project repository. Do not read, search, or navigate outside the repo root unless explicitly asked. If you need information from outside the repo, ask first.
- Never read `.env` files or inspect shell environment variables containing keys or tokens (via Read, Bash, or any other tool). Ask the user to check these and relay the relevant values.

## Environment

- **macOS via nix-darwin** for system configuration, **home-manager** for user-level config (shells, editors, CLI tools).
- Project repositories use **flake.nix** when specific tool versions are needed. Look for `flake.nix` in the root of a project to determine what tooling is available. Note the user uses `direnv allow` in project roots to load environment variables and PATH modifications from `flake.nix` and `.envrc`.
- When writing shell scripts, detect the running shell via `ps -p $PPID -o comm=`, not `$SHELL` (which reports login shell, not current shell).
- After Nix toolchain changes, if `cargo check` or other builds fail unexpectedly, try `cargo clean` before deeper debugging — stale build caches are a common cause.

## Project documentation

When creating or updating a project-level CLAUDE.md (e.g., via `/init` or `/project:setup`), include:

- Build, test, and preview commands (exact commands, not descriptions)
- File structure: which directories hold source, data, output, and config
- Known gotchas: anything that has caused a wrong approach in a previous session
- External dependencies and how they are managed (flake.nix, renv, pip, etc.)

## Writing

Write in a natural academic voice. Avoid patterns that signal AI-generated text:

- No AI-tell words (delve, crucial, leverage, robust, nuanced) or stock phrases (rich tapestry, pave the way, at its core)
- No moreover/furthermore/additionally/in conclusion as paragraph openers
- No empty qualifiers (It's important to note..., Generally speaking...)
- Vary sentence and paragraph length. Sentence case in headings. Active voice by default.
- No emojis, no corporate tone, no fabricated references or garbled citations.

Use `/writing:refine <file>` for a thorough pass across vocabulary, structure, voice, and formatting.

## Project logs convention

All project types use a `logs/` directory at the repo root for
machine-generated status artifacts. Commands that write to `logs/`:

- `/project:review-week` — writes `logs/weekly-review-YYYY-MM-DD.md`
- `/project:status` and `/project:plan-session` — read from `logs/` for context

Each entry gets its own dated file. Do not consolidate into a single log file.
The `logs/` directory is created automatically by `/project:setup`.

## Command workflows

Commands are organized into namespaced groups under `~/.claude/commands/`.

### Project lifecycle (`/project:*`)

- `/project:setup [type]` — scaffold a new project (research, teaching, grant, service, development)
- `/project:status` — analyze git history, specs, and milestones
- `/project:manage [subcommand]` — update docs, track progress, fix issues, create specs
- `/project:plan-session` — assess state, set goals, build a dependency-linked task list
- `/project:review-week` — weekly progress report from git log and specs

Typical flow: `setup` once, then `plan-session` at the start of each work session, `review-week` at week's end.

### Research (`/research:*`)

- `/research:search <topic>` — search Zotero and Semantic Scholar, produce annotated tables
- `/research:challenge [file or aspect]` — stress-test theory, methods, design, and contribution with literature-backed critique
- `/research:target [file or focus]` — synthesize search and challenge output into 2-4 ranked research paths with pros, cons, and feasibility

Typical flow: `search` to survey the field, `challenge` to pressure-test the design, `target` to identify and commit to the strongest path.

### Writing (`/writing:*`)

- `/writing:draft <section>` — draft a section from project context and sources
- `/writing:refine <file>` — detect and remove AI writing artifacts
- `/writing:reviewer-2 [file]` — tough-but-fair peer review with literature-backed critique

Typical flow: `draft` a section, run `reviewer-2` for critique, address tasks, then `refine` for final polish.

### Assessment (`/assess:*`)

Pipeline for Canvas rubric grading:

1. `/assess:setup [assignment_id]` — fetch rubric, submissions, create assessment JSON
2. `/assess:ai-pass` — AI-evaluate all submissions against rubric
3. `/assess:refine` — cohort-aware score normalization (0.5-point steps)
4. `/assess:submit` — post approved grades to Canvas

### Utility (root level)

- `/brainstorm <topic>` — Socratic thinking partner with project context
- `/chat` — conversational mode, no tools
- `/implement <plan>` — execute a plan with checkpoints at decision points
- `/ai-commit` — stage and commit with generated message

### Templates (`/templates:specs:*`)

Spec scaffolds for research, teaching, grant, service, and development projects (planning, progress, implementation).
