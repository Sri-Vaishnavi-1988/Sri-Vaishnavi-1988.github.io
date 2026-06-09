# Tableau LOD Expressions — Practical Guide
**Author: Sri Vaishnavi Devarashetty**
*Patterns built from real L&D and NVIDIA analytics work*

---

## What are LOD Expressions?

Level of Detail (LOD) expressions let you control the granularity of a calculation **independently of the view**. They answer questions like "what was each learner's *first* course?" or "what is the department average, shown alongside each individual row?"

Three types: `FIXED`, `INCLUDE`, `EXCLUDE`.

---

## 1. FIXED — Most Common

Computes at a specified dimension, **ignoring the view's level of detail**.

### Pattern: Department Average Alongside Individual Rows

```
// Average completion rate per department — fixed regardless of view filters
{ FIXED [Department] : AVG([Completion Rate]) }
```

**Use case:** Show each course row alongside its department average for benchmarking.

---

### Pattern: First Enrollment Date per Learner

```
{ FIXED [Learner ID] : MIN([Enrollment Date]) }
```

**Use case:** Cohort analysis — segment learners by when they first enrolled.

---

### Pattern: Distinct Learner Count Across All Filters

```
{ FIXED : COUNTD([Learner ID]) }
```

**Use case:** Total unique learners for the full dataset, shown in a KPI tile even when the view is filtered to one department.

---

## 2. INCLUDE — Add Granularity

Computes at a **finer granularity** than the current view.

### Pattern: Average Score per Course Within Each Department View

```
{ INCLUDE [Course Name] : AVG([Score]) }
```

**Use case:** When the view is at department level, this forces the average to consider individual course scores — preventing Simpson's paradox in aggregated scoring.

---

## 3. EXCLUDE — Remove Granularity

Removes a dimension from the calculation, useful for percent-of-total calculations.

### Pattern: Completion Rate as % of Program Total

```
SUM([Completions]) / { EXCLUDE [Course Name] : SUM([Completions]) }
```

**Use case:** Each course bar shows its share of total completions without needing a table calculation.

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| Using FIXED when INCLUDE is needed | Ask: should this ignore view filters? FIXED = yes, INCLUDE = no |
| Slow dashboard from LOD on large data | Pre-aggregate in Snowflake SQL, use LOD only for view-level calcs |
| Context filter not applied to FIXED | FIXED ignores dimension filters — use Context Filters to force it |

---

## Quick Reference: When to use which

| Scenario | Use |
|---|---|
| "Show total across whole dataset" | `FIXED` with no dimensions |
| "Benchmark each row against its group" | `FIXED [Group]` |
| "% of total column" | `EXCLUDE [current dimension]` |
| "Average considering sub-level detail" | `INCLUDE [sub-level dimension]` |
