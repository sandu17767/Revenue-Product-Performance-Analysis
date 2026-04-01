-- ============================================================
-- QUERY 1: DATA AUDIT
-- Purpose: Verify all tables loaded correctly in BigQuery
-- Checks row counts across all 8 tables before any analysis
-- ============================================================

SELECT 'orders'              AS table_name, COUNT(*) AS row_count FROM `olist-analysis-492006.olist.orders`
UNION ALL
SELECT 'order_items',                        COUNT(*) FROM `olist-analysis-492006.olist.order_items`
UNION ALL
SELECT 'products',                           COUNT(*) FROM `olist-analysis-492006.olist.products`
UNION ALL
SELECT 'customers',                          COUNT(*) FROM `olist-analysis-492006.olist.customers`
UNION ALL
SELECT 'sellers',                            COUNT(*) FROM `olist-analysis-492006.olist.sellers`
UNION ALL
SELECT 'reviews',                            COUNT(*) FROM `olist-analysis-492006.olist.order_reviews`
UNION ALL
SELECT 'payments',                           COUNT(*) FROM `olist-analysis-492006.olist.order_payments`
UNION ALL
SELECT 'category_translation',               COUNT(*) FROM `olist-analysis-492006.olist.category_translation`
ORDER BY row_count DESC;
