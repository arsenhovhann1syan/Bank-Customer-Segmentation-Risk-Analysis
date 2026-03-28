# Bank RFM Analysis
**Customer Segmentation & Risk Analysis using the Berka Financial Dataset**

---

## Project Overview

This project applies RFM (Recency, Frequency, Monetary) analysis and unsupervised machine learning to a real-world Czech bank dataset in order to identify customer segments and detect anomalous behavioral patterns. The pipeline covers the full data workflow — from raw SQL ingestion to a multi-page Power BI dashboard.

---

## Project Structure

```
bank-rfm-analysis/
│
├── data/
│   ├── raw/                        # Original Berka dataset (8 CSV files)
│   │   ├── account.csv
│   │   ├── client.csv
│   │   ├── card.csv
│   │   ├── disp.csv
│   │   ├── district.csv
│   │   ├── loan.csv
│   │   ├── order.csv
│   │   └── trans.csv
│   └── processed/                  # Outputs exported from Python notebooks
│       ├── rfm_segments.csv
│       ├── rfm_flagged.csv
│       └── rfm_final_clustering_results.csv
│
├── sql/
│   ├── 01_create_tables.sql        # Schema definition (MySQL)
│   ├── 02_exploration.sql          # Row counts, nulls, distributions
│   ├── 03_cleaning.sql             # Duplicates, nulls, referential integrity
│   ├── 04_rfm_calculation.sql      # Recency, Frequency, Monetary views
│   └── 05_segmentation.sql         # RFM scores, segments, flagged accounts
│
├── notebooks/
│   ├── 01_eda.ipynb                # EDA, visualizations, correlation analysis
│   └── 02_clustering.ipynb         # KMeans, DBSCAN, PCA, model comparison
│
├── powerbi/
│   ├── bank_rfm_dashboard.pbix
│   ├── bank_rfm_dashboard.pdf
│   └── screenshots/
│       ├── page1_overview.png
│       └── page2_segments.png
│
└── README.md
```

---

## Dataset

**Source:** [Berka Financial Dataset](https://sorry.vse.cz/~berka/challenge/pkdd1999/) — a real anonymized Czech bank dataset from 1999.

| Table | Rows | Description |
|---|---|---|
| trans | 1,056,320 | All bank transactions |
| account | 4,500 | Customer accounts |
| client | 5,369 | Individual clients |
| disp | 5,369 | Client-account relationships |
| district | 77 | Regional demographic data |
| loan | 682 | Loan records with repayment status |
| card | 892 | Credit/debit card records |
| order | 6,471 | Standing payment orders |

---

## Methodology

### 1. SQL Pipeline (MySQL)

- **Schema design** — 8 relational tables with foreign key constraints
- **Exploration** — null checks, categorical profiling, date range analysis
- **Cleaning** — duplicate removal, null handling, referential integrity validation
- **RFM Calculation** — computed as MySQL views using window functions (NTILE)
- **Segmentation** — weighted RFM score with 7 behavioral segments

**RFM Scoring Formula:**
```
RFM Score = (R × 0.30) + (F × 0.35) + (M × 0.35)
```

| Segment | RFM Score |
|---|---|
| Loyal Customers | ≥ 4.0 |
| Potential Loyalists | ≥ 3.5 |
| Recent Customers | ≥ 3.0, R ≥ 4 |
| At Risk | ≥ 2.5, F ≥ 3 |
| Hibernating | ≥ 2.0, R ≤ 2 |
| About to Sleep | ≥ 1.5 |
| Lost / Inactive | < 1.5 |

---

### 2. Python Analysis (Notebooks)

**01_eda.ipynb**
- Transaction amount distribution (log scale, boxplot)
- Transaction volume over time (1993–1998)
- RFM metric distributions (Recency, Frequency, Monetary)
- Segment distribution bar chart
- RFM correlation heatmap
- Loan status by segment analysis

**02_clustering.ipynb**
- Feature scaling using StandardScaler
- KMeans — Elbow Method + Silhouette Score optimization
- DBSCAN — noise point detection and outlier identification
- PCA 2D projection for cluster visualization
- Model comparison by Silhouette Score

**Final Cluster Labels (KMeans, k=4):**

| Cluster | Label | Profile |
|---|---|---|
| 1 | 01. VIP / Champions | Highest monetary & frequency |
| 3 | 02. Loyal Customers | High activity, recent |
| 0 | 03. Regular / Standard | Moderate activity |
| 2 | 04. Lost / Churned | 500+ days inactive |

---

### 3. Power BI Dashboard

**Page 1 — Overview**
- KPI Cards: Total Accounts, Total Transactions, Total Monetary Volume
- Customer Distribution by Cluster
- Transaction Volume by Monetary Range
- Transaction Share by Segment (Donut)

**Page 2 — Customer Segments & Clustering**
- KPI Cards: Avg Monetary, Total Segments, Avg RFM Score
- Average Monetary by Segment
- Recency vs Monetary Scatter Plot (Outlier Detection)
- Filter by Segment (Slicer)

---

## Tech Stack

| Layer | Tools |
|---|---|
| Database | MySQL 8.0, DBeaver |
| Data Processing | Python, Pandas, NumPy |
| Machine Learning | Scikit-learn (KMeans, DBSCAN, PCA) |
| Visualization | Matplotlib, Seaborn |
| Business Intelligence | Power BI Desktop |
| Version Control | Git, GitHub |

---

## Key Findings

- **Loyal Customers** hold the highest average monetary value (~$1.8M), making them the primary revenue driver
- **Lost / Churned** accounts represent the largest cluster (Regular/Standard), indicating significant retention opportunity
- **DBSCAN** identified a small set of extreme outlier accounts with unusually high monetary values and low frequency — consistent with anomalous behavior patterns
- Accounts in the **At Risk** segment show declining recency despite moderate historical frequency, signaling early churn risk

---

## Setup & Usage

### Requirements
```
pip install pandas numpy matplotlib seaborn scikit-learn mysql-connector-python
```

### Database Setup
1. Import CSV files from `data/raw/` into MySQL using DBeaver
2. Run SQL scripts in order: `01` → `02` → `03` → `04` → `05`

### Notebooks
1. Update MySQL connection credentials in `01_eda.ipynb` Cell 2
2. Run `01_eda.ipynb` — exports processed CSVs to `data/processed/`
3. Run `02_clustering.ipynb` — exports final clustering results

### Power BI
Load `data/processed/rfm_final_clustering_results.csv` into Power BI Desktop.
