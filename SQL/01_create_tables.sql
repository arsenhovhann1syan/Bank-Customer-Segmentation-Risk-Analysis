-- -- Check the total row counts for each table to verify successful data import
-- SELECT 
--     (SELECT COUNT(*) FROM account) as account_rows,
--     (SELECT COUNT(*) FROM card) as card_rows,
--     (SELECT COUNT(*) FROM client) as client_rows,
--     (SELECT COUNT(*) FROM disp) as disp_rows,
--     (SELECT COUNT(*) FROM district) as district_rows,
--     (SELECT COUNT(*) FROM loan) as loan_rows,
--     (SELECT COUNT(*) FROM `order`) as order_rows,
--     (SELECT COUNT(*) FROM trans) as trans_rows;


-- -- ============================================
-- -- 01_create_tables.sql
-- -- Berka Financial Dataset — MySQL
-- -- ============================================

-- USE bank_rfm_analysis;

-- -- 1. District
-- CREATE TABLE district (
--     district_id      INT PRIMARY KEY,
--     district_name    VARCHAR(100),
--     region           VARCHAR(100),
--     population       INT,
--     avg_salary       INT,
--     unemployment_95  DECIMAL(5,2),
--     unemployment_96  DECIMAL(5,2),
--     nr_entrepreneurs INT,
--     nr_crimes_95     INT,
--     nr_crimes_96     INT
-- );

-- -- 2. Account
-- CREATE TABLE account (
--     account_id   INT PRIMARY KEY,
--     district_id  INT,
--     frequency    VARCHAR(50),
--     date_created DATE,
--     FOREIGN KEY (district_id) REFERENCES district(district_id)
-- );

-- -- 3. Client
-- CREATE TABLE client (
--     client_id   INT PRIMARY KEY,
--     birth_date  DATE,
--     gender      CHAR(1),
--     district_id INT,
--     FOREIGN KEY (district_id) REFERENCES district(district_id)
-- );

-- -- 4. Disposition
-- CREATE TABLE disp (
--     disp_id    INT PRIMARY KEY,
--     client_id  INT,
--     account_id INT,
--     type       VARCHAR(20),
--     FOREIGN KEY (client_id)  REFERENCES client(client_id),
--     FOREIGN KEY (account_id) REFERENCES account(account_id)
-- );

-- -- 5. Card
-- CREATE TABLE card (
--     card_id  INT PRIMARY KEY,
--     disp_id  INT,
--     type     VARCHAR(20),
--     issued   DATE,
--     FOREIGN KEY (disp_id) REFERENCES disp(disp_id)
-- );

-- -- 6. Order
-- CREATE TABLE `order` (
--     order_id   INT PRIMARY KEY,
--     account_id INT,
--     bank_to    VARCHAR(10),
--     account_to INT,
--     amount     DECIMAL(10,2),
--     k_symbol   VARCHAR(20),
--     FOREIGN KEY (account_id) REFERENCES account(account_id)
-- );

-- -- 7. Loan
-- CREATE TABLE loan (
--     loan_id    INT PRIMARY KEY,
--     account_id INT,
--     date_issued DATE,
--     amount     DECIMAL(10,2),
--     duration   INT,
--     payments   DECIMAL(10,2),
--     status     CHAR(1),
--     FOREIGN KEY (account_id) REFERENCES account(account_id)
-- );

-- -- 8. Transaction
-- CREATE TABLE trans (
--     trans_id   INT PRIMARY KEY,
--     account_id INT,
--     date_trans DATE,
--     type       VARCHAR(20),
--     operation  VARCHAR(50),
--     amount     DECIMAL(10,2),
--     balance    DECIMAL(10,2),
--     k_symbol   VARCHAR(20),
--     bank       VARCHAR(10),
--     account    INT,
--     FOREIGN KEY (account_id) REFERENCES account(account_id)
-- );