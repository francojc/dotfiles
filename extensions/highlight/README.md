# Highlight (Quarto Extension)

HTML-only extension to control the color of inline highlights written as
Pandoc marks (`==text==`) or HTML `<mark>`.

## Install

Option A: Add to a project (copies files under `_extensions/highlight/`).

```bash
quarto add /path/to/highlight
```

Option B: Use as a local filter without copying (reference relative path):

```yaml
filters:
  - ./highlight
```


## Configure

The 'mark' element must be turned on in the output format. If using
`==text==`, the `markdown+mark` extension must be enabled.

```yaml
filters: [highlight]
from: markdown+mark
format: html
```

This can be set at the project or document level.

Project- or document-level default color:

```yaml
highlight-color: "#ffec99"
# or
highlight:
  color: "#ffec99"
```

The extension injects a CSS variable `--hl-color` for HTML; CSS targets
both `<mark>` and `.mark` for compatibility across Pandoc versions.

## Use

```markdown
This is ==highlighted==.

<mark>Also highlighted</mark>.

Palette: <mark data-hl="green">methodologically salient</mark>.

[==scoped color==]{data-hl="blue"}
```


