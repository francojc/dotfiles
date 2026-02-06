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

## Avoid overused patterns

Write in a natural academic voice. Avoid patterns that signal AI-generated text:

- Do not use AI-tell words (delve, crucial, leverage, robust, nuanced, etc.) or stock phrases (rich tapestry, pave the way, at its core, etc.)
- Do not open paragraphs with moreover, furthermore, additionally, or in conclusion
- Do not hedge with empty qualifiers (It's important to note..., Generally speaking...)
- Vary sentence length, paragraph length, and structure — break monotony
- Use sentence case in headings, not title case
- Prefer active voice; use passive only when the agent is unknown or irrelevant
- No emojis, no sycophantic openers, no corporate tone
- No fabricated references, garbled citation codes, or broken wikitext

The PostToolUse hook in `settings.json` enforces surface-level checks on academic file writes automatically. Use `/refine <file>` for a thorough pass across vocabulary, structure, voice, formatting, and deep structural issues.
