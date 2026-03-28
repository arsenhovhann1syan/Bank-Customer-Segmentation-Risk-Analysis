-- -- ============================================
-- -- 03_cleaning.sql
-- -- Berka Financial Dataset — Data Cleaning & Standardization
-- -- ============================================

-- USE bank_rfm_analysis;

-- -- ============================================
-- -- 1. DUPLICATE CHECK
-- -- Identifying potential duplicate records in primary tables.
-- -- ============================================

-- -- Check for duplicate Transaction IDs
-- SELECT trans_id, COUNT(*) AS cnt
-- FROM trans
-- GROUP BY trans_id
-- HAVING cnt > 1;

-- -- Check for duplicate Account IDs
-- SELECT account_id, COUNT(*) AS cnt
-- FROM account
-- GROUP BY account_id
-- HAVING cnt > 1;

-- -- Check for duplicate Loan IDs
-- SELECT loan_id, COUNT(*) AS cnt
-- FROM loan
-- GROUP BY loan_id
-- HAVING cnt > 1;

-- -- ============================================
-- -- 2. NULL HANDLING — Transactions
-- -- Removing or filling missing values to ensure accurate RFM metrics.
-- -- ============================================

-- -- Delete records without an amount (Essential for Monetary calculation)
-- DELETE FROM trans
-- WHERE amount IS NULL;

-- -- Replace NULL balances with 0
-- UPDATE trans
-- SET balance = 0
-- WHERE balance IS NULL;

-- -- Fill missing categorical descriptions with 'UNKNOWN'
-- UPDATE trans
-- SET k_symbol = 'UNKNOWN'
-- WHERE k_symbol IS NULL OR k_symbol = '';

-- UPDATE trans
-- SET operation = 'UNKNOWN'
-- WHERE operation IS NULL OR operation = '';

-- UPDATE trans
-- SET bank = 'UNKNOWN'
-- WHERE bank IS NULL OR bank = '';

-- -- ============================================
-- -- 3. NULL HANDLING — Loans
-- -- ============================================

-- -- Delete loans with missing status or amount
-- DELETE FROM loan
-- WHERE status IS NULL OR amount IS NULL;

-- -- ============================================
-- -- 4. LOGICAL CONSISTENCY
-- -- Removing rows with impossible or erroneous data.
-- -- ============================================

-- -- Delete transactions with negative amounts (likely data entry errors)
-- DELETE FROM trans
-- WHERE amount < 0;

-- -- Check for and remove future-dated transactions relative to current date
-- DELETE FROM trans
-- WHERE date > CURDATE();

-- -- ============================================
-- -- 5. STRING STANDARDIZATION
-- -- Ensuring consistent casing and removing extra spaces.
-- -- ============================================

-- -- Trim whitespaces and standardize transaction types to UPPERCASE
-- UPDATE trans
-- SET type = UPPER(TRIM(type));

-- -- ============================================
-- -- 6. REFERENTIAL INTEGRITY (ORPHAN RECORDS)
-- -- Removing child records that do not have a corresponding parent record.
-- -- ============================================

-- -- Delete transactions that are not linked to any existing account
-- DELETE FROM trans
-- WHERE account_id NOT IN (SELECT account_id FROM account);

-- -- Identify orphan records in other related tables
-- SELECT COUNT(*) AS orphan_disp
-- FROM disp
-- WHERE client_id NOT IN (SELECT client_id FROM client);

-- SELECT COUNT(*) AS orphan_loans
-- FROM loan
-- WHERE account_id NOT IN (SELECT account_id FROM account);

-- -- ============================================
-- -- 7. FINAL POST-CLEANING AUDIT
-- -- Verification of row counts after the cleaning process.
-- -- ============================================

-- SELECT 'trans'    AS table_name, COUNT(*) AS row_count FROM trans
-- UNION ALL
-- SELECT 'account', COUNT(*) FROM account
-- UNION ALL
-- SELECT 'client',  COUNT(*) FROM client
-- UNION ALL
-- SELECT 'loan',    COUNT(*) FROM loan;