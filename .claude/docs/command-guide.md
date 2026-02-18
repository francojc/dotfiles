# Claude Code Command Guide

## Overview

Claude Code provides 3 streamlined slash commands for complete academic project management, from initial setup through ongoing maintenance and analysis.

## Command Structure

### 1. Project Setup: `/project-setup [type] [name]`

**Purpose:** Initialize new academic projects with intelligent scaffolding

**Prerequisites:** Project description file (README.md, PROJECT.md, CONCEPT.md, or PROPOSAL.md) with meaningful project details

**Project Types:**
- `research` - Research projects with data collection, analysis, and publication workflows
- `teaching` - Course development, pedagogical design, and educational materials  
- `grant` - Proposal development, funding applications, and compliance tracking
- `service` - Committee work, governance, and institutional service
- `development` - Software development projects (CLI tools, web apps, APIs, libraries)

**Enhanced Workflow:**

```bash
# Step 1: Create meaningful project description
cat > README.md << 'EOF'
# Spanish Dialect Corpus Analysis

## Overview
This project analyzes phonetic variation in Andalusian Spanish through 
corpus-based sociolinguistic analysis, focusing on vowel reduction patterns.

## Research Questions
- How does social class affect vowel reduction in unstressed syllables?
- What are the geographic distribution patterns across Andalusian provinces?

## Methodology  
Mixed-methods approach combining sociolinguistic interviews and acoustic analysis.
EOF

# Step 2: Run intelligent setup with context-aware templates
/project-setup research "Spanish Dialect Corpus"
```

**What It Creates:**

- CLAUDE.md with project-specific guidance derived from description
- specs/ directory with contextual planning, progress, and implementation templates
- Development environment (flake.nix)
- Project-appropriate .gitignore patterns

### 2. Project Status: `/project-status`

**Purpose:** Comprehensive project analysis and reporting

**Features:**

- Current progress assessment
- File structure analysis
- Git status and recent activity
- Documentation quality evaluation
- Next steps recommendations

**Usage:**
```bash
# Run from any project directory
/project-status
```

### 3. Project Management: `/project [subcommand]`

**Purpose:** Unified project management with specialized sub-commands

**Available Sub-Commands:**

#### `/project update`
- Documentation synchronization
- AI-powered project recommendations
- File organization analysis
- Progress tracking updates

#### `/project track`
- Progress tracking and milestone management
- Task completion monitoring
- Timeline analysis
- Goal achievement assessment

#### `/project fix [issue-number]`
- GitHub issue analysis and resolution
- Code debugging assistance
- Problem identification and solutions
- Integration with repository workflow

#### `/project create [type]`
- Documentation and specs creation
- Template generation for specific needs
- Academic writing assistance
- Project artifact development

**Usage Examples:**
```bash
# Update project documentation and get recommendations
/project update

# Track progress and milestones
/project track

# Fix specific GitHub issue
/project fix 42

# Create additional documentation
/project create specs
```

## Project Type Configurations

### Research Projects

**Focus:** Data collection, analysis, publication workflows

**Templates Generated:**
- specs/planning.md - Research design and methodology
- specs/progress.md - Data collection and analysis tracking
- specs/implementation.md - Technical infrastructure and tools

**CLAUDE.md Includes:**
- Research questions and objectives
- Methodology and data collection plans
- Analysis approach and tools
- Publication strategy
- Timeline and ethical considerations

### Teaching Projects

**Focus:** Course development, pedagogical design, assessment

**Templates Generated:**
- specs/planning.md - Course design and learning objectives
- specs/progress.md - Weekly progress and student engagement
- specs/implementation.md - Technology integration and assessment

**CLAUDE.md Includes:**
- Course overview and learning objectives
- Pedagogical approach and teaching philosophy
- Assessment strategy and technology integration
- Student engagement methods

### Grant Projects

**Focus:** Proposal development, funding applications, compliance

**Templates Generated:**
- specs/planning.md - Proposal strategy and timeline
- specs/progress.md - Funding lifecycle tracking
- specs/implementation.md - Project phases and governance

