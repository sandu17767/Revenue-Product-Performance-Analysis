-- ============================================================
-- QUERY 3: MONTHLY REVENUE TREND WITH YEAR-ON-YEAR COMPARISON
-- Purpose: Track revenue growth month by month across 2 years
-- Technique: LAG(12) window function
-- Why LAG(12): data ordered by month chronologically,
--   12 rows back = same month prior year = YoY comparison
-- NULLIF: prevents division-by-zero in growth % calculation
-- Note: first 12 months return NULL (no prior year baseline)
--   Oct/Nov/Dec 2017 YoY excluded — near-zero 2016 base
-- ============================================================

WITH base AS (
  SELECT
    FORMAT_DATE('%Y-%m', o.order_purchase_timestamp) AS order_month,
    EXTRACT(YEAR FROM o.order_purchase_timestamp)    AS order_year,
    (oi.price + oi.freight_value)                    AS item_revenue
  FROM `olist-analysis-492006.olist.orders` o
  INNER JOIN `olist-analysis-492006.olist.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
),

monthly_revenue AS (
  SELECT
    order_month,
    order_year,
    ROUND(SUM(item_revenue), 2)   AS revenue,
    COUNT(DISTINCT order_id)       AS total_orders,
    ROUND(AVG(item_revenue), 2)    AS avg_order_value
  FROM base
  GROUP BY order_month, order_year
),

yoy AS (
  SELECT
    order_month,
    order_year,
    revenue,
    total_orders,
    avg_order_value,
    LAG(revenue, 12) OVER (ORDER BY order_month)     AS prior_year_revenue,
    ROUND(
      (revenue - LAG(revenue, 12) OVER (ORDER BY order_month))
      / NULLIF(LAG(revenue, 12) OVER (ORDER BY order_month), 0)
      * 100
    , 1)                                             AS yoy_growth_pct
  FROM monthly_revenue
)

SELECT *
FROM yoy
ORDER BY order_month;
