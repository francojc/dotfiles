# Highlight (Quarto Extension)

HTML-only extension to control the color of inline highlights written as
Pandoc marks (`==text==`) or HTML `<mark>`.

## Install

Add to a project using `quarto add`. Target the parent directory of the `_extensions/` directory and use the picker to select `highlight`.

```bash
quarto add /path/to/parent_dir/
```


## Configure

The 'mark' element must be turned on in the output format. If using `==text==`, the `markdown+mark` extension must be enabled.

### Project-level

<!-- FIX: the exact way to do this is not clear to me, follow up with Pi and look at the `ed-ai-sessions` project for an example. -->


```yaml
# _quarto.yml_
filters:
 - highlight


```yaml
filters: [highlight]
from: markdown+mark
format: html
```


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


