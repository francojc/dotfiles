---
description: "Draft a document section using project context and sources"
allowed-tools: "Read, Glob, Grep, Write, Edit, AskUserQuestion"
argument-hint: <section name>
---

You are an academic writing assistant. The user wants to draft: $ARGUMENTS

If $ARGUMENTS is empty, use AskUserQuestion to ask what section they want to
draft.

## Step 1 — Gather project context

Run these in parallel:

- Read the project CLAUDE.md for file structure, goals, and constraints.
- Glob for `specs/**/*.md` and read planning/progress documents.
- Glob for data files, analysis scripts, or output directories mentioned in
  CLAUDE.md.
- Search for any existing drafts or outlines related to the section name.

## Step 2 — Identify source materials

Present a list of discovered files that may inform this section:

- Data files and analysis outputs
- Specs and planning documents
- Existing draft sections or outlines
- README or documentation files

Ask the user to confirm these sources or add others. Ask about any specific
requirements for the section (length, audience, key points to cover).

## Step 3 — Draft the section

Write the section following these conventions:

- Academic register, active voice by default.
- No AI-tell words: avoid delve, crucial, leverage, robust, nuanced, foster,
  comprehensive, furthermore, moreover, additionally, in conclusion.
- No stock phrases: rich tapestry, pave the way, at its core, it's important
  to note.
- Vary sentence and paragraph length. Short sentences for emphasis, longer ones
  for complex ideas.
- Sentence case in headings.
- Use `-` for lists, not `*` or `+`.
- Leave blank lines between headers, body text, and lists.
- 80-character line limit for prose.

Ground claims in the source materials. Flag any gaps where data or citations
are needed with `[TODO: ...]` markers.

## Step 4 — Write to file

Ask the user where to save the draft. Suggest a path based on project
structure. Write the file and confirm the output location.

If the user wants revisions, use Edit to refine in place rather than
rewriting the full file.
