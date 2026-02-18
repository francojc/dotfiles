# Application Implementation Details

**Project:** {PROJECT_NAME}
**Status:** {STATUS}
**Last Updated:** {DATE}

## Architecture

### System Design

- **Architecture Pattern:** [Monolith/Microservices/Serverless/CLI pipeline/etc.]
- **Primary Language:** [Language and version]
- **Framework:** [Framework and version, if applicable]
- **Build System:** [Build tool and configuration]

### Component Overview

```
project/
├── src/               # Application source code
│   ├── core/          # Business logic and domain models
│   ├── api/           # API routes or CLI commands
│   ├── lib/           # Shared utilities and helpers
│   └── config/        # Configuration and environment handling
├── tests/             # Test suite
│   ├── unit/          # Unit tests
│   ├── integration/   # Integration tests
│   └── fixtures/      # Test data and mocks
├── docs/              # Documentation
├── scripts/           # Build, deploy, and utility scripts
├── logs/              # Weekly reviews and session logs
└── specs/             # Project planning and tracking
```

### Key Modules

1. **[Module 1]**
   - **Purpose:** [What it does]
   - **Public Interface:** [Key functions/classes/endpoints]
   - **Dependencies:** [What it depends on]

2. **[Module 2]**
   - **Purpose:** [What it does]
   - **Public Interface:** [Key functions/classes/endpoints]
   - **Dependencies:** [What it depends on]

3. **[Module 3]**
   - **Purpose:** [What it does]
   - **Public Interface:** [Key functions/classes/endpoints]
   - **Dependencies:** [What it depends on]

### Data Model

- **Primary Data Structures:** [Core types and their relationships]
- **Persistence Layer:** [Database, file system, or in-memory]
- **Serialization Format:** [JSON/TOML/YAML/Protobuf/etc.]
- **Migration Strategy:** [How schema changes are handled]

## Development Environment

### Setup

- **Language Runtime:** [Version and installation method]
- **Package Manager:** [Tool and lock file strategy]
- **Environment Management:** [Nix flake/venv/nvm/etc.]
- **Local Services:** [Database, cache, queue — how to run locally]

### Build and Run

```bash
# Build
[build command]

# Run locally
[run command]

# Run with watch/hot-reload
[dev command]
```

### Code Standards

- **Formatting:** [Tool and config file]
- **Linting:** [Tool and rule set]
- **Type Checking:** [Tool and strictness level]
- **Naming Conventions:** [snake_case/camelCase/etc. by context]

## Testing Strategy

### Test Levels

- **Unit Tests:** [Framework, location, naming convention]
- **Integration Tests:** [Framework, setup requirements]
- **End-to-End Tests:** [Framework, environment needs]

### Running Tests

```bash
# All tests
[test command]

# Unit tests only
[unit test command]

# With coverage
[coverage command]
```

### Coverage Targets

- **Overall:** [Target percentage]
- **Critical Paths:** [Higher target for core logic]
- **Exclusions:** [What is intentionally not tested and why]

### Test Data

- **Fixtures:** [Location and management approach]
- **Mocks/Stubs:** [Strategy for external dependencies]
- **Test Databases:** [Setup and teardown approach]

## Deployment

### Target Environment

- **Platform:** [Cloud provider/VPS/Package registry/etc.]
- **Runtime:** [Container/binary/interpreted/etc.]
- **Configuration:** [Environment variables, config files, secrets management]

### CI/CD Pipeline

- **Platform:** [GitHub Actions/GitLab CI/etc.]
- **Triggers:** [On push, on PR, on tag]
- **Stages:** [Lint, test, build, deploy]
- **Artifact Publishing:** [Package registry, container registry, release assets]

### Release Process

- **Versioning:** [SemVer/CalVer/etc.]
- **Changelog:** [How changes are documented]
- **Release Steps:** [Tag, build, publish, announce]
- **Rollback Procedure:** [How to revert a bad release]

## Monitoring and Observability

### Logging

- **Framework:** [Logging library and configuration]
- **Log Levels:** [When to use each level]
- **Structured Logging:** [Format and key fields]

### Error Handling

- **Error Types:** [Application error hierarchy]
- **User-Facing Errors:** [How errors are presented]
- **Error Reporting:** [Crash reporting or alerting service]

### Health Checks

- **Endpoints or Signals:** [How to verify the app is running]
- **Dependency Checks:** [Verifying external service connectivity]

## Security Considerations

### Input Validation

- **User Input:** [Sanitization and validation approach]
- **API Boundaries:** [Request validation and rate limiting]
- **File Handling:** [Safe file I/O practices]

### Authentication and Authorization

- **Auth Method:** [API keys/OAuth/JWT/none]
- **Permission Model:** [Role-based/attribute-based/none]
- **Secret Management:** [How credentials are stored and accessed]

### Dependency Security

- **Audit Process:** [How dependencies are vetted]
- **Update Strategy:** [How and when dependencies are updated]
- **Known Vulnerabilities:** [Scanning tool and policy]

## Decision Log

Record significant technical decisions and their rationale.

| Date | Decision | Rationale | Alternatives Considered |
|------|----------|-----------|------------------------|
| {DATE} | [Decision 1] | [Why this choice] | [What else was considered] |
