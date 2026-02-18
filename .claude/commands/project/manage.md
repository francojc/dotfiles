---
allowed-tools: Read, Grep, Edit, Bash, LS, Write
description: |
  Project management sub-comands: create, update, track, fix, create with unified interface and academic and professional workflows.
---

Unified project management for workflows with sub-command support.

**Command:** /project $ARGUMENTS

## Sub-Command Router

### Available Sub-Commands

- **`create [type]`** - Create project documentation (specs, planning docs, etc.)
- **`update`** - Synchronize project documentation and provide AI-powered next-step recommendations
- **`track`** - Track project progress including milestones, tasks, and deadlines
- **`fix [issue-number]`** - Analyze and fix GitHub issues with automated workflow

### Sub-Command Dispatcher

Parse the first argument to determine which sub-command to execute:

```bash
SUBCOMMAND="$1"
shift  # Remove subcommand from arguments
REMAINING_ARGS="$*"

case "$SUBCOMMAND" in
    update|sync)
        # Execute project-update functionality
        ;;
    track|progress)
        # Execute tracking functionality
        ;;
    fix|issue)
        # Execute GitHub issue fixing
        ;;
    create|new|spec|specs)
        # Execute documentation creation
        ;;
    help|--help|-h)
        # Show help information
        ;;
    *)
        # Default to update if no subcommand specified
        ;;
esac
```

## Sub-Command Implementations

### 1. Update Sub-Command (`/project update`)

Synchronize project documentation with current state and generate intelligent next-step recommendations based on recent changes and project type.

**Functionality from project-update.md:**

#### Documentation Synchronization Process

1. **Current State Analysis**
   - Scan project files for recent changes and developments
   - Review git history for development patterns and focus areas
   - Assess completeness of existing documentation
   - Identify documentation gaps or outdated information

2. **specs/ Directory Updates**
   - Update specs/progress.md with current status and recent accomplishments
   - Sync specs/implementation.md with actual methodologies and procedures
   - Revise specs/planning.md if objectives or timelines have changed
   - Ensure consistency across all documentation files

3. **CLAUDE.md Maintenance**
   - Verify project description still accurately reflects current work
   - Update methodology sections based on implementation changes
   - Refresh timeline and milestone information
   - Add new insights or direction changes

4. **Context Integration**
   - **Research:** Align with research lifecycle and methodology standards
   - **Teaching:** Integrate pedagogical best practices and course design principles
   - **Grant:** Ensure compliance with proposal requirements and funder expectations
   - **Service:** Maintain institutional alignment and governance standards
   - **Development:** Follow software development lifecycle and deployment best practices

#### AI-Powered Recommendations

Generate project type-specific guidance:

**Research Projects:** Literature integration, data analysis approaches, quality assurance steps, dissemination opportunities

**Teaching Projects:** Pedagogical enhancements, assessment alignment, student engagement, accessibility improvements

**Grant Projects:** Proposal strengthening, budget optimization, compliance, collaboration opportunities

**Service Projects:** Efficiency improvements, stakeholder engagement, deliverable quality, institutional impact

**Development Projects:** Architecture decisions, development workflow, testing strategy, deployment and release planning

### 2. Track Sub-Command (`/project track`)

Track the progress of the project in the current repository, including milestones, tasks, and deadlines.

**Enhanced Functionality:**

#### Progress Analysis

- Read specs/planning.md to understand project objectives and timeline
- Parse specs/progress.md for current status and completed milestones
- Read recent entries from `logs/` directory for historical context
- Analyze git commit history for development activity patterns
- Identify areas of high productivity vs. areas needing attention

#### Milestone Tracking

- Extract milestone information from planning documents
- Compare planned vs. actual completion dates
- Calculate progress percentages for major project phases
- Flag overdue or at-risk milestones

#### Task Management

- Parse TODO items from documentation and code comments
- Track task completion rates and time estimates
- Identify dependencies and critical path items
- Generate priority recommendations

#### Specific Tracking

- **Research:** Data collection phases, analysis milestones, writing deadlines
- **Teaching:** Course development stages, material creation, assessment design
- **Grant:** Proposal sections, submission deadlines, review cycles
- **Service:** Committee deliverables, meeting schedules, governance tasks
- **Development:** Feature development, testing phases, deployment milestones

### 3. Fix Sub-Command (`/project fix [issue-number]`)

Analyze and fix the GitHub issue with automated development workflow.

**Functionality from fix-gh-issue.md:**

#### GitHub Issue Workflow

1. **Issue Analysis**
   - Use `gh issue view` to get detailed issue information
   - Parse issue description, labels, and comments
   - Identify issue type (bug, feature, enhancement, documentation)
   - Extract reproduction steps and expected behavior

