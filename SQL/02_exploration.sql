-- -- ============================================
-- -- 02_exploration.sql
-- -- Berka Financial Dataset — Exploratory Data Analysis (EDA)
-- -- ============================================

-- USE bank_rfm_analysis;

-- -- ============================================
-- -- 1. DATA AUDIT: Check row counts for all tables 
-- -- to ensure data was fully imported.
-- -- ============================================

-- SELECT 'district' AS table_name, COUNT(*) AS row_count FROM district
-- UNION ALL
-- SELECT 'account',  COUNT(*) FROM account
-- UNION ALL
-- SELECT 'client',   COUNT(*) FROM client
-- UNION ALL
-- SELECT 'disp',     COUNT(*) FROM disp
-- UNION ALL
-- SELECT 'card',     COUNT(*) FROM card
-- UNION ALL
-- SELECT 'order',    COUNT(*) FROM `order`
-- UNION ALL
-- SELECT 'loan',     COUNT(*) FROM loan
-- UNION ALL
-- SELECT 'trans',    COUNT(*) FROM trans;

-- -- ============================================
-- -- 2. QUALITY CHECK: Identify missing values (NULLs) 
-- -- in critical transaction and customer tables.
-- -- ============================================

-- -- Transaction Table NULL Check
-- SELECT
--     COUNT(*)                                            AS total_rows,
--     SUM(CASE WHEN trans_id   IS NULL THEN 1 ELSE 0 END) AS null_trans_id,
--     SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END) AS null_account_id,
--     SUM(CASE WHEN date       IS NULL THEN 1 ELSE 0 END) AS null_date, -- Adjusted to 'date'
--     SUM(CASE WHEN amount     IS NULL THEN 1 ELSE 0 END) AS null_amount,
--     SUM(CASE WHEN balance    IS NULL THEN 1 ELSE 0 END) AS null_balance,
--     SUM(CASE WHEN type       IS NULL THEN 1 ELSE 0 END) AS null_type
-- FROM trans;

-- -- Account Table NULL Check
-- SELECT
--     COUNT(*)                                              AS total_rows,
--     SUM(CASE WHEN account_id  IS NULL THEN 1 ELSE 0 END) AS null_account_id,
--     SUM(CASE WHEN district_id IS NULL THEN 1 ELSE 0 END) AS null_district_id,
--     SUM(CASE WHEN frequency   IS NULL THEN 1 ELSE 0 END) AS null_frequency,
--     SUM(CASE WHEN date        IS NULL THEN 1 ELSE 0 END) AS null_date -- Adjusted to 'date'
-- FROM account;

-- -- ============================================
-- -- 3. CATEGORICAL PROFILING: Review unique values 
-- -- to understand business logic and labels.
-- -- ============================================

-- SELECT DISTINCT type     FROM trans;
-- SELECT DISTINCT operation FROM trans;
-- SELECT DISTINCT k_symbol  FROM trans;
-- SELECT DISTINCT frequency FROM account;
-- SELECT DISTINCT type      FROM disp;
-- SELECT DISTINCT type      FROM card;
-- SELECT DISTINCT status    FROM loan;

-- -- ============================================
-- -- 4. TIME HORIZON: Check the date range 
-- -- to determine the "snapshot date" for RFM calculation.
-- -- ============================================

-- SELECT 
--     STR_TO_DATE(MIN(date), '%y%m%d') AS first_transaction,
--     STR_TO_DATE(MAX(date), '%y%m%d') AS last_transaction
-- FROM trans;

-- SELECT 
--     STR_TO_DATE(MIN(date), '%y%m%d') AS first_account_created,
--     STR_TO_DATE(MAX(date), '%y%m%d') AS last_account_created
-- FROM account;

-- -- ============================================
-- -- 5. STATISTICAL SUMMARY: Analyze the distribution 
-- -- of transaction amounts.
-- -- ============================================

-- SELECT
--     MIN(amount)                    AS min_amount,
--     MAX(amount)                    AS max_amount,
--     ROUND(AVG(amount), 2)          AS avg_amount,
--     ROUND(STDDEV(amount), 2)       AS std_amount
-- FROM trans;

-- -- ============================================
-- -- 6. VOLUMETRIC ANALYSIS: Top 20 accounts by transaction volume.
-- -- This helps identify the most active customers.
-- -- ============================================

-- SELECT
--     account_id,
--     COUNT(*)               AS tx_count,
--     ROUND(SUM(amount), 2)  AS total_volume,
--     ROUND(AVG(amount), 2)  AS avg_tx_size
-- FROM trans
-- GROUP BY account_id
-- ORDER BY tx_count DESC
-- LIMIT 20;

-- -- ============================================
-- -- 7. LOAN PORTFOLIO: Distribution of loan statuses.
-- -- (A: Finished/OK, B: Finished/Unpaid, C: Running/OK, D: Running/Debt)
-- -- ============================================

-- SELECT
--     status,
--     COUNT(*)              AS loan_count,
--     ROUND(AVG(amount), 2) AS avg_loan_amount
-- FROM loan
-- GROUP BY status
-- ORDER BY loan_count DESC;

-- -- ============================================
-- -- 8. PRODUCT MIX: Breakdown of credit card types.
-- -- ============================================

-- SELECT
--     type,
--     COUNT(*) AS card_count
-- FROM card
-- GROUP BY type
-- ORDER BY card_count DESC;