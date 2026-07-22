-- ===============================================================================
-- 🚀 SQL MASTERY ROADMAP SESSION: ADVANCED ANALYTICS & WINDOW FUNCTIONS
-- ===============================================================================
-- Database Engine: Generic ANSI SQL / PostgreSQL Compatible
-- Topics Covered: Ranking Functions, Value/Positioning Functions, Window Framing, 
--                 CTEs, Correlated Subqueries, DataLemur Interview Benchmarks
-- ===============================================================================


-- ===============================================================================
-- 🎯 SECTION 1: DATALEMUR INTERVIEW QUESTIONS
-- ===============================================================================

---------------------------------------------------------------------------------
-- 1. User's Third Transaction (DataLemur - Amazon Medium)
-- Task: Extract the exact 3rd transaction for every user chronologically.
-- Technique: ROW_NUMBER() over CTE pattern
---------------------------------------------------------------------------------
WITH third_trans AS (
    SELECT 
        user_id, 
        spend, 
        transaction_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY transaction_date ASC
        ) AS rank_transaction
    FROM transactions
)
SELECT 
    user_id, 
    spend, 
    transaction_date
FROM third_trans
WHERE rank_transaction = 3;


---------------------------------------------------------------------------------
-- 2. LinkedIn Power Creators - Part 1 (DataLemur - LinkedIn Easy/Medium)
-- Task: Find profile_ids of users who have more followers than their employer page.
-- Technique: Correlated Subquery / Inner Join pattern
---------------------------------------------------------------------------------
-- Solution A: Correlated Subquery Approach
SELECT profile_id 
FROM personal_profiles p
WHERE followers > (
    SELECT followers
    FROM company_pages c
    WHERE p.employer_id = c.company_id
)
ORDER BY profile_id ASC;

-- Solution B: INNER JOIN Approach
SELECT 
    pf.profile_id
FROM personal_profiles pf
INNER JOIN company_pages cp
    ON pf.employer_id = cp.company_id
WHERE pf.followers > cp.followers
ORDER BY pf.profile_id ASC;


---------------------------------------------------------------------------------
-- 3. Photoshop Revenue Analysis (DataLemur - Adobe Medium)
-- Task: Calculate total revenue across ALL products for customers who bought 'Photoshop'.
-- Technique: Subquery / Conditional Aggregation / EXISTS filtering
---------------------------------------------------------------------------------
-- Solution A: Subquery IN Approach
SELECT 
    customer_id, 
    SUM(revenue) AS total_revenue
FROM adobe_transactions
WHERE customer_id IN (
    SELECT customer_id 
    FROM adobe_transactions 
    WHERE product = 'Photoshop'
)
GROUP BY customer_id
ORDER BY customer_id ASC;

-- Solution B: HAVING Clause Conditional Aggregation Approach
SELECT 
    customer_id, 
    SUM(revenue) AS total_revenue
FROM adobe_transactions
GROUP BY customer_id
HAVING SUM(CASE WHEN product = 'Photoshop' THEN 1 ELSE 0 END) > 0
ORDER BY customer_id ASC;


-- ===============================================================================
-- 🎯 SECTION 2: CONCEPT PRACTICE QUESTIONS & WINDOW FUNCTIONS
-- ===============================================================================

---------------------------------------------------------------------------------
-- 4. The "First Contact" Isolation (ROW_NUMBER)
-- Task: Deduplicate customer interaction logs to retain only earliest interaction per customer.
---------------------------------------------------------------------------------
WITH ranked_interactions AS (
    SELECT 
        interaction_id,
        customer_id,
        channel,
        interaction_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY interaction_date ASC
        ) AS rn
    FROM customer_interactions
)
SELECT 
    interaction_id,
    customer_id,
    channel,
    interaction_date
FROM ranked_interactions
WHERE rn = 1;


---------------------------------------------------------------------------------
-- 5. The Academic Leaderboard (RANK)
-- Task: Rank students by exam scores per subject allowing Olympic-style skipped ranks.
---------------------------------------------------------------------------------
SELECT 
    student_id,
    subject,
    score,
    RANK() OVER (
        PARTITION BY subject 
        ORDER BY score DESC
    ) AS student_rank
FROM student_scores;


---------------------------------------------------------------------------------
-- 6. The Elite Salary Tiers (DENSE_RANK)
-- Task: Find employees earning in the top 2 distinct salary tiers per department.
---------------------------------------------------------------------------------
WITH ranked_salaries AS (
    SELECT 
        employee_id,
        department_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department_id 
            ORDER BY salary DESC
        ) AS salary_tier
    FROM employees
)
SELECT 
    employee_id,
    department_id,
    salary,
    salary_tier
FROM ranked_salaries
WHERE salary_tier <= 2;


---------------------------------------------------------------------------------
-- 7. Day-Over-Day Sales Change (LAG)
-- Task: Calculate revenue difference compared to the previous day per store.
---------------------------------------------------------------------------------
WITH sales_with_lag AS (
    SELECT 
        store_id,
        sale_date,
        revenue,
        LAG(revenue, 1, 0) OVER (
            PARTITION BY store_id 
            ORDER BY sale_date ASC
        ) AS prev_revenue
    FROM daily_sales
)
SELECT 
    store_id,
    sale_date,
    revenue,
    prev_revenue,
    revenue - prev_revenue AS revenue_diff
FROM sales_with_lag;


---------------------------------------------------------------------------------
-- 8. Subscription Plan Upgrades (LEAD)
-- Task: Determine user's current plan alongside next plan and transition date.
---------------------------------------------------------------------------------
WITH lead_plan AS (  
    SELECT 
        user_id,
        plan_type AS current_plan,
        change_date,
        LEAD(plan_type, 1, 'Current Active Plan') OVER (
            PARTITION BY user_id 
            ORDER BY change_date ASC
        ) AS next_plan,
        LEAD(change_date, 1, NULL) OVER (
            PARTITION BY user_id 
            ORDER BY change_date ASC
        ) AS next_plan_date
    FROM subscription_logs
)
SELECT 
    user_id,
    current_plan,
    change_date,
    next_plan,
    next_plan_date
FROM lead_plan;


---------------------------------------------------------------------------------
-- 9. Customer Purchase Benchmarks (FIRST_VALUE & NTH_VALUE)
-- Task: Fetch the first order amount and second order amount for each customer using window framing.
---------------------------------------------------------------------------------
WITH order_amount AS (
    SELECT 
        customer_id,
        order_date,
        amount AS current_order_amount, 
        FIRST_VALUE(amount) OVER (
            PARTITION BY customer_id 
            ORDER BY order_date ASC
        ) AS first_order_amount,
        NTH_VALUE(amount, 2) OVER (
            PARTITION BY customer_id 
            ORDER BY order_date ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS second_order_amount 
    FROM orders
)
SELECT 
    customer_id,
    order_date,
    current_order_amount,
    first_order_amount,
    second_order_amount
FROM order_amount;
