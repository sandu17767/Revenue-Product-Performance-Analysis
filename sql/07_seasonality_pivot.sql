-- ============================================================
-- QUERY 7: SEASONALITY ANALYSIS — ALL YEARS SIDE BY SIDE
-- Purpose: Identify peak months and plan marketing calendar
-- Technique: Conditional aggregation pivot
--   SUM(CASE WHEN order_year = 2017 THEN revenue ELSE 0 END)
--   pivots years into columns without separate queries or JOINs
-- AVG included alongside SUM to detect whether growth is
--   volume-driven (more orders) or value-driven (higher spend)
-- Note: 2016 excluded — ramp-up period, not representative
-- ============================================================

WITH base AS (
  SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp)   AS order_month_num,
    FORMAT_DATE('%B', o.order_purchase_timestamp)    AS month_name,
    EXTRACT(YEAR FROM o.order_purchase_timestamp)    AS order_year,
    (oi.price + oi.freight_value)                    AS item_revenue
  FROM `olist-analysis-492006.olist.orders` o
  INNER JOIN `olist-analysis-492006.olist.order_items` oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
    AND EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
)

SELECT
  order_month_num,
  month_name,
  ROUND(SUM(CASE WHEN order_year = 2017 THEN item_revenue ELSE 0 END), 2) AS revenue_2017,
  ROUND(SUM(CASE WHEN order_year = 2018 THEN item_revenue ELSE 0 END), 2) AS revenue_2018,
  ROUND(AVG(CASE WHEN order_year = 2017 THEN item_revenue END), 2)        AS avg_order_2017,
  ROUND(AVG(CASE WHEN order_year = 2018 THEN item_revenue END), 2)        AS avg_order_2018
FROM base
GROUP BY order_month_num, month_name
ORDER BY order_month_num;
