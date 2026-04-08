---
name: memory-recall
description: |
  Triggered when user mentions recalling previous work, remembering past sessions,
  or asking about things done before. Automatically retrieves relevant episodic memories.
  Use when user input contains keywords like: remember, recall, previous work, similar to,
  we did before, last time, earlier, like when we, etc.
---

# Memory Recall Skill

You are activated when the user mentions keywords related to past work or previous sessions.

## When to Use

Trigger this skill when user input contains phrases like:
- "remember when we..."
- "like with the previous..."
- "recall that project..."
- "similar to what we did..."
- "last time we..."
- "can you recall..."

## How to Use

1. Extract the query from the user's message (what they're trying to recall)
2. Extract optional date context (e.g., "last week", "yesterday", "a month ago")
3. Extract optional project filter (if they mention a specific project)
4. Call the `memory_recall` tool with these parameters
5. Incorporate the returned relevant sessions into your response

## Parameters

- **query**: The topic/project/task being asked about (required)
- **dateRange**: Optional time context ("last week", "yesterday", "recently")
- **projectFilter**: Optional project path filter
- **limit**: Max results (default 3, use 2-3 for context window efficiency)

## Example

User: "Remember that React component we built last week for the dotfiles project?"

Action:
1. Call `memory_recall` with:
   - query: "React component"
   - projectFilter: "dotfiles"
   - dateRange: "last week"
   - limit: 2

2. Based on results, answer with context from relevant sessions

## Response Style

- Be conversational: "Yes, I recall we worked on..."
- Reference the specific date and project
- Summarize what was done
- Connect to the current question
