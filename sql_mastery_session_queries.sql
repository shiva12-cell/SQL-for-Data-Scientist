-- ===============================================================================
-- 🚀 SQL MASTERY ROADMAP SESSION: ADVANCED ANALYTICS & WINDOW FUNCTIONS
-- Topics Covered: Ranking Functions, Value/Positioning Functions, Window Framing, 
--CTEs, Correlated Subqueries, DataLemur Interview Benchmarks
-- 1. User's Third Transaction (DataLemur - Amazon Medium)
-- Task: Extract the exact 3rd transaction for every user chronologically.
-- Technique: ROW_NUMBER() over CTE pattern
---------------------------------------------------------------------------------
-- Step 1: Create a Common Table Expression (CTE) to attach chronological sequence numbers
WITH third_trans AS (
    SELECT 
        user_id, 
        spend, 
        transaction_date,
        -- Generate a unique sequential integer per user ordered from oldest to newest transaction
        ROW_NUMBER() OVER (
            PARTITION BY user_id             -- Group rows independently for each user
            ORDER BY transaction_date ASC    -- Sequence rows chronologically
        ) AS rank_transaction
    FROM transactions
)
-- Step 2: Query the CTE to isolate only the 3rd transaction
SELECT 
    user_id, 
    spend, 
    transaction_date
FROM third_trans
WHERE rank_transaction = 3;                  -- Filter out all transactions except the 3rd


---------------------------------------------------------------------------------
-- 2. LinkedIn Power Creators - Part 1 (DataLemur - LinkedIn Easy/Medium)
-- Task: Find profile_ids of users who have more followers than their employer page.
-- Technique: Correlated Subquery / Inner Join pattern
---------------------------------------------------------------------------------
-- Solution A: Correlated Subquery Approach
SELECT profile_id 
FROM personal_profiles p
WHERE followers > (
    -- Subquery executes per candidate profile row to fetch matching employer's follower count
    SELECT followers
    FROM company_pages c
    WHERE p.employer_id = c.company_id      -- Link profile's employer to company page ID
)
ORDER BY profile_id ASC;                     -- Sort final output deterministically

-- Solution B: INNER JOIN Approach
SELECT 
    pf.profile_id
FROM personal_profiles pf
INNER JOIN company_pages cp
    ON pf.employer_id = cp.company_id        -- Join employee profiles directly with company pages
WHERE pf.followers > cp.followers            -- Filter for profiles with higher followers than employer
ORDER BY pf.profile_id ASC;


---------------------------------------------------------------------------------
-- 3. Photoshop Revenue Analysis (DataLemur - Adobe Medium)
-- Task: Calculate total revenue across ALL products for customers who bought 'Photoshop'.
-- Technique: Subquery / Conditional Aggregation / EXISTS filtering
---------------------------------------------------------------------------------
-- Solution A: Subquery IN Approach
SELECT 
    customer_id, 
    SUM(revenue) AS total_revenue             -- Sum overall customer spend across all products
FROM adobe_transactions
WHERE customer_id IN (
    -- Subquery identifies all distinct customer IDs who purchased 'Photoshop' at least once
    SELECT customer_id 
    FROM adobe_transactions 
    WHERE product = 'Photoshop'
)
GROUP BY customer_id                         -- Aggregate total revenue per qualifying customer
ORDER BY customer_id ASC;

-- Solution B: HAVING Clause Conditional Aggregation Approach
SELECT 
    customer_id, 
    SUM(revenue) AS total_revenue             -- Aggregate total revenue for all products
FROM adobe_transactions
GROUP BY customer_id
-- Filter groups: keep customer if sum of Photoshop transactions is greater than 0
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
        -- Assign sequential row numbers starting at 1 for each customer's earliest interaction
        ROW_NUMBER() OVER (
            PARTITION BY customer_id         -- Separate calculation window per customer
            ORDER BY interaction_date ASC    -- Earliest date gets row_number = 1
        ) AS rn
    FROM customer_interactions
)
SELECT 
    interaction_id,
    customer_id,
    channel,
    interaction_date
FROM ranked_interactions
WHERE rn = 1;                                -- Keep strictly the first interaction record per customer


