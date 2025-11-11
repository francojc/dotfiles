---
description: Use spanish-pedagogy-expert agent to evaluate all submissions with AI-generated assessments
args:
  - name: course_id
    description: Canvas course ID (auto-discovers from state if not provided)
    required: false
  - name: assignment_id
    description: Canvas assignment ID (auto-discovers from state if not provided)
    required: false
---

# AI Preliminary Assessment - Evaluate Submissions

Use the spanish-pedagogy-expert agent to evaluate all student submissions and populate the assessment JSON file.

## Task Overview

Process each submission chronologically, using the agent to provide rubric-based evaluation with concise Spanish feedback.

## Step 1: Locate Assessment File

**If course_id and assignment_id provided**:

- Look for `.claude/assessments/{{course_id}}_{{assignment_id}}_*.json` in the current repository
- Use most recent file matching that pattern

**If no arguments provided**:

- Check `.claude/state/assessment_state.json` for last used file
- If state file exists, use that assessment file
- If not found, search for `assessments_*.json` and use most recent
- If no files found, report error and tell user to run `/assess-setup` first

Load the assessment file using `mcp__mcp-canvas__load_assessment_file`.

## Step 2: Process Each Submission

For each student in the assessment file who has submitted (process in chronological order by submission time):

1. **Check if already evaluated**:
   - Skip if assessment already has scores (don't re-evaluate)
   - Report: "Skipping user {user_id} - already evaluated"

2. **Launch spanish-pedagogy-expert agent** via Task tool with this prompt:

```
You are evaluating a Spanish language student's submission.

## Student Submission

User ID: {user_id}
Submission Time: {submitted_at}
Word Count: {word_count}

### Submission Text:
{submission_text}

## Rubric Criteria

You must evaluate this submission against the rubric criteria. For EACH criterion, provide:
- Points awarded (based on rating levels, half-points acceptable)
- Rating ID (the specific ID matching the points)
- Concise feedback (`justification`) in Spanish (EXACTLY 15-20 words)
- A final summary of all criteria at the end in the overall comments section.

{full_rubric_details_here}

## Your Task

Provide your assessment in this EXACT format:

**CRITERION: {criterion_name} [{criterion_id}]**
Points: {points_awarded}
Rating ID: {rating_id}
Justification: {15-20 word Spanish feedback focusing ONLY on main positive/negative attributes}
Overall Comments: {final summary of all criteria in Spanish, 30-40 words}

## Feedback Requirements

- EXACTLY 15-20 words in Spanish per criterion
- Focus ONLY on the main strength OR weakness (not both if space-constrained)
- Use clear, comprehensible phrases (need not be complete sentences)
- Directly address the specific criterion
- Provide actionable insight

*Note: no need to report the word count in your feedback, only mention it if the student's submission is very short or very long.*

## Evaluation Guidelines

- Use the language of the rubric levels to guide your scoring and justification feedback
- Be lenient in applying rubric criteria and lean toward higher points when borderline
- Value attempts at grammatical and lexical complexity, do not penalize these
- Use partial credit when appropriate
- Ensure feedback helps student understand the assessment
- Consider this is upper-level Spanish (advanced low proficiency expected)

## Final Summary

- Summarize the individual criterion ratings and justification comments in the overall comments section.
- Provide praise for strengths and constructive suggestions for improvement.

The tone for all written feedback should be supportive and encouraging, aiming to motivate the student to improve their Spanish skills. It is written in Spanish and directed at the student using the informal "tú" form.

Provide complete assessment for all criteria now.
```

3. **Parse agent response** to extract:
   - Points for each criterion
   - Rating ID for each criterion
   - 15-20 word Spanish feedback for each criterion
   - Overall comments summary

4. **Validate agent output**:
   - Verify all criteria have assessments
   - Check that rating IDs match the rubric structure
   - Count words in each feedback (must be 15-20)
   - Verify feedback is in Spanish

5. **Save assessment** using `mcp__mcp-canvas__review_assessment`:
   - `file_path`: the assessment JSON file
   - `user_id`: student's Canvas user ID
   - `updated_assessment`: dictionary with rubric_assessment and notes
   - `mark_reviewed`: true (marks as reviewed by AI)
   - `mark_approved`: false (requires human review before submission)

6. **Report progress**:

   ```
   ✓ Evaluated User {user_id} - {total_points}/20 pts
     [{criterion1}: {pts1}, {criterion2}: {pts2}, {criterion3}: {pts3}, {criterion4}: {pts4}]
   ```

## Step 3: Display Summary

After processing all submissions, report:

```
AI Preliminary Assessment Complete
===================================

Submissions Evaluated: X/Y
- Newly evaluated: X students
- Previously evaluated (skipped): Y students
- No submission (skipped): Z students
- Already graded in Canvas (excluded during setup): A students

Score Distribution:
  Average: {avg} / 20 pts
  Range: {min} - {max} pts

  Criterion Averages:
  - {criterion1}: {avg1} / {max1} pts
  - {criterion2}: {avg2} / {max2} pts
  - {criterion3}: {avg3} / {max3} pts
  - {criterion4}: {avg4} / {max4} pts

Assessment File Updated:
  📄 {assessment_file_path}

Status:
  ✓ All assessments marked as "reviewed"
  ⚠ None marked as "approved" yet

Note: Already-graded submissions were excluded during setup to prevent overwriting.

Next Steps:
  1. Review the assessment file manually
  2. Edit any assessments as needed using review tools or JSON editing
  3. Mark assessments as "approved" when ready
  4. Run `/assess-submit` to submit approved grades to Canvas
```

## Error Handling

- If agent fails to evaluate: Report error, continue with next student
- If feedback not 15-20 words: Report warning, ask agent to revise
- If rating ID invalid: Report error, ask agent to provide valid ID
- If assessment file not found: Report error, tell user to run `/assess-setup`

## Important Notes

- Process submissions chronologically (earliest first)
- Skip students without submissions (already filtered by setup)
- **Already-graded submissions excluded during setup** to prevent overwriting Canvas grades
- Never overwrite existing assessments (skip if already evaluated)
- All assessments marked as "reviewed" but NOT "approved"
- Human review required before submission to Canvas
- The spanish-pedagogy-expert agent ensures pedagogically appropriate evaluation

Begin AI evaluation now.
