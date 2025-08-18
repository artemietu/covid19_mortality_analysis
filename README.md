# COVID-19 Mortality Analysis

## Overview

This is a small **R data analysis project** exploring COVID-19 mortality patterns.  
The aim is to demonstrate **core R skills** for data analysis and visualization, including:
- Data cleaning & preparation
- Hypothesis testing (t-tests)
- Visualization with ggplot2
- Writing helper functions
- Using loops for automated summaries

This project is intentionally small-scale and educational, showing an end-to-end workflow.

---

## Dataset

The dataset (`data.csv`) contains anonymized records of COVID-19 patients.

---

## Analysis Workflow

### 1. Data Preparation

- Converted `death` into a binary variable `death_dummy`
- Calculated **overall mortality rate**

### 2. Hypothesis Testing

- **Age**  
  Hypothesis: older patients have higher mortality  
  → `t.test()` confirmed that deceased patients were significantly older  

- **Gender**  
  Hypothesis: mortality is not affected by gender  
  → Results showed men had significantly higher mortality than women (p < 0.01)

### 3. Visualization

- `figures/age_vs_outcome.png`: violin + boxplot of age by survival outcome  
- `figures/gender_rate_ci.png`: bar chart with 95% Wilson confidence intervals of mortality by gender  

### 4. Functions & Loops

- Wrote `summarize_rate()` to calculate mortality rates by category with Wilson CIs  
- Wrote a loop to compute mortality across age bands: `0–29`, `30–49`, `50–69`, `70+`

---

## Results

- **Overall death rate**: ~6%  
- **Age effect**: deceased patients were significantly older (p ≈ 0)  
- **Gender effect**: male mortality ~8%, female ~4% (p < 0.01)  
- **Age bands**: mortality grows monotonically, reaching ~24% for patients 70+  

---

## Figures

Saved plots are located in the `figures/` folder:
- `age_vs_outcome.png`
- `gender_rate_ci.png`

---

## File Structure

```
.
├── covid19_mortality_analysis.Rproj          # RStudio project file
├── covid19_mortality_analysis.R              # Main script with analysis
├── data.csv                                  # Source data
└── figures/                                  # Exported figures
    ├── age_vs_outcome.png
    └── gender_rate_ci.png
```

---

## How to Run

1. Clone or download the repository  
2. Open `covid19_mortality_analysis.Rproj` in RStudio  
3. Run `covid19_mortality_analysis.R` step by step  
4. Plots were saved in `figures/`

---

## Requirements

- R (≥ 4.0)
- Packages: `tidyverse`, `Hmisc`

Install via:

```r
install.packages(c("tidyverse", "Hmisc"))
```

## Author

Artemie Țurcanu — Data Analyst  
artemietu@icloud.com