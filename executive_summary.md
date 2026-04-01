# Executive Summary
## Revenue & Product Performance Analysis — Olist Brazilian E-Commerce (2017–2018)

**Analyst:** Sanduni &nbsp;|&nbsp; **Tools:** BigQuery Standard SQL, Power BI &nbsp;|&nbsp; **Dataset:** Olist, Kaggle

---

## Project Overview

This project delivers a full revenue and product performance analysis of a Brazilian e-commerce marketplace
across approximately two years of transaction data (September 2016 – August 2018).

The core business question driving every step of this analysis:

> *Which categories are growing, when does demand peak, and which sellers are performance risks
> hiding behind strong revenue numbers?*

The analysis covers 96,478 delivered orders totalling **R$15,419,773** in revenue,
built on a clean 4-table JOIN foundation validated before any business logic was applied.

---

## Analytical Approach — Step by Step

&nbsp;

### Step 1 — Data Audit Before Any Analysis

**Approach:**
Before writing a single business query, every table was audited for row counts, completeness, and structural integrity.

This step identified a critical data quality issue: the category translation table had been uploaded to BigQuery
without schema auto-detection. Column headers were loaded as data rows, and columns received generic names
(`string_field_0`, `string_field_1`) instead of their correct names
(`product_category_name`, `product_category_name_english`).

**Why this mattered:**
Had this not been caught, every JOIN on the category translation table would have silently failed or returned
incorrect results. All category names would have appeared as NULL or generic labels across every downstream query —
invalidating the entire category analysis without any visible error message.

**Resolution:**
The table was deleted and re-uploaded with schema auto-detection enabled. The corrected table was validated
with a direct SELECT before proceeding.

**Business thinking:**
An analyst who skips the data audit and runs straight to insights is an analyst who presents wrong numbers
with confidence. Auditing first is not caution — it is professional standard practice.

&nbsp;

### Step 2 — Building the Clean Base CTE

**Approach:**
A single reusable base CTE was constructed joining four tables:
`orders → order_items → products → category_translation`

Each JOIN type was chosen deliberately:

- `orders → order_items`: **INNER JOIN** — orders with no items have no revenue and no analytical value
- `order_items → products`: **INNER JOIN** — every line item must reference a real product record
- `products → category_translation`: **LEFT JOIN** — a missing translation is a labelling gap, not a missing transaction

`COALESCE()` was applied on the category field to convert any NULL translation to `'uncategorised'`,
ensuring GROUP BY operations and dashboard visuals never break on NULL values.

**Critical filter applied:**
`WHERE order_status = 'delivered'`

Revenue is only recognised on completed transactions. The dataset contains 8 order statuses.
Cancelled, processing, shipped, and invoiced orders were all excluded.
This reduced the working dataset from 99,441 total orders to **96,478 delivered orders**.

**Business thinking:**
Presenting revenue that includes cancelled or undelivered orders to a CFO is not just analytically wrong —
it is a trust-destroying mistake. Every number in this analysis reflects only what the business actually earned.

&nbsp;

### Step 3 — Monthly Revenue Trend with Year-on-Year Comparison

**Technique:** `LAG(12) OVER (ORDER BY order_month)`

**Approach:**
Monthly revenue was aggregated across the full dataset and a `LAG(12)` window function applied
to pull the equivalent month from the prior year — enabling direct YoY comparison within a single query.

`NULLIF()` was used in the YoY growth calculation to prevent division-by-zero errors in months
with no prior-year data. NULL values in the first 12 months were retained and flagged rather than
filtered out, ensuring the analysis was transparent about its own limitations.

**A key data quality decision:**
YoY figures for October–December 2017 showed growth rates of 500,000% to 4,000,000%.
These were not errors — they were caused by a near-zero 2016 revenue base (as few as 1 order in some months).
These figures were explicitly excluded from business conclusions and documented as low-base artefacts,
not genuine performance indicators.

**Business thinking:**
A growth rate of 4,000,000% is not a headline — it is a data literacy failure waiting to happen.
Knowing when a number is technically correct but commercially meaningless is a core analyst skill.

&nbsp;

### Step 4 — Revenue by Category with RANK() and Cumulative Percentage

**Technique:** `RANK() OVER (ORDER BY SUM(item_revenue) DESC)` + nested `SUM() OVER()`

**Approach:**
All product categories were ranked by total revenue. A cumulative revenue percentage was calculated
using a nested window SUM — the inner SUM aggregating revenue per category, the outer SUM running
a cumulative total across all categories.

`RANK()` was chosen over `ROW_NUMBER()` because categories with equal revenue should receive
equal rank. Forcing an arbitrary ordering on tied values would misrepresent the data.

**Business thinking:**
Revenue concentration analysis answers a question every commercial director should know:
*how many categories does this business actually depend on?*

The top 10 categories generate 62.4% of total revenue. Health & beauty alone accounts for 9.2%.
That is a moderate concentration risk — not dangerous today, but a structural vulnerability
if the leading category faces competitive pressure or supply disruption.

&nbsp;

### Step 5 — YoY Category Growth: Where to Invest and Where to Reduce Exposure

**Technique:** Conditional aggregation — `SUM(CASE WHEN order_year = 2017 THEN revenue END)`

**Approach:**
Annual revenue was pivoted by year into a single table using conditional aggregation,
then YoY growth calculated per category.

A revenue threshold of R$10,000 in 2017 was applied before calculating growth percentages.
Without this filter, micro-categories with minimal 2017 revenue produce inflated growth figures
that obscure the genuine investment signals.

