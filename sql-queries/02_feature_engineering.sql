-- ============================================================
-- 02_FEATURE_ENGINEERING.SQL
-- Purpose: Create binned and segmented features for 
--          dashboard visualization and risk profiling.
-- ============================================================

-- ----------------------------------------------------------
-- FEATURE 1: Credit Score Bins (FICO tiers)
-- Used in: "Default Rate by Credit Score Range"
-- ----------------------------------------------------------
SELECT 
    CASE
      WHEN credit_score >= 300 AND credit_score < 350 THEN '300-349'
      WHEN credit_score >= 350 AND credit_score < 400 THEN '350-399'
      WHEN credit_score >= 400 AND credit_score < 450 THEN '400-449'
      WHEN credit_score >= 450 AND credit_score < 500 THEN '450-499'
      WHEN credit_score >= 500 AND credit_score < 550 THEN '500-549'
      WHEN credit_score >= 550 AND credit_score < 600 THEN '550-599'
      WHEN credit_score >= 600 AND credit_score < 650 THEN '600-649'
      WHEN credit_score >= 650 AND credit_score < 700 THEN '650-699'
      WHEN credit_score >= 700 AND credit_score < 750 THEN '700-749'
      WHEN credit_score >= 750 AND credit_score < 800 THEN '750-799'
      WHEN credit_score >= 800 AND credit_score <= 850 THEN '800-850'
      ELSE 'Uncategorized'
    END AS credit_score_bin,
    COUNT(status) AS total,
    SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS defaults,
    ROUND((SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) * 1.0) / COUNT(status), 3) AS default_rate
FROM loan_default_final_2
GROUP BY 1  -- Group by first column (credit_score_bin)
ORDER BY 1; -- Order alphabetically: 300-349, 350-399, ... 800-850

-- ----------------------------------------------------------
-- FEATURE 2: Income Quartiles
-- Used in: "Default Rate by Income Quartile"
-- ----------------------------------------------------------
WITH RankedIncome AS (
    SELECT
        income,
        status,
        NTILE(4) OVER (ORDER BY income ASC) AS income_quartile
    FROM loan_default_final_2
)
SELECT 
    income_quartile,
    COUNT(status) AS total,
    SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS defaults,
    ROUND((SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) * 1.0) / COUNT(status), 3) AS default_rate
FROM RankedIncome
GROUP BY income_quartile
ORDER BY income_quartile ASC;

-- ----------------------------------------------------------
-- FEATURE 3: Loan Amount Quartiles
-- ----------------------------------------------------------
WITH RankedLoanAmount AS (
    SELECT
        loan_amount,
        status,
        NTILE(4) OVER (ORDER BY loan_amount ASC) AS loan_amount_quartile
    FROM loan_default_final_2
)
SELECT 
    loan_amount_quartile,
    COUNT(status) AS total,
    SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS defaults,
    ROUND((SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) * 1.0) / COUNT(status), 3) AS default_rate
FROM RankedLoanAmount
GROUP BY loan_amount_quartile
ORDER BY loan_amount_quartile ASC;

-- ----------------------------------------------------------
-- FEATURE 4: Region x Income Quartile Matrix
-- Used in: "Default Risk Matrix: Region vs Income"
-- Key insight: North-East Q1 = 45.19% default rate
-- ----------------------------------------------------------
WITH RankedIncome AS (
    SELECT
        region,
        income,
        status,
        NTILE(4) OVER (PARTITION BY region ORDER BY income ASC) AS income_quartile
    FROM loan_default_final_2
)
SELECT
    region,
    income_quartile,
    COUNT(status) AS total,
    SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS defaults,
    ROUND((SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) * 1.0) / COUNT(status), 4) AS default_rate
FROM RankedIncome
GROUP BY region, income_quartile
ORDER BY default_rate DESC;