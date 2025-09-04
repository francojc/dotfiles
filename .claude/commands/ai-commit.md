---
description: Automatically stage all changes and commit with AI-generated message
argument-hint: [optional-message-override]
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*)
---

# AI Git Commit Command

Analyze the current git changes and create an intelligent commit with a generated message that describes what was actually changed.

## Process:

1. **Stage all changes** using `git add --all`
2. **Analyze the diff** to understand what files were added, modified, or deleted
3. **Generate contextual commit message** based on:
   - File types (JavaScript, Python, CSS, documentation, etc.)
   - Nature of changes (add, update, remove, mixed)
   - Number of files affected
4. **Show preview** of the generated message
5. **Commit with confirmation**

## Usage Examples:

- `/ai-commit` - Analyze changes and generate commit message
- `/ai-commit "Custom message override"` - Use provided message instead

## Command Logic:

First, check if we're in a git repository and have changes to commit:

```bash
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

if git diff --quiet && git diff --cached --quiet; then
    echo "✅ No changes to commit"
    exit 0
fi
```

Stage all changes:

```bash
git add --all
```


If user provided a custom message via $ARGUMENTS, use that:

```bash
if [ -n "$ARGUMENTS" ]; then
    echo "Using custom message: $ARGUMENTS"
    git commit -m "$ARGUMENTS"
    echo "✅ Committed with custom message!"
    exit 0
fi
```

Otherwise, analyze the staged changes to generate an intelligent message:

```bash
# Get file change statistics
DIFF_OUTPUT=$(git diff --cached --stat)
DETAILED_DIFF=$(git diff --cached --name-status)

echo "📊 Changes to commit:"
echo "$DIFF_OUTPUT"
echo
```

Generate the commit message based on change patterns:

- Count added (A), modified (M), and deleted (D) files
- Identify file types by extensions (.js, .py, .css, .md, etc.)
- Create contextual messages like:
  - "Add navbar component - JavaScript updates"
  - "Update 3 files - Documentation changes"
  - "Mixed changes: add 2, update 1 - Python refactoring"
  - "Remove deprecated utils - Cleanup"

Show the generated message and ask for confirmation:

```bash
echo "🧠 Generated commit message:"
echo "\"$COMMIT_MESSAGE\""
echo

read -p "Commit with this message? (y/n): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git commit -m "$COMMIT_MESSAGE"
    echo "✅ Successfully committed!"
    git log --oneline -1
else
    echo "❌ Commit cancelled (changes remain staged)"
fi
```

