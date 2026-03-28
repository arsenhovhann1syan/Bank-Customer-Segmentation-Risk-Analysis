-- -- ============================================
-- -- 04_rfm_calculation.sql
-- -- Berka Financial Dataset — RFM Metrics & Scoring
-- -- ============================================

-- USE bank_rfm_analysis;

-- -- ============================================
-- -- 1. RAW RFM METRICS (VIEW)
-- -- Calculating Recency, Frequency, and Monetary values per account.
-- -- ============================================

-- CREATE OR REPLACE VIEW rfm_raw AS
-- SELECT
--     t.account_id,

--     -- RECENCY: Days since the last transaction relative to the dataset's max date
--     DATEDIFF(
--         (SELECT MAX(date) FROM trans), 
--         MAX(t.date)
--     ) AS recency_days,

--     -- FREQUENCY: Total count of all transactions for the account
--     COUNT(t.trans_id) AS frequency,

--     -- MONETARY: Sum of 'VYDAJ' (Withdrawal/Expense) amounts
--     ROUND(SUM(CASE WHEN t.type = 'VYDAJ' THEN t.amount ELSE 0 END), 2) AS monetary

-- FROM trans t
-- GROUP BY t.account_id;

-- -- ============================================
-- -- 2. RFM SCORING (VIEW)
-- -- Ranking customers into 5 equal groups (Quintiles) based on metrics.
-- -- ============================================

-- CREATE OR REPLACE VIEW rfm_scores AS
-- SELECT
--     account_id,
--     recency_days,
--     frequency,
--     monetary,

--     -- R Score: Lower recency_days = Higher Score (1-5 scale)
--     -- We use DESC so that the smallest recency_days get the score 5.
--     NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,

--     -- F Score: Higher frequency = Higher Score
--     NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,

--     -- M Score: Higher monetary = Higher Score
--     NTILE(5) OVER (ORDER BY monetary ASC) AS m_score

-- FROM rfm_raw;

-- -- ============================================
-- -- 3. CONSOLIDATED RFM SCORE & SEGMENT STRINGS (VIEW)
-- -- Creating a weighted average score and a string representation.
-- -- ============================================

-- CREATE OR REPLACE VIEW rfm_combined AS
-- SELECT
--     account_id,
--     recency_days,
--     frequency,
--     monetary,
--     r_score,
--     f_score,
--     m_score,

--     -- Weighted Score: Recency (30%), Frequency (35%), Monetary (35%)
--     ROUND((r_score * 0.3) + (f_score * 0.35) + (m_score * 0.35), 2) AS rfm_score,

--     -- RFM String: e.g., '555' for best customers
--     CONCAT(r_score, f_score, m_score) AS rfm_string

-- FROM rfm_scores;

-- -- ============================================
-- -- 4. VALIDATION: Distribution Analysis
-- -- Checking if the NTILE function distributed scores correctly.
-- -- ============================================

-- -- Frequency of each R score
-- SELECT r_score, COUNT(*) AS account_count FROM rfm_combined GROUP BY r_score;

-- -- Frequency of each F score
-- SELECT f_score, COUNT(*) AS account_count FROM rfm_combined GROUP BY f_score;

-- -- Frequency of each M score
-- SELECT m_score, COUNT(*) AS account_count FROM rfm_combined GROUP BY m_score;

-- -- ============================================
-- -- 5. TOP CUSTOMER INSIGHTS
-- -- Preview of the top 10 customers based on the combined RFM score.
-- -- ============================================

-- SELECT
--     account_id,
--     recency_days,
--     frequency,
--     monetary,
--     rfm_score,
--     rfm_string
-- FROM rfm_combined
-- ORDER BY rfm_score DESC
-- LIMIT 10;