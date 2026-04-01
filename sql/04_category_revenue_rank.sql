-- ============================================================
-- QUERY 4: REVENUE BY PRODUCT CATEGORY WITH RANK
-- Purpose: Identify top revenue categories and concentration risk
-- Technique: RANK() window function + nested SUM() OVER()
-- Why RANK() not ROW_NUMBER(): equal revenue = equal rank,
--   no arbitrary ordering of tied categories
-- Nested SUM: inner SUM aggregates per category,
--   outer SUM runs cumulative total across category groups
-- COALESCE: preserves revenue from uncategorised products
-- ============================================================

WITH base AS (
  SELECT
    (oi.price + oi.freight_value)                                     AS item_revenue,
    COALESCE(ct.product_category_name_english, 'uncategorised')       AS category
  FROM `olist-analysis-492006.olist.orders` o
  INNER JOIN `olist-analysis-492006.olist.order_items` oi ON o.order_id = oi.order_id
  INNER JOIN `olist-analysis-492006.olist.products` p     ON oi.product_id = p.product_id
  LEFT JOIN `olist-analysis-492006.olist.category_translation` ct
    ON p.product_category_name = ct.product_category_name
  WHERE o.order_status = 'delivered'
),

category_revenue AS (
  SELECT
    category,
    ROUND(SUM(item_revenue), 2)                              AS revenue,
    COUNT(*)                                                  AS total_items_sold,
    RANK() OVER (ORDER BY SUM(item_revenue) DESC)            AS revenue_rank,
    ROUND(
      SUM(SUM(item_revenue)) OVER (ORDER BY SUM(item_revenue) DESC)
      / SUM(SUM(item_revenue)) OVER ()
      * 100
    , 1)                                                      AS cumulative_pct
  FROM base
  GROUP BY category
)

SELECT *
FROM category_revenue
ORDER BY revenue_rank
LIMIT 20;
