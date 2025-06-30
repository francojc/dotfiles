#!/usr/bin/env bash

# setup-mcp-repos.sh - Set up MCP development environment using GitHub CLI
set -euo pipefail

# Script information
SCRIPT_NAME=$(basename "$0")
VERSION="1.0.0"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handler
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Help function
show_help() {
    printf "${GREEN}MCP Repository Setup Tool${NC} v${VERSION}\n\n"

    printf "${YELLOW}DESCRIPTION:${NC}\n"
    printf "    Sets up a Model Context Protocol (MCP) development environment with:\n"
    printf "    - Bare git repository for efficient storage\n"
    printf "    - Two worktrees: dev/ (development) and prod/ (production)\n"
    printf "    - Automatic fork creation if needed\n"
    printf "    - Upstream remote configuration\n\n"

    printf "${YELLOW}USAGE:${NC}\n"
    printf "    $SCRIPT_NAME [OPTIONS] <owner/repo>\n\n"

    printf "${YELLOW}OPTIONS:${NC}\n"
    printf "    -h, --help          Show this help message and exit\n"
    printf "    -v, --version       Show version information\n"
    printf "    -d, --dir <path>    Custom base directory (default: \$HOME/.local/mcp)\n"
    printf "    -n, --no-fork       Skip fork creation (assumes fork exists)\n\n"

    printf "${YELLOW}ARGUMENTS:${NC}\n"
    printf "    owner/repo          GitHub repository in format 'owner/repository'\n\n"

    printf "${YELLOW}EXAMPLES:${NC}\n"
    printf "    ${BLUE}# Set up a new MCP server project${NC}\n"
    printf "    $SCRIPT_NAME handle/mcp-server-example\n\n"

    printf "    ${BLUE}# Use custom directory${NC}\n"
    printf "    $SCRIPT_NAME --dir ~/projects/mcp handle/mcp-server-sqlite\n\n"

    printf "    ${BLUE}# Skip fork creation (if you already have a fork)${NC}\n"
    printf "    $SCRIPT_NAME --no-fork anthropics/mcp-server-demo\n\n"

    printf "${YELLOW}DIRECTORY STRUCTURE:${NC}\n"
    printf "    After setup, you'll have:\n"
    printf "    \${MCP_DIR}/\n"
    printf "    ├── dev/           # Development worktrees\n"
    printf "    │   └── project/   # Main/master branch\n"
    printf "    ├── prod/          # Production worktrees\n"
    printf "    │   └── project/   # Production branch\n"
    printf "    └── repos/         # Bare repositories\n"
    printf "        └── project.git/\n\n"

    printf "${YELLOW}REQUIREMENTS:${NC}\n"
    printf "    - GitHub CLI (gh) installed and authenticated\n"
    printf "    - Git version 2.15+ (for worktree support)\n"
    printf "    - Write access to the base directory\n\n"

    printf "${YELLOW}ENVIRONMENT VARIABLES:${NC}\n"
    printf "    MCP_DIR     Base directory for MCP projects (default: \$HOME/.local/mcp)\n\n"

    printf "${YELLOW}MORE INFORMATION:${NC}\n"
    printf "    GitHub CLI: https://cli.github.com\n"
    printf "    MCP Docs:   https://modelcontextprotocol.io\n\n"
}

# Parse command line options
BASE_DIR="${MCP_DIR:-$HOME/.local/mcp}"
SKIP_FORK=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "$SCRIPT_NAME v$VERSION"
            exit 0
            ;;
        -d|--dir)
            BASE_DIR="$2"
            shift 2
            ;;
        -n|--no-fork)
            SKIP_FORK=true
            shift
            ;;
        -*)
            error_exit "Unknown option: $1. Use --help for usage information."
            ;;
        *)
            REPO_SLUG="$1"
            shift
            ;;
    esac
done

# Validate that repo slug was provided
if [[ -z "${REPO_SLUG:-}" ]]; then
    echo -e "${RED}Error: Repository argument required${NC}" >&2
    echo "Use '$SCRIPT_NAME --help' for usage information."
    exit 1
fi

# Check for gh CLI
if ! command -v gh &> /dev/null; then
    error_exit "GitHub CLI (gh) is required but not installed. Install from: https://cli.github.com"
fi

# Check gh auth status
if ! gh auth status &> /dev/null; then
    error_exit "Not authenticated with GitHub. Run 'gh auth login' first"
fi

# Validate repo slug format
if [[ ! "$REPO_SLUG" =~ ^[^/]+/[^/]+$ ]]; then
    error_exit "Invalid repository format. Use 'owner/repo' format"
fi

# Extract owner and repo name
OWNER="${REPO_SLUG%/*}"
PROJECT="${REPO_SLUG#*/}"

# Get authenticated user
YOUR_USERNAME=$(gh api user -q .login) || error_exit "Failed to get GitHub username"

# Set base directory
BASE_DIR="${MCP_DIR:-$HOME/.local/mcp}"

echo -e "Setting up MCP development environment for ${YELLOW}$REPO_SLUG${NC}"
echo -e "Your GitHub username: ${GREEN}$YOUR_USERNAME${NC}"

