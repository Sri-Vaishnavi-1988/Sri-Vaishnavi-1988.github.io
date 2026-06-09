# Dashboard QA Report — Learner Progression by Cohort — 2026-05-22

## Summary

- Checks passed: 7 of 10
- Critical issues: 1
- Warnings: 2
- Ready to publish: **No — fix critical issue first**

## Check Results

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 1 | Row count integrity | **Fail** | Dashboard total: 4,217 learners. Source query: 4,584. 8% discrepancy. |
| 2 | NULL handling | Pass | No silent NULL drops in dimensions; measures use COALESCE correctly. |
| 3 | Join correctness | Pass | Verified one-to-many join from learners to completions uses COUNT(DISTINCT learner_id). |
| 4 | Filter behavior | Warn | Region filter does not propagate to the FIXED LOD cohort calculation. Promote to context filter. |
| 5 | KPI definition compliance | Pass | All 4 KPIs match the team catalog (verified 2026-05-22). |
| 6 | Tooltip accuracy | Pass | All 12 tooltips reviewed; descriptions match calculations. |
| 7 | Data freshness | Pass | Last refresh: 2026-05-22 02:00 UTC. SLA is 24 hours. Within tolerance. |
| 8 | Edge case behavior | Warn | Empty filter state shows "0 learners" without explanation. Add a contextual message. |
| 9 | Accessibility and readability | Pass | Color contrast passes WCAG AA. Mobile responsive. |
| 10 | Performance under realistic load | Pass | Top 3 filter combos render in 3.2s, 4.1s, 2.8s. All under 5s target. |

## Critical issues (must fix before publication)

**1. Row count mismatch (Check 1).** 367 learners are not appearing in the dashboard. Investigation:

- Suspected cause: a LEFT JOIN to the optional `learner_status` table is implicitly filtering rows where status is NULL via a WHERE clause on `status = 'active'`. This should be `(status = 'active' OR status IS NULL)` or moved into the join condition.
- Owner: Sri Vaishnavi
- ETA to fix: 30 minutes
- Re-run: Re-run this checklist after the fix and verify row count matches.

## Warnings (fix before next iteration)

**1. Region filter does not propagate to FIXED LOD (Check 4).** When a user filters by region, the cohort percent-of-total denominator still calculates globally. Fix: promote the region filter to a context filter, OR rewrite the FIXED LOD as an INCLUDE.

**2. Empty filter state needs context (Check 8).** When all filters are unselected or return zero rows, the dashboard shows "0 learners" with no explanation. Add a "No data for the selected filters — try broadening" message.

## Sign-off

- [ ] All critical issues resolved
- [ ] Warnings acknowledged or scheduled
- [ ] Reviewed by analyst: Sri Vaishnavi Devarashetty
- [ ] Reviewed by domain stakeholder: __________________
- [ ] Publication approved: __________________

---

*This is a sample output produced by the `dashboard-qa-checklist` Agent Skill. Real output will vary based on the dashboard under review.*