**Business thinking:**
The most important finding here is not the highest growth rate — it is the combination of
scale and growth rate. Health & beauty (60.2% YoY) is already the largest category.
Most analysts would focus on construction tools at 509%. The sharper insight is that
health & beauty's growth is more valuable because it compounds on a much larger base.

The home improvement cluster — construction tools, home appliances, home construction —
surged simultaneously. Treated as individual categories, each looks like a moderate trend.
Treated as a cluster, they signal a macro consumer behaviour shift toward home investment
that warrants a coordinated commercial response.

&nbsp;

### Step 6 — Seller Performance: Dual Ranking by Revenue and Quality

**Technique:** `RANK()` applied simultaneously on `SUM(revenue)` and `AVG(review_score)`

**Approach:**
Each seller was ranked on both revenue contribution and average customer review score.
A minimum threshold of 50 completed orders was applied to exclude sellers with
insufficient transaction history — a 5.0 review from 3 orders is not statistically meaningful.

**Business thinking:**
The dual ranking reveals a structural platform problem invisible in revenue-only analysis.

The #2 seller by revenue holds a 3.35 review score — ranking 446th for customer satisfaction.
They generate R$239,645 across 1,366 orders. Every one of those 1,366 customers
associates their poor experience with the marketplace brand, not the individual seller.

Simultaneously, a seller ranked 20th by revenue holds a 4.45 review score and generates
R$477 per order — 3.5x the platform average. That seller is operating with high quality
and high value at low volume. The business question is not "how do we manage our top sellers" —
it is "why is our highest-quality seller not our highest-volume seller, and what is stopping them?"

**Platform risk statement:**
A marketplace that rewards revenue over quality will grow in the short term and erode in the long term.
Customer trust, once lost at scale, is significantly more expensive to rebuild than to protect.

&nbsp;

### Step 7 — Seasonality Analysis: Three Years Side by Side

**Technique:** Conditional aggregation pivot — `SUM(CASE WHEN order_year = 2017 THEN revenue ELSE 0 END)`

**Approach:**
Revenue for 2017 and 2018 was pivoted into a single table by calendar month using conditional aggregation,
enabling direct month-by-month visual comparison without multiple separate queries or joins.

Average order value was included alongside revenue to determine whether growth was volume-driven or value-driven.

**Business thinking:**
The seasonality data answers a question that directly affects budget allocation:
*when does the business actually make its money?*

November 2017 at R$1,153,364 is 53% above October and represents the single most important
commercial moment in the dataset. Q4 (October–December) generated approximately R$2.75M —
around 42% of full-year revenue in three months.

Equally significant: average order value was flat across the entire two-year period (R$128–R$152).
Revenue growth was driven entirely by transaction volume, not by customers spending more per visit.
This flatness is not a neutral finding — it is an unrealised opportunity. A business growing
through volume alone, with no AOV improvement, is leaving significant revenue on the table
from its existing customer base.

---

## Key Findings Summary

| Finding | Business Impact |
|---|---|
| Health & beauty: #1 category, +60.2% YoY | 20% decline = R$282K annual revenue loss |
| Q4 = 42% of annual revenue | November underperformance cannot be recovered |
| Basket size: 1.14 items per order | Cross-sell opportunity almost entirely untapped |
| AOV flat across 2 years: R$128–R$152 | All growth is volume-driven; upsell levers unused |
| #2 seller by revenue: 3.35 review score | Platform quality at risk behind strong headline numbers |
| Home improvement cluster: +148–509% YoY | Macro trend requiring coordinated category investment |
| Baby category: +68.2% YoY | High-LTV segment in early growth phase |
| Instalment payments exceed orders | Flexible payment is a conversion driver, not an edge case |

---

## Strategic Recommendations

&nbsp;

**1 — Protect and invest in health & beauty**
The #1 category is still accelerating. Assign a dedicated category owner.
Protect supplier relationships, expand assortment, and allocate disproportionate
above-the-line marketing spend. A 20% decline here costs R$282K — no other category compensates.

&nbsp;

**2 — Treat home improvement as a strategic cluster**
Construction tools, home appliances, and home construction are riding the same macro wave.
Build a coordinated "Home" category strategy rather than managing each in isolation.

&nbsp;

**3 — Introduce a free delivery threshold**
Basket size of 1.14 items is the clearest signal of untapped revenue in this dataset.
A delivery threshold set just above average order value requires minimal cost
and is proven to increase AOV by 10–30% on comparable platforms.

&nbsp;

**4 — Build Q4 as the primary commercial event**
42% of annual revenue flows through October–November–December.
Begin pre-Black Friday awareness campaigns in September.
Treat November as the single most important month in the commercial calendar.

&nbsp;

**5 — Introduce seller quality gates**
No seller should achieve top-10 visibility with a review score below 3.5,
regardless of revenue contribution. Quality-adjusted ranking protects
long-term platform trust and customer retention.

&nbsp;

**6 — Invest in baby category now**
68% YoY growth with high repeat purchase frequency and multi-year customer lifetime value.
The acquisition cost window is open. It will close as the category matures.

---

## Data Limitations & Caveats

- **2016 excluded from YoY analysis** — ramp-up period with as few as 1 order per month; not representative
- **2018 data covers January–August only** — all 2018 growth figures are understated; actual annual rates are estimated 30–40% higher
- **~2,963 non-delivered orders excluded** — represent real operational leakage worth ~R$450K; warrant separate investigation
- **No returns data available** — delivered orders are treated as final revenue; return window impact cannot be quantified
- **Seller IDs are anonymised** — category-level seller quality analysis is possible; individual seller identification is not

---

*Analysis by Sanduni | BigQuery Standard SQL + Power BI | Dataset: Olist Brazilian E-Commerce, Kaggle*

---
