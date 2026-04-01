-- ============================================================
-- QUERY 2: BASE CTE — CLEAN FOUNDATION
-- Purpose: Single reusable base joining 4 tables
-- Technique: Multi-table JOIN chain
-- Key decisions:
--   INNER JOIN orders→items: orders without items have no revenue
--   INNER JOIN items→products: every item needs a product record
--   LEFT JOIN products→category_translation: missing translation
--     is a labelling gap, not a missing transaction
--   WHERE delivered: only recognise completed revenue
--   COALESCE: NULL categories → 'uncategorised', never dropped
-- ============================================================

WITH base AS (
  SELECT
    o.order_id,
    o.customer_id,
    DATE(o.order_purchase_timestamp)                 AS order_date,
    FORMAT_DATE('%Y-%m', o.order_purchase_timestamp) AS order_month,
    EXTRACT(YEAR FROM o.order_purchase_timestamp)    AS order_year,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value)                    AS item_revenue,
    COALESCE(ct.product_category_name_english, 'uncategorised') AS category

  FROM `olist-analysis-492006.olist.orders` o
  INNER JOIN `olist-analysis-492006.olist.order_items` oi
    ON o.order_id = oi.order_id
  INNER JOIN `olist-analysis-492006.olist.products` p
    ON oi.product_id = p.product_id
  LEFT JOIN `olist-analysis-492006.olist.category_translation` ct
    ON p.product_category_name = ct.product_category_name

  WHERE o.order_status = 'delivered'
)

-- Validation: run this to confirm base CTE is working correctly
SELECT
  COUNT(*)                     AS total_line_items,
  COUNT(DISTINCT order_id)     AS total_orders,
  COUNT(DISTINCT category)     AS total_categories,
  ROUND(SUM(item_revenue), 2)  AS total_revenue_brl,
  MIN(order_date)              AS earliest_order,
  MAX(order_date)              AS latest_order
FROM base;
