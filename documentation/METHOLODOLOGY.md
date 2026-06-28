# Data Cleaning Methodology

## Phase 1: Missing Value Audit

Analyzed 8 columns with &gt;6% missing values:
- rate_of_interest: 24.51% missing
- Interest_rate_spread: 24.645% missing
- Upfront_charges: 26.664% missing
- property_value: 10.155% missing
- LTV: 10.155% missing
- income: 6.155% missing
- dtir1: 16.225% missing (retained as-is; missing values may indicate data collection gaps worth investigating)
- credit_score: 0% missing (no blanks)

## Phase 2: Imputation Strategy

**rate_of_interest & Interest_rate_spread:** Imputed by loan_type using MEDIAN
- Rationale: Interest rates vary significantly by product type; column-wide median would distort Type 1 vs Type 3 risk profiles
- type1: 4.114%
- type2: 3.968%
- type3: 3.603%

**income:** Imputed by region using MEDIAN
- Rationale: Income distributions differ by region (North-East median is 17.6% lower than South); regional imputation preserves local economic reality
- North: 6,987.67
- North-East: 5,753.07
- South: 7,004.59
- Central: 6,510.24

**Upfront_charges, property_value, LTV:** Imputed with column medians
- Rationale: These are property-specific and do not vary systematically by loan type or region

**Result:** 0 blanks in critical columns

## Phase 3: Outlier Detection

- Credit_Score: 18,532 records outside **FICO range 300–850** (deleted)
  - *Rationale: These contained placeholder values (e.g., 999, 0) indicating data entry errors, not extreme borrowers*
- LTV: 193 records outside **0–120%** (deleted)
  - *Rationale: LTV &gt;120% implies loan exceeds collateral value — structurally impossible without data corruption*
- Interest_rate_spread: 20 records outside **-1 to +10** (deleted)
  - *Rationale: Negative spreads indicate data corruption (bank cannot offer rate below benchmark)*
- rate_of_interest: 0 outliers (range 0–8%, threshold 0–10%)

**Total removed: 18,745 records (12.6% of raw data)**

## Phase 4: Data Quality Flags

- **173 records** with Unknown Gender + Unknown Age = 100% default
  - *FLAGGED: Potential fraud or system error. Excluded from overall default rate (24.45%) but retained in dataset for investigation*
- **113 records** with Unknown loan_purpose (labeled as "Unknown" category, not deleted)
- **3,247 records** with 'Sex Not Available' standardized to 'Unknown' for clean segmentation
- **0 duplicate IDs** (primary key validation passed)

## Final Dataset

- **Records:** 129,950
- **Columns:** 35
- **Imputed:** 6 columns (0 blanks in final data)
- **Removed:** 18,745 outlier/corruption records
- **Flagged:** 173 records for fraud investigation
- **Cleaned:** Ready for analysis
