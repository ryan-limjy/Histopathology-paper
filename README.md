# Breast Cancer Histopathology Analysis – Reproducibility Archive

This repository contains selected R scripts and a dummy dataset to illustrate how key figures and results from the associated paper were generated. It is intended to support transparency, peer review, and reproducibility.

---

## 📂 Repository Contents
```text
api_prompts/
├── prompts/              # Contains .txt files with prompts used for LLM extraction
│   ├── API1.txt
│   ├── API2.txt
│   ├── API3.txt
│   ├── API4.txt
│   └── API5.txt
├── scripts/              # Shell scripts used to run extraction jobs in parallel
│   ├── API1_parallel.sh
│   ├── API2_parallel.sh
│   ├── API3_parallel.sh
│   ├── API4_parallel.sh
│   └── API5_parallel.sh

scripts/
├── odds_hazard_ratio.R              # Odds/hazard ratio script
├── accuracy.R             # API accuracy script
└── all_others.R              # Clustering, KM plots and logistic/Poisson regression script

data/
└── dummy_dataset.csv         # Dummy dataset
```
---

## NLP & API-Powered Data Extraction

Before any statistical analysis, key variables were extracted from unstructured pathology reports using large language model (LLM) API calls. These prompts were designed to extract:

- Filter for cases with **malignant breast cancer**
- Confirm that a relevant **procedure** was described (e.g., excision, FNB, CNB, VBA)
- Extract presence/absence of key **histopathologic features** (e.g., ADH, ALH, LCIS, cysts)

Due to iterative filtering and model constraints, the extraction was run in multiple batches using parallel processing. The relevant files have been organized into two subfolders:

📁 [`api_prompts/prompts/`](api_prompts/prompts/) – Contains the actual prompt `.txt` files  
📁 [`api_prompts/scripts/`](api_prompts/scripts/) – Shell scripts used to run batch jobs in parallel

These outputs were post-processed and validated before forming the basis of the structured dataset used for downstream analysis (see [Dummy dataset](data/dummy_dataset.csv)).

---

## Methods Overview

All regression models were fit using R. Odds ratios were computed using multinomial logistic regression (`nnet::multinom`), with adjustments for demographic and clinical covariates. Hierarchical clustering was performed using Pearson correlation and Ward’s method. Survival analysis was conducted using `survival::survfit` and visualized with `survminer::ggsurvplot`.

The included R scripts demonstrate:
- [How odds/hazard ratios were computed](scripts/odds_hazard_ratio.R)
- [How API accuracy was calculated](scripts/accuracy.R)
- [All other plots including clustering, KM plots, and logistic/Poisson regression](scripts/all_others.R)

---

## Dummy Dataset

The included [dummy dataset](data/dummy_dataset.csv) mimics the structure of the real data and is used for illustrative purposes only. Most, if not all scripts above, will produce errors or fail to yield meaningful results due to the small sample size. 

### Variables include:

| Variable     | Description                                      |
|--------------|--------------------------------------------------|
| `ID`         | Unique identifier                                |
| `ADH`        | Atypical ductal hyperplasia (`True`/`False`)     |
| `ALH`        | Atypical lobular hyperplasia (`True`/`False`)    |
| `Cyst`       | Presence of breast cysts (`True`/`False`)        |
| `ER_status`  | Estrogen receptor status (`positive`, `negative`, `unknown`) |
| `PR_status`  | Progesterone receptor status (`positive`, `negative`, `unknown`) |
| `tnm`        | Tumor stage (`Stage 1`, `Stage 2`, `Stage 3`)    |
| `age`        | Age at diagnosis (in years)                      |
| `menopause`  | Menopausal status (`pre`, `post`)                |
| `child`      | Number of children (integer)                     |
| `nodes`      | Nodal involvement (0 = none, 1 = any involvement)|
| `famhx`      | Family history of breast cancer (`True`/`False`) |
| `race`       | Race (`Chinese`, `Malay`, `Indian`, `Others`)   |
| `dx_date`    | Date of diagnosis (YYYY-MM-DD)                   |
| `dx_year`    | Calendar period (`<2002`, `2002–2009`, `>2009`)    |
| `OS_time`    | Overall survival time (years)                    |
| `death`      | 10 years survival (1 = death, 0 = alive)              |
| `trunc_OS`   | 10 years survival time (years, capped at 10)   |
| `n_char`   | Number of characters in freetext |
| `n_benign`   | Number of benign features investigated present |


### Preview of dummy dataset

The below table is meant to be a visual representation and only a subset of variables are shown below; all variables listed above can be found in the .csv file above.

| ID  | ADH   | ALH   | Cyst  | ER_status | tnm     | age | nodes | OS_time | death |
|-----|-------|-------|-------|-----------|---------|-----|--------|---------|--------|
| 001 | True  | False | False | positive  | Stage 1 | 45  | 0      | 7.3     | 0      |
| 003 | False | True  | False | positive  | Stage 3 | 52  | 1      | 2.9     | 1      |
| 006 | True  | False | True  | unknown   | Stage 3 | 59  | 1      | 1.8     | 1      |

To import the dataset into R:

```r
df <- read.csv("data/dummy_dataset.csv")
```
