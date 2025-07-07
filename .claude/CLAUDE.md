# Claude Guidelines

## Professional Context

**Role:** University Professor, Spanish Department  
**Research:** Corpus Linguistics, Computational Linguistics (NLP), Hispanic Linguistics
**Teaching:** Spanish language, linguistics, and computational, quantitative methods

## Project Planning Framework

Use `specs/` directory for systematic project development:

- Planning Documents, Progress Tracking, Analysis Reports, Specifications
- Centralized organization with version control integration
- Living documentation with clear status indicators

## Coding Standards

### Languages & Style

- **R**: Tidyverse ecosystem, native pipe (`|>`), 2-space indentation
- **Python**: Data science stack, Ruff formatting, 4-space indentation
- **Bash**: POSIX-compliant, 2-space indentation
- **Lua**: Neovim config and Quarto extensions
- **Line limit**: 80 characters (except Markdown)
- **Naming**: snake_case (functions/variables), PascalCase (Python classes)
- **Lists**: Use `-` not `*` or `+`
- In Markdown (md) and Quarto (qmd) documents, make sure to add a carriage return between: 
    - headers and body
    - body and bullet lists

    ```markdown 
    # Header 

    Body text.

    A description of an upcoming bullet list:

    - Bullet item 1
    - Bullet item 2
    ```

### Documentation

- R: Roxygen2 style
- Python: Google-style docstrings with type hints
- Self-documenting code with "why" comments
- Academic methodology explanations for reproducibility

### Testing

- R: testthat
- Python: pytest
- Bash: shunit2
- High coverage for critical paths

## Environment & Tools

- **OS**: macOS (primary), NixOS, Linux
- **Package Manager**: Nix flakes with direnv (not nix develop)
- **Editor**: Neovim
- **Containerization**: Docker for reproducible research
  - The attribute `version` is obsolete in Docker. Do not include.

### Nix Flake Structure

```nix
outputs = { nixpkgs, flake-utils, ... }:
  flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {inherit system;};
    packages = with pkgs; [ pandoc quarto ];
    # Language-specific packages
    allPackages = packages ++ languagePackages;
  in {
    devShell = pkgs.mkShell {
      buildInputs = allPackages;
      shellHook = ''# Environment setup'';
    };
  });
```

## Version Control

- Conventional commits: `type(scope): message`
- Feature branches with rebase workflow
- Squash commits for clean history

## Research Considerations

- Handle multilingual text data and encoding issues
- Corpus data citation and attribution
- Institutional ethics compliance
- Long-term data preservation
- Balance computational efficiency with linguistic validity