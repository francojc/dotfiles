---
description: Analyze an academic document for AI writing artifacts and rewrite with corrections
argument-hint: <file-path>
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(wc:*)
---

# Academic writing refinement

Read the file at `$ARGUMENTS`. Analyze it for AI writing artifacts across the 7 categories below, then rewrite it with corrections.

## Analysis categories

Work through each category systematically. Count every instance.

### 1. Vocabulary artifacts

Flagged words (replace with context-specific alternatives):

- **Verbs**: delve, underscore, showcase, highlight, leverage, harness, illuminate, facilitate, foster, navigate
- **Adjectives**: crucial, comprehensive, notable, pivotal, robust, intricate, nuanced, multifaceted, transformative, groundbreaking
- **Adverbs**: notably, particularly, importantly, interestingly, remarkably, fundamentally

Flagged phrases (remove or rephrase entirely):

- "rich tapestry", "stands as a testament", "unlock the potential", "pave the way", "at its core"
- "It's important to note that...", "Generally speaking...", "From a broader perspective...", "It is worth mentioning..."

### 2. Hedging and filler

- Throat-clearing openers that add no information
- Excessive "however", "moreover", "furthermore", "additionally" as paragraph openers
- Empty qualifiers and redundant hedges

### 3. Structural monotony

- Uniform paragraph length (should vary naturally)
- Rigid topic sentence -> support -> summary in every paragraph
- "From X to Y" sentence openers
- Lists with identical grammatical structures (vary them)
- Excessive participial phrases (main clause + comma + "-ing" phrase)
- Formulaic endings: "In conclusion," "Despite challenges..."

### 4. Voice and tone

- Generic, emotionally detached corporate tone
- Absence of specific examples or lived experience
- Perfect consistency without natural quirks
- Excessive passive voice (convert where active is clearer)
- Sycophantic openers: "Great question!", "Absolutely!", "You're absolutely right"
- Sentences of similar length and structure (vary rhythm)

### 5. Heading and formatting

- Title case headings (convert to sentence case)
- Gratuitous bold text for emphasis (remove unless structurally necessary)
- Overuse of em dashes as universal connectors
- Use of cliches and idioms
- Use of emojis (remove)

### 6. Technical artifacts

- Garbled citation codes (turn0search0, :contentReference)
- Broken wikitext mixed with Markdown
- Fabricated references with invalid DOIs/ISBNs
- Letter-like formatting ("Dear Wikipedia Editors...")

### 7. Deep structural issues

- Generalizations that lack evidence or specificity — flag with `[REVIEW: generalization without support]`
- Redundant recaps or summaries that repeat earlier content — remove
- Passages where the author's own perspective or experience is needed — mark with `[AUTHOR VOICE NEEDED]`
- Conclusions that merely restate the introduction — flag with `[REVIEW: conclusion restates introduction]`

## Output procedure

1. **Read** the full file with the Read tool
2. **Count** issues per category
3. **Print analysis summary** as a table:

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

4. **List the most significant changes** (up to 15) with:
   - Original text (quoted)
   - Replacement text (quoted)
   - Brief rationale

5. **Rewrite the file** in place using Edit (for targeted fixes) or Write (for extensive changes). Preserve all meaning, structure, and author intent. Do not add content or expand scope.

6. **Leave markers** where you cannot determine author intent:
   - `[REVIEW: <reason>]` — needs human judgment
   - `[AUTHOR VOICE NEEDED]` — passage requires personal perspective or domain expertise

Do NOT invent facts, add citations, expand arguments, or change the author's position. The goal is to remove detectable AI artifacts while preserving the document's substance.
