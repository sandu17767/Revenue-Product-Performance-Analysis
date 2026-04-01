# 📊 Revenue & Product Performance Analysis

### Olist Brazilian E-Commerce &nbsp;|&nbsp; 2017–2018 &nbsp;|&nbsp; BigQuery SQL + Power BI

---

## 📊 Live Dashboard

👉 [View Interactive Dashboard](https://sandu17767.github.io/Revenue-Product-Performance-Analysis/)

> **One-line summary:**
> Multi-table revenue and product performance analysis on 96,478 orders across a Brazilian e-commerce marketplace —
> identifying growth categories, seasonal demand patterns, and seller quality risks using window functions,
> YoY analysis, and conditional aggregation.

---

## 🧩 Business Problem

An e-commerce marketplace cannot answer three questions that directly drive commercial strategy:

- Which product categories are growing — and which are quietly declining?
- When does demand peak, and how should the marketing calendar respond?
- Which sellers are revenue risks disguised as top performers?

This analysis answers all three using two years of real transaction data.

---

## 🔍 Data Cleaning & Quality Decisions

Real analysis is not just writing queries.
It is making deliberate decisions about what data to trust, what to exclude, and what to flag.
Every decision below has a business reason.

&nbsp;

**1 — Filtered to `delivered` orders only**

The orders table contains 8 status values: delivered, shipped, processing, cancelled, invoiced, approved, unavailable, created.

Only `delivered` represents a completed, revenue-realised transaction. Including other statuses would overstate revenue and mislead financial reporting.

This reduced the dataset from 99,441 total orders to **96,478 delivered orders**.
The ~2,963 excluded orders represent operational leakage worth approximately R$450,000 in undelivered revenue — a separate analysis in its own right.

&nbsp;

**2 — LEFT JOIN on the category translation table**

The category translation table maps 72 Portuguese category names to English.

An INNER JOIN would silently drop any product whose category name had no English translation — removing revenue from totals without warning.

A LEFT JOIN was used instead, with `COALESCE()` converting NULL translations to `'uncategorised'`.
Revenue is always preserved. Only the label is occasionally missing.

&nbsp;

**3 — Excluded 2016 from all YoY comparisons**

The dataset begins in September 2016, with only 3 active months and extremely low order volumes — as few as 1 order in some months.

These figures are not representative of steady-state business performance. They reflect a platform in its earliest ramp-up phase.

Including 2016 in YoY comparisons produces growth rates of 4,000,000%+ — statistically true and commercially meaningless.
All trend analysis uses **2017 as Year 1**.

&nbsp;

**4 — Flagged August 2018 as an incomplete period**

The dataset cuts off in August 2018. Orders placed in late July and August 2018 may not have reached `delivered` status before the data was extracted, causing the final month to be understated.

All 2018 figures carry this caveat: actual annual growth rates are likely **30–40% higher** than observed.

&nbsp;

**5 — Applied minimum volume threshold on seller analysis**

Sellers with fewer than 50 completed orders were excluded from the seller performance analysis.

A seller with 3 orders and a 5.0 review score is statistically unreliable — their average is not meaningful at that volume.
The threshold ensures only sellers with sufficient transaction history are ranked.

&nbsp;

**6 — Applied revenue threshold on category YoY growth**

Categories with less than R$10,000 in 2017 revenue were excluded from the YoY growth ranking.

A category generating R$50 in 2017 and R$500 in 2018 shows 900% growth — technically accurate, strategically irrelevant.
The filter removes low-base noise and surfaces genuine growth signals.

&nbsp;

**7 — Resolved schema issue on category translation upload**

During initial BigQuery upload, the category translation CSV loaded without schema auto-detection.
Column headers were treated as data rows, and columns received generic names (`string_field_0`, `string_field_1`).

The table was re-uploaded with auto-detect enabled and validated before joining.

This is a common ingestion issue in real data pipelines — identifying and correcting it before analysis is standard data validation practice.

---

## 💡 Key Business Findings

&nbsp;

### 1 — Health & Beauty is the growth engine. Protect it.

Health & beauty is the #1 revenue category at **R$1,412,089** — and it is still growing at **60.2% YoY**.

That combination of scale and acceleration is rare. Most market-leading categories plateau as they mature.
A 20% decline in this single category would cost the business approximately **R$282,000 annually**.

It deserves disproportionate investment in assortment, marketing, and supplier relationships.

&nbsp;

### 2 — A home improvement macro-trend is emerging

Three categories are surging simultaneously:

| Category | YoY Growth |
|---|---|
| Construction tools | +509% |
| Home appliances | +286% |
| Home construction | +148% |

This is not three independent trends. It reflects a single macro shift: Brazilian consumers investing in their homes during 2017–2018.

A category manager who spots this pattern early redirects budget toward the cluster, not a single SKU — and captures significantly more growth.
Collectively, this segment grew from approximately R$100K to R$366K in one year.

&nbsp;

### 3 — November makes or breaks the annual revenue target

November 2017 generated **R$1,153,364** — 53% above October and the highest single month in the dataset.

Q4 (October–December) produced approximately **R$2.75M**, representing roughly **42% of full-year revenue in just 3 months**.

A 20% underperformance in November alone costs over **R$230,000** that no other month can recover.

The marketing calendar should treat September–November as the primary investment window, not an afterthought.

&nbsp;

### 4 — All revenue growth is volume-driven. AOV is completely flat.

Average order value barely moved across two years — ranging R$128–R$152.

Every R$15.4M of revenue growth came from more orders, not higher spend per order.

With a basket size of just **1.14 items per order** (vs Amazon's 2–3 items), the cross-sell and upsell opportunity is almost entirely untapped.

A free delivery threshold set just above the average order value is the single highest-leverage revenue action available —
proven to increase AOV by 10–30% on comparable marketplaces.

&nbsp;

### 5 — Instalment payments are a conversion driver, not a data quirk

The payments table contains **103,886 rows against 99,441 orders** — more payment records than orders.

In a UK context this might suggest failed payment retries.
In Brazil, it reflects *parcelado* — instalment-based purchasing, where customers split payments across multiple months.

Instalment options are not a convenience feature here.
They are a primary conversion mechanism that expands the addressable market to customers who cannot pay full price upfront.

&nbsp;

### 6 — The platform is prioritising revenue over quality

The #2 seller by revenue generates **R$239,645** — but holds a **3.35 average review score**, ranking 446th for customer satisfaction.

That seller handles 1,366 customer touchpoints per year, each one associated with Olist's brand, not the seller's.

At Amazon, a seller with sustained sub-3.5 reviews faces suspension regardless of revenue contribution.

Meanwhile, the seller ranked 20th by revenue holds a **4.45 review score** with an average order value of **R$477** — 3.5x the platform average.
Understanding what makes that seller exceptional and replicating it is a higher-value action than protecting one underperforming high-volume account.

&nbsp;

### 7 — Baby is the highest-potential emerging category

Baby grew **68.2% YoY** from a meaningful base.

Customers with young children have predictable, high-frequency, multi-category purchase needs across several years.
The lifetime value potential of a well-retained baby category customer is significantly above the platform average.

This category warrants targeted acquisition investment now, before competitors establish dominance.

---

## 🛠️ SQL Techniques Demonstrated

| Technique | Applied To |
|---|---|
| Multi-table JOIN chain (4 tables) | Base CTE across orders, items, products, categories |
| `LAG(12)` window function | Year-over-year monthly revenue comparison |
| `RANK()` window function | Category revenue ranking, seller dual-ranking |
| Conditional aggregation (`SUM CASE WHEN`) | Seasonality pivot — all years in a single query |
| Cumulative `SUM() OVER()` | Running revenue percentage by category |
| `NULLIF()` for safe division | YoY growth % without division-by-zero errors |
| `COALESCE()` for NULL handling | Uncategorised products preserved, not dropped |
| `LEFT JOIN` on lookup tables | Revenue never silently lost via failed joins |
| `HAVING` with volume threshold | Seller analysis excludes statistically unreliable accounts |

---

## 📁 Dataset

**Source:** [Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — Kaggle

**Scale:** 99,441 total orders &nbsp;|&nbsp; 96,478 delivered &nbsp;|&nbsp; R$15,419,773 revenue &nbsp;|&nbsp; Sept 2016 – Aug 2018

&nbsp;

**Tables used:**
```
olist.orders               → 99,441 rows
olist.order_items          → 112,650 rows
olist.products             → 32,951 rows
olist.customers            → 99,441 rows
olist.sellers              → 3,095 rows
olist.order_reviews        → 99,224 rows
olist.order_payments       → 103,886 rows
olist.category_translation → 72 rows
```

&nbsp;

**Data notes:**

- 2016 excluded from YoY comparisons — ramp-up period, not representative of steady-state performance
- 2018 covers January–August only — all growth figures are conservatively understated
- ~2,963 non-delivered orders excluded — represent operational leakage, not realised revenue

---

## 🔧 Tools

- **BigQuery Standard SQL** — all queries, CTEs, window functions
- **Power BI** — KPI dashboard, revenue trend, category breakdown, seasonality heatmap
- **Google Sheets** — intermediate result validation

---

## 📂 Project Structure
```
olist-revenue-analysis/
│
├── sql/
│   ├── 01_data_audit.sql
│   ├── 02_base_cte.sql
│   ├── 03_monthly_revenue_yoy.sql
│   ├── 04_category_revenue_rank.sql
│   ├── 05_category_yoy_growth.sql
│   ├── 06_seller_performance.sql
│   └── 07_seasonality_pivot.sql
│
├── dashboard/
│   └── olist_revenue_dashboard.pbix
│
└── README.md
```

---

## 📌 Strategic Recommendations

&nbsp;

**1 — Protect health & beauty**
Allocate disproportionate marketing budget to defend and grow the #1 category.
A 20% decline costs R$282K annually — no other category compensates for that loss.

&nbsp;

**2 — Invest in the home improvement cluster**
Treat construction, appliances, and home construction as a single strategic segment riding a macro trend.
The window to invest ahead of competition is open now.

&nbsp;

**3 — Introduce a free delivery threshold**
Basket size of 1.14 items signals major untapped AOV upside.
A threshold set just above average order value requires minimal cost and delivers measurable revenue uplift.

&nbsp;

**4 — Build a Black Friday playbook**
42% of annual revenue is won or lost in Q4.
Treat November as the single most important commercial event of the year and plan campaigns from September.

&nbsp;

**5 — Introduce seller quality gates**
Revenue rank alone is not sufficient for seller promotion.
Review score must be a threshold criterion — high-revenue, low-quality sellers damage platform trust at scale.

&nbsp;

**6 — Develop baby category early**
68% YoY growth with high repeat purchase potential.
Acquire customers now, before the category matures and acquisition costs rise.

---

## 👩‍💻 About

**Sanduni** | Data Analyst | London, UK

Building an e-commerce analytics portfolio targeting mid-level analyst roles at Amazon UK, ASOS, Harrods, H&M, and Louis Vuitton.

&nbsp;

*"I analyse customer and marketing data for e-commerce and retail businesses to improve conversion, retention,
and revenue — using SQL, Power BI, and AI-powered analytics."*

&nbsp;

🔗 [Project 1 — Customer Retention & Cohort Analysis](#)

🔗 [Project 2 — RFM Segmentation & CLV](#)

🔗 [Project 3 — Revenue & Product Performance Analysis](#) ← you are here

---
