/* ============================================================================
   🏆 SQL MASTERY WORKBOOK: MODULE 1 (RANKING FUNCTIONS)
   ============================================================================
   This file contains verified, optimized solutions developed to solve
   deduplication, tie-gaps, and consecutive window tiering problems.
*/

-- ----------------------------------------------------------------------------
-- 🎯 CHALLENGE 1: The "First Contact" Isolation
-- Core Concept: ROW_NUMBER() Deduplication Pattern
-- Business Rule: Strict uniqueness. Isolate only the earliest chronological 
--                interaction per customer. Break ties deterministically via ID.
-- ----------------------------------------------------------------------------

WITH ranked_interaction AS (
    SELECT 
        interaction_id, 
        customer_id, 
        interaction_date,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY interaction_date ASC, interaction_id ASC
        ) AS rn   
    FROM customer_interactions
) 
SELECT 
    interaction_id,
    customer_id,
    interaction_date,
    channel
FROM ranked_interaction 
WHERE rn = 1;


-- ----------------------------------------------------------------------------
-- 🎯 CHALLENGE 2: The Academic Leaderboard
-- Core Concept: RANK() Gap-leaving Pattern
-- Business Rule: Olympic-style sorting. Ties share ranks, subsequent physical 
--                counter index spaces are skipped to leave meaningful gaps.
-- ----------------------------------------------------------------------------

WITH leader_board AS (
    SELECT 
        student_id,
        subject,
        score,
        RANK() OVER (
            PARTITION BY subject 
            ORDER BY score DESC
        ) AS top_scorer 
    FROM exam_results
)
SELECT 
    student_id,
    subject,
    score
FROM leader_board 
WHERE top_scorer <= 3;


-- ----------------------------------------------------------------------------
-- 🎯 CHALLENGE 3: The Elite Salary Tiers
-- Core Concept: DENSE_RANK() Consecutive Tie Pattern
-- Business Rule: Extract top N distinct value tiers. Shared metrics share ranks 
--                without skipping subsequent numbers (continuous integers).
-- ----------------------------------------------------------------------------

WITH topsalary AS (
    SELECT 
        employee_id,
        department,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department  
            ORDER BY salary DESC
        ) AS salary_rank
    FROM company_payroll
)
SELECT 
    employee_id,
    department,
    salary
FROM topsalary
WHERE salary_rank <= 2;

/* ============================================================================
   END OF MODULE 1 WORKBOOK
   ============================================================================ */