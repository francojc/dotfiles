# CopilotChat: Token-Efficient Knowledge Work Guide

A comprehensive guide to using CopilotChat for academic writing, research, and documentation with minimal token usage.

## Overview

This configuration optimizes CopilotChat for knowledge work (academic writing, research proposals, documentation) rather than code generation. It emphasizes:

- **Token efficiency**: Send only what you need via explicit context selection
- **Academic focus**: Prompts tailored for writing, research, and teaching
- **Flexible models**: Quick switching between AI models and temperature settings
- **Organized workflows**: WhichKey-integrated keymaps for discoverability

## Default Configuration

- **Model**: Claude Sonnet 4.5 (excellent for academic prose)
- **Temperature**: 0.4 (balanced structure and creativity)
- **History**: 5 items max (token-efficient conversation)
- **System prompt**: Focuses on academic tone and explicit context usage

## Context Variables (Token-Efficient)

Use these to send **only** what the AI needs:

| Variable | Description | Example Usage |
|----------|-------------|---------------|
| `#selection` | Current visual selection | Select text → `<leader>av` |
| `#buffer:active` | Entire active buffer | `<leader>ab` |
| `#file:path` | Specific file | `:CopilotChat #file:docs/intro.md` |
| `#gitdiff:staged` | Staged git changes | `<leader>ag` |
| `#diagnostics` | Current buffer diagnostics | `<leader>aw` |
| `#quickfix` | Quickfix list entries | `<leader>aq` |
| `#clipboard` | System clipboard | `:CopilotChat #clipboard` |

**Best Practice**: Always use context variables to avoid sending unnecessary content.

## Model Presets

Switch between optimized configurations for different work types:

### Quick Access

- `<leader>aM` - Interactive preset picker (shows current with ●)
- `<leader>aM1` - Academic mode (default)
- `<leader>aM2` - Creative mode
- `<leader>aM3` - Precise mode
- `<leader>aM4` - Research mode
- `<leader>aM5` - Code mode

### Preset Details

| Preset | Model | Temp | Best For |
|--------|-------|------|----------|
| **Academic** | Claude 4.5 | 0.4 | Default writing, proposals, documentation |
| **Creative** | Claude 4.5 | 0.7 | Brainstorming, ideation, exploration |
| **Precise** | GPT-5.2 | 0.2 | Editing, proofreading, final review |
| **Research** | Gemini 2.5 Pro | 0.5 | Literature synthesis, research analysis |
| **Code** | Claude 4.5 | 0.1 | Code review, debugging (when needed) |

**Example workflow**: Start in Academic mode, switch to Creative for brainstorming, then Precise for final editing.

## Knowledge Work Prompts

### Academic Writing

#### Outline Generation (`<leader>aAo`)
**Prompt**: "Create a detailed outline for this section"

**Example**:
```
Select: "Introduction paragraph about Spanish pedagogy..."
Press: <leader>aAo
Result: Structured outline with main points and sub-points
```

#### Clarify Academic Text (`<leader>aCl`)
**Prompt**: "Improve clarity while maintaining academic tone"

**Example**:
```
Select: Dense theoretical paragraph
Press: <leader>aCl
Result: Clearer version with precise language suggestions
```

#### Improve Flow (`<leader>aFl`)
**Prompt**: "Suggest improvements to flow and transitions"

**Example**:
```
Select: Multiple paragraphs with rough transitions
Press: <leader>aFl
Result: Enhanced connecting phrases and logical flow
```

#### Generate Section Headings (`<leader>aHd`)
**Prompt**: "Suggest descriptive section headings"

**Example**:
```
In document with sections
Press: <leader>aHd (uses whole buffer)
Result: Proposed heading structure based on content
```

#### Literature Synthesis (`<leader>aLr`)
**Prompt**: "Synthesize these ideas into coherent prose"

**Example**:
```
Select: Bullet points from multiple sources
Press: <leader>aLr
Result: Flowing paragraph integrating all sources
```

### Research & Planning

#### Identify Research Gaps (`<leader>aRg`)
**Prompt**: "Identify potential research gaps and weaknesses"

