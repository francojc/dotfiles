---
description: Refine AI rubric assessments using cohort-aware normalization with 0.5-point increments
args:
  - name: course_id
    description: Canvas course ID (auto-discovers from state if not provided)
    required: false
  - name: assignment_id
    description: Canvas assignment ID (auto-discovers from state if not provided)
    required: false
  - name: target
    description: Desired class median total (e.g., 16). Required unless policy=advisory-only
    required: false
  - name: policy
    description: nonnegative-only | symmetric | advisory-only (default nonnegative-only)
    required: false
  - name: algorithm
    description: additive-capped | linear | percentile (default additive-capped)
    required: false
  - name: cap_per_criterion
    description: Maximum uplift per criterion in points (default 1.0). Enforced at 0.5-step granularity
    required: false
  - name: cap_total
    description: Optional maximum total uplift per student. Default none
    required: false
  - name: scope
    description: reviewed-only | all | user_ids=<comma-separated list>
    required: false
  - name: feedback_mode
    description: rewrite | append | none (default rewrite)
    required: false
  - name: approve
    description: true | false (default true). Auto-approve adjusted assessments if validations pass
    required: false
  - name: dry_run
    description: true | false (default true). Preview changes without writing
    required: false
  - name: reapply
    description: true | false (default false). Allow re-run even if refinement_meta exists
    required: false
---

# Assess Refine - Cohort-Aware Normalization (0.5-point increments)

Refine rubric assessments produced by `/assess-ai-prelim` by adjusting scores and
justifications based on cohort performance. All adjustments use 0.5-point
increments for clarity and rubric integrity.

## Task Overview

Normalize totals toward a median target using a nonnegative-only, additive-capped
uplift K applied in 0.5 steps per criterion, respecting per-criterion maximums
and preserving Canvas rubric validity. Optionally rewrite criterion feedback
(Spanish, 15–20 words), then mark as reviewed and approved.

## Step 1: Locate Assessment File

If `course_id` and `assignment_id` provided:

- Look for `.claude/assessments/{{course_id}}_{{assignment_id}}_*.json` in the current repository
- Use most recent file matching that pattern

If no arguments provided:

- Check `.claude/state/assessment_state.json` for last used file
- If state file exists, use that assessment file
- If not found, search for `assessments_*.json` and use most recent
- If no files found, report error and tell user to run `/assess-setup` first

Load the assessment file using `mcp__mcp-canvas__load_assessment_file`.

## Step 2: Determine Scope and Readiness

- Default scope: `reviewed-only` (AI evaluated, not yet submitted)
- Exclude:
  - Already submitted/approved (unless `reapply=true`)
  - Already graded in Canvas (protected during setup)
  - Entries without rubric data or with invalid structures

Report counts: eligible, skipped (and reasons).

## Step 3: Compute Cohort Statistics (Before)

For the scoped set, compute:

- Total score distribution (min, Q1, median, mean, Q3, max)
- Per-criterion averages and medians
- Feasible maximum median under caps at 0.5-step precision (see below)

Display a concise summary for instructor context.

## Step 4: Normalization Policy and Parameters

Defaults unless overridden by flags:

- `policy`: `nonnegative-only` (no decreases)
- `algorithm`: `additive-capped`
- `cap_per_criterion`: `+1.0` (i.e., at most two 0.5 steps)
- `cap_total`: none
- `feedback_mode`: `rewrite`
- `approve`: `true`
- `dry_run`: `true`

Target selection:

- Median-anchored normalization to `--target` (required unless `policy=advisory-only`)
- If target missing and not advisory-only → prompt for target

0.5-step enforcement (global):

- `step_size = 0.5`
- Quantization function: `half(x) = floor(x*2)/2`

## Step 5: Solve for Uplift K (0.5-grid search)

Only for `algorithm=additive-capped`:

- Search K over the discrete grid: `{0.0, 0.5, 1.0, ..., cap_per_criterion}`
- Simulate per student:
  - For criterion c with current points Pc and max Mc:
    - `headroom_c = Mc - Pc`
    - `raw_uplift_c = min(K, cap_per_criterion, headroom_c)`
    - `uplift_c = half(raw_uplift_c)`
    - `new_points_c = min(Mc, half(Pc + uplift_c))`
  - Apply `cap_total` if provided by clamping the sum of uplifts
- Choose K whose resulting class median total is closest to target
- If target exceeds feasible median given caps and 0.5 steps:
  - Clamp to feasible maximum median and warn

Display dry-run preview:

