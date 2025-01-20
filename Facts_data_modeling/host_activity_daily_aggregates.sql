--QUESTION 8
INSERT INTO host_activity_reduced(host, month, site_hits, unique_site_hits, hit_array, unique_visitors_array)
WITH daily_aggregate AS (
    SELECT
        host,
            DATE(event_time) AS date, --current_date
            COUNT(1) AS num_site_hits,
            COUNT(DISTINCT user_id) AS num_unique_site_hits
    FROM events
    WHERE DATE(event_time) = DATE('2023-01-02')
    AND host IS NOT NULL
    GROUP BY host, DATE(event_time)
),
yesterday_array AS (
        SELECT *
        FROM host_activity_reduced
        WHERE month = DATE('2023-01-01')
    )
SELECT
    COALESCE(da.host, ya.host) as user_id,
    COALESCE(ya.month, DATE_TRUNC('month', da.date)) as month,
    'site_hits' AS site_hits,
    CASE WHEN ya.hit_array IS NOT NULL THEN
        ya.hit_array || ARRAY[COALESCE((da.num_site_hits::REAL), 0)]
    WHEN ya.hit_array IS NULL
        --The math in this line below, subtracts the start of the month from date when the user started viewing the site and returns an array of zero till that date.
        THEN array_fill(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)]) || ARRAY[COALESCE(da.num_site_hits::REAL, 0)]
    END AS hit_array,


    'unique_site_hits' AS unique_visitors,
    CASE WHEN ya.unique_visitors_array IS NOT NULL THEN
        ya.unique_visitors_array || ARRAY[COALESCE((da.num_unique_site_hits::REAL), 0)]::REAL[]
    WHEN ya.unique_visitors_array IS NULL
        --The math in this line below, subtracts the start of the month from date when the user started viewing the site and returns an array of zero till that date.
        THEN array_fill(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)]) || ARRAY[COALESCE(da.num_unique_site_hits::REAL, 0)]::REAL[]
    END AS unique_visitors_array

FROM daily_aggregate da
    FULL OUTER JOIN yesterday_array ya ON
        da.host = ya.host
ON CONFLICT (host, month, hit_array, unique_visitors_array)
DO
    UPDATE SET hit_array = EXCLUDED.hit_array, unique_visitors_array = EXCLUDED.unique_visitors_array;