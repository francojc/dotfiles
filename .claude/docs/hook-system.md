# Claude Code Hook System Documentation

## Overview

The Claude Code hook system provides automatic project tracking and documentation updates through shell commands that execute at specific points in the Claude workflow. This system enables seamless integration between Claude sessions and project management without manual intervention.

## Architecture

### Hook Types

Claude Code supports several hook types that trigger at different workflow stages:

- **Stop hooks**: Execute when Claude finishes responding to a user query
- **PreToolUse hooks**: Execute before Claude uses any tool
- **PostToolUse hooks**: Execute after Claude completes tool usage
- **SubagentStop hooks**: Execute when subagents complete their tasks

### Configuration Structure

Hooks are configured in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Blow.aiff"
          },
          {
            "type": "command",
            "command": "/Users/francojc/.dotfiles/.claude/scripts/project-update-hook.sh"
          }
        ]
      }
    ]
  }
}
```

### Hook Execution

- **Sequential Processing**: Hooks execute in the order they appear in the configuration
- **Silent Failure**: Hook failures don't interrupt Claude's workflow
- **Working Directory**: Hooks execute in the current working directory where Claude is running
- **Environment**: Hooks inherit the shell environment from Claude

## Project Update Hook Implementation

### Detection Logic

The project update hook (`project-update-hook.sh`) uses a multi-criteria approach to identify project directories:

```bash
is_project_directory() {
  # Check for CLAUDE.md file (primary indicator)
  if [[ -f "CLAUDE.md" ]]; then
    return 0
  fi
  
  # Check for .claude/commands directory (custom commands)
  if [[ -d ".claude/commands" ]]; then
    return 0
  fi
  
  # Check for specs directory (academic projects)
  if [[ -d "specs" ]]; then
    return 0
  fi
  
  return 1
}
```

### Project Type Classification

The hook analyzes `CLAUDE.md` content to classify projects:

- **Research**: Keywords like "methodology", "hypothesis", "data collection"
- **Teaching**: Keywords like "course", "students", "learning", "pedagogical"
- **Grant**: Keywords like "proposal", "funding", "sponsor"
- **Service**: Keywords like "committee", "governance", "meeting"
- **Development**: Keywords like "software", "application", "code"
- **Generic**: Default fallback for unmatched projects

### Logging Mechanisms

The hook adapts to existing project documentation patterns:

1. **Primary**: `specs/progress.md` (academic projects)
2. **Secondary**: `PROGRESS.md` (general projects)
3. **Tertiary**: `CHANGELOG.md` (development projects)
4. **Fallback**: `.claude/session-log.md` (created automatically)

### Git Integration

The hook tracks development activity by counting commits since the last session:

```bash
count_recent_commits() {
  local last_hook_file=".claude/last-hook-run"
  local commit_count=0
  
  if [[ -f "${last_hook_file}" ]]; then
    local last_run=$(cat "${last_hook_file}")
    commit_count=$(git rev-list --count --since="${last_run}" HEAD)
  else
    # First run - count commits from last 24 hours
    commit_count=$(git rev-list --count --since="24 hours ago" HEAD)
  fi
  
  echo "${commit_count}"
}
```

## Benefits

### 1. Automatic Progress Tracking

- **Zero Manual Effort**: Sessions logged automatically without workflow interruption
- **Consistent Documentation**: Every Claude session recorded with timestamp and git activity
- **Project Context Awareness**: Logs adapt to existing project structure and conventions

### 2. Workflow Continuity

- **Session Memory**: Track accomplishments across multiple Claude conversations
- **Git Correlation**: Links Claude work with actual code/document changes
- **Historical Record**: Build long-term project development timeline

### 3. Academic Workflow Enhancement

#### Research Projects
- Track analysis sessions and methodology development
- Monitor data collection and processing progress
- Document writing and revision cycles

#### Teaching Projects
- Log course development and material creation
- Track assessment design and pedagogical improvements
- Monitor student feedback integration

#### Grant Projects
- Document proposal writing sessions and collaboration
- Track deadline progress and milestone completion
- Monitor compliance and submission preparation

#### Service Projects
- Log committee work and meeting preparation
- Track administrative task completion
- Document governance and policy development

### 4. Integration Benefits

- **Command Synergy**: Enhances `/project-status` and `/project-update` commands with rich activity data
- **AI Context**: Provides more information for intelligent recommendations
- **Workflow Intelligence**: Enables pattern recognition across project types

## Configuration Options

### Environment Variables

Control hook behavior through environment variables:

```bash
# Disable the hook entirely
export PROJECT_HOOK_ENABLED=false

