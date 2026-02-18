---
allowed-tools: Read, Grep, Edit, Bash, Write, AskUserQuestion
description: |
  Create complete project scaffolding for research, teaching, grant, service, or application projects including CLAUDE.md, specs/, logs/ directories, and development environment setup.
---

Set up a comprehensive project structure with documentation, planning, and development environment.

**Usage:** /project:setup [type] [optional-name]

**Prerequisites:** Project description file (README.md, PROJECT.md, CONCEPT.md, or PROPOSAL.md) with meaningful project details

## Unified Project Setup

### Supported Project Types

- **research** - Research projects with data collection, analysis, and publication workflows
- **teaching** - Course development, pedagogical design, and educational materials
- **grant** - Proposal development, funding applications, and compliance tracking
- **service** - Committee work, governance, and institutional service
- **application** - Software development projects (CLI tools, web apps, APIs, libraries)

### Setup Process

1. **Validate Project Prerequisites**
   - Check for project description document (README.md or equivalent)
   - Validate minimum content requirements for meaningful scaffolding
   - Extract project context for intelligent template customization
   - Block setup if insufficient project information available

2. **Parse Arguments and Detect Project Type**
   - Extract project type from first argument
   - Use project name from remaining arguments or current directory name
   - Validate project type against supported options
   - Read project description for context-aware setup

3. **Create Project Structure with Context**
   - Generate CLAUDE.md with project-specific content from description
   - Create specs/ directory with contextually appropriate templates
   - Create logs/ directory for weekly reviews and session logs
   - Set up development environment (flake.nix)
   - Configure project-specific .gitignore patterns

4. **Implementation Steps**
   - Check for existing files to avoid overwriting
   - Create specs/ directory if it doesn't exist
   - Generate specs files from templates with intelligent content population
   - Copy flake.nix template if no Nix configuration exists
   - Create/update .gitignore with project-specific patterns

## Project Type Configurations

### Research Projects

**Templates:**

- specs/planning.md: `~/.dotfiles/.claude/commands/templates/specs/research-planning.md`
- specs/progress.md: `~/.dotfiles/.claude/commands/templates/specs/research-progress.md`
- specs/implementation.md: `~/.dotfiles/.claude/commands/templates/specs/research-implementation.md`

**CLAUDE.md Requirements:**

- Research question and objectives
- Methodology and data collection plans
- Analysis approach and tools
- Publication and dissemination strategy
- Timeline and milestones
- Ethical considerations and IRB status

**Gitignore Patterns:**

```
# Sensitive research data
data/raw/participants/
data/confidential/
surveys/responses/

# Analysis outputs
analysis/exploratory/
models/intermediate/
results/drafts/

# Academic writing
manuscripts/drafts/
reviews/peer_review/
.DS_Store
```

### Teaching Projects  

**Templates:**

- specs/planning.md: `~/.dotfiles/.claude/commands/templates/specs/teaching-planning.md`
- specs/progress.md: `~/.dotfiles/.claude/commands/templates/specs/teaching-progress.md`
- specs/implementation.md: `~/.dotfiles/.claude/commands/templates/specs/teaching-implementation.md`

**CLAUDE.md Requirements:**

- Course overview and learning objectives
- Pedagogical approach and teaching philosophy
- Assessment strategy and grading criteria
- Student engagement and participation methods
- Technology integration and digital tools
- Accessibility and inclusive design considerations

**Gitignore Patterns:**

```
# Student information
roster/personal_info/
grades/individual/
feedback/private/

# Course materials
exams/answers/
assignments/solutions/
videos/raw_recordings/

# Administrative
syllabus/drafts/
.DS_Store
```

### Grant Projects

**Templates:**

- specs/planning.md: `~/.dotfiles/.claude/commands/templates/specs/grant-planning.md`
- specs/progress.md: Create grant-specific progress template
- specs/implementation.md: Create grant-specific implementation template

**CLAUDE.md Requirements:**

- Grant opportunity overview and funder information
- Proposal abstract and project concept
- Principal investigators and collaborators
- Narrative sections and component responsibilities
- Budget and compliance requirements
- Timeline and submission plan

**Gitignore Patterns:**

```
# Sensitive proposal information
budgets/internal/
personnel/private/
reviews/confidential/

# Version control for collaborative writing
*.docx~
*_tracked_changes.docx
narrative/drafts/

# Submission files
final_submission/
archive/
.DS_Store
```

### Service Projects

**Templates:**

- specs/planning.md: `~/.dotfiles/.claude/commands/templates/specs/service-planning.md`
- specs/progress.md: Create service-specific progress template
- specs/implementation.md: Create service-specific implementation template

**CLAUDE.md Requirements:**

- Committee overview and scope
- Purpose, goals, and deliverables
- Membership and roles
- Meeting structure and documentation
- Communication and collaboration methods
- Repository structure and organization

**Gitignore Patterns:**

```
# Confidential committee materials
personnel_files/
evaluations/private/
executive_sessions/

# Meeting materials
minutes/drafts/
recordings/
sensitive_documents/

# Administrative files
.DS_Store
*.tmp
backup/
archive/old/
```

