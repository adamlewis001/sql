--Cross Shopping Dashboard Data
SELECT m1.month, m1.brand_product, m2.brand_product, COUNT(DISTINCT(m1.visit_id)) as "crossvisits" FROM
    (SELECT
      DATE_TRUNC('month', dt::date)::date as "month"
         , lower(post_prop18) || '_' || lower(post_prop19) as "brand_product"
         , post_visid_high || '-' || post_visid_low || '-' || visit_num as "visit_id"
         , SUM(CASE WHEN post_page_event = 0 THEN 1 END) as "pageviews"
      FROM xyz_bi_redshift_spectrum.daily_omniture_hub_ext_tbl
      WHERE 
         dt::date >= '2024-01-01'::date 
         AND dt::date <= '2026-12-31'::date
         AND hit_source = 1
         AND exclude_hit = 0
         AND lower(post_prop18) LIKE '%_%'
         AND lower(post_prop19) LIKE '%_%'
         AND lower(geo_country) = 'usa'
         AND post_page_event = 0
      GROUP BY month, brand_product, visit_id
      ORDER BY month ASC
      ) m1
FULL OUTER JOIN
      (SELECT
      DATE_TRUNC('month', dt::date)::date as "month"
         , lower(post_prop18) || '_' || lower(post_prop19) as "brand_product"
         , post_visid_high || '-' || post_visid_low || '-' || visit_num as "visit_id"
         , SUM(CASE WHEN post_page_event = 0 THEN 1 END) as "pageviews"
      FROM xyz_bi_redshift_spectrum.daily_omniture_hub_ext_tbl m1
      WHERE 
         dt::date >= '2024-01-01'::date 
         AND dt::date <= '2026-12-31'::date
         AND hit_source = 1
         AND exclude_hit = 0
         AND lower(post_prop18) LIKE '%_%'
         AND lower(post_prop19) LIKE '%_%'
         AND lower(geo_country) = 'usa'
         AND post_page_event = 0
      GROUP BY month, brand_product, visit_id
      ORDER BY month ASC
      ) m2
ON m1.visit_id=m2.visit_id
AND (m1.brand_product <> m2.brand_product OR m1.brand_product=m2.brand_product)
--WHERE m1.brand_product = 'test_name_goes_here'
WHERE m2.brand_product LIKE '%_%'
GROUP BY 1,2,3
HAVING crossvisits >= 50
ORDER BY crossvisits DESC;
