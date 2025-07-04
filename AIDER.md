  This document outlines my preferred conventions and practices to help guide style choices, code generation, and other suggestions.

# Coding Conventions

## General Coding Style

- **Primary programming languages**: I primarily work with R, Python, and Bash
  (for local scripts). Occasionally I work with other languages as needed
  (HTML, CSS, JavaScript, etc.).

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
  - R: tidyverse ecosystem (dplyr, ggplot2, tidyr, etc.)
  - Python: pandas, numpy, scikit-learn for data science; requests for HTTP; pytest for testing
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

- **OS**: macOS
- **Package manager**: Nix with flakes, Darwin, and Home-manager
- **Editor**: Neovim 
- **Environment activation**: direnv for automatic project environments

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

