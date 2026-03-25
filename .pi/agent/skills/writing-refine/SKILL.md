---
name: writing-refine
description: Analyze a document for AI writing artifacts across 7 categories and rewrite it with corrections. Use when a draft needs to be cleaned of detectable AI patterns — overused vocabulary, hedging, structural monotony, voice issues, formatting problems, technical artifacts, and unsupported generalizations. Preserves meaning and author intent throughout.
allowed-tools: Read, Write, Edit, Grep, Bash, question
---

# Academic writing refinement

## Step 1 — Identify the document

Check the user's message for a file path.

If no path is provided, use the `question` tool to ask:

> Which file should I refine?

(Allow free-text entry for the file path.)

Read the full file before proceeding.

## Step 2 — Analyze across 7 categories

Work through each category systematically. Count every instance.

### 1. Vocabulary artifacts

Flagged words (replace with context-specific alternatives):

- **Verbs**: delve, underscore, showcase, highlight, leverage, harness,
  illuminate, facilitate, foster, navigate
- **Adjectives**: crucial, comprehensive, notable, pivotal, robust,
  intricate, nuanced, multifaceted, transformative, groundbreaking
- **Adverbs**: notably, particularly, importantly, interestingly,
  remarkably, fundamentally

Flagged phrases (remove or rephrase entirely):

- "rich tapestry", "stands as a testament", "unlock the potential",
  "pave the way", "at its core"
- "It's important to note that...", "Generally speaking...",
  "From a broader perspective...", "It is worth mentioning..."

### 2. Hedging and filler

- Throat-clearing openers that add no information
- Excessive "however", "moreover", "furthermore", "additionally" as
  paragraph openers
- Empty qualifiers and redundant hedges

### 3. Structural monotony

- Uniform paragraph length (should vary naturally)
- Rigid topic sentence → support → summary in every paragraph
- "From X to Y" sentence openers
- Lists with identical grammatical structures (vary them)
- Excessive participial phrases (main clause + comma + "-ing" phrase)
- Formulaic endings: "In conclusion," "Despite challenges..."

### 4. Voice and tone

- Generic, emotionally detached corporate tone
- Absence of specific examples or lived experience
- Perfect consistency without natural quirks
- Excessive passive voice (convert where active is clearer)
- Sycophantic openers: "Great question!", "Absolutely!", "You're
  absolutely right"
- Sentences of similar length and structure (vary rhythm)

### 5. Heading and formatting

- Title case headings (convert to sentence case)
- Gratuitous bold text for emphasis (remove unless structurally necessary)
- Overuse of em dashes as universal connectors
- Use of clichés and idioms
- Use of emojis (remove)

### 6. Technical artifacts

- Garbled citation codes (turn0search0, :contentReference)
- Broken wikitext mixed with Markdown
- Fabricated references with invalid DOIs/ISBNs
- Letter-like formatting ("Dear Wikipedia Editors...")

### 7. Deep structural issues

- Generalizations that lack evidence or specificity — flag with
  `[REVIEW: generalization without support]`
- Redundant recaps or summaries that repeat earlier content — remove
- Passages where the author's own perspective or experience is needed —
  mark with `[AUTHOR VOICE NEEDED]`
- Conclusions that merely restate the introduction — flag with
  `[REVIEW: conclusion restates introduction]`

## Step 3 — Print analysis summary

Output a table before making any changes:

```
| Category                | Issues found |
|-------------------------|-------------|
| 1. Vocabulary artifacts | N           |
| 2. Hedging and filler   | N           |
| 3. Structural monotony  | N           |
| 4. Voice and tone       | N           |
| 5. Heading/formatting   | N           |
| 6. Technical artifacts  | N           |
| 7. Deep structural      | N           |
| **Total**               | **N**       |
```

## Step 4 — List significant changes

List up to 15 of the most significant changes planned:

- Original text (quoted)
- Replacement text (quoted)
- Brief rationale

## Step 5 — Rewrite the file

Use Edit for targeted fixes or Write for extensive changes. Preserve all
meaning, structure, and author intent. Do not add content or expand scope.

Leave markers where author intent is unclear:

- `[REVIEW: <reason>]` — needs human judgment
- `[AUTHOR VOICE NEEDED]` — passage requires personal perspective or
  domain expertise

Do NOT invent facts, add citations, expand arguments, or change the
author's position. The goal is to remove detectable AI artifacts while
preserving the document's substance.
