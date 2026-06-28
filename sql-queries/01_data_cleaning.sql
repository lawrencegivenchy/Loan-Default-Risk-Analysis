-- ============================================================
-- 01_DATA_CLEANING.SQL
-- Purpose: Load raw data, handle missing values, remove 
--          outliers, and standardize categorical fields.
-- Dataset: 129,950 loan records
-- Tool: Databricks / Delta Lake
-- ============================================================

-- ----------------------------------------------------------
-- STEP 1: Create base table from CSV with median imputation
-- Rationale: Median imputation preserves distribution without 
--            extreme value bias vs. mean imputation.
-- ----------------------------------------------------------
CREATE OR REPLACE TABLE loan_default
USING DELTA
TBLPROPERTIES (
  'delta.columnMapping.mode' = 'name', 
  'delta.minReaderVersion' = '2', 
  'delta.minWriterVersion' = '5'
)
AS
SELECT 
  *,
  COALESCE(Upfront_charges, MEDIAN(Upfront_charges) OVER ()) AS Upfront_charges_imputed,
  COALESCE(property_value, MEDIAN(property_value) OVER ()) AS property_value_imputed,
  ROUND(COALESCE(LTV, MEDIAN(LTV) OVER ()), 2) AS LTV_imputed
FROM read_files('/Volumes/june2026/default/loan_default_cleaned/Loan_Default (version 2).csv');

-- ----------------------------------------------------------
-- STEP 2: Drop auto-generated / summary columns
-- ----------------------------------------------------------
ALTER TABLE loan_default
DROP COLUMN IF EXISTS `_rescued_data`;

ALTER TABLE loan_default
DROP COLUMN IF EXISTS `Median rate_of_interest`, `Median Interst_rate_spread`, `Median Income`, `Imputation_Flag`;

ALTER TABLE loan_default
DROP COLUMN IF EXISTS `Blank Count`, `Total Rows`, `%Missings`;

-- ----------------------------------------------------------
-- STEP 3: Check for duplicate loan IDs
-- Result: 0 duplicates found
-- ----------------------------------------------------------
SELECT 
    ID,
    COUNT(*) AS duplicate_count
FROM loan_default
GROUP BY ID
HAVING duplicate_count > 1
ORDER BY duplicate_count DESC;

-- ----------------------------------------------------------
-- STEP 4: Identify outliers across key numeric fields
-- Rationale: Remove biologically impossible values that would
--            distort default rates and model training.
-- ----------------------------------------------------------
SELECT 
    'Credit_Score' AS outlier_type,
    COUNT(*) AS outlier_count
FROM loan_default
WHERE Credit_Score NOT BETWEEN 300 AND 850

UNION ALL

SELECT 
    'LTV' AS outlier_type,
    COUNT(*) AS outlier_count
FROM loan_default
WHERE LTV_imputed NOT BETWEEN 0 AND 120

UNION ALL

SELECT 
    'rate_of_interest' AS outlier_type,
    COUNT(*) AS outlier_count
FROM loan_default
WHERE rate_of_interest_imputed NOT BETWEEN 0 AND 10

UNION ALL

SELECT 
    'Interest_rate_spread' AS outlier_type,
    COUNT(*) AS outlier_count
FROM loan_default
WHERE Interest_rate_spread_imputed NOT BETWEEN -1 AND 10;

-- ----------------------------------------------------------
-- STEP 5: Standardize categorical fields
-- Rationale: 'Sex Not Available' is missing data in disguise.
-- ----------------------------------------------------------
UPDATE loan_default
SET Gender = 'Unknown'
WHERE Gender = 'Sex Not Available';

-- ----------------------------------------------------------
-- STEP 6: Create clean analysis table with outlier removal
-- ----------------------------------------------------------
CREATE TABLE loan_default_final
USING DELTA
AS
SELECT *
FROM loan_default
WHERE Credit_Score BETWEEN 300 AND 850
  AND LTV_imputed BETWEEN 0 AND 120
  AND rate_of_interest_imputed BETWEEN 0 AND 10
  AND Interest_rate_spread_imputed BETWEEN -1 AND 10;

-- ----------------------------------------------------------
-- STEP 7: Drop original unimputed columns
-- ----------------------------------------------------------
ALTER TABLE loan_default_final
DROP COLUMNS (rate_of_interest, Interest_rate_spread, Income, Upfront_charges, property_value, LTV);

-- ----------------------------------------------------------
-- STEP 8: Create final production table with clean aliases
-- NOTE: Column `co-applicant_credit_type` contains a hyphen.
--       Backticks are required. Single quotes would create 
--       a string literal, not a column reference.
-- ----------------------------------------------------------
CREATE TABLE loan_default_final_2
USING DELTA
AS
SELECT 
    ID,
    year,
    loan_limit,
    Gender,
    approv_in_adv,
    loan_type,
    loan_purpose,
    Credit_Worthiness,
    open_credit,
    business_or_commercial,
    loan_amount,
    rate_of_interest_imputed AS rate_of_interest,
    Interest_rate_spread_imputed AS Interest_rate_spread,
    Upfront_charges_imputed AS Upfront_charges,
    term,
    Neg_ammortization,
    interest_only,
    lump_sum_payment,
    property_value_imputed AS property_value,
    construction_type,
    occupancy_type,
    Secured_by,
    total_units,
    income_imputed AS income,
    credit_type,
    Credit_Score,
    `co-applicant_credit_type`,  -- Backticks required for hyphenated names
    age,
    submission_of_application,
    LTV_imputed AS LTV,
    Region,
    Security_Type,
    Status,
    dtir1
FROM loan_default_final;