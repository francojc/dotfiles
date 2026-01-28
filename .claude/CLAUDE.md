# Claude Code Guidelines

## KEY POINTS

- DO NOT always praise the user's work. Provide constructive feedback and push back when necessary. This is to ensure that the user is challenged and that the work is of high quality.
- Avoid sycophantic openers like "Great question!" or "Absolutely!" - start with substance.
- When using Markdown/ Quarto, ENSURE THAT THERE IS A CARRIAGE RETURN BETWEEN HEADERS AND BODY TEXT, AND BETWEEN BODY TEXT AND BULLET LISTS! See example below:

```markdown
# Header

Body text.

A description of an upcoming bullet list:

- Bullet item 1
- Bullet item 2
```

## Coding Standards

### Languages & Style

- **R**: Tidyverse ecosystem, native pipe (`|>`), 2-space indentation
- **Python**: Data science stack, Ruff formatting, 4-space indentation
- **Bash**: POSIX-compliant, 2-space indentation
- **Lua**: Neovim config and Quarto extensions
- **Line limit**: 80 characters (except Markdown)
- **Naming**: snake_case (functions/variables), PascalCase (Python classes)
- **Lists**: Use `-` not `*` or `+`

### Documentation

- R: Roxygen2 style
- Python: Google-style docstrings with type hints
- Self-documenting code with "why" comments
- Academic methodology explanations for reproducibility

### Version Control

- Conventional commits: `type(scope): message`
- Feature branches with rebase workflow
- Squash commits for clean history

## Research Considerations

- Handle multilingual text data and encoding issues
- Corpus data citation and attribution
- Institutional ethics compliance
- Long-term data preservation
- Balance computational efficiency with linguistic validity

## Avoid Overused Patterns

Patterns that signal AI-generated text and undermine authentic academic voice.

### Overused Words

Avoid these high-frequency AI markers (per academic studies on LLM vocabulary):

- **Verbs**: delve, underscore, showcase, highlight, leverage, harness, illuminate, facilitate, foster, navigate
- **Adjectives**: crucial, comprehensive, notable, pivotal, robust, intricate, nuanced, multifaceted, transformative, groundbreaking
- **Adverbs**: notably, particularly, importantly, interestingly, remarkably, fundamentally
- **Phrases**: "rich tapestry," "stands as a testament," "unlock the potential," "pave the way," "at its core"

### Hedging and Filler

- "It's important to note that..."
- "Generally speaking..."
- "From a broader perspective..."
- "It is worth mentioning..."
- Excessive "however," "moreover," "furthermore," "additionally" as paragraph openers

### Structural Patterns

- Uniform paragraph length (vary naturally)
- Rigid topic sentence → support → summary in every paragraph
- "From X to Y" sentence openers
- Lists with identical grammatical structures
- Excessive participial phrases (main clause + comma + "-ing" phrase)
- Formulaic endings: "In conclusion," "Despite challenges..."

### Voice and Tone

- Generic, emotionally detached corporate tone
- Absence of specific examples or lived experience
- Perfect consistency without natural quirks
- Excessive passive voice
- Sycophantic openers: "Great question!", "Absolutely!", "You're absolutely right"

### Style Issues

- Title case in headings (Capitalizing Every Word)
- Excessive bold text for emphasis
- Overuse of em dashes as universal connectors
- Use of clichés and idioms
- Use of emojis
- Sentences of similar length and structure (lack of variety)

### Technical Problems

- Broken wikitext mixed with Markdown formatting
- Garbled citation codes like "turn0search0" or ":contentReference"
- Fabricated references with invalid DOIs/ISBNs
- Letter-like formatting ("Dear Wikipedia Editors...")
