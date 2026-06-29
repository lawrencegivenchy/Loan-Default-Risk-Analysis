# Loan Default Risk Analysis

**Author:** Lawrence Makhafola  
**Dataset:** Kaggle Loan Default Data (South African Context)  
**Records Analyzed:** 129,950 (after cleaning 148,670 raw records)  
**Technologies:** SQL (Databricks), Excel, Power BI  

**Quick Links:**
[📊 Dashboard 1](Dashboard/Dashboard%201.png) | 
[📊 Dashboard 2](Dashboard/Dashboard%202.png) | 
[💾 SQL Queries](sql-queries/) | 
[📝 Methodology](documentation/METHOLODOLOGY.md) |
[📋 Findings](documentation/FINDINGS.md)

---

## Project Overview

Comprehensive segmentation analysis identifying key risk factors driving loan defaults across demographic, geographic, and loan structure dimensions. Deliverables include 2 interactive Power BI dashboards, production-grade SQL analysis queries, and actionable business recommendations.

**Key Deliverables:**
- 2 Interactive Power BI dashboards (129,950 records)
- 9 SQL analysis queries with feature engineering
- Data cleaning pipeline (imputation, outlier detection, validation)
- Business recommendations for credit risk and pricing strategy

---

## Business Questions This Analysis Answers

1. **Which borrower segments have the highest default risk?**
   - Answer: North-East + Low Income (45.19% default)

2. **Does income level influence loan default?**
   - Answer: Yes, 85% variation across quartiles (Q1: 34.9% vs Q3: 18.9%)

3. **Which loan products require closer monitoring?**
   - Answer: Type 2 (34.2%) and p2 purpose (32.7%) loans

4. **Are there regional differences in default behaviour?**
   - Answer: Yes, 35% variation (North-East: 30.2% vs North: 22.4%)

5. **What is the data quality baseline?**
   - Answer: 129,950 clean records after removing 18,745 outliers (12.6%)

---

## Key Findings

### Dashboard 1: Geographic & Income Segmentation

| Metric | Finding | Business Impact |
|---|---|---|
| **Income Effect** | Q1: 34.9% default vs Q3: 18.9% | 85% risk variation — income is strongest predictor |
| **Geographic Effect** | North-East: 30.2% vs North: 22.4% | 35% risk variation — geography matters |
| **Interaction Effect** | North-East Q1: 45.19% vs North Q4: 16.98% | 2.66x risk multiplier for combined factors |
| **Loan Type Risk** | Type 2: 34.2% vs Type 1: 22.7% | 50% higher default for Type 2 loans |
| **Credit Score** | 450–499: 28.3% vs 800–850: 25.0% | Weak predictor (only 3.3pp variation) |

### Dashboard 2: Demographics & Loan Structure

| Factor | Finding | Action |
|---|---|---|
| **Unknown Gender + Age** | 173 records = 100% default | Flag for fraud/data corruption investigation |
| **Loan Purpose p2** | 32.73% default (highest) | High-risk purpose — likely debt consolidation |
| **Loan Purpose p4** | 22.73% default (lowest) | Low-risk purpose — likely primary residence |
| **Occupancy Type** | Investment: 28.7% vs Primary: 24.1% | Investment properties 19% riskier |
| **Commercial Loans** | 34.21% default vs Personal: 23.4% | Commercial 46% riskier than personal |

---

## Data Cleaning & Methodology

### Data Cleaning Tool Selection

**Initial Approach:** Excel with VLOOKUP formulas for 148K rows

**Challenge:** Excel crashed at 36,439 formula cells (26.7% of data during imputation)

**Decision:** Migrated pipeline to **Databricks SQL** for scalability

**Outcome:** 
- ✓ Completed imputation in <5 seconds (vs. Excel timeout)
- ✓ Validated outlier detection with UNION ALL queries  
- ✓ Reproducible pipeline (vs. Excel manual steps)
- ✓ Production-ready (vs. one-off spreadsheet)

**Lesson:** Match tool to data volume. Excel excels at <50K rows; SQL for production pipelines.

---

### Phase 1: Missing Value Audit

Analyzed 8 columns with >6% missing values:
- rate_of_interest: 24.51% missing
- Interest_rate_spread: 24.645% missing
- Upfront_charges: 26.664% missing
- property_value: 10.155% missing
- LTV: 10.155% missing
- income: 6.155% missing
- dtir1: 16.225% missing
- credit_score: 0% missing ✓

**Decision:** Impute strategically (preserve data volume vs. deletion)

---

### Phase 2: Imputation Strategy

**rate_of_interest & Interest_rate_spread:** By loan_type median
- type1: 4.114%
- type2: 3.968%
- type3: 3.603%

**income:** By region median
- North: 6,987.67
- North-East: 5,753.07
- South: 7,004.59
- Central: 6,510.24

**Upfront_charges, property_value, LTV:** Column medians

**Result:** 0 blanks in critical columns after imputation

