# Claude Guidelines

This document provides context about myself and my work and outlines my preferred conventions and practices to help guide style choices, code generation, and other suggestions.

# Context

## Professional Context

**Role:** University Professor, Spanish Department  
**Specializations:** Corpus Linguistics, Computational Linguistics (NLP), Hispanic Linguistics  
**Education:** PhD Linguistics & Cognitive Science, MA Hispanic Linguistics, BA History & Spanish

### Research Domains

- **Corpus Linguistics** - large-scale text analysis, frequency studies, concordancing
- **Computational Linguistics/NLP** - text processing, linguistic feature extraction, language modeling
- **Hispanic Linguistics** - Spanish language research, dialectology, sociolinguistics
- **Academic Applications** - teaching support tools, departmental/college service automation

### Project Types

#### Research Projects

- Corpus compilation and preprocessing
- Statistical analysis of linguistic phenomena
- NLP model development and evaluation
- Cross-linguistic comparative studies

#### Teaching Applications

- Student assessment automation
- Language learning tools
- Corpus-based pedagogy resources
- Assessment analysis and reporting

#### Service Applications

- Department data analysis and reporting
- Administrative task automation
- Curriculum analysis tools
- Faculty workload optimization

# Project Planning 

## Project Specifications Framework

A `specs/` directory serves as a centralized planning and documentation hub for
systematic project development, containing:

Core Categories

- Planning Documents - Strategic planning, requirements analysis, and project roadmaps
- Progress Tracking - Status updates, milestone tracking, and development progress
- Analysis Reports - Research analysis, gap identification, and strategic recommendations
- Specifications - Technical specifications, design documents, and implementation guidelines

Key Principles

1. Centralized Organization - Single location for all planning materials
2. Version Control Integration - All specifications tracked with main repository
3. Living Documentation - Regular updates as requirements evolve
4. Cross-Referencing - Links to relevant code, documentation, and research
5. Status Transparency - Clear completion indicators and current status

Implementation Guidelines

- Use descriptive filenames with clear purposes
- Include document metadata (purpose, creation date, status)
- Maintain README index with document descriptions
- Follow consistent formatting standards
- Update documentation as project evolves

This framework supports systematic project development by maintaining clear separation between planning/analysis documents and implementation code, while ensuring all strategic materials remain accessible and current.

# Conventions

## General Coding Style

- **Primary programming languages**: 
  - **R** (extensive experience) - primary language for statistical analysis, corpus linguistics, and research
  - **Python** (moderate experience) - used for NLP tasks and when R limitations require it
  - **Bash** (basic experience) - scripting and system administration
  - **Lua** (basic experience) - used when necessary
  - Occasionally work with other languages as needed (HTML, CSS, JavaScript, etc.)

- **Style guides**:
  - R: Follow the Tidyverse style guide
    - Use the native R pipe operator (`|>`) for piping
  - Python: Use Ruff for linting and formatting (compliant with PEP 8 with some customizations)
  - Bash: Write POSIX-compliant shell scripts when possible
  - In Markdown (md) and Quarto (qmd) documents, make sure to add a line between: 
    - headers and body
    - body and bullet lists

- **Indentation preference**: Use spaces, not tabs:
  - 2 spaces for R and Bash
  - 4 spaces for Python
  - Use `-` for unordered lists, not `*` or `+`  

- **Line length limit**:
  - 80 characters all languages (except for Markdown (and flavors like Quarto))

- **Naming conventions**:
  - R, Python, and Bash: snake_case for functions and variables
  - Python: PascalCase for classes

## Code Organization

- **Import organization**:
  - R: Group imports by package type (tidyverse first, then data manipulation, visualization, etc.)
  - Python: Standard library first, then third-party packages, then local modules, all alphabetized within groups
  - Use import optimization tools when available (isort for Python)

- **File organization**:
  - One primary function/class per file when possible
  - Group related functionality in modules/packages
  - Use consistent directory structure:
    - src/ or R/ for source code
    - tests/ for test files
    - data/ for data files
    - docs/ for documentation

- **Architectural patterns**:
  - For R: Prefer functional programming approaches with tidyverse
  - For Python: Use appropriate patterns for the task (functional for data processing, OOP for larger applications)
  - Modularize code into reusable components
  - Prioritize reproducible research practices
  - Emphasize clear documentation for academic collaboration
  - Focus on statistical rigor and methodological transparency
  - Balance efficiency with interpretability for research contexts

- **Quarto projects (R or Python)**:
  - Use Quarto project website or blog format for reproducible reports and documents
  - For data analysis projects:
    - Include a project overview with goals, methods, and steps to reproduce the work (`README.md`)
    - Include a data dictionary for all datasets used
    - Analysis directory for data processing and analysis scripts
    - A clear and well-organized `_quarto.yml` file to coordinate the project
  - Include code chunks for data processing and analysis

