-- ============================================================================
-- SQL CHALLENGES & SOLUTIONS: SUBQUERIES, CORRELATION, AND DUPLICATES
-- ============================================================================
-- Purpose: A collection of production-ready SQL queries covering intermediate
--          to advanced concepts like NOT EXISTS, Correlated Subqueries, and 
--          aggregation filtering (HAVING counts).
-- AUTHOR: Github Contributor
-- DATE: 2026
-- ============================================================================


-- ----------------------------------------------------------------------------
-- CHALLENGE 1: Unassigned Departments (The Inner Join Trap Fix)
-- Objective: Find the names of departments that have no employees assigned.
-- Concept: Avoiding Inner Joins when looking for missing data; utilizing
--          NOT EXISTS to isolate empty sets.
-- ----------------------------------------------------------------------------
-- Schema: 
-- departments (dept_id INT PK, dept_name VARCHAR)
-- employees (employee_id INT PK, dept_id INT FK)

SELECT d.dept_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 
    FROM employees e
    WHERE e.dept_id = d.dept_id
);


-- ----------------------------------------------------------------------------
-- CHALLENGE 2: Find Inactive Customers (NOT EXISTS Pattern)
-- Objective: Find the names of customers who have never placed a single order.
-- Concept: Uses the 'SELECT 1' subquery optimization.
-- ----------------------------------------------------------------------------
-- Schema: 
-- customers (customer_id INT PK, customer_name VARCHAR)
-- orders (order_id INT PK, customer_id INT FK)

SELECT customer_name 
FROM customers c
WHERE NOT EXISTS (
    -- The engine returns 1 immediately if a matching row is found, 
    -- avoiding expensive column lookups.
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- ----------------------------------------------------------------------------
-- CHALLENGE 3: High-Value Suppliers (EXISTS Pattern)
-- Objective: Find the names and countries of suppliers who supply at least 
--            one product priced over $500.
-- Concept: Positive existence evaluation using correlation.
-- ----------------------------------------------------------------------------
-- Schema:
-- suppliers (supplier_id INT PK, supplier_name VARCHAR, country VARCHAR)
-- products (product_id INT PK, supplier_id INT FK, unit_price DECIMAL)

SELECT supplier_name, country 
FROM suppliers s
WHERE EXISTS (
    SELECT 1 
    FROM products p
    WHERE p.supplier_id = s.supplier_id 
      AND p.unit_price > 500
);


-- ----------------------------------------------------------------------------
-- CHALLENGE 4: Non-Sci-Fi Authors (Negative Filtering)
-- Objective: Return the names of authors who have never published a book 
--            in the 'Sci-Fi' genre.
-- Concept: Ensuring complete absence of a attribute condition across rows.
-- ----------------------------------------------------------------------------
-- Schema:
-- authors (author_id INT PK, author_name VARCHAR)
-- books (book_id INT PK, author_id INT FK, genre VARCHAR)

SELECT author_name 
FROM authors a
WHERE NOT EXISTS (
    SELECT 1 
    FROM books b
    WHERE b.author_id = a.author_id 
      AND b.genre = 'Sci-Fi'
);


-- ----------------------------------------------------------------------------
-- CHALLENGE 5: Strictly Business Travelers (The Double Condition Trap)
-- Objective: Find passengers who have flown in 'Business' class, but have 
--            NEVER once flown in 'First' class.
-- Concept: Overcoming the row-by-row filtering blindspot by isolating 
--          inclusion rules from total exclusion rules.
-- ----------------------------------------------------------------------------
-- Schema:
-- flight_bookings (booking_id INT PK, passenger_id INT, flight_class VARCHAR)

SELECT DISTINCT passenger_id
FROM flight_bookings fb
WHERE flight_class = 'Business' 
  AND NOT EXISTS (
      SELECT 1
      FROM flight_bookings
      WHERE passenger_id = fb.passenger_id 
        AND flight_class = 'First' 
  );


-- ----------------------------------------------------------------------------
-- CHALLENGE 6: Medical Records Audit (Dynamic Correlation)
-- Objective: Return unique patient IDs who have a 'Prescription' status record, 
--            but have never received a 'Discharge' status record.
-- Concept: Re-running the correlated subquery by dynamically altering its 
--          matching parameter for every single row in the outer scope.
-- ----------------------------------------------------------------------------
-- Schema:
-- medical_records (record_id INT PK, patient_id INT, status VARCHAR)

SELECT DISTINCT patient_id
FROM medical_records mr
WHERE status = 'Prescription' 
  AND NOT EXISTS ( 
      SELECT 1 
      FROM medical_records 
      WHERE patient_id = mr.patient_id 
        AND status = 'Discharge'
  );


-- ----------------------------------------------------------------------------
-- CHALLENGE 7: Bank Account Portfolio Analysis
-- Objective: Find the unique customer IDs of customers who hold a 'Savings' 
--            account but do NOT own a 'Loan' account.
-- Concept: Utilizing correlated scanning to evaluate account portfolios.
-- ----------------------------------------------------------------------------
-- Schema:
-- bank_accounts (account_id INT PK, customer_id INT, account_type VARCHAR)

SELECT DISTINCT customer_id 
FROM bank_accounts ba 
WHERE account_type = 'Savings' 
  AND NOT EXISTS (
      SELECT 1 
      FROM bank_accounts 
      WHERE customer_id = ba.customer_id 
        AND account_type = 'Loan'
  );


-- ----------------------------------------------------------------------------
-- CHALLENGE 8: Finding Duplicates (Aggregated Counter Pattern)
-- Objective: Find duplicate emails in a user directory and return the email
--            along with the number of times it was duplicated.
-- Concept: Grouping by a unique attribute and filtering groups via HAVING COUNT.
-- ----------------------------------------------------------------------------
-- Schema:
-- users (user_id INT PK, username VARCHAR, email VARCHAR)

SELECT email, COUNT(email) AS duplicate_mail
FROM users 
GROUP BY email
HAVING COUNT(*) > 1;