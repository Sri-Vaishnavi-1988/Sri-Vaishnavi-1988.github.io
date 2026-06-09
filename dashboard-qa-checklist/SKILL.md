---
name: dashboard-qa-checklist
description: Run a 10-point quality assurance checklist on a Tableau dashboard or any BI dashboard before publication. Catches missing joins, NULL handling issues, broken calculations, inconsistent KPI definitions, accessibility problems, and stale data. Use when a dashboard is about to be published, after significant changes, or when stakeholders question dashboard numbers.
---

# Dashboard QA Checklist

A structured pre-publication QA pass for any BI dashboard. The agent works through 10 specific checks and produces a sign-off report. Calibrated for Tableau on Snowflake but applies to any BI tool plus warehouse combination.

## When to use this skill

- A new dashboard is about to be published to stakeholders
- An existing dashboard has had significant changes (new data source, new calculations, new filters)
- A dashboard's numbers are being questioned and a systematic review is needed
- Onboarding a new analyst — teach the QA discipline through a real example

## The 10 checks

### 1. Row count integrity

**Ask:** Does the total row count visible in the dashboard match the source data after applying intended filters?

**Action:** Run a control query against the source. Compare to the dashboard's displayed totals. Flag any discrepancy over 0.5%.

**Example control query:**

```sql
SELECT COUNT(*) AS source_rows
FROM   learners l
LEFT JOIN completions c ON l.learner_id = c.learner_id
WHERE  l.region = 'EMEA'
  AND  c.completion_date >= DATEADD('day', -90, CURRENT_DATE());
```

### 2. NULL handling

**Ask:** Are NULLs in dimension columns being silently dropped? Are NULLs in measure columns being treated as zero where they should be excluded?

**Action:** For each dimension, count NULLs in source vs. visible in viz. For each measure, verify the aggregation treats NULL as zero, blank, or excluded — and that this matches the documented KPI definition.

### 3. Join correctness

**Ask:** Are any joins inflating measures due to one-to-many relationships?

**Action:** For each join, verify the cardinality. If one-to-many, confirm the aggregation handles inflation correctly (DISTINCT counts, pre-aggregation CTEs, or LOD expressions).

### 4. Filter behavior

**Ask:** Does every dashboard filter actually filter as expected?

**Action:** For each filter, apply it and verify the row counts and key measures change appropriately. Pay special attention to filters that interact with FIXED LOD expressions — those require context filters to behave correctly.

### 5. KPI definition compliance

**Ask:** Do all displayed KPI calculations match the team's documented KPI catalog?

**Action:** For each KPI on the dashboard, look up the catalog definition. Verify the formula in the calculated field or SQL matches. Flag any drift.

### 6. Tooltip accuracy

**Ask:** Do tooltips correctly describe the visible metrics, units, and time grains?

**Action:** Read every tooltip. Verify against the actual calculation and data source. Flag mismatches — these are common after copy-paste from older dashboards.

### 7. Data freshness

**Ask:** Is the underlying data current enough for the stakeholder's decision context?

**Action:** Check the last refresh timestamp of the underlying extract or live connection. Compare to the freshness SLA. Flag if stale.

### 8. Edge case behavior

**Ask:** What does the dashboard show when filters return zero rows, when a single category is selected, or when the date range is at extremes (first day, last day, all-time)?

**Action:** Test each scenario explicitly. Verify the dashboard does not display misleading "0%" or empty placeholders without context.

### 9. Accessibility and readability

**Ask:** Is the dashboard readable for users with color vision deficiencies, mobile users, and users on low-resolution displays?

**Action:** Check color contrast. Verify sort and group options. Confirm mobile responsiveness if relevant. Avoid red-green as the only encoding.

### 10. Performance under realistic load

**Ask:** Does the dashboard render in under 5 seconds for the typical filter combinations stakeholders use?

**Action:** Test the 3 most common filter combinations. Time the render. Flag any over 5 seconds. Common fixes: push aggregation to the warehouse, use extracts instead of live connections for large data, simplify calculated fields.

## Output format

After running the 10 checks, produce a report in this exact format:

```markdown
# Dashboard QA Report — [Dashboard Name] — [Date]

## Summary
- Checks passed: X of 10
- Critical issues: N
- Warnings: M
- Ready to publish: Yes / No / After fixes

## Check Results

| # | Check                          | Status         | Notes                              |
|---|--------------------------------|----------------|------------------------------------|
| 1 | Row count integrity            | Pass / Warn / Fail | Specifics                      |
| 2 | NULL handling                  | ...            | ...                                |
| 3 | Join correctness               | ...            | ...                                |
| 4 | Filter behavior                | ...            | ...                                |
| 5 | KPI definition compliance      | ...            | ...                                |
| 6 | Tooltip accuracy               | ...            | ...                                |
| 7 | Data freshness                 | ...            | ...                                |
| 8 | Edge case behavior             | ...            | ...                                |
| 9 | Accessibility and readability  | ...            | ...                                |
| 10| Performance under realistic load | ...          | ...                                |

## Critical issues (must fix before publication)
- ...

## Warnings (fix before next iteration)
- ...

## Sign-off
- [ ] All critical issues resolved
- [ ] Warnings acknowledged or scheduled
- [ ] Reviewed by analyst: ___________________
- [ ] Reviewed by domain stakeholder: ___________________
- [ ] Publication approved: ___________________
```

## Calibration notes

- The 0.5% row count discrepancy threshold may be too tight or too loose for your context — adjust to your team's tolerance.
- For dashboards with sensitive numbers (financial, headcount, compliance), drop the threshold to 0%.
- For exploratory dashboards, raise it to 1–2%.

## Pair this skill with a domain stakeholder

For the first 3 dashboards a new analyst publishes, run this checklist with a domain stakeholder present. Stakeholders catch errors the data cannot tell you about — for example, a learner cohort that should have 200 people but the dashboard shows 184.

## Versioning

This skill follows the agentskills.io open standard. Version: 1.0.0. Maintainer: Sri Vaishnavi Devarashetty.