## Documentation

- **Documentation style**:
  - Include docstrings for all public functions, classes, and modules
  - Use inline comments for complex logic only
  - Maintain README.md files for projects with setup and usage instructions
  - Include clear methodology explanations for academic reproducibility
  - Provide references to linguistic theories and computational methods
  - Document data sources and preprocessing steps thoroughly
  - Include statistical assumptions and limitations

- **Documentation formats**:
  - R: Use Roxygen2 style documentation
  - Python: Use Google-style docstrings
    - Include type hints in Python
  - Bash: Include comments for complex scripts
  - Include a help menu and usage instructions for any executable script
  - Use Markdown for README.md files

- **Comment level**:
  - Write self-documenting code with clear variable and function names
  - Comment on "why" not "what" the code is doing
  - Document complex algorithms and logic thoroughly

## Testing

- **Testing frameworks**:
  - R: testthat
  - Python: pytest
  - Bash: shunit2
  - Use GitHub Actions for CI/CD

- **Testing approach**:
  - Write tests for all new functionality
  - Aim for high test coverage for critical paths
  - Mix of unit tests and integration tests as appropriate

- **Test naming conventions**:
  - R: test_that("it should do something specific", {...})
  - Python: test_function_name_condition()
  - Bash: test_function_name_condition()
  - Group tests logically by functionality

## Libraries & Dependencies

- **Preferred libraries**:
  - R: tidyverse ecosystem (dplyr, ggplot2, tidyr, etc.), appropriate statistical packages for linguistic analysis
  - Python: pandas, numpy, scikit-learn for data science; requests for HTTP; pytest for testing; spaCy, transformers for NLP; NLTK for linguistic analysis
  - Bash: coreutils, sed, awk, grep, etc.

- **Libraries to avoid**:
  - Avoid unmaintained or deprecated packages
  - Prefer pandas over older numpy-only solutions for data manipulation
  - Avoid packages with restrictive licenses for open-source work

- **Dependency management**:
  - Use Nix flakes for reproducible environments
  - Define all dependencies in flake.nix
  - Use direnv for automatic environment loading
  - Pin dependency versions for reproducibility

## Error Handling

- **Error handling approach**:
  - R: Use tryCatch for error handling
  - Python: Use try/except blocks with specific exceptions
  - Bash: Use set -e to exit on error
  - Fail fast and explicitly
  - Provide meaningful error messages

- **Logging practices**:
  - Use appropriate logging levels (DEBUG, INFO, WARNING, ERROR)
  - Include contextual information in log messages
  - Configure logging based on environment (development vs. production)

## Performance & Optimization

- **Performance considerations**:
  - Vectorize operations in R and Python when working with data
  - Use appropriate data structures for the task
  - Consider memory usage for large datasets
  - Profile code before optimizing

- **Optimization vs. readability**:
  - Prioritize readability and correctness first
  - Optimize only after profiling identifies bottlenecks
  - Document performance-critical sections
  - Use benchmarking to verify improvements

## Version Control

- **Commit message format**:
  - Use conventional commits format: type(scope): message
  - Types include: feat, fix, docs, style, refactor, test, chore
  - Write descriptive commit messages in imperative mood
  - Reference issue numbers when applicable

- **Git workflow**:
  - Use feature branches for development
  - Rebase feature branches before merging
  - Squash commits when appropriate for clean history
  - Use pull requests for code review

## Other Preferences

- **Project conventions**:
  - Document environment setup in README.md
  - Include a Makefile/Justfile for common tasks
  - Use consistent tooling configurations across projects

- **Anti-patterns to avoid**:
  - Avoid global state and side effects when possible
  - Don't repeat yourself (DRY principle)
  - Avoid premature optimization
  - Don't commit sensitive information (use environment variables)
  - Avoid deeply nested code (aim for flat structures)

## Development Environment

- **OS**: macOS (primary), NixOS, Linux (various distributions for research computing)
- **Package manager**: Nix with flakes, Darwin, and Home-manager
- **Editor**: Neovim 
- **Environment activation**: direnv for automatic project environments
- **Containerization**: Docker for reproducible research environments
- **Virtualization**: Virtual Machines for isolated development and testing environments

## Research Data Considerations

- Handle multilingual text data appropriately
- Consider encoding issues (UTF-8, legacy encodings)
- Implement proper citation and attribution for corpus data
- Ensure compliance with institutional research ethics requirements
- Plan for long-term data preservation and sharing

## Communication Preferences

### Code Review & Feedback
- Explain statistical reasoning behind analytical choices
- Reference relevant linguistic literature when applicable
- Discuss methodological trade-offs and alternatives
- Address reproducibility and replication concerns

### Documentation Style
- Academic precision with practical applicability
- Include theoretical background when relevant
- Provide step-by-step methodology for complex analyses
- Balance technical detail with accessibility for linguistics colleagues

