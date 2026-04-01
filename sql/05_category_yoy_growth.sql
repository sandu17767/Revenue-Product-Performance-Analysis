-- ============================================================
-- QUERY 5: CATEGORY YEAR-ON-YEAR GROWTH ANALYSIS
-- Purpose: Identify growing vs declining categories
--   to inform investment and budget allocation decisions
-- Technique: Conditional aggregation (SUM CASE WHEN)
--   pivots years into columns within a single query
-- Filter: revenue_2017 > 10,000 removes low-base categories
--   whose growth % is statistically inflated and misleading
-- Note: 2018 = Jan–Aug only, all growth rates understated
-- ============================================================

WITH base AS (
  SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp)                     AS order_year,
    COALESCE(ct.product_category_name_english, 'uncategorised')       AS category,
    (oi.price + oi.freight_value)                                     AS item_revenue
  FROM `olist-analysis-492006.olist.orders` o
  INNER JOIN `olist-analysis-492006.olist.order_items` oi ON o.order_id = oi.order_id
  INNER JOIN `olist-analysis-492006.olist.products` p     ON oi.product_id = p.product_id
  LEFT JOIN `olist-analysis-492006.olist.category_translation` ct
    ON p.product_category_name = ct.product_category_name
  WHERE o.order_status = 'delivered'
    AND EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
),

yearly AS (
  SELECT
    category,
    ROUND(SUM(CASE WHEN order_year = 2017 THEN item_revenue ELSE 0 END), 2) AS revenue_2017,
    ROUND(SUM(CASE WHEN order_year = 2018 THEN item_revenue ELSE 0 END), 2) AS revenue_2018
  FROM base
  GROUP BY category
),

growth AS (
  SELECT
    category,
    revenue_2017,
    revenue_2018,
    ROUND((revenue_2018 - revenue_2017) / NULLIF(revenue_2017, 0) * 100, 1) AS yoy_growth_pct
  FROM yearly
  WHERE revenue_2017 > 10000
)

SELECT *
FROM growth
ORDER BY yoy_growth_pct DESC
LIMIT 20;