```
Refinement Preview (DRY RUN)
===========================

Policy: nonnegative-only
Algorithm: additive-capped
Step size: 0.5
Target median: {target} (feasible max: {feasible})
Chosen K: {K}

Totals (median): {old_med} → {new_med}
Criterion averages:
- {crit1}: {old1} → {new1}
- {crit2}: {old2} → {new2}
- {crit3}: {old3} → {new3}
- {crit4}: {old4} → {new4}

Adjusted: X students
No change: Y students
Skipped: Z students (reasons)
```

## Step 6: Rating ID Remap and Validation

For each adjusted criterion:

- If `new_points_c` exactly equals a rating value → use that `rating_id`
- Else map to the highest rating whose points ≤ `new_points_c`; store points
- Validate rubric rules. If Canvas disallows fractional criterion points:
  - Round to the nearest allowed step
  - Warn and record rounding in the audit log

Global validations:

- All criteria present and within [0, max]
- Idempotency: if `refinement_meta` exists and `reapply=false`, abort with guidance

## Step 7: Spanish Feedback Refinement (15–20 words)

If `feedback_mode=rewrite` or `append`, launch `spanish-pedagogy-expert` via Task
per adjusted student to produce criterion-level comments with these constraints:

- EXACTLY 15–20 words in Spanish per criterion
- Focus ONLY on the criterion; one main strength OR weakness
- Actionable and specific; avoid generic praise
- Do NOT mention curves, cohort, calibration, or numeric step sizes

Prompt template (per criterion):

```
Reescribe un comentario breve para la rúbrica (15–20 palabras, español),
centrado SOLO en este criterio. Mantén precisión, especificidad y
recomendación accionable. No menciones ajustes de calificación ni curva.

Criterio: {criterion_name}
Puntaje final: {new_points_c}/{max_c}
Descripción breve del desempeño y rasgos observables: {signals_from_submission}
```

Append mode:

- If `feedback_mode=append`, keep el comentario original y añade una cláusula
  final de 8–12 palabras coherente con el nuevo puntaje (sin mencionar la
  calibración). Validar que el total por criterio quede en 15–20 palabras si
  se requiere; si no, solo añadir una cláusula concisa.

Validation:

- Verificar 15–20 palabras, español, relevancia al criterio
- Si falla, reintentar una vez; si persiste, usar `append` o `none` y marcar para revisión

## Step 8: Confirm and Write

- Show a confirmation prompt. If `dry_run=true`, exit after preview
- If confirmed and `dry_run=false`:
  - For cada estudiante ajustado, usar `mcp__mcp-canvas__review_assessment`:
    - `file_path`: assessment JSON
    - `user_id`: Canvas user ID
    - `updated_assessment`: rubric_assessment con nuevos puntos y rating ids,
      comentarios por criterio (15–20 palabras) y nota general breve sobre
      expectativas de dominio (sin mencionar curva)
    - `mark_reviewed`: true
    - `mark_approved`: según `approve` (default true)
  - Escribir bloque `refinement_meta` con:
    - policy, algorithm, step_size=0.5, target, K, caps, feasibility, timestamp,
      version y resumen de cambios por estudiante/criterio

## Step 9: Summary and State Update

Mostrar resumen final:

```
Refinement Complete
===================

Adjusted: X
No change: Y
Skipped: Z (reasons)

Totals (median): {old_med} → {new_med}
Means: {old_mean} → {new_mean}

Criterion averages:
- {crit1}: {old1} → {new1}
- {crit2}: {old2} → {new2}
- {crit3}: {old3} → {new3}
- {crit4}: {old4} → {new4}

Assessment File Updated:
  📄 {assessment_file_path}

Status:
  ✓ All adjusted assessments marked as "reviewed"
  {approved_line}
```

Update `.claude/state/assessment_state.json` with refinement details to enable
auto-discovery in subsequent commands.

## Error Handling

- Missing target (and not advisory-only): prompt for `--target` or abort with guidance
- Target infeasible under caps/0.5 steps: clamp to feasible and warn
- Invalid rating map: fallback to nearest-below rating; store points; warn
- Feedback validation fails twice: fallback to `append` or `none` and flag
- Idempotency: refinement already present without `--reapply`: abort with guidance
- Assessment file not found: ask user to run `/assess-setup` and `/assess-ai-prelim`

## Important Notes

- All adjustments use 0.5-point increments (`step_size=0.5`)
- Default policy prevents any score decreases (nonnegative-only)
- Per-criterion cap enforced at 0.5 precision (default +1.0)
- Total cap optional; disabled by default
- Feedback remains criterion-specific; do not reference cohort adjustments
- Safe to run in `dry_run` repeatedly; use `--reapply` for subsequent writes
- Preserves Canvas-grade safety by excluding already graded submissions

## Next Steps

- Review refined assessments as needed
- Run `/assess-submit` to post approved grades to Canvas