# Check if directories already exist
if [[ -d "$BASE_DIR/repos/$PROJECT.git" ]]; then
    error_exit "Repository already exists at $BASE_DIR/repos/$PROJECT.git"
fi

# Check if upstream repo exists
echo "Checking upstream repository..."
if ! gh repo view "$REPO_SLUG" &> /dev/null; then
    error_exit "Repository $REPO_SLUG not found or not accessible"
fi

# Check if fork exists, create if needed
if [[ "$SKIP_FORK" == "false" ]]; then
    echo "Checking for existing fork..."
    if ! gh repo view "$YOUR_USERNAME/$PROJECT" &> /dev/null; then
        echo "Fork not found. Creating fork..."
        gh repo fork "$REPO_SLUG" --clone=false || error_exit "Failed to create fork"
        echo -e "${GREEN}Fork created successfully!${NC}"
        # Give GitHub a moment to process the fork
        sleep 2
    else
        echo -e "${GREEN}Fork already exists${NC}"
    fi
else
    echo "Skipping fork check (--no-fork specified)"
    # Verify fork exists when skipping
    if ! gh repo view "$YOUR_USERNAME/$PROJECT" &> /dev/null; then
        error_exit "Fork $YOUR_USERNAME/$PROJECT does not exist. Remove --no-fork flag to create it."
    fi
fi

# Create directory structure
echo "Creating directory structure..."
mkdir -p "$BASE_DIR"/{prod,repos,dev} || error_exit "Failed to create directories"

# Navigate to repos directory
cd "$BASE_DIR/repos/" || error_exit "Failed to change to repos directory"

# Clone fork as bare repository
echo "Cloning your fork as bare repository..."
if ! gh repo clone "$YOUR_USERNAME/$PROJECT" -- --bare; then
    error_exit "Failed to clone repository"
fi

cd "$PROJECT.git" || error_exit "Failed to enter repository directory"

# Add upstream remote (gh repo clone may have already added it)
echo "Configuring upstream remote..."
if git remote get-url upstream &>/dev/null; then
    echo "Upstream remote already exists, updating URL..."
    git remote set-url upstream "https://github.com/$OWNER/$PROJECT.git"
else
    echo "Adding upstream remote..."
    git remote add upstream "https://github.com/$OWNER/$PROJECT.git" || \
        error_exit "Failed to add upstream remote"
fi

# Fetch both remotes
echo "Fetching from origin..."
git fetch origin || error_exit "Failed to fetch from origin"

echo "Fetching from upstream..."
git fetch upstream || error_exit "Failed to fetch from upstream"

# Check default branch name
DEFAULT_BRANCH=$(gh repo view "$YOUR_USERNAME/$PROJECT" --json defaultBranchRef -q .defaultBranchRef.name)
DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}

# Create production branch before setting up worktrees
echo "Creating production branch from $DEFAULT_BRANCH..."
if ! git show-ref --verify --quiet refs/heads/production; then
    # In a bare repo, we need to use the local branch reference
    git branch production "$DEFAULT_BRANCH" || error_exit "Failed to create production branch"
    echo -e "${GREEN}Production branch created${NC}"
else
    echo "Production branch already exists"
fi

# Set up worktrees
echo "Setting up development worktree..."
if ! git worktree add "../../dev/$PROJECT" "$DEFAULT_BRANCH"; then
    error_exit "Failed to create development worktree"
fi

echo "Setting up production worktree..."
if ! git worktree add "../../prod/$PROJECT" production; then
    # Clean up dev worktree if prod fails
    echo "Cleaning up development worktree..."
    git worktree remove "../../dev/$PROJECT" 2>/dev/null || true
    rm -rf "../../dev/$PROJECT" 2>/dev/null || true
    error_exit "Failed to create production worktree - branch 'production' may not exist"
fi

# Success message
echo -e "\n${GREEN}✅ Setup complete!${NC}"
echo
echo "Repository info:"
echo "  Upstream: https://github.com/$OWNER/$PROJECT"
echo "  Your fork: https://github.com/$YOUR_USERNAME/$PROJECT"
echo
echo "Directory structure:"
echo -e "  ${YELLOW}$BASE_DIR/dev/$PROJECT${NC}  - Development worktree ($DEFAULT_BRANCH branch)"
echo -e "  ${YELLOW}$BASE_DIR/prod/$PROJECT${NC} - Production worktree (production branch)"
echo -e "  ${YELLOW}$BASE_DIR/repos/$PROJECT.git${NC} - Bare repository"
echo
echo "Next steps:"
echo "  1. cd $BASE_DIR/dev/$PROJECT"
echo "  2. git pull upstream $DEFAULT_BRANCH"
echo "  3. Start developing!"
echo
echo "Useful commands:"
echo -e "  ${GREEN}gh pr create${NC} - Create a pull request"
echo -e "  ${GREEN}gh pr view${NC} - View pull request in browser"
echo -e "  ${GREEN}gh repo sync${NC} - Sync your fork with upstream"
