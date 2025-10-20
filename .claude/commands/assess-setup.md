---
description: Initialize Canvas assignment grading workflow and create assessment JSON file
args:
  - name: course_id
    description: Canvas course ID (auto-discovers if not provided)
    required: false
  - name: assignment_id
    description: Canvas assignment ID (auto-discovers if not provided)
    required: false
---

# Assessment Setup - Initialize Grading Workflow

Initialize the grading workflow for Canvas assignment {{assignment_id}} in course {{course_id}}.

## Task Overview

Create the assessment JSON file with all student submissions and rubric structure, ready for AI evaluation.

## Step 1: Determine Course and Assignment IDs

**If arguments provided**:

- Use `course_id={{course_id}}` and `assignment_id={{assignment_id}}`

**If no arguments provided**:

- Search current directory for existing `assessments_*.json` files
- If found, extract course_id and assignment_id from most recent file
- If not found, ask user to provide course_id and assignment_id

## Step 2: Generate Assessment Structure

Use `mcp__mcp-canvas__generate_rubric_assessments` with:

- `course_identifier`: the course_id
- `assignment_id`: the assignment_id
- `output_dir`: current directory (`.`)
- `exclude_graded`: true (default: skips already-graded submissions)

This will:

- Fetch assignment details and rubric criteria. Make sure to include the apprpriate attributes that conform to the Canvas API.
- Retrieve all student submissions with text content
- Skip already-graded submissions (workflow_state = "graded")
- Create JSON file: `assessments_{course_id}_{assignment_id}_{timestamp}.json`
- Skip students without submissions automatically

## Step 3: Display Summary

Report the following information:

```
Assessment Setup Complete
========================

Assignment: [assignment name]
Due Date: [due date]
Points Possible: [total points]

Submissions Found: X students
- On time: Y students
- Late: Z students
- Already graded: A students (excluded by default)
- No submission: W students (skipped)

Rubric Structure:
- Number of criteria: [count]
- Total points: [points]
- Criteria overview:
  1. [criterion 1 name] - [max points] pts
  2. [criterion 2 name] - [max points] pts
  ...

Assessment File Created:
  📄 assessments_{course_id}_{assignment_id}_{timestamp}.json

Note: Already-graded submissions were excluded to prevent overwriting existing grades.

Next Steps:
  Run `/assess-ai-prelim` to begin AI evaluation of submissions
```

## Step 4: Save State

Create `.claude/state/assessment_state.json` with:

```json
{
  "last_assessment_file": "assessments_{course_id}_{assignment_id}_{timestamp}.json",
  "course_id": "{course_id}",
  "assignment_id": "{assignment_id}",
  "created_at": "{timestamp}",
  "total_submissions": X
}
```

This allows subsequent commands to auto-discover the assessment file.

## Error Handling

- If course_id or assignment_id invalid: Report error and ask user to verify
- If no submissions found: Report warning but create file anyway
- If rubric not found: Report error - assignment must have rubric for this workflow
- If file already exists: Ask user if they want to overwrite or use existing file

## Important Notes

- Only processes assignments with online_text_entry submission type
- Automatically skips students who haven't submitted
- **Excludes already-graded submissions by default** to prevent overwriting existing grades
- Creates fresh assessment file each time (timestamped to avoid conflicts)
- Preserves all rubric details for AI evaluation step

Begin setup now.