**CLAUDE.md Includes:**
- Grant opportunity and funder information
- Proposal concept and collaborators
- Budget and compliance requirements
- Submission strategy

### Service Projects

**Focus:** Committee work, governance, institutional service

**Templates Generated:**
- specs/planning.md - Committee overview and responsibilities
- specs/progress.md - Meeting logs and deliverable tracking
- specs/implementation.md - Governance and operational framework

**CLAUDE.md Includes:**
- Committee scope and deliverables
- Meeting structure and documentation
- Communication and collaboration methods
- Repository organization

### Development Projects

**Focus:** Software development lifecycle, architecture, deployment

**Templates Generated:**
- specs/planning.md - Architecture and development roadmap
- specs/progress.md - Feature development and release tracking
- specs/implementation.md - Technical stack and deployment

**CLAUDE.md Includes:**
- Project purpose and architecture overview
- Development workflow and tooling
- Testing strategy and CI/CD
- Deployment and release process

## Help and Discovery

### Command Help
```bash
# General help for all commands
/help

# Project command help and sub-commands
/project help

# Specific sub-command help
/project help update
/project help track
/project help fix
/project help create

# Project setup help and types
/project-setup help
```

### Tab Completion
- `/project` + TAB → shows available sub-commands
- `/project-setup` + TAB → shows project types (research, teaching, grant, service, development)
- `/project create` + TAB → shows documentation types

## Benefits and Features

### Intelligent Scaffolding
- Templates populated with actual project context from descriptions
- Research questions and methodologies automatically extracted
- Realistic timelines based on project scope
- Academic discipline-specific workflows

### Academic Rigor
- Enforces thoughtful project conception before setup
- Ensures meaningful documentation from project start
- Promotes proper academic planning sequence
- Context validation prevents generic scaffolding

### Workflow Integration
- Seamless integration with git workflows
- Compatible with existing hook system
- Natural command progression through project lifecycle
- Extensible foundation for automation

### Professional Organization
- Centralized specs/ directory for all project documentation
- Consistent structure across project types
- Version control friendly organization
- Academic best practices embedded

## Success Criteria

After successful project setup:
- [ ] Project description validated for sufficient detail
- [ ] CLAUDE.md generated with project-specific content
- [ ] specs/ directory created with contextual templates
- [ ] Development environment configured (flake.nix)
- [ ] Project-appropriate .gitignore patterns applied
- [ ] Templates populated with intelligent content
- [ ] Academic workflow foundation established

## Advanced Usage

### Command Aliases
Create shortcuts for frequent commands:
```bash
alias ps='/project-status'
alias pu='/project update'
alias pt='/project track'
alias pf='/project fix'
alias pc='/project create'
```

### Workflow Integration
Natural progression through project phases:
```bash
# Complete project lifecycle
/project-setup research "New Study"
/project-status
/project create additional-specs
/project track
git add -A && git commit -m "Initial project setup"
/project update
```

### Hook System Compatibility
Commands work seamlessly with automated project update hooks for enhanced workflow automation and session logging.

### Brainstorm: `/brainstorm <topic>`

**Purpose:** Socratic thinking partner for exploring ideas with project awareness

Sits between `/chat` (no tools, no context) and `/project:plan-session` (full planning output). Reads project context (CLAUDE.md, specs/, logs/) when available but works without it. Engages through probing questions, assumption-surfacing, and devil's advocacy rather than producing plans or code.

**Usage:**

```bash
# Start with a topic
/brainstorm "Should I split the API into microservices?"

# Start without a topic (will prompt for one)
/brainstorm
```

**Features:**

- Silently reads project context to inform the conversation
- Socratic dialogue style — questions over statements
- Offers handoff to `/project:plan-session` or `/implement` when ideas crystallize
- Can save a summary to `logs/brainstorm-YYYY-MM-DD.md` on request

---

This streamlined command structure provides comprehensive academic project management with intelligent scaffolding, ensuring meaningful project documentation and efficient workflow integration.