### Application Projects

**Interactive Setup:** When the `application` type is selected, first read the project description document (README.md or equivalent) and attempt to infer:

1. **Application type** — CLI tool, web application, API service, library/package, desktop app, or mobile app
2. **Primary language and framework** — e.g., Python + FastAPI, Rust CLI, TypeScript + React
3. **Key goals** — what the software should accomplish

Then use `AskUserQuestion` to present the inferred answers for confirmation and ask about any details that could not be determined from the README. Pre-populate option labels with the best guess from the README where possible, so the user can confirm with a single click or override with a different choice.

Incorporate the confirmed answers into the generated specs and CLAUDE.md content.

**Templates:**

- specs/planning.md: `~/.dotfiles/.claude/commands/templates/specs/application-planning.md`
- specs/progress.md: `~/.dotfiles/.claude/commands/templates/specs/application-progress.md`
- specs/implementation.md: `~/.dotfiles/.claude/commands/templates/specs/application-implementation.md`

**CLAUDE.md Requirements:**

- Software purpose and target users
- Architecture overview and key components
- Build, test, and run commands (exact commands)
- Language, framework, and dependency management
- Directory structure with source, test, and config locations
- Development workflow and contribution guidelines

**Gitignore Patterns:**

```
# Build artifacts
dist/
build/
target/
*.egg-info/
__pycache__/

# Dependencies (when not vendored)
node_modules/
.venv/

# Environment and secrets
.env
.env.local
*.pem
credentials.json

# IDE and OS
.DS_Store
.idea/
.vscode/
*.swp
```

## Implementation Logic

### Step 1: Project Prerequisites Validation


```bash
# Check for project description document
PROJECT_DOC=""
if [ -f "README.md" ]; then
    PROJECT_DOC="README.md"
elif [ -f "PROJECT.md" ]; then
    PROJECT_DOC="PROJECT.md"
elif [ -f "CONCEPT.md" ]; then
    PROJECT_DOC="CONCEPT.md"
elif [ -f "PROPOSAL.md" ]; then
    PROJECT_DOC="PROPOSAL.md"
else
    echo "Error: No project description found"
    echo ""
    echo "Please create a project description file with basic information:"
    echo "  README.md (recommended) or PROJECT.md/CONCEPT.md/PROPOSAL.md"
    echo ""
    echo "Required content:"
    echo "  - Project overview and objectives"
    echo "  - Key research questions or goals"
    echo "  - Expected outcomes and approach"
    echo "  - Timeline or scope considerations"
    echo ""
    echo "Example for research project:"
    echo '  # Spanish Dialect Corpus Analysis'
    echo '  ## Overview'
    echo '  This project analyzes phonetic variation in Andalusian Spanish...'
    echo '  ## Research Questions'
    echo '  - How does social class affect vowel reduction?'
    echo '  - What are the geographic distribution patterns?'
    echo '  ## Methodology'
    echo '  Mixed-methods approach combining sociolinguistic interviews...'
    echo ""
    echo "Then run /project:setup again."
    exit 1
fi

# Validate minimum content (basic check for project structure)
if [ $(wc -l < "$PROJECT_DOC") -lt 5 ]; then
    echo "Error: Project description in $PROJECT_DOC appears too brief"
    echo "Please add more detail about your project before running setup."
    echo "A meaningful description helps generate better scaffolding."
    exit 1
fi

echo "✓ Found project description: $PROJECT_DOC"
```


### Step 2: Argument Parsing and Project Context


```bash
# Parse first argument as project type
PROJECT_TYPE="$1"
shift

# Remaining arguments form project name, or use directory name, or extract from description
if [ $# -gt 0 ]; then
    PROJECT_NAME="$*"
else
    # Try to extract project name from description file first line
    FIRST_LINE=$(head -n 1 "$PROJECT_DOC" | sed 's/^# *//')
    if [ -n "$FIRST_LINE" ] && [ "$FIRST_LINE" != "$PROJECT_DOC" ]; then
        PROJECT_NAME="$FIRST_LINE"
    else
        PROJECT_NAME=$(basename "$PWD")
    fi
fi

# Validate project type
case "$PROJECT_TYPE" in
    research|teaching|grant|service|application)
        echo "Setting up $PROJECT_TYPE project: $PROJECT_NAME"
        echo "Using context from: $PROJECT_DOC"
        ;;
    *)
        echo "Error: Invalid project type '$PROJECT_TYPE'"
        echo "Supported types: research, teaching, grant, service, application"
        exit 1
        ;;
esac
```


### Step 3: Context-Aware Template Application


