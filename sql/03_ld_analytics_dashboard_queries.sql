-- ============================================================
-- L&D Analytics: Core Dashboard Queries
-- Author: Sri Vaishnavi Devarashetty
-- Context: Tableau data sources used in Apple L&D global dashboards
-- ============================================================


-- 1. EXECUTIVE KPI SUMMARY
-- Top-level numbers for the C-suite / program owner slide
SELECT
    COUNT(DISTINCT learner_id)                                          AS total_active_learners,
    COUNT(DISTINCT course_id)                                           AS total_courses,
    COUNT(CASE WHEN status = 'completed' THEN 1 END)                    AS total_completions,
    ROUND(
        COUNT(CASE WHEN status = 'completed' THEN 1 END)
        / NULLIF(COUNT(*), 0) * 100, 1
    )                                                                   AS overall_completion_rate_pct,
    ROUND(AVG(CASE WHEN status = 'completed' THEN score END), 1)        AS avg_assessment_score,
    COUNT(DISTINCT CASE WHEN status = 'in_progress' THEN learner_id END) AS learners_in_progress
FROM ld_enrollments
WHERE enrollment_date >= DATE_TRUNC('year', CURRENT_DATE);


-- 2. DEPARTMENT-LEVEL ENGAGEMENT SCORECARD
-- Feeds the department drill-down view in Tableau
SELECT
    d.department_name,
    d.department_head,
    COUNT(DISTINCT e.learner_id)                                         AS enrolled_learners,
    COUNT(CASE WHEN e.status = 'completed' THEN 1 END)                   AS completions,
    ROUND(
        COUNT(CASE WHEN e.status = 'completed' THEN 1 END)
        / NULLIF(COUNT(DISTINCT e.learner_id), 0) * 100, 1
    )                                                                    AS completion_rate_pct,
    ROUND(AVG(e.time_spent_hours), 1)                                    AS avg_hours_per_learner,
    ROUND(AVG(CASE WHEN e.status = 'completed' THEN e.score END), 1)     AS avg_score
FROM ld_enrollments e
INNER JOIN dim_departments d ON e.department_id = d.department_id
WHERE e.enrollment_date BETWEEN :start_date AND :end_date
GROUP BY 1, 2
ORDER BY completion_rate_pct DESC;


-- 3. COURSE EFFECTIVENESS MATRIX
-- Used to tag courses as High/Medium/Low performer for L&D strategy meetings
SELECT
    c.course_name,
    c.course_category,
    c.duration_hours,
    COUNT(e.learner_id)                                              AS total_enrollments,
    ROUND(
        COUNT(CASE WHEN e.status = 'completed' THEN 1 END)
        / NULLIF(COUNT(e.learner_id), 0) * 100, 1
    )                                                                AS completion_rate_pct,
    ROUND(AVG(CASE WHEN e.status = 'completed' THEN e.score END), 1) AS avg_score,
    ROUND(AVG(e.learner_satisfaction_rating), 2)                     AS avg_satisfaction,
    CASE
        WHEN completion_rate_pct >= 80 AND avg_satisfaction >= 4 THEN 'High Performer'
        WHEN completion_rate_pct >= 60 AND avg_satisfaction >= 3 THEN 'Medium Performer'
        ELSE 'Needs Review'
    END                                                              AS performance_tier
FROM ld_enrollments e
INNER JOIN dim_courses c ON e.course_id = c.course_id
GROUP BY 1, 2, 3
ORDER BY completion_rate_pct DESC;


-- 4. WEEKLY TREND FOR STAKEHOLDER BRIEFINGS
-- 13-week rolling view used in weekly program owner calls
SELECT
    DATE_TRUNC('week', completion_date)                              AS week_start,
    COUNT(*)                                                         AS completions_this_week,
    COUNT(DISTINCT learner_id)                                       AS unique_learners,
    AVG(COUNT(*)) OVER (
        ORDER BY DATE_TRUNC('week', completion_date)
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    )                                                                AS rolling_4wk_avg
FROM ld_course_completions
WHERE completion_date >= DATEADD('week', -13, CURRENT_DATE)
GROUP BY 1
ORDER BY 1;


-- 5. AT-RISK LEARNER IDENTIFICATION
-- Drives re-engagement outreach — feeds daily operational report
SELECT
    l.learner_id,
    l.learner_name,
    l.department,
    l.manager_email,
    e.course_name,
    e.enrollment_date,
    DATEDIFF('day', e.enrollment_date, CURRENT_DATE)                 AS days_since_enrollment,
    e.pct_complete,
    CASE
        WHEN DATEDIFF('day', e.enrollment_date, CURRENT_DATE) > 30
             AND e.pct_complete < 20  THEN 'High Risk'
        WHEN DATEDIFF('day', e.enrollment_date, CURRENT_DATE) > 14
             AND e.pct_complete < 50  THEN 'Medium Risk'
        ELSE 'On Track'
    END                                                              AS risk_flag
FROM ld_enrollments e
INNER JOIN dim_learners l ON e.learner_id = l.learner_id
WHERE e.status = 'in_progress'
  AND risk_flag IN ('High Risk', 'Medium Risk')
ORDER BY risk_flag, days_since_enrollment DESC;
