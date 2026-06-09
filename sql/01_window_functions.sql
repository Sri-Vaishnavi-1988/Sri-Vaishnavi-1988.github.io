-- ============================================================
-- Window Functions: L&D Analytics Use Cases
-- Platform: Snowflake
-- Author: Sri Vaishnavi Devarashetty
-- Context: Real patterns from Apple L&D dashboard work
-- ============================================================


-- 1. RUNNING TOTAL OF COURSE COMPLETIONS BY MONTH
-- Used to track cumulative learner progress across a program year
SELECT
    learner_id,
    course_name,
    completion_date,
    completion_count,
    SUM(completion_count) OVER (
        PARTITION BY learner_id
        ORDER BY completion_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_completions
FROM ld_course_completions
ORDER BY learner_id, completion_date;


-- 2. RANK COURSES BY ENGAGEMENT WITHIN EACH DEPARTMENT
-- Helps L&D teams identify top-performing content per business unit
SELECT
    department,
    course_name,
    total_enrollments,
    avg_completion_rate,
    RANK() OVER (
        PARTITION BY department
        ORDER BY avg_completion_rate DESC
    ) AS engagement_rank
FROM ld_course_metrics
QUALIFY engagement_rank <= 5;  -- Top 5 courses per department


-- 3. MONTH-OVER-MONTH COMPLETION RATE CHANGE
-- KPI used in Apple L&D weekly stakeholder briefings
WITH monthly_completions AS (
    SELECT
        DATE_TRUNC('month', completion_date) AS month,
        COUNT(DISTINCT learner_id)           AS completions
    FROM ld_course_completions
    GROUP BY 1
)
SELECT
    month,
    completions,
    LAG(completions) OVER (ORDER BY month)                          AS prev_month_completions,
    completions - LAG(completions) OVER (ORDER BY month)            AS mom_change,
    ROUND(
        (completions - LAG(completions) OVER (ORDER BY month))
        / NULLIF(LAG(completions) OVER (ORDER BY month), 0) * 100, 2
    )                                                               AS mom_pct_change
FROM monthly_completions
ORDER BY month;


-- 4. LEARNER PERCENTILE RANKING BY COURSE SCORE
-- Used for identifying high-performers and at-risk learners
SELECT
    learner_id,
    course_name,
    score,
    PERCENT_RANK() OVER (
        PARTITION BY course_name
        ORDER BY score
    )                                                        AS percentile_rank,
    NTILE(4) OVER (
        PARTITION BY course_name
        ORDER BY score
    )                                                        AS quartile   -- 1=bottom, 4=top
FROM ld_assessment_scores;


-- 5. DAYS SINCE LAST ACTIVITY (LAPSED LEARNER DETECTION)
-- Feeds into re-engagement campaign targeting
SELECT
    learner_id,
    last_activity_date,
    DATEDIFF('day', last_activity_date, CURRENT_DATE)        AS days_inactive,
    MAX(last_activity_date) OVER (PARTITION BY learner_id)   AS most_recent_activity
FROM ld_learner_activity
WHERE DATEDIFF('day', last_activity_date, CURRENT_DATE) > 30
ORDER BY days_inactive DESC;