2. **Codebase Investigation**
   - Search relevant files based on issue description
   - Identify affected components and dependencies
   - Review recent changes that might have introduced the issue
   - Analyze related test cases and documentation

3. **Solution Implementation**
   - Implement necessary changes to fix the issue
   - Follow project coding standards and conventions
   - Add or update tests to verify the fix
   - Update documentation if needed

4. **Quality Assurance**
   - Run existing tests to ensure no regressions
   - Perform linting and type checking
   - Test the specific fix against issue reproduction steps
   - Verify edge cases and error handling

5. **Submission Workflow**
   - Create descriptive commit message linking to issue
   - Push changes to feature branch
   - Create pull request with detailed description
   - Link PR to original issue for automatic closure

#### Usage Examples

```bash
/project fix 123           # Fix GitHub issue #123
/project fix bug-login     # Fix issue by title search
/project issue 456         # Alternative syntax
```


### 4. Create Sub-Command (`/project create [type]`)

Create systematic project documentation in specs/ format.

**Functionality from create-specs.md:**

#### Documentation Types

- **planning** - Project planning documents with clear status
- **progress** - Progress tracking framework with milestones
- **implementation** - Design specifications and technical details
- **specs** - Complete specs/ directory structure

#### Creation Process

1. **Project Analysis**
   - Read existing README.md and CLAUDE.md to identify aims and goals
   - Analyze current project structure and files
   - Determine project type (research, teaching, grant, service, development)
   - Identify documentation gaps

2. **Template Selection**
   - Choose appropriate templates based on project type
   - Customize templates with project-specific information
   - Replace placeholders with actual project data
   - Ensure consistency with existing documentation

3. **Content Generation**
   - Generate planning documents with clear objectives
   - Create progress tracking framework with milestones
   - Develop implementation details and specifications
   - Include academic/professional best practices and methodology

#### Usage Examples

```bash
/project create planning     # Create specs/planning.md
/project create progress     # Create specs/progress.md
/project create specs        # Create complete specs/ structure
/project new implementation  # Alternative syntax
```

## Help System

### Usage Information

```
Usage: /project [subcommand] [arguments]

Sub-commands:
  update              Synchronize documentation and get recommendations
  track               Track progress, milestones, and tasks
  fix <issue>         Analyze and fix GitHub issues
  create <type>       Create project documentation

Examples:
  /project update                    # Update docs and get recommendations
  /project track                     # View project progress
  /project fix 123                   # Fix GitHub issue #123
  /project create planning           # Create planning document

For detailed help on any sub-command:
  /project help <subcommand>
```

### Sub-Command Help

Provide detailed help for each sub-command including:
- Purpose and functionality
- Required and optional arguments
- Usage examples
- Related commands and workflows

## Error Handling

### Invalid Sub-Commands

```bash
if [ "$SUBCOMMAND" != "update" ] && [ "$SUBCOMMAND" != "track" ] &&
   [ "$SUBCOMMAND" != "fix" ] && [ "$SUBCOMMAND" != "create" ] &&
   [ "$SUBCOMMAND" != "help" ]; then
    echo "Error: Unknown sub-command '$SUBCOMMAND'"
    echo "Run '/project help' for available sub-commands"
    exit 1
fi
```

### Missing Arguments

```bash
if [ "$SUBCOMMAND" = "fix" ] && [ -z "$REMAINING_ARGS" ]; then
    echo "Error: 'fix' sub-command requires an issue number or identifier"
    echo "Usage: /project fix <issue-number>"
    exit 1
fi
```

### Project Context Validation

```bash
# Check if we're in a project directory
if [ ! -f "CLAUDE.md" ] && [ ! -d "specs" ] && [ ! -d ".git" ]; then
    echo "Warning: This doesn't appear to be a project directory"
    echo "Consider running '/project:setup [type]' first"
fi
```

## Integration Benefits

This unified command structure provides:

1. **Simplified Interface** - Single entry point for all project management tasks
2. **Consistent Workflows** - Common patterns across all sub-commands
3. **Better Discoverability** - Help system guides users to appropriate functionality
4. **Extensibility** - Easy to add new sub-commands without polluting command namespace
5. **Hook Integration** - Works seamlessly with the project update hook system
6. **Academic Focus** - Maintains discipline-specific workflows and best practices
7. **Professional Focus** - Aligns with industry standards for project management and development

The `/project` command replaces the need for separate project-update.md, tracking.md, fix-gh-issue.md, and create-specs.md commands while preserving all their functionality in a more organized, discoverable format.
