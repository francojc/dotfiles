---
description: Submit approved assessments to Canvas gradebook with rubric-based grading
args:
  - name: course_id
    description: Canvas course ID (auto-discovers from state if not provided)
    required: false
  - name: assignment_id
    description: Canvas assignment ID (auto-discovers from state if not provided)
    required: false
---

# Submit Assessments - Send Approved Grades to Canvas

Submit approved assessments from the JSON file to the Canvas gradebook.

## Task Overview

Review approved assessments, preview submission, and send grades to Canvas with safety checks.

## Step 1: Locate Assessment File

**If course_id and assignment_id provided**:

- Look for `assessments_{{course_id}}_{{assignment_id}}_*.json` in current directory
- Use most recent file matching that pattern

**If no arguments provided**:

- Check `.claude/state/assessment_state.json` for last used file
- If state file exists, use that assessment file
- If not found, search for `assessments_*.json` and use most recent
- If no files found, report error and tell user to run `/assess-setup` first

## Step 2: Load and Validate Assessment File

Use `mcp__mcp-canvas__load_assessment_file` to:

- Load the assessment JSON file
- Validate structure
- Get statistics on assessments

Display validation summary:

```
Assessment File Status
======================

File: {assessment_file_path}
Assignment: {assignment_name}
Course: {course_name}

Assessments Overview:
  Total submissions: X
  Reviewed: Y (AI-evaluated)
  Approved: Z (ready to submit)
  Not reviewed: W

Score Statistics (approved only):
  Average: {avg} / 20 pts
  Range: {min} - {max} pts
```

## Step 3: Dry Run Preview

Use `mcp__mcp-canvas__submit_reviewed_assessments` with:

- `file_path`: the assessment JSON file
- `course_identifier`: {course_id}
- `assignment_id`: {assignment_id}
- `only_approved`: true
- `dry_run`: true
- `overwrite_existing`: false (default: prevents overwriting existing Canvas grades)

Display preview:

```
Submission Preview (DRY RUN)
============================

WILL BE SUBMITTED (Z approved):
  ✓ User {user_id} - {total_pts}/20 pts
    - {criterion1}: {pts1}/5
    - {criterion2}: {pts2}/5
    - {criterion3}: {pts3}/5
    - {criterion4}: {pts4}/5
  ...

WILL BE SKIPPED:
  ⊘ User {user_id} - not approved (needs review)
  ⊘ User {user_id} - already graded in Canvas (protected)
  ...

NO SUBMISSION (W students):
  - User {user_id} - no submission to grade
  ...
```

## Step 4: Confirm Submission

Ask user for confirmation:

```
Ready to submit Z approved assessments to Canvas?

This will:

  • Submit grades for Z students
  • Skip X unapproved assessments
  • Post rubric scores and Spanish feedback to Canvas
  • Mark submitted assessments in JSON file

Continue? (Y/n)
```

Use `AskUserQuestion` tool with:

- Question: "Submit approved assessments to Canvas gradebook?"
- Options: ["Yes - submit to Canvas", "No - cancel submission"]

## Step 5: Submit to Canvas

**If user confirms YES**:

Use `mcp__mcp-canvas__submit_reviewed_assessments` with:

- `file_path`: the assessment JSON file
- `course_identifier`: {course_id}
- `assignment_id`: {assignment_id}
- `only_approved`: true
- `dry_run`: false
- `overwrite_existing`: false (default: prevents overwriting existing Canvas grades)

Report results:

```
Submission Complete
===================

Successfully Submitted: X students
  ✓ User {user_id} - {total_pts}/20 pts posted to Canvas
  ...

Skipped:
  ⊘ Not approved: Y students
  ⊘ Already graded in Canvas: Z students (protected)
  ...

Failed (errors): W students
  ✗ User {user_id} - Error: {error_message}
  ...

Grades Posted to Canvas: X/{total_submissions}
Assessment File Updated: ✓
```

**If user cancels**:
- Report: "Submission cancelled. No grades posted to Canvas."
- Exit without making changes

## Step 6: Update State

Update `.claude/state/assessment_state.json` with:

```json
{
  "last_assessment_file": "{file_path}",
  "course_id": "{course_id}",
  "assignment_id": "{assignment_id}",
  "last_submission_time": "{timestamp}",
  "total_submitted": X,
  "total_approved": Y,
  "total_skipped": Z
}
```

## Post-Submission Summary

```
Final Summary
=============

Assignment: {assignment_name}
Course: {course_name}

Grading Complete:
  ✓ X students graded in Canvas
  ⊘ Y students pending approval
  - Z students no submission

Class Performance (submitted grades):
  Average: {avg}/20 pts ({percentage}%)

  Criterion Averages:
  - {criterion1}: {avg1}/{max1} pts
  - {criterion2}: {avg2}/{max2} pts
  - {criterion3}: {avg3}/{max3} pts
  - {criterion4}: {avg4}/{max4} pts

Assessment File: {file_path}
  Preserved as audit trail with submission timestamps

Next Steps:
  • Review skipped assessments if any
  • Check Canvas gradebook to verify grades posted
  • Follow up with students who didn't submit
```

## Error Handling

- If no approved assessments: Report warning, ask if user wants to review assessments first
- If submission fails for any student: Report error but continue with others
- If Canvas API error: Report error with details, preserve assessment file
- If assessment file not found: Report error, tell user to run setup/prelim first

## Important Notes

- ALWAYS runs dry-run preview first before actual submission
- ONLY submits assessments explicitly marked as "approved"
- **Protects existing Canvas grades by default** (overwrite_existing=false)
- Skips unapproved assessments and already-graded submissions
- Preserves assessment file as audit trail
- Updates JSON with submission timestamps
- No grades can be submitted without human approval
- Safe to run multiple times (won't duplicate submissions or overwrite existing grades)

Begin submission process now.