---

### Phase 3: Outlier Detection & Removal

- Credit_Score outside 300–850: 18,532 records deleted
- LTV outside 0–120%: 193 records deleted
- Interest_rate_spread outside -1 to +10: 20 records deleted
- rate_of_interest outside 0–10%: 0 records (all valid)
- **Total removed: 18,745 records (12.6% of data)**

**Validation:** Removed records have impossible values (e.g., Credit_Score = 920, LTV = 150%), not natural outliers.

---

### Phase 4: Data Quality Flags

- 173 records with Unknown Gender + Unknown Age = 100% default (flagged for fraud investigation)
- 113 records with Unknown loan_purpose = 24.78% default (kept, labeled "Unknown")
- 0 duplicate IDs (validation passed)

**Final dataset:** 129,950 clean records ready for analysis

**Overall Default Rate:** 24.47% (all records) / 24.45% (excluding 173 Unknown Age/Gender flagged records)

*Note: 0.02% difference due to data quality exclusion. See Dashboard 2 alert for details.*

---

## Data Limitations & Considerations

1. **Static Snapshot**
   - Dataset represents a fixed point in time (likely 2019–2021)
   - Does not capture macro-economic shifts (SA repo rate hikes, inflation)
   - Current application: Baseline for historical analysis, not real-time forecasting

2. **Imputation Trade-Offs**
   - 25% of `rate_of_interest` and `Interest_rate_spread` imputed using median-by-category
   - Benefit: Preserves 129K records vs. deletion
   - Trade-off: Artificial variance reduction
   - Recommendation: Use imputed columns for segmentation, but acknowledge variance compression in modeling

3. **Geographic Coding**
   - 4 broad regions (North, North-East, South, Central) mask sub-regional variation
   - Finer geographic data would improve precision

4. **Unknown Demographics**
   - 173 records with Unknown Gender + Unknown Age show 100% default (data corruption)
   - Recommend source system audit before using this dataset in production models

5. **Feature Engineering**
   - Loan purpose (p1–p4) inferred from default rates, not business definitions
   - Recommend business owner validation of purpose encoding

---

## Challenges & Solutions

| Challenge | Solution | Portfolio Value |
|---|---|---|
| Excel crashed at 148K rows | Migrated to Databricks SQL pipeline | Demonstrates tool selection judgment |
| 18,745 outlier records (12.6% of data) | Removed with documented business thresholds | Shows data governance rigor |
| 173 records: 100% default rate (Unknown Age/Gender) | Flagged for fraud investigation, NOT deleted | Distinguishes between data quality issues and analysis |
| Red-green color palette inaccessible | Switched to purple-orange-teal gradient | Accessibility = professionalism |
| Credit Score line chart on categorical data | Replaced with bar chart for ordinal categories | Statistical correctness matters |

---

## What I Learned

1. **Income + Geography >> Credit Score**
   - Credit score alone: 3.3pp variation (weak)
   - Income quartiles: 16pp variation (strong)
   - Interaction (Region × Income): 28.2pp variation (strongest)
   - Lesson: Composite features beat individual predictors

2. **Data Quality Is Analysis**
   - 173 records with 100% default flagged as corruption, not insight
   - Removed 18,745 outliers systematically (not arbitrarily)
   - Lesson: Trust the data only after validation

3. **Accessibility ≠ Cosmetic**
   - 8% of population has red-green colorblindness
   - Switched palette (red → purple, green → teal) → same insights, broader audience
   - Lesson: Design decisions are product decisions

4. **Tool Matters**
   - Excel: Best for <50K rows, exploration, ad-hoc analysis
   - SQL: Required for 148K rows, reproducible pipelines, audit trails
   - Power BI: Visualization layer, not data layer
   - Lesson: Choose tools based on problem scale, not familiarity

---

## Technical Stack

**SQL (Databricks)**
- Window functions: `NTILE(4)` for regional quartiles, `MEDIAN() OVER ()`
- Aggregations: `GROUP BY`, `COUNT()`, `SUM()`, `CASE` statements
- Imputation: `COALESCE()` with window median
- Outlier detection: `WHERE` clauses with range validation
- Optimization: `GROUP BY 1` (avoid duplicate CASE statements), `UNION ALL` for multi-table queries

**Excel (Data Cleaning Phase)**
- `COUNTBLANK()` for missing value audit
- Pivot tables for median calculations by category
- Data validation and outlier flagging
- **Limitation identified:** Excel crashed at 148K rows with formulas → escalated to SQL

**Power BI (Visualization)**
- Matrix with conditional formatting (purple/orange/teal gradient)
- Bar/Column/Line charts with custom sorting
- KPI cards for key metrics
- Colorblind-accessible palette (8% population consideration)

---

## Files Structure