**Example**:
```
Select: Literature review section
Press: <leader>aRg
Result: Critical analysis of gaps, missing citations, underdeveloped arguments
```

#### Proposal Strength Evaluation (`<leader>aPs`)
**Prompt**: "Evaluate proposal persuasiveness"

**Example**:
```
Select: Grant proposal objectives section
Press: <leader>aPs
Result: Analysis of strengths and suggestions for improvement
```

#### SMART Objectives Check (`<leader>aOb`)
**Prompt**: "Review objectives against SMART criteria"

**Example**:
```
Select: Project objectives
Press: <leader>aOb
Result: Evaluation of Specific, Measurable, Achievable, Relevant, Time-bound criteria
```

#### Data Analysis Planning (`<leader>aDa`)
**Prompt**: "Develop data analysis plan"

**Example**:
```
Select: Research design description
Press: <leader>aDa
Result: Suggested analysis approaches for the research questions
```

#### Methodology Review (`<leader>aMr`)
**Prompt**: "Review methodology for rigor and clarity"

**Example**:
```
Select: Methods section
Press: <leader>aMr
Result: Assessment of rigor, replicability, appropriateness
```

### Teaching & Pedagogy

#### General Pedagogy Review (`<leader>aPr`)
**Prompt**: "Review for teaching effectiveness and engagement"

**Example**:
```
Select: Course syllabus or lesson plan
Press: <leader>aPr
Result: Analysis of learning outcomes, engagement, accessibility
```

#### Simplify for Teaching (`<leader>aSt`)
**Prompt**: "Rewrite for undergraduate students"

**Example**:
```
Select: Complex theoretical concept
Press: <leader>aSt
Result: Simplified version maintaining accuracy
```

#### Spanish Pedagogy Review (`<leader>aSp`)
**Prompt**: "Review for Spanish teaching effectiveness"

**Example**:
```
Select: Spanish course materials
Press: <leader>aSp
Result: Analysis of language acquisition principles, cultural integration
```

#### Bilingual Content Check (`<leader>aBl`)
**Prompt**: "Check bilingual content for consistency"

**Example**:
```
Select: English/Spanish parallel text
Press: <leader>aBl
Result: Verification of accuracy, cultural appropriateness, natural language
```

### Code Prompts (Existing)

These work with code when needed:

- `<leader>ae` - Explain code
- `<leader>ar` - Review code
- `<leader>af` - Fix code issues
- `<leader>ao` - Optimize code
- `<leader>ad` - Add documentation
- `<leader>at` - Generate tests
- `<leader>ac` - Generate commit message

## Quick Action Workflows

### Context-Specific Sends (Interactive)

These open the chat with pre-filled context, letting you add your prompt:

- `<leader>av` (visual) - Chat with selection
- `<leader>al` - Chat with current line
- `<leader>ab` - Chat with active buffer
- `<leader>ag` - Chat with git diff (staged)
- `<leader>aq` - Chat with quickfix entries
- `<leader>aw` - Chat with diagnostics

**Example**:
```
Select paragraph → <leader>av
Chat opens with: "#selection "
Type: "Make this more concise"
```

### Quick Visual Mode Actions

These execute immediately with selection:

- `<leader>aE` - Explain selection
- `<leader>aF` - Fix selection
- `<leader>aO` - Optimize selection

### Base Chat Controls

- `<leader>aa` - Toggle chat window
- `<leader>ax` - Close chat
- `<leader>aR` - Reset chat (clear history)
- `<leader>as` - Stop current response
- `<leader>ap` - Browse all prompts
- `<leader>am` - Select model manually

## Token Efficiency Best Practices

### 1. Use Visual Selection Liberally

**Good**:
```
Select specific paragraph → <leader>aCl
```

**Avoid**:
```
Open chat with whole document loaded
```

### 2. Combine Context Variables

```
:CopilotChat #selection #diagnostics Fix these errors in the selected code
```

### 3. Reset When Changing Topics

Press `<leader>aR` to clear history when switching to a new topic. This prevents old context from using tokens.

### 4. Use Appropriate Presets

- Writing draft → Academic mode (0.4 temp)
- Brainstorming → Creative mode (0.7 temp)
- Final edit → Precise mode (0.2 temp)

