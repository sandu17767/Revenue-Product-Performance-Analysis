-- ============================================================
-- QUERY 6: SELLER PERFORMANCE — DUAL RANKING
-- Purpose: Identify revenue risks hiding behind strong numbers
--   by ranking sellers on BOTH revenue AND review quality
-- Technique: RANK() applied simultaneously on two metrics
-- HAVING COUNT(*) >= 50: excludes low-volume sellers whose
--   average review score is statistically unreliable
-- LEFT JOIN reviews: some orders have no review — LEFT JOIN
--   preserves all sellers rather than dropping unreviewed ones
-- Key insight: revenue rank ≠ quality rank reveals platform risk
-- ============================================================

WITH base AS (
  SELECT
    oi.seller_id,
    (oi.price + oi.freight_value)  AS item_revenue,
    r.review_score
  FROM `olist-analysis-492006.olist.orders` o
  INNER JOIN `olist-analysis-492006.olist.order_items` oi ON o.order_id = oi.order_id
  LEFT JOIN `olist-analysis-492006.olist.order_reviews` r  ON o.order_id = r.order_id
  WHERE o.order_status = 'delivered'
),

seller_stats AS (
  SELECT
    seller_id,
    ROUND(SUM(item_revenue), 2)                                   AS total_revenue,
    COUNT(*)                                                       AS total_orders,
    ROUND(AVG(review_score), 2)                                    AS avg_review_score,
    RANK() OVER (ORDER BY SUM(item_revenue) DESC)                 AS revenue_rank,
    RANK() OVER (ORDER BY AVG(review_score) DESC)                 AS review_rank
  FROM base
  GROUP BY seller_id
  HAVING COUNT(*) >= 50
)

SELECT *
FROM seller_stats
ORDER BY revenue_rank
LIMIT 20;
