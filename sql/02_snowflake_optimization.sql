-- ============================================================
-- Snowflake Query Optimization Patterns
-- Author: Sri Vaishnavi Devarashetty
-- Context: Patterns used to cut data processing time 30% at Apple
-- ============================================================


-- 1. USE CLUSTERING KEYS ON HIGH-CARDINALITY FILTER COLUMNS
-- Reduces micro-partition scanning on large fact tables
ALTER TABLE ld_course_completions
    CLUSTER BY (DATE_TRUNC('month', completion_date), department_id);


-- 2. CTE CHAIN: AVOID REPEATED SUBQUERIES
-- Breaks complex dashboard queries into readable, reusable steps
WITH
active_learners AS (
    SELECT DISTINCT learner_id
    FROM ld_learner_activity
    WHERE last_activity_date >= DATEADD('day', -90, CURRENT_DATE)
),

course_metrics AS (
    SELECT
        course_id,
        course_name,
        COUNT(*)                                AS total_enrollments,
        COUNT(CASE WHEN status = 'completed' THEN 1 END)  AS completions,
        ROUND(
            COUNT(CASE WHEN status = 'completed' THEN 1 END)
            / NULLIF(COUNT(*), 0) * 100, 1
        )                                       AS completion_rate_pct
    FROM ld_enrollments
    GROUP BY 1, 2
),

active_course_metrics AS (
    SELECT cm.*
    FROM course_metrics cm
    INNER JOIN ld_enrollments e ON cm.course_id = e.course_id
    INNER JOIN active_learners al ON e.learner_id = al.learner_id
    GROUP BY cm.course_id, cm.course_name, cm.total_enrollments,
             cm.completions, cm.completion_rate_pct
)

SELECT *
FROM active_course_metrics
ORDER BY completion_rate_pct DESC;


-- 3. QUALIFY INSTEAD OF OUTER SUBQUERY
-- Snowflake-native way to filter window function results — more readable and faster
SELECT
    department,
    learner_id,
    total_courses_completed,
    RANK() OVER (PARTITION BY department ORDER BY total_courses_completed DESC) AS dept_rank
FROM ld_learner_summary
QUALIFY dept_rank <= 3;   -- Top 3 learners per department, no outer SELECT needed


-- 4. ZERO-COPY CLONE FOR QA TESTING
-- Create a full copy of a production table instantly for testing — no storage cost until changes
CREATE OR REPLACE TABLE ld_course_completions_qa
    CLONE ld_course_completions;


-- 5. TIME TRAVEL: COMPARE YESTERDAY'S DATA TO CATCH PIPELINE ISSUES
-- Used in data governance: detect unexpected row drops between loads
SELECT
    COUNT(*) AS current_count
FROM ld_course_completions

UNION ALL

SELECT
    COUNT(*) AS yesterday_count
FROM ld_course_completions
    AT (OFFSET => -86400);   -- 86400 seconds = 24 hours


-- 6. RESULT CACHING — FORCE FRESH RESULTS WHEN NEEDED
-- By default Snowflake caches results for 24h; use this for live KPI checks
ALTER SESSION SET USE_CACHED_RESULT = FALSE;

SELECT
    DATE_TRUNC('day', completion_date) AS date,
    COUNT(*)                           AS daily_completions
FROM ld_course_completions
WHERE completion_date >= DATEADD('day', -7, CURRENT_DATE)
GROUP BY 1
ORDER BY 1;

ALTER SESSION SET USE_CACHED_RESULT = TRUE;  -- re-enable after spot check