### 5. Keep History Short

The 5-item history limit is set by default. If you need more context, use resources (`#buffer`, `#file`) instead of relying on conversation history.

## Common Workflows

### Workflow 1: Draft a Research Proposal Section

1. **Brainstorm** (Creative mode):
   ```
   <leader>aM2 (switch to creative)
   Select rough notes → <leader>aAo (generate outline)
   ```

2. **Write** (Academic mode):
   ```
   <leader>aM1 (switch to academic)
   Write draft based on outline
   ```

3. **Review** (Precise mode):
   ```
   <leader>aM3 (switch to precise)
   Select draft → <leader>aCl (improve clarity)
   ```

### Workflow 2: Edit Documentation

1. Check overall structure:
   ```
   <leader>aHd (suggest section headings)
   ```

2. Improve specific sections:
   ```
   Select each section → <leader>aFl (improve flow)
   ```

3. Final clarity pass:
   ```
   <leader>aM3 (precise mode)
   Select each paragraph → <leader>aCl
   ```

### Workflow 3: Review Teaching Materials

1. Overall pedagogy check:
   ```
   Select syllabus → <leader>aPr
   ```

2. Simplify complex sections:
   ```
   Select dense content → <leader>aSt
   ```

3. Bilingual content verification (if applicable):
   ```
   Select Spanish/English sections → <leader>aBl
   ```

### Workflow 4: Literature Review Synthesis

1. Analyze current state:
   ```
   <leader>aM4 (research mode)
   Select literature review → <leader>aRg (find gaps)
   ```

2. Synthesize new sources:
   ```
   Select notes from multiple sources → <leader>aLr
   ```

3. Check flow:
   ```
   Select synthesized paragraph → <leader>aFl
   ```

## WhichKey Navigation

All keymaps are organized in WhichKey for easy discovery:

- Press `<leader>a` to see all Assistant commands
- Press `<leader>aA` to see Academic prompts
- Press `<leader>aP` to see Proposal/Pedagogy prompts
- Press `<leader>aR` to see Research prompts
- And so on...

Each group shows available commands with descriptions.

## Troubleshooting

### Chat not opening or slow to respond

1. Check Copilot status: `:Copilot status`
2. Ensure you're signed in: `:Copilot auth`
3. Try resetting: `<leader>aR`

### Model preset not switching

Verify the preset name is correct. Available: `academic`, `creative`, `precise`, `research`, `code`

### Too many tokens / context too large

1. Use `<leader>aR` to reset history
2. Use `#selection` instead of `#buffer`
3. Reduce the number of items in history (edit config: `history.max_items`)

### Prompts not appearing

1. Restart Neovim after configuration changes
2. Check for Lua errors: `:messages`
3. Verify CopilotChat is loaded: `:CopilotChat`

## Advanced Tips

### Custom Context in Commands

You can manually type context variables:

```
:CopilotChat #file:chapter1.md #file:chapter2.md Compare these chapters
```

### Combining Multiple Prompts

Use the prompt picker (`<leader>ap`) to combine multiple strategies.

### Saving Useful Conversations

Use `:CopilotChatSave session_name` to save a conversation for later reference.

### Model Recommendations by Task

| Task | Recommended Model | Reason |
|------|-------------------|--------|
| Academic writing | Claude 4.5 | Best prose, academic tone |
| Research synthesis | Gemini 2.5 Pro | Large context, excellent synthesis |
| Quick editing | GPT-5.2 | Fast, precise corrections |
| Brainstorming | Claude 4.5 | Creative yet structured |
| Bilingual content | Gemini 2.5 Pro | Strong multilingual capabilities |

## Summary

**Key Principles**:
1. Use context variables to send only what's needed
2. Switch model presets for different work types
3. Visual selection is your friend
4. Reset history when changing topics
5. Leverage prompts for common tasks

**Most Used Keymaps**:
- `<leader>av` - Chat with selection (most versatile)
- `<leader>aM` - Switch model preset
- `<leader>ap` - Browse all prompts
- `<leader>aR` - Reset chat

**Remember**: The goal is token efficiency without sacrificing quality. Always think "What's the minimum context the AI needs to help me?"
