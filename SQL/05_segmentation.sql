-- -- ============================================
-- -- 05_segmentation.sql
-- -- Berka Financial Dataset — Customer Segmentation & Risk Analysis
-- -- ============================================

-- USE bank_rfm_analysis;

-- -- ============================================
-- -- 1. CUSTOMER SEGMENTATION
-- -- Classifying customers based on their weighted RFM scores.
-- -- ============================================

-- CREATE OR REPLACE VIEW rfm_segments AS
-- SELECT
--     account_id,
--     recency_days,
--     frequency,
--     monetary,
--     r_score,
--     f_score,
--     m_score,
--     rfm_score,
--     rfm_string,

--     CASE
--         WHEN rfm_score >= 4.5                      THEN 'Champions'
--         WHEN rfm_score >= 4.0                      THEN 'Loyal Customers'
--         WHEN rfm_score >= 3.5                      THEN 'Potential Loyalists'
--         WHEN rfm_score >= 3.0 AND r_score >= 4     THEN 'Recent Customers'
--         WHEN rfm_score >= 2.5 AND f_score >= 3     THEN 'At Risk'
--         WHEN rfm_score >= 2.0 AND r_score <= 2     THEN 'Hibernating'
--         WHEN rfm_score >= 1.5                      THEN 'About to Sleep'
--         ELSE                                            'Lost / Inactive'
--     END AS segment

-- FROM rfm_combined;

-- -- ============================================
-- -- 2. SEGMENT PROFILE SUMMARY
-- -- Aggregating metrics to understand the behavior of each group.
-- -- ============================================

-- SELECT
--     segment,
--     COUNT(account_id)           AS account_count,
--     ROUND(AVG(recency_days), 1) AS avg_recency,
--     ROUND(AVG(frequency), 1)    AS avg_frequency,
--     ROUND(AVG(monetary), 2)     AS avg_monetary,
--     ROUND(AVG(rfm_score), 2)    AS avg_rfm_score
-- FROM rfm_segments
-- GROUP BY segment
-- ORDER BY avg_rfm_score DESC;

-- -- ============================================
-- -- 3. ANOMALY & FRAUD DETECTION FLAGS
-- -- Statistical / Data-driven Approach using IQR (MySQL-compatible)
-- -- ============================================

-- CREATE OR REPLACE VIEW rfm_flagged AS

-- WITH
-- -- Step 1: Calculate Q1, Q3, and IQR for frequency
-- freq_stats AS (
--     SELECT
--         MAX(CASE WHEN rn = FLOOR(0.25*cnt)+1 THEN frequency END) AS Q1,
--         MAX(CASE WHEN rn = FLOOR(0.75*cnt)+1 THEN frequency END) AS Q3
--     FROM (
--         SELECT frequency, ROW_NUMBER() OVER (ORDER BY frequency) AS rn, COUNT(*) OVER() AS cnt
--         FROM rfm_segments
--     ) t
-- ),
-- -- Step 2: Calculate Q1, Q3, and IQR for monetary
-- mon_stats AS (
--     SELECT
--         MAX(CASE WHEN rn = FLOOR(0.25*cnt)+1 THEN monetary END) AS Q1,
--         MAX(CASE WHEN rn = FLOOR(0.75*cnt)+1 THEN monetary END) AS Q3
--     FROM (
--         SELECT monetary, ROW_NUMBER() OVER (ORDER BY monetary) AS rn, COUNT(*) OVER() AS cnt
--         FROM rfm_segments
--     ) t
-- ),
-- -- Step 3: Calculate Q1, Q3, and IQR for recency_days
-- recency_stats AS (
--     SELECT
--         MAX(CASE WHEN rn = FLOOR(0.25*cnt)+1 THEN recency_days END) AS Q1,
--         MAX(CASE WHEN rn = FLOOR(0.75*cnt)+1 THEN recency_days END) AS Q3
--     FROM (
--         SELECT recency_days, ROW_NUMBER() OVER (ORDER BY recency_days) AS rn, COUNT(*) OVER() AS cnt
--         FROM rfm_segments
--     ) t
-- )

-- SELECT
--     s.account_id,
--     s.recency_days,
--     s.frequency,
--     s.monetary,
--     s.r_score,
--     s.segment,

--     -- Flag 1: High Frequency Low Monetary
--     CASE
--         WHEN s.frequency > (SELECT Q3 + 1.5*(Q3-Q1) FROM freq_stats)
--          AND s.monetary < (SELECT Q1 - 1.5*(Q3-Q1) FROM mon_stats)
--         THEN 'High Frequency Low Volume'
--         ELSE NULL
--     END AS flag_hflv,

--     -- Flag 2: Low Frequency High Monetary
--     CASE
--         WHEN s.frequency < (SELECT Q1 - 1.5*(Q3-Q1) FROM freq_stats)
--          AND s.monetary > (SELECT Q3 + 1.5*(Q3-Q1) FROM mon_stats)
--         THEN 'Low Frequency High Volume'
--         ELSE NULL
--     END AS flag_lfhv,

--     -- Flag 3: Sudden Reactivation
--     CASE
--         WHEN s.recency_days < (SELECT Q1 - 1.5*(Q3-Q1) FROM recency_stats)
--          AND s.r_score <= 2
--         THEN 'Sudden Reactivation'
--         ELSE NULL
--     END AS flag_reactivation

-- FROM rfm_segments s;

-- -- ============================================
-- -- 4. RISK OVERLAY: Loan Status vs segments
-- -- Checking how segments correlate with loan repayment status.
-- -- ============================================

-- SELECT
--     s.segment,
--     l.status,
--     COUNT(*)                AS loan_count,
--     ROUND(AVG(l.amount), 2) AS avg_loan_amount
-- FROM rfm_segments s
-- JOIN loan l ON s.account_id = l.account_id
-- GROUP BY s.segment, l.status
-- ORDER BY s.segment, l.status;

-- -- ============================================
-- -- 5. FINAL ANALYTICAL EXPORT (Fixed Column Names)
-- -- Consolidated view for Python or Power BI.
-- -- ============================================

-- CREATE OR REPLACE VIEW rfm_final_export AS
-- SELECT
--     s.account_id,
--     a.district_id,
--     d.A2 AS district_name, -- Adjusted from district_name to A2
--     d.A3 AS region,        -- Adjusted from region to A3
--     s.recency_days,
--     s.frequency,
--     s.monetary,
--     s.r_score,
--     s.f_score,
--     s.m_score,
--     s.rfm_score,
--     s.rfm_string,
--     s.segment,
--     f.flag_hflv,
--     f.flag_lfhv,
--     f.flag_reactivation
-- FROM rfm_segments s
-- JOIN account  a ON s.account_id  = a.account_id
-- JOIN district d ON a.district_id = d.A1        -- Adjusted district_id to A1
-- LEFT JOIN rfm_flagged f ON s.account_id = f.account_id;

-- -- Final data preview
-- SELECT * FROM rfm_final_export LIMIT 20;