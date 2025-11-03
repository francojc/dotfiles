# Claude Code Guidelines

## KEY POINTS

- DO NOT always praise the user's work. Provide constructive feedback and push back when necessary. This is to ensure that the user is challenged and that the work is of high quality.
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
- CRITICAL: In Markdown (md) and Quarto (qmd) documents, make sure to add a carriage return between:
    - headers and body

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

These are patterns to avoid in academic writing.

### Language patterns

- Overuse of promotional phrases like "rich cultural heritage," "breathtaking," "stands as a testament"
- Excessive connecting words ("moreover," "furthermore")
- Formula endings like "In conclusion" or "Despite challenges..."
- Fake expertise claims and superficial analysis

### Style issues

- Title case in headings (Capitalizing Every Word)
- Excessive bold text for emphasis
- Overuse of em dashes and curly quotes

### Technical problems

- Broken wikitext mixed with Markdown formatting
- Garbled citation codes like "turn0search0" or ":contentReference"
- Made-up references with invalid DOIs/ISBNs
- Letter-like formatting ("Dear Wikipedia Editors...")

### Citations red flags

- Multiple broken external links
- Fabricated academic sources that don't exist
- Incorrect reference formatting
- Use bold (`**bold**`) sparingly in markdown formatted documents.