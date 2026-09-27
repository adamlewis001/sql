-- Android Daily Ratings
SELECT --package_name,
       --app_version_code,
       --app_version_name,
       --reviewer_language,
       --device,
       review_submit_date_and_time::date as date,
       'Android' as platform,
       --review_submit_millis_since_epoch,
       --review_last_update_date_and_time,
       --review_last_update_millis_since_epoch,
       SUM(CASE WHEN star_rating::int = 1 THEN 1 END) as "1_star",
       SUM(CASE WHEN star_rating::int = 2 THEN 1 END) as "2_stars",
       SUM(CASE WHEN star_rating::int = 3 THEN 1 END) as "3_stars",
       SUM(CASE WHEN star_rating::int = 4 THEN 1 END) as "4_stars",
       SUM(CASE WHEN star_rating::int = 5 THEN 1 END) as "5_stars",
       COUNT(star_rating::int) as "ttl",
       (SUM(COUNT(CASE WHEN star_rating::int = 1 THEN 1 END)*1) OVER (PARTITION BY platform ORDER BY date asc rows between unbounded preceding and current row) +
       SUM(COUNT(CASE WHEN star_rating::int = 2 THEN 1 END)*2) OVER (PARTITION BY platform ORDER BY date asc rows between unbounded preceding and current row) +
       SUM(COUNT(CASE WHEN star_rating::int = 3 THEN 1 END)*3) OVER (PARTITION BY platform ORDER BY date asc rows between unbounded preceding and current row) +
       SUM(COUNT(CASE WHEN star_rating::int = 4 THEN 1 END)*4) OVER (PARTITION BY platform ORDER BY date asc rows between unbounded preceding and current row) +
       SUM(COUNT(CASE WHEN star_rating::int = 5 THEN 1 END)*5) OVER (PARTITION BY platform ORDER BY date asc rows between unbounded preceding and current row)*1.00) /
       SUM(COUNT(review_submit_date_and_time::date)) OVER (PARTITION BY platform ORDER BY date asc rows between unbounded preceding and current row) as "running_count",
       SUM(star_rating::int)*1.00 / COUNT(star_rating::int) as "avg_rating"
       --review_title,
       --review_text,
       --developer_reply_date_and_time,
       --developer_reply_millis_since_epoch,
       --developer_reply_text,
       --review_link
FROM db.xyz_googleplay_spectrum.reviews a
WHERE package_name = 'com.xyz.example'
--WHERE date >= '2018-01-01'
--JOIN db.xyz_googleplay_spectrum.reviews b
--ON a.review_submit_date_and_time 
GROUP BY date, platform
ORDER BY date ASC;