### Problem-Solving Approach
- Consider both computational efficiency and linguistic validity
- Discuss ethical implications of data use and analysis
- Address cross-platform compatibility (macOS/Linux/NixOS)
- Integrate with existing academic workflows and tools

## Nix Environment Structure

### Flake-based Development Environments

- **Modular package grouping**: Organize packages into logical groups:
  ```nix
  # Define general development packages
  packages = with pkgs; [
    pandoc
    quarto
  ];

  # Combine all package lists
  allPackages = packages ++ languagePackages ++ texlivePackages;
  ```

- **Shell configuration**:
  - Set up project-specific library paths in shellHook
  - Create necessary directories automatically
  - Configure environment variables as needed

- **Flake structure**:
  - Use nixpkgs-unstable for access to latest packages
  - Include flake-utils for multi-platform support
  - Organize using the pattern:
    1. Define package groups
    2. Combine groups into a single list
    3. Set up environment-specific configurations in shellHook

### Language-Specific Configurations

- **Build environment-specific configurations**:
  ```nix
  # ... inputs
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      # Define general development packages
      # ...
      # Define language-specific packages
      # ...
      # Combine all package lists
      # ...
      in {
      devShell = pkgs.mkShell {
        buildInputs = allPackages; # Use allPackages as input to the development shell
        shellHook = ''
          # Environment setup
        '';
      };
    });


  ```

#### R Development

- **R-specific package organization**:
  ```nix
  # Define general development packages
  packages = with pkgs; [
    R
    radianWrapper
  ];

  # R packages using rPackages overlay
  rPackages = with pkgs.rPackages; [
    tidyverse
    quanteda
    skimr
  ];

  # Combine all package lists
  allPackages = packages ++ rPackages ++ texlivePackages;
  ```


- **R-specific shellHook**:
  ```nix
  shellHook = ''
    # R environment setup
    export R_LIBS_USER=$PWD/R/Library;
    mkdir -p "$R_LIBS_USER";
  '';
  ```

- **R-specific considerations**:
  - Use radianWrapper for an improved R console experience
  - Include appropriate TeX Live packages for Quarto rendering
  - Configure local package directories to avoid polluting the home directory
  - Use tidyverse ecosystem when appropriate for data manipulation and visualization
  - Employ R Markdown/Quarto for literate programming and report generation
  - Follow best practices for corpus data handling and text preprocessing

#### Python Development

- **Python packages organization**:
  ```nix
  # Define general development packages
  packages = with pkgs; [
    pandoc
    quarto
  ];

  # Python environment with packages
  python = pkgs.python3.withPackages pythonPackages;

  # Python packages
  pythonPackages = ps:
    with ps; [
      ipython
      jupyter
    ];

  # Combine all package lists
  allPackages = packages ++ [python] ++ texlivePackages;
  ```

- **Python-specific shellHook**:
  ```nix
  shellHook = ''
    echo "Python development environment activated"
    export PATH=$PATH:${python}/bin;
  '';
  ```

- **Python-specific considerations**:
  - Use `withPackages` to create an integrated Python environment
  - Include `ipython` for interactive development
  - Create isolated project-specific environments
  - Use for NLP tasks that exceed R's capabilities (spaCy, transformers, etc.)
  - Integrate with R workflows when necessary (reticulate, rpy2)
  - Focus on linguistic analysis libraries (NLTK, spaCy, scikit-learn)

## Environment-Specific Notes

- **NixOS**: Emphasize declarative, reproducible package management
- **Docker**: Create containerized environments for research reproducibility
- **macOS/Linux**: Ensure cross-platform compatibility for collaboration
- **Academic Infrastructure**: Work within institutional computing constraints

## Domain-Specific Library Recommendations

### Corpus Linguistics
- **R:** quanteda, tidytext, tm, koRpus, spacyr
- **Python:** spaCy, NLTK, gensim, scikit-learn, pandas

### Statistical Analysis
- **R:** tidyverse, broom, modelr, infer, rstatix
- **Python:** scipy, statsmodels, pingouin, seaborn

### Text Processing & NLP
- **R:** stringr, textdata, tidytext, quanteda
- **Python:** spaCy, transformers, datasets, tokenizers

### Data Visualization
- **R:** ggplot2, plotly, ggiraph, patchwork
- **Python:** matplotlib, seaborn, plotly, altair

### Academic Reporting
- **Quarto:** Universal choice for reproducible documents
- **R:** knitr, rmarkdown, gt, flextable
- **Python:** jupyter, papermill, tabulate

## Implementation Notes

### For Claude Code Users
- Always check project indicators before suggesting approaches
- Reference this document's priorities when making trade-off decisions
- Suggest specs/ framework for complex, multi-phase projects
- Maintain academic standards while respecting efficiency needs
- Consider institutional constraints and collaborative requirements

