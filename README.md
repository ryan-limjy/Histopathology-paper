# Breast Cancer Histopathology Analysis – Reproducibility Archive

This repository contains selected R scripts and a dummy dataset to illustrate how key figures and results from the associated paper were generated. It is intended to support transparency, peer review, and reproducibility.

---

## 📂 Repository Contents
[Odds/hazard ratio](scripts/multinomial_model.R)
[API accuracy](scripts/sensitivity.R)
[Kaplan-Meier plots and others](scripts/all_others.R)

[Dummy dataset](data/dummy_dataset.csv)


---

## 🔬 Methods Overview

All regression models were fit using R. Odds ratios were computed using multinomial logistic regression (`nnet::multinom`), with adjustments for demographic and clinical covariates. Hierarchical clustering was performed using Pearson correlation and Ward’s method. Survival analysis was conducted using `survival::survfit` and visualized with `survminer::ggsurvplot`.

The included R scripts demonstrate:
- [How odds ratios were computed](scripts/multinomial_model.R)
- [How Kaplan-Meier plots were created](scripts/km_plot.R)
- [How benign features were grouped using clustering](scripts/clustering.R)

---

## 📊 Dummy Dataset

The included [dummy dataset](data/dummy_dataset.csv) mimics the structure of the real data and is used for illustrative purposes only.

### Variables include:

| Variable     | Description                                |
|--------------|--------------------------------------------|
| `ADH`, `ALH`, `Cyst` | Histopathologic features (`True`/`False`) |
| `tnm`        | Tumor stage (`Stage 1` to `Stage 3`)        |
| `ER_status`, `PR_status` | Hormone receptor status        |
| `age`, `menopause`, `child`, `nodes` | Demographic/clinical |
| `famhx`      | Family history of breast cancer            |
| `race`       | Race (`Chinese`, `Malay`, `Indian`, `Others`) |
| `dx_date`, `dx_year` | Date and era of diagnosis          |
| `OS_time`, `trunc_OS`, `death` | Overall survival info     |

### Example Rows

| ID  | ADH   | ALH   | Cyst  | ER_status | tnm     | age | nodes | OS_time | death |
|-----|-------|-------|-------|-----------|---------|-----|--------|---------|--------|
| 001 | True  | False | False | positive  | Stage 1 | 45  | 0      | 7.3     | 0      |
| 003 | False | True  | False | positive  | Stage 3 | 52  | 1      | 2.9     | 1      |
| 006 | True  | False | True  | unknown   | Stage 3 | 59  | 1      | 1.8     | 1      |

To try it out:

```r
df <- read.csv("data/dummy_dataset.csv")
model <- multinom(tnm ~ ADH + age + race, data = df)
summary(model)
