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

Fetch data from Canvas using three separate API calls:

### 2a. Get Assignment Details

Use `mcp__mcp-canvas__get_assignment_details`:

- `course_identifier`: the course_id
- `assignment_id`: the assignment_id

This returns assignment metadata (name, due date, points possible, submission type).

### 2b. Get Rubric Structure

Use `mcp__mcp-canvas__get_assignment_rubric_details`:

- `course_identifier`: the course_id
- `assignment_id`: the assignment_id

This returns complete rubric with all criteria and rating levels.

### 2c. Get Student Submissions

Use `mcp__mcp-canvas__get_submissions_with_content`:

- `course_identifier`: the course_id
- `assignment_id`: the assignment_id
- `include_unsubmitted`: false
- `exclude_graded`: true (skips already-graded submissions)

This returns all student submissions with extracted text content from uploaded files (DOCX, PDF).

### 2d. Construct Assessment JSON

Manually create the JSON file `assessments_{course_id}_{assignment_id}_{timestamp}.json` using the `Write` tool with this structure:

```json
{
  "metadata": {
    "course_id": "...",
    "course_name": "...",
    "assignment_id": "...",
    "assignment_name": "...",
    "due_date": "...",
    "points_possible": ...,
    "total_submissions": ...,
    "created_at": "...",
    "workflow_version": "1.0"
  },
  "rubric": {
    "total_points": ...,
    "criteria_count": ...,
    "criteria": {
      "criterion_id": {
        "description": "...",
        "max_points": ...,
        "ratings": [...]
      }
    }
  },
  "assessments": [
    {
      "user_id": ...,
      "user_name": "...",
      "user_email": "...",
      "submission_id": ...,
      "submitted_at": "...",
      "late": false,
      "word_count": ...,
      "submission_text": "...",
      "rubric_assessment": {
        "criterion_id": {
          "points": null,
          "rating_id": null,
          "justification": ""
        }
      },
      "overall_comment": "",
      "reviewed": false,
      "approved": false
    }
  ],
  "ai_instructions": "..."
}
```

This will:

- Combine data from all three API calls into one assessment file
- Skip already-graded submissions (workflow_state = "graded")
- Skip students without submissions automatically
- Extract text from uploaded DOCX and PDF files

Finally, save the resulting JSON file:

- Create `.claude/assessments/` if it doesn't exist.
- Write this file to `.claude/assessments/{course_id}_{assignment_id}_{timestamp}.json`.

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

- Supports `online_upload` submission types with automatic text extraction from DOCX and PDF files
- Supports `online_text_entry` submission types
- Automatically skips students who haven't submitted
- **Excludes already-graded submissions by default** to prevent overwriting existing grades
- Creates fresh assessment file each time (timestamped to avoid conflicts)
- Preserves all rubric details for AI evaluation step

Begin setup now.
