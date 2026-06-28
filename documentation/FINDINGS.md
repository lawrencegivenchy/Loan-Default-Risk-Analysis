# Key Findings & Business Recommendations

## Dashboard 1: Geographic & Income Segmentation

### Income Quartile Analysis
- Q1 (lowest income): 34.9% default rate
- Q2: 24.0% default rate
- Q3: 18.9% default rate (lowest)
- Q4 (highest income): 20.0% default rate

**Insight:** 85% variation in default rates across income levels. Income is the strongest single risk predictor.

### Geographic Analysis
- North-East: 30.2% default rate (highest risk)
- Central: 27.3% default rate
- South: 26.4% default rate
- North: 22.4% default rate (lowest risk)

**Insight:** 35% variation across regions. Geographic location matters for risk assessment.

### Region × Income Interaction
- North-East + Q1 (lowest income): 45.19% default (CRITICAL)
- North + Q4 (highest income): 16.98% default
- **Risk multiplier:** 2.66x

**Insight:** The combination of low income + North-East region creates extreme risk. Segmentation must be intersectional, not additive.

### Loan Type Analysis
- Type 2: 34.2% default (highest)
- Type 3: 24.6% default
- Type 1: 22.7% default (lowest)

**Insight:** Type 2 loans are 50% riskier than Type 1. Pricing or underwriting adjustment needed.

### Credit Score Analysis
- 450–499: 28.30% default (elevated risk — threshold effect at low scores)
- 500–549: 24.40% default
- 550–599: 24.60% default
- 600–649: 24.60% default
- 650–699: 24.20% default
- 700–749: 24.00% default (lowest)
- 750–799: 24.40% default
- 800–850: 25.00% default

**Insight:** Credit score shows a **threshold effect**, not a linear relationship.
- Borrowers below 500: 28.3% default (high risk)
- Borrowers 500+: ~24% default (flat, minimal variation)
- **Strategic implication:** Use 500 as a hard cutoff rather than a sliding scale. Above 500, credit score adds little predictive value.

---

## Dashboard 2: Demographics & Loan Structure

### Gender × Age Analysis
- **Unknown/Unknown:** 100% default (173 records) — DATA CORRUPTION
- Female/25–34: 30.26% default (elevated)
- Male/25–34: 23.47% default
- Male/65–74: 16.98% default (lowest)

**Insight:** Young females (25–34) show 29% higher default risk than young males (30.26% vs 23.47%). This contradicts typical industry patterns and warrants investigation into product design or income verification gaps.

### Loan Purpose Analysis (Inferred)
- p2 (high-risk, likely debt consolidation): 32.73% default
- p1 (standard, likely home purchase): 25.84% default
- p3 (moderate, likely home improvement): 24.84% default
- p4 (low-risk, likely primary residence): 22.73% default
- Unknown (missing purpose): 24.78% default

**Insight:** Loan purpose drives risk. p2 is 45% riskier than p4.

### Occupancy Type Analysis
- ir (Investment Residential): 28.72% default (highest)
- sr (Secondary Residential): 27.01% default
- pr (Primary Residential): 24.12% default (lowest)

**Insight:** Investment properties 19% riskier than primary residences.

### Business vs Commercial Analysis
- b/c (Business/Commercial): 34.21% default (highest)
- nob/c (Not Business/Commercial): 23.40% default

**Insight:** Commercial loans are 46% riskier than personal loans.

---

## Business Recommendations

### For Credit Risk/Underwriting
1. **Tighten North-East approval criteria** for income Q1 (45% default rate is unsustainable)
2. **Require income verification** for loans &gt;$200K (income is strongest predictor)
3. **Restrict Type 2 loans** or require additional collateral (34.2% default)
4. **Flag p2 purpose loans** for manual review (32.7% default)
5. **Use 500 credit score as hard cutoff** — sliding scale above 500 adds no predictive value

### For Pricing/Interest Rates
1. **Recommend A/B testing 1.5–2.5% premium on Type 2 loans** (vs Type 1); monitor conversion rates
2. **Recommend pricing committee review for commercial loans** — 46% higher default warrants risk-adjusted return analysis
3. **Recommend 1–1.5% premium for investment properties** (vs primary residences)
4. **Recommend geographic risk-adjustment:** North-East premium of 0.5–1% relative to North

### For Fraud/Risk Management
1. **Investigate 173 records** with Unknown Gender + Unknown Age (100% default = systemic issue)
2. **Audit p2 loan origination** (high default concentration)
3. **Investigate young female 25–34 segment** (30.26% default vs 23.47% for young males)

### For Portfolio Management
1. **Recommend stress-testing portfolio at 5%, 10%, and 15% NE Q1 concentration** before setting caps
2. **Diversify by region:** Current concentration in risky regions increases portfolio volatility
3. **Rebalance loan type mix:** Reduce Type 2 from current % to lower-risk Type 1/Type 3

---

## Data Quality Issues Noted

- 173 records: Unknown Gender + Unknown Age (100% default) — Recommend source system audit
- 113 records: Unknown loan_purpose (24.78% default) — Near average, acceptable
- Missing data patterns suggest data entry gaps rather than fraud, except for Unknown/Unknown records

---

## Limitations

- Credit score has weak predictive power above 500 in this dataset (threshold effect, not linear)
- Loan purpose inference based on default rates, not documented business definitions
- Regional analysis limited to 4 broad regions (more granular geographic data would improve insights)
- Pricing recommendations lack cost-of-capital data; require business stakeholder validation
