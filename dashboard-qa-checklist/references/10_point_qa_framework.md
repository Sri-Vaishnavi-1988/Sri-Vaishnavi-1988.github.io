# The 10-Point Dashboard QA Framework — Deep Reference

The reasoning behind each check in the `dashboard-qa-checklist` Agent Skill. Read this when you need to explain *why* a check exists, or when you are adapting the skill to a new context.

## Check 1 — Row count integrity

**The failure mode this prevents:** A dashboard that silently drops rows due to an unintended INNER JOIN, an aggressive WHERE clause, or a misconfigured filter — leading stakeholders to underestimate volume.

**Why it is check 1:** It is the cheapest check (one query) with the highest catch rate. Row count mismatches catch ~40% of all dashboard bugs in my experience.

**Common causes of failure:**
- INNER JOIN where LEFT JOIN was intended
- `status = 'active'` WHERE clause that drops NULL statuses
- Filter applied at the data source level that the analyst forgot about
- A CROSS JOIN that double-counts unintentionally

## Check 2 — NULL handling

**The failure mode this prevents:** NULLs being silently treated as zero in averages, or silently dropped in counts. Both distort metrics in ways that are not obvious from the dashboard.

**Why it matters:** A completion rate that includes NULL completion dates as "zero completions" looks different from one that excludes them. Both are valid choices — but only one matches the documented KPI definition. The check ensures the choice is conscious.

## Check 3 — Join correctness

**The failure mode this prevents:** One-to-many joins inflating measures. A learner with 5 completions joined naively to a learners table produces 5 rows — and `SUM(learner_value)` becomes 5x what it should be.

**The senior move:** Pre-aggregate the many side in a CTE before joining. Or use DISTINCT counts. Or use Tableau LOD expressions. The check forces explicit handling.

## Check 4 — Filter behavior

**The failure mode this prevents:** Filters that look like they work but do not — particularly with FIXED LOD expressions in Tableau, which ignore normal dimension filters unless those filters are promoted to context filters.

**The trap:** A stakeholder sees a region filter applied to a "% of total" KPI and assumes the percent is *of that region's total*. If the FIXED LOD calculates the denominator globally, the percent is *of the global total* — a different, often misleading number.

## Check 5 — KPI definition compliance

**The failure mode this prevents:** Definition drift across dashboards. Three teams measure "active learner" three different ways. Leadership sees three different numbers and trust in analytics erodes.

**The fix:** A single KPI catalog (Notion, Confluence, internal repo) that every dashboard references. The check is: does the calculated field on this dashboard match the catalog formula?

## Check 6 — Tooltip accuracy

**The failure mode this prevents:** A tooltip that describes the calculation incorrectly, often after copy-paste from an older dashboard. The number is right; the explanation is wrong. Stakeholders trust the explanation.

**Why this is easy to miss:** Tooltips are not part of the visible viz. They are read only when a user hovers. Reviewers often skip them. The check makes review explicit.

## Check 7 — Data freshness

**The failure mode this prevents:** Decisions made on stale data. The dashboard says "last week" but the data is two weeks old. Leadership makes a call based on what they think is current.

**The fix:** Display the last refresh timestamp on the dashboard itself. Set a freshness SLA. The check verifies the SLA is being met.

## Check 8 — Edge case behavior

**The failure mode this prevents:** A dashboard that breaks gracelessly when filters return zero rows, when a single category is selected, or when the date range is at extremes.

**Common breaks:**
- "0%" displayed without explanation when no data matches the filter
- A line chart that shows nothing when only one date is selected
- A pie chart that crashes when one category is 100% and others are zero

**The fix:** Test these explicitly. Add contextual messages where appropriate.

## Check 9 — Accessibility and readability

**The failure mode this prevents:** A dashboard that excludes ~8% of users (color vision deficiency rates) or that is unusable on mobile / low-resolution displays.

**The senior move:** Treat accessibility as a design constraint, not an afterthought. Use color-blind-safe palettes by default. Always pair color with another encoding (label, position, shape).

## Check 10 — Performance under realistic load

**The failure mode this prevents:** A dashboard that takes 30 seconds to render. Stakeholders click once, wait, get frustrated, and stop using it. Adoption dies silently.

**The bar:** Under 5 seconds for the top 3 filter combinations. Under 10 seconds for any combination. If you cannot hit this, the dashboard is too ambitious for its tech stack — simplify.

## The meta-pattern

Every check has the same structure:
1. **Ask:** the question to investigate
2. **Action:** the specific verification step
3. **Failure mode prevented:** what bad thing happens without this check

This structure is reusable. When you discover a new failure mode in your work, add an 11th check using the same structure. The framework grows with your team's experience.

## Calibration over time

The first three months after deploying this checklist:

- Track which checks catch real issues
- Track which checks are pure overhead
- Tune thresholds based on actual data

After three months, you should have a team-specific version of this framework. The original 10 may become 8, 12, or 15 — calibrated to your actual failure modes.
