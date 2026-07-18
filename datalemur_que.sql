-- ============================================================================
-- SQL PRACTICE PORTFOLIO: CODING CHALLENGES
-- Target Engines: MySQL & PostgreSQL Compatible
-- Tracked Order: Match Order of DataLemur Tracker Sheet
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CHALLENGE 1: Page With No Likes
-- Objective: Identify pages with absolute zero interaction presence.
-- ----------------------------------------------------------------------------
SELECT p.page_id
FROM pages p
WHERE NOT EXISTS (
  SELECT 1 
  FROM page_likes l 
  WHERE l.page_id = p.page_id
);


-- ----------------------------------------------------------------------------
-- CHALLENGE 2: Laptop vs. Mobile Viewership
-- Objective: Pivot device rows into horizontal metric summary counters.
-- ----------------------------------------------------------------------------
SELECT
  COUNT(CASE WHEN device_type = 'laptop' THEN 1 END) AS laptop_views,
  COUNT(CASE WHEN device_type IN ('tablet', 'phone') THEN 1 END) AS mobile_views
FROM viewership;


-- ----------------------------------------------------------------------------
-- CHALLENGE 3: Cities With Completed Trades
-- Objective: Rank cities by total volume of successful transactions.
-- ----------------------------------------------------------------------------
SELECT 
  u.city, 
  COUNT(t.order_id) AS total_orders
FROM users u
INNER JOIN trades t 
  ON u.user_id = t.user_id
WHERE t.status = 'Completed'
GROUP BY u.city
ORDER BY total_orders DESC;


-- ----------------------------------------------------------------------------
-- CHALLENGE 4: Average Post Hiatus (Part 1)
-- Objective: Calculate the exact day count between users' first and last posts
--            during a specific calendar year, ignoring single-action logs.
-- ----------------------------------------------------------------------------
SELECT 
  user_id, 
  DATEDIFF(MAX(post_date), MIN(post_date)) AS days_between
FROM posts 
WHERE YEAR(post_date) = 2021
GROUP BY user_id
HAVING COUNT(user_id) > 1;


-- ----------------------------------------------------------------------------
-- CHALLENGE 5: Teams Power Users
-- Objective: Filter aggregate message volumes for a target date bracket.
-- ----------------------------------------------------------------------------
SELECT 
  sender_id, 
  COUNT(message_id) AS message_count
FROM messages
WHERE sent_date >= '2022-08-01' AND sent_date < '2022-09-01'
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2;


-- ----------------------------------------------------------------------------
-- CHALLENGE 6: App Click-Through Rate (CTR)
-- Objective: Calculate conversion rates (Clicks/Impressions) using 
--            conditional value counters grouped by asset IDs.
-- ----------------------------------------------------------------------------
SELECT 
  app_id,
  ROUND(100.0 * COUNT(CASE WHEN event_type = 'click' THEN 1 END) / 
        COUNT(CASE WHEN event_type = 'impression' THEN 1 END), 2) AS CTR
FROM events 
WHERE YEAR(timestamp) = 2022
GROUP BY app_id;


-- ----------------------------------------------------------------------------
-- CHALLENGE 7: Sending vs. Opening Snaps
-- Objective: Find the percentage of time spent sending versus opening snaps
--            for each age bucket by joining activity logs with age demographics.
-- ----------------------------------------------------------------------------
SELECT 
  age.age_bucket,
  ROUND(
    100.0 * SUM(CASE WHEN act.activity_type = 'send' THEN act.time_spent ELSE 0 END) /
    NULLIF(SUM(CASE WHEN act.activity_type IN ('send', 'open') THEN act.time_spent ELSE 0 END), 0), 
    2
  ) AS send_perc,
  ROUND(
    100.0 * SUM(CASE WHEN act.activity_type = 'open' THEN act.time_spent ELSE 0 END) /
    NULLIF(SUM(CASE WHEN act.activity_type IN ('send', 'open') THEN act.time_spent ELSE 0 END), 0), 
    2
  ) AS open_perc
FROM activities act
INNER JOIN age_breakdown age 
  ON act.user_id = age.user_id
GROUP BY age.age_bucket;