```bash
# Create specs and logs directories
mkdir -p specs logs

# Apply project-specific templates with intelligent content population
TEMPLATE_DIR="$HOME/.dotfiles/.claude/commands/templates/specs"

# Copy and customize templates with project context
for template in planning progress implementation; do
    if [ -f "$TEMPLATE_DIR/${PROJECT_TYPE}-${template}.md" ]; then
        echo "Generating ${template}.md with project context..."
        
        # Basic placeholder replacement
        sed "s/{PROJECT_NAME}/$PROJECT_NAME/g; s/{DATE}/$(date '+%Y-%m-%d')/g" \
            "$TEMPLATE_DIR/${PROJECT_TYPE}-${template}.md" > "specs/${template}.md"
        
        # Enhanced context integration: 
        # Claude will read $PROJECT_DOC and intelligently populate templates
        # with project-specific research questions, objectives, methodologies,
        # timelines, and other contextually appropriate content beyond basic
        # placeholder replacement
    fi
done

echo "✓ Generated specs/ templates with project context"
echo "  Note: Templates include project-specific context from $PROJECT_DOC"
echo "  Review and customize the generated files as needed."
```

### Step 4: Environment Setup


```bash
# Copy flake.nix if not present
if [ ! -f "flake.nix" ]; then
    cp "$HOME/.dotfiles/.claude/commands/templates/flake.nix" .
fi

# Create/update .gitignore
cat >> .gitignore << EOF
# Project-specific patterns for $PROJECT_TYPE project
[project-specific patterns based on type]
EOF
```

### Step 5: CLAUDE.md Generation with Context Integration


Create comprehensive project documentation based on project type requirements, incorporating:

- Project-specific sections and requirements from existing description
- Academic best practices for the discipline
- Integration with specs/ structure and project context
- Clear usage guidance for Claude assistance
- Enhanced content based on README.md/project description analysis

The command will read the project description document and use it to:

- Extract key research questions, objectives, or goals
- Identify relevant methodologies and approaches
- Populate CLAUDE.md with contextually appropriate guidance
- Generate project-specific instructions for Claude assistance

## Usage Examples

### Enhanced Workflow with Project Description

```bash
# Step 1: Create project description first
cat > README.md << 'EOF'
# Spanish Dialect Corpus Analysis

## Overview
This project analyzes phonetic variation in Andalusian Spanish through 
corpus-based sociolinguistic analysis, focusing on vowel reduction patterns.

## Research Questions
- How does social class affect vowel reduction in unstressed syllables?
- What are the geographic distribution patterns across Andalusian provinces?
- Do age and gender intersect with class in predictable ways?

## Methodology  
Mixed-methods approach combining:
- Sociolinguistic interviews (n=120 speakers)
- Acoustic analysis using Praat
- Statistical modeling with R

## Expected Outcomes
- Peer-reviewed publication in Journal of Sociolinguistics
- Conference presentations at LSA and NWAV
- Open dataset for future comparative studies
EOF

# Step 2: Then run project setup (project name extracted from title)
/project:setup research

# Alternative: Specify custom project name
/project:setup research "Andalusian Vowel Study"
```

### Project Type Examples

```bash
# Teaching project (after creating course description)
/project:setup teaching "Advanced Linguistic Analysis"

# Grant proposal (after creating preliminary proposal concept)
/project:setup grant "NSF Linguistics Research Proposal"

# Service committee (after creating committee charter/description)
/project:setup service "Faculty Search Committee"

# Application project (will prompt for app type, language, goals)
/project:setup application "corpus-query-tool"
```

### Error Prevention Examples

```bash
# This will fail with helpful guidance:
/project:setup research "My Study"
# Error: No project description found
# Please create a project description file...

# This will also fail:
echo "# Brief title" > README.md
/project:setup research
# Error: Project description in README.md appears too brief
# Please add more detail about your project...
```

## Success Criteria

After successful setup:
- [ ] **Project Description Validated:** README.md or equivalent with sufficient detail
- [ ] **CLAUDE.md Generated:** Project-specific content derived from description
- [ ] **Specs/ Directory Created:** planning.md, progress.md, implementation.md with context
- [ ] **Logs/ Directory Created:** ready for weekly reviews and session logs
- [ ] **Environment Setup:** flake.nix file for reproducible environment
- [ ] **Project Configuration:** .gitignore with appropriate patterns
- [ ] **Context Integration:** Templates populated with project-specific information
- [ ] **Academic Workflow Ready:** Directory structure prepared for discipline-specific work

## Enhanced Benefits

This enhanced setup command provides:

### **Intelligent Scaffolding**

- Templates populated with actual project context rather than generic placeholders
- Research questions, objectives, and methodologies derived from project description
- Realistic timelines and milestones based on project scope and complexity

### **Academic Rigor** 

- Enforces thoughtful project conception before setup
- Ensures meaningful project documentation from the start
- Promotes proper academic planning sequence

### **Time Efficiency**

- Reduces manual template customization after setup
- Generates contextually appropriate starting content
- Better integration between project description and formal documentation

### **Quality Assurance**

- Prevents setup with insufficient project information
- Encourages comprehensive project planning
- Creates foundation for effective Claude assistance throughout project lifecycle

This unified setup command replaces the need for separate research.md, teaching.md, grant.md, and service.md commands while maintaining all their functionality and adding intelligent context integration.