```text
Loan-Default-Risk-Analysis/
├── Dashboard/
│   ├── Dashboard_1.pdf
│   ├── Dashboard_2.pdf
│   └── Loan_Analysis.pbix
├── data/
├── documentation/
│   ├── FINDINGS.md
│   └── METHODOLOGY.md
├── sql-queries/
│   ├── 01_data_cleaning.sql
│   ├── 02_feature_engineering.sql
│   └── 03_analysis_queries.sql
└── README.md
```

---

## How to Run This Project

### Requirements
- Databricks SQL workspace (or Spark SQL environment)
- Power BI Desktop (for viewing dashboards)
- Excel (for data validation, optional)

### Steps

1. **Data Cleaning:** Run `sql-queries/01_data_cleaning.sql`
   - Creates `loan_default_final_2` table (129,950 clean records)
   - Imputes missing values, removes outliers
   - Execution time: ~2 minutes

2. **Feature Engineering:** Run `sql-queries/02_feature_engineering.sql`
   - Creates income quartiles, credit score bins, region-income matrix
   - Generates analysis CSVs to `/data/`
   - Execution time: ~1 minute

3. **Analysis Queries:** Run `sql-queries/03_analysis_queries.sql`
   - Validates KPIs match dashboard
   - Generates results for Power BI
   - Execution time: <30 seconds

4. **Dashboards:** Open `.pbix` files in Power BI
   - `Loan_Default_Risk_Analysis.pbix` (Dashboard 1)
   - `Loan_Default_Risk_Analysis_Dashboard2.pbix` (Dashboard 2)
   - Refresh data connections to your Databricks environment

### Expected Output
- 129,950 clean loan records
- Overall default rate: 24.47%
- 9 analysis CSVs ready for Power BI

---

## Business Recommendations

### For Credit Risk / Underwriting
1. **Tighten North-East approval criteria** for income Q1 (45% default is unsustainable)
2. **Require income verification** for loans >$200K (income is strongest predictor)
3. **Restrict Type 2 loans** or require additional collateral (34.2% default)
4. **Flag p2 purpose loans** for manual review (32.7% default)

### For Pricing / Interest Rates
1. **Price Type 2 loans 2–3% premium** (vs Type 1 @ 22.7% default)
2. **Price commercial loans 1.5–2% premium** (vs personal @ 23.4% default)
3. **Price investment properties 1–1.5% premium** (vs primary residences @ 24.1% default)
4. **Risk-adjust by geography:** North-East 0.5–1% premium relative to North

### For Fraud / Risk Management
1. **Investigate 173 records** with Unknown Gender + Unknown Age (100% default = systemic issue)
2. **Audit p2 loan origination** (high default concentration)
3. **Monitor North-East Q1 segment** for early warning signals

### For Portfolio Management
1. **Cap North-East Q1 lending** at <5% of portfolio until risk controls in place
2. **Diversify by region:** Reduce concentration in high-risk regions
3. **Rebalance loan type mix:** Reduce Type 2 lending to lower-risk Type 1/Type 3

---

## Skills Demonstrated

✓ **Data Cleaning & Imputation** — Strategic imputation preserves 129K+ records vs. deletion  
✓ **SQL Analysis** — Window functions, aggregations, outlier detection, reproducible queries  
✓ **Statistical Validation** — Default rate calculations, sanity checks, discrepancy reconciliation  
✓ **Data Visualization** — Power BI dashboards, conditional formatting, accessibility considerations  
✓ **Business Communication** — Actionable recommendations, stakeholder-ready insights  
✓ **Data Governance** — Transparency, quality flagging, documentation, audit trails  
✓ **Tool Selection** — Excel → SQL migration (tool-to-problem fit)  
✓ **Iterative Improvement** — Color palette accessibility, feedback integration, methodology refinement

---

## How to Use These Dashboards

**Dashboard 1 → Credit Risk Team**
- Approval strategy by segment
- Segment-based underwriting criteria
- Default rate benchmarks by loan type, region, income

**Dashboard 2 → Pricing Team**
- Rate adjustment strategy by loan purpose and occupancy
- Risk-based premium calculation
- Segment profitability analysis

**Both Dashboards → Analyst Onboarding**
- Risk factor education
- Data quality understanding
- Portfolio composition analysis

---

## Next Steps

- [ ] Build a logistic regression model using these segments as features
- [ ] A/B test pricing strategy: higher rates for North-East Q1 borrowers
- [ ] Automate data quality alerts for Unknown-demographic anomaly pattern
- [ ] Investigate source system for 173 records with 100% default
- [ ] Portfolio rebalancing: reduce Type 2 lending concentration
- [ ] Occupancy type risk controls: implement premium for investment properties

---

## Contact

**Email:** lawrencegivenchy@yahoo.com  
**Portfolio:** https://lawrence-makhafola.vercel.app/  
**GitHub:** https://github.com/lawrencegivenchy  
**LinkedIn:** [www.linkedin.com/in/lawrence-makhafola-8b0075249]

---

**License:** Open for portfolio/educational use

---

*Last updated: June 2026*