---------------------------------------------------------------------------------
-- 5. The Academic Leaderboard (RANK)
-- Task: Rank students by exam scores per subject allowing Olympic-style skipped ranks.
---------------------------------------------------------------------------------
SELECT 
    student_id,
    subject,
    score,
    -- RANK() leaves numerical gaps after tie values (e.g., 1, 2, 2, 4)
    RANK() OVER (
        PARTITION BY subject                 -- Reset ranking evaluation for each academic subject
        ORDER BY score DESC                  -- Highest test scores receive top rank (#1)
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
        -- DENSE_RANK() assigns dense consecutive ranks without gaps during ties (e.g., 1, 2, 2, 3)
        DENSE_RANK() OVER (
            PARTITION BY department_id       -- Reset ranking calculation per department
            ORDER BY salary DESC             -- Top salary gets rank 1
        ) AS salary_tier
    FROM employees
)
SELECT 
    employee_id,
    department_id,
    salary,
    salary_tier
FROM ranked_salaries
WHERE salary_tier <= 2;                      -- Retain all employees within top 2 distinct pay tiers


---------------------------------------------------------------------------------
-- 7. Day-Over-Day Sales Change (LAG)
-- Task: Calculate revenue difference compared to the previous day per store.
---------------------------------------------------------------------------------
WITH sales_with_lag AS (
    SELECT 
        store_id,
        sale_date,
        revenue,
        -- LAG() fetches value from 1 row prior; defaults to 0 if no prior record exists
        LAG(revenue, 1, 0) OVER (
            PARTITION BY store_id            -- Evaluate timelines independently per store
            ORDER BY sale_date ASC           -- Traverse timeline chronologically
        ) AS prev_revenue
    FROM daily_sales
)
SELECT 
    store_id,
    sale_date,
    revenue,
    prev_revenue,
    revenue - prev_revenue AS revenue_diff   -- Compute day-over-day net revenue shift
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
        -- LEAD() looks ahead 1 row for next tier string (defaults to 'Current Active Plan' if latest row)
        LEAD(plan_type, 1, 'Current Active Plan') OVER (
            PARTITION BY user_id             -- Group execution by user
            ORDER BY change_date ASC         -- Order subscription history chronologically
        ) AS next_plan,
        -- LEAD() looks ahead 1 row for next change date (defaults to NULL if latest row)
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
        -- FIRST_VALUE retrieves the very first purchase amount in customer history
        FIRST_VALUE(amount) OVER (
            PARTITION BY customer_id 
            ORDER BY order_date ASC
        ) AS first_order_amount,
        -- NTH_VALUE fetches 2nd order amount across entire partition using explicit frame extension
        NTH_VALUE(amount, 2) OVER (
            PARTITION BY customer_id 
            ORDER BY order_date ASC
            -- Full frame allows row #1 to peek forward to grab the 2nd order amount once it exists
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


-- ------------------------------------------------------------------------------
-- Challenge 1: Relative Lookback vs. First Partition Boundary (LAG vs FIRST_VALUE)
-- Description: Compare each customer's order against their immediately preceding 
--              order amount and their first-ever order amount.
-- ------------------------------------------------------------------------------

WITH current_order_amount AS (
  SELECT 
    customer_id, 
    order_date, 
    amount,
    -- LAG(): Reaches 1 row backward inside customer partition (defaults to 0 if no prior order)
    LAG(amount, 1, 0) OVER (
      PARTITION BY customer_id 
      ORDER BY order_date ASC
    ) AS prev_order_amount,
    
    -- FIRST_VALUE(): Anchors to the absolute first record in the customer partition
    FIRST_VALUE(amount) OVER (
      PARTITION BY customer_id 
      ORDER BY order_date ASC
    ) AS first_ever_amount
  FROM orders
)
SELECT 
  customer_id, 
  order_date, 
  amount, 
  prev_order_amount, 
  first_ever_amount
FROM current_order_amount;


-- ------------------------------------------------------------------------------
-- Challenge 2: Lookahead with Fallback Values & Dates (LEAD)
-- Description: Retrieve the next subscription/membership tier upgrade and change date, 
--              handling end-of-timeline defaults gracefully.
-- ------------------------------------------------------------------------------

WITH next_membership AS (
  SELECT 
    user_id,
    tier_name AS current_tier,
    change_date,
    -- LEAD() for string: Reaches 1 row forward (defaults to 'CURRENT ACTIVE TIER' if last record)
    LEAD(tier_name, 1, 'CURRENT ACTIVE TIER') OVER (
      PARTITION BY user_id 
      ORDER BY change_date ASC
    ) AS next_tier,
    
    -- LEAD() for date: Reaches 1 row forward (defaults to NULL if last record)
    LEAD(change_date, 1, NULL) OVER (
      PARTITION BY user_id 
      ORDER BY change_date ASC
    ) AS next_change_date
  FROM membership_changes
)
SELECT 
  user_id,
  current_tier,
  change_date,
  next_tier,
  next_change_date
FROM next_membership;


-- ------------------------------------------------------------------------------
-- Challenge 3: Pinned N-th Value with Full Partition Framing (NTH_VALUE)
-- Description: Extract the 2nd payment amount across the user's partition, 
--              expanding the frame so Row #1 can look ahead across all rows.
-- ------------------------------------------------------------------------------

WITH second_users_payments AS (
  SELECT 
    user_id,
    payment_date,
    amount,
    -- NTH_VALUE(): Fetches 2nd record in partition.
    -- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ensures row 1 
    -- sees the 2nd row even when evaluating at the beginning of the partition frame.
    NTH_VALUE(amount, 2) OVER (
      PARTITION BY user_id 
      ORDER BY payment_date ASC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_payment_amount
  FROM user_payments
)
SELECT 
  user_id,
  payment_date,
  amount,
  second_payment_amount
FROM second_users_payments;


-- ------------------------------------------------------------------------------
-- Bonus Capstone Pattern: Deduplication + Gapless Ranking
-- Description: Deduplicate logs by timestamp (tie-breaking by lowest interaction_id),
--              then compute consecutive interaction ranks per user.
-- ------------------------------------------------------------------------------

WITH deduplicated_interactions AS (
  SELECT 
    interaction_id,
    user_id,
    interaction_date,
    action_type,
    -- Primary rank to isolate duplicate interactions per timestamp deterministic tie-break
    ROW_NUMBER() OVER (
      PARTITION BY user_id, interaction_date 
      ORDER BY interaction_id ASC            -- Deterministically choose lowest interaction ID on tie
    ) AS row_num
  FROM interaction_logs
),
clean_logs AS (
  SELECT 
    interaction_id,
    user_id,
    interaction_date,
    action_type
  FROM deduplicated_interactions
  WHERE row_num = 1                          -- Retain strictly 1 record per unique timestamp per user
)
SELECT 
  user_id,
  interaction_date,
  action_type,
  -- Calculate dense sequential interaction sequence per user across deduplicated records
  DENSE_RANK() OVER (
    PARTITION BY user_id 
    ORDER BY interaction_date ASC
  ) AS interaction_rank,
  -- Fetch prior interaction date to analyze user retention gaps
  LAG(interaction_date) OVER (
    PARTITION BY user_id 
    ORDER BY interaction_date ASC
  ) AS prior_interaction_date
FROM clean_logs;
