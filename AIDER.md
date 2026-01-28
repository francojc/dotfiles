  This document outlines my preferred conventions and practices to help guide response generation.

# Coding Conventions

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