# Enable verbose logging (for debugging)
export PROJECT_HOOK_DEBUG=true
```

### Customization

Modify the hook script to customize behavior:

1. **Project Detection**: Add new indicators in `is_project_directory()`
2. **Project Types**: Extend classification in `get_project_type()`
3. **Logging Targets**: Modify file selection in `log_session_completion()`
4. **Log Format**: Customize entry format and content

### Log File Locations

- **Hook Activity**: `~/.claude/project-hook.log`
- **Session Timestamps**: `.claude/last-hook-run` (per project)
- **Session History**: Varies by project structure

## Real-World Usage Examples

### Research Project Workflow

```
$ cd ~/research/corpus-analysis
$ claude "Help me analyze the frequency distribution"
[Claude session with data analysis]
$ # Hook automatically logs: "2024-07-14 15:30:45 - Claude session completed (2 new commits since last update)"

$ claude "/project-status"
[Command finds rich session history for analysis]
```

### Development Project Workflow

```
$ cd ~/dev/web-app
$ claude "Add user authentication feature"
[Claude session with code implementation]
$ # Hook logs to CHANGELOG.md: "2024-07-14 16:45:22 - Claude session completed (5 new commits since last update)"

$ claude "/project-update"
[Command uses session data for next-step recommendations]
```

### Multi-Project Benefits

The hook system works across all your projects:
- Automatically detects context switching
- Maintains separate session logs per project
- Provides consistent tracking regardless of project type

## Troubleshooting

### Common Issues

#### Hook Not Executing
- **Check**: Hook script is executable (`chmod +x`)
- **Check**: Path in settings.json is correct and absolute
- **Check**: `PROJECT_HOOK_ENABLED` environment variable

#### Permission Errors
- **Solution**: Ensure hook script has proper permissions
- **Solution**: Check write permissions for log directories

#### Git Integration Problems
- **Issue**: "not a git repository" errors
- **Solution**: Hook gracefully handles non-git directories
- **Check**: Git repository initialization

#### Log File Issues
- **Issue**: Cannot write to log files
- **Solution**: Hook creates directories as needed
- **Check**: Disk space and permissions

### Debugging

Enable debug mode for detailed logging:

```bash
export PROJECT_HOOK_DEBUG=true
```

Monitor hook activity:

```bash
tail -f ~/.claude/project-hook.log
```

Test hook manually:

```bash
cd /path/to/project
/Users/francojc/.dotfiles/.claude/scripts/project-update-hook.sh
```

### Performance Considerations

- **Lightweight Operation**: Hook completes in <100ms typically
- **Silent Failure**: Errors don't impact Claude performance
- **Resource Usage**: Minimal CPU and memory footprint
- **Network**: No network dependencies

## Integration with Current Commands

### `/project-status` Command Enhancement

The hook provides rich data for project status analysis:
- Session frequency and timing patterns
- Git activity correlation with Claude work
- Project momentum indicators

### `/project update` Command Benefits

Session logs enable intelligent recommendations:
- Context-aware next steps based on recent activity
- Pattern recognition across project types
- Automated documentation synchronization

### Custom Command Development

Use hook data in custom commands:

```bash
# Access session timestamps
cat .claude/last-hook-run

# Analyze session patterns
grep "Claude session completed" specs/progress.md | tail -10

# Correlate with git activity
git log --since="$(cat .claude/last-hook-run)" --oneline
```

## Security and Privacy

### Data Handling

- **Local Only**: All data stays on your machine
- **No Network**: Hook doesn't transmit any information
- **Minimal Logging**: Only timestamps and commit counts
- **Configurable**: Full user control over operation

### Sensitive Projects

For sensitive work:
- Disable globally: `export PROJECT_HOOK_ENABLED=false`
- Disable per-project: Create `.project_hook_disabled` file
- Review logs regularly and clean as needed

## Maintenance

### Regular Tasks

- **Log Rotation**: Monitor `~/.claude/project-hook.log` size
- **Cleanup**: Remove old session logs if needed
- **Updates**: Keep hook script updated with new features

### Backup Considerations

Include in your backup strategy:
- Hook configuration (`~/.claude/settings.json`)
- Session logs (`specs/progress.md`, etc.)
- Hook timestamps (`.claude/last-hook-run`)

## Future Enhancements

### Planned Features

- **Rich Logging**: Capture more session context
- **Analytics**: Generate usage reports and insights
- **Integration**: Connect with external project management tools
- **Collaboration**: Share session data across team members

### Customization Ideas

- **Slack Integration**: Post session summaries to channels
- **Time Tracking**: Monitor session duration and productivity
- **AI Enhancement**: Use session patterns for better recommendations
- **Project Templates**: Auto-setup based on session patterns

## Conclusion

The Claude Code hook system transforms Claude from a session-based assistant into an integrated project workflow tool. By automatically tracking sessions and correlating them with project development, it provides the foundation for intelligent project management and continuous improvement of academic and development workflows.

The system's design prioritizes reliability, flexibility, and user control while remaining completely transparent and optional. Whether working on research, teaching, grants, or development projects, the hook system adapts to your existing patterns while enhancing them with automated intelligence.