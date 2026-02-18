---
description: Initialize Canvas assignment grading workflow and create assessment JSON file
args:
  - name: assignment_id
    description: Canvas assignment ID (auto-discovers if not provided)
    required: false
argument-hint: <Canvas assignment ID>
allowed-tools: Read, Write, AskUserQuestion, mcp__mcp-canvas__get_assignment_details, mcp__mcp-canvas__get_assignment_rubric_details, mcp__mcp-canvas__get_submissions_with_content, Glob
---

# Assessment Setup - Initialize Grading Workflow

Initialize the grading workflow for Canvas assignment {{assignment_id}}.

## Task Overview

Create the assessment JSON file with all student submissions and rubric structure, ready for AI evaluation.

## Step 1: Validate course_parameters.yaml

Check for `.claude/course_parameters.yaml` in the current repository.

**If missing**: Use `AskUserQuestion` to collect all fields, then create the file:

```yaml
course_title: "Exploring the Hispanic World"
course_code: "SPA-212-T"
canvas_course_id: 79384
term: "Spring"
year: 2026
level: "undergraduate"
feedback_language: "Spanish"
language_learning: true
language_level: "ACTFL Intermediate Mid"
formality: "casual"
```

Notes on field values:

- `level` specifies the educational setting: "undergraduate", "graduate", "professional", etc. This informs the depth and rigor of feedback expectations.
- `formality` controls tone across all feedback: "casual" or "formal". For Spanish courses, "casual" implies tú and "formal" implies usted. For English feedback, "casual" means academic casual tone and "formal" means standard academic tone.
- `language_learning: false` means `language_level` should be `"NA"`
- `feedback_language` accepts full names ("Spanish", "English")

**If present**: Parse YAML and validate all fields are populated. If any field is missing, prompt user for the missing values and update the file.

**Extract values for downstream use**:

- `canvas_course_id` becomes the `course_id` for all Canvas API calls
- Map `feedback_language` to language code: "Spanish" → `"es"`, "English" → `"en"`
- `level` carries through to metadata for agent context

## Step 2: Generate Assessment Structure

Fetch data from Canvas using three separate API calls:

### 2a. Get Assignment Details and Prompt

Use `mcp__mcp-canvas__get_assignment_details`:

- `course_identifier`: the `canvas_course_id` from course_parameters.yaml
- `assignment_id`: the assignment_id

This returns assignment metadata (name, due date, points possible, submission type) and the assignment description/instructions. Extract the `description` field — this is the **assignment prompt** that students responded to. Store it in the assessment JSON as `assignment_instructions`. This prompt is essential context for the AI evaluation step: it tells the evaluator what the student was asked to do.

### 2b. Get Rubric Structure

Use `mcp__mcp-canvas__get_assignment_rubric_details`:

- `course_identifier`: the `canvas_course_id`
- `assignment_id`: the assignment_id

This returns complete rubric with all criteria and rating levels.

### 2c. Get Student Submissions

Use `mcp__mcp-canvas__get_submissions_with_content`:

- `course_identifier`: the `canvas_course_id`
- `assignment_id`: the assignment_id
- `include_unsubmitted`: false
- `exclude_graded`: true (skips already-graded submissions)

**IMPORTANT - FERPA Compliance**: This function automatically filters submissions
to ONLY include students enrolled in the specified course. For cross-listed
assignments, submissions from other sections are excluded to prevent unauthorized
access to student data.

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
    "assignment_instructions": "...",
    "level": "undergraduate|graduate|...",
    "feedback_language": "en|es",
    "language_learning": true|false,
    "language_level": "ACTFL Intermediate Mid|NA",
    "formality": "casual|formal",
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

Copy these fields from course_parameters.yaml into the JSON metadata:

- `course_id` (from `canvas_course_id`)
- `level` (educational setting string)
- `feedback_language` (mapped to `"es"` or `"en"`)
- `language_learning` (boolean)
- `language_level` (string or `"NA"`)
- `formality` (`"casual"` or `"formal"`)

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

Course: {course_title} ({course_code})
Level: {level}
Term: {term} {year}
Feedback Language: {feedback_language}

Assignment: [assignment name]
Due Date: [due date]
Points Possible: [total points]

Course Enrollment: X students enrolled in this course

Submissions Found: Y students
- On time: A students
- Late: B students
- Already graded: C students (excluded by default)
- No submission: D students (skipped)
  Student IDs: [list of student IDs with no submissions]

Assignment Prompt: Captured ({word_count} words)

Rubric Structure:
- Number of criteria: [count]
- Total points: [points]
- Criteria overview:
  1. [criterion 1 name] - [max points] pts
  2. [criterion 2 name] - [max points] pts
  ...

Assessment File Created:
  assessments_{course_id}_{assignment_id}_{timestamp}.json

Note: Already-graded submissions were excluded to prevent overwriting existing grades.

Next Steps:
  Run `/assess:ai-pass` to begin AI evaluation of submissions
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
- **FERPA COMPLIANCE: Enrollment filtering enabled** - Only includes submissions from students enrolled in the specified course, preventing cross-section contamination in cross-listed assignments
- Creates fresh assessment file each time (timestamped to avoid conflicts)
- Preserves all rubric details for AI evaluation step

Begin setup now.
