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

When creating or updating a project-level CLAUDE.md (e.g., via `/init` or `/project-setup`), include:

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

Use `/refine <file>` for a thorough pass across vocabulary, structure, voice, and formatting.
