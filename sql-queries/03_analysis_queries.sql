-- ============================================================
-- 03_ANALYSIS_QUERIES.SQL
-- Purpose: Core BI queries feeding directly into dashboard.
-- Each query maps to a specific visualization.
-- ============================================================

-- ----------------------------------------------------------
-- DASHBOARD 1: Geographic & Income Segmentation
-- ----------------------------------------------------------

-- KPI: Overall Default Rate
-- NOTE: 24.47% includes all records. Dashboard 2 shows 24.45% 
--       which excludes 173 Unknown Age/Gender flagged records.
-- ----------------------------------------------------------
SELECT 
    COUNT(*) AS total_loans,
    SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND(AVG(Status) * 100, 2) AS overall_default_rate
FROM loan_default_final_2;

-- VIZ: Default Rate by Loan Type
-- Insight: Type 2 = 34.2% default vs Type 1 = 22.7%
-- ----------------------------------------------------------
SELECT 
    loan_type,
    COUNT(Status) AS total,
    SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS defaults,
    ROUND((SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) * 1.0) / COUNT(Status), 3) AS default_rate
FROM loan_default_final_2
GROUP BY loan_type
ORDER BY default_rate DESC;

-- VIZ: Default Rate by Region
-- Insight: North-East = 30.1% (highest), North = 22.4% (lowest)
-- ----------------------------------------------------------
SELECT
    region,
    COUNT(*) AS total,
    SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS defaults,
    ROUND((SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) * 1.0) / COUNT(*), 3) AS default_rate
FROM loan_default_final_2
GROUP BY region
ORDER BY default_rate DESC;

-- ----------------------------------------------------------
-- DASHBOARD 2: Demographic & Loan Structure
-- ----------------------------------------------------------

-- DATA QUALITY ALERT: Unknown Age + Gender = 100% default
-- Rationale: Flagged for fraud/data corruption investigation.
-- ----------------------------------------------------------
SELECT 
    COUNT(*) AS unknown_demo_records,
    ROUND(AVG(Status) * 100, 2) AS default_rate
FROM loan_default_final_2
WHERE age IS NULL AND Gender = 'Unknown';

-- VIZ: Default Rate by Loan Purpose
-- Insight: p2 (high-risk purpose) = 32.73% default rate
-- ----------------------------------------------------------
SELECT 
    COALESCE(loan_purpose, 'Unknown') AS loan_purpose,
    COUNT(*) AS total,
    COUNT(CASE WHEN Status = 1 THEN 1 END) AS defaults,
    ROUND(COUNT(CASE WHEN Status = 1 THEN 1 END) * 1.0 / COUNT(*), 4) AS default_rate
FROM loan_default_final_2
GROUP BY loan_purpose
ORDER BY default_rate DESC;

-- VIZ: Default Rate by Property Occupancy Type
-- Insight: Investment Residential = 29.7% vs Primary = 24.1%
-- ----------------------------------------------------------
SELECT 
    occupancy_type,
    COUNT(*) AS total,
    COUNT(CASE WHEN Status = 1 THEN 1 END) AS defaults,
    ROUND(COUNT(CASE WHEN Status = 1 THEN 1 END) * 1.0 / COUNT(*), 4) AS default_rate
FROM loan_default_final_2
GROUP BY occupancy_type
ORDER BY default_rate DESC;

-- VIZ: Default Rate by Business vs Commercial
-- ----------------------------------------------------------
SELECT 
    business_or_commercial,
    COUNT(*) AS total,
    COUNT(CASE WHEN Status = 1 THEN 1 END) AS defaults,
    ROUND(COUNT(CASE WHEN Status = 1 THEN 1 END) * 1.0 / COUNT(*), 4) AS default_rate
FROM loan_default_final_2
GROUP BY business_or_commercial
ORDER BY default_rate DESC;

-- VIZ: Default Rate by Gender & Age (Heatmap)
-- Insight: Unknown Age & Gender = 100% default rate
-- NOTE: Verify age bins in your source data. Common variants 
--       are '>74', '>75', or '75+'. Adjust CASE if needed.
-- ----------------------------------------------------------
SELECT 
    COALESCE(Gender, 'Unknown') AS Gender,
    COALESCE(age, 'Unknown') AS age,
    COUNT(*) AS total,
    COUNT(CASE WHEN Status = 1 THEN 1 END) AS defaults,
    ROUND(COUNT(CASE WHEN Status = 1 THEN 1 END) * 1.0 / COUNT(*), 4) AS default_rate
FROM loan_default_final_2
GROUP BY Gender, age
ORDER BY 
    CASE 
        WHEN age = '<25' THEN 0
        WHEN age = '25-34' THEN 1
        WHEN age = '35-44' THEN 2
        WHEN age = '45-54' THEN 3
        WHEN age = '55-64' THEN 4
        WHEN age = '65-74' THEN 5
        WHEN age = '>74' THEN 6
        WHEN age = '>75' THEN 6  -- Alternative bin; verify your data
        ELSE 7
    END,
    Gender;