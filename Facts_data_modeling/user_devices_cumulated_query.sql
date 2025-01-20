--QUESTION 3
--Creating a  cumulative query to generate device_activity_datelist from events
-- Inserting the cumulative query into the user_devices_cumulated table
INSERT INTO user_device_cumulated
   WITH yesterday AS (
    SELECT * FROM user_device_cumulated
    WHERE date = DATE('2023-01-30') -- hard coded for now
),
    --Deduping the events and device table before joining.
    today_distinct AS (
          SELECT DISTINCT
       				user_id,
       				browser_type,
                   DATE(cast(event_time as TIMESTAMP)) AS date_active
                  FROM devices d join events e
                  on d.device_id = e.device_id
            WHERE DATE(CAST(event_time AS TIMESTAMP)) = DATE('2023-01-31') -- this is hardcoded
            AND user_id IS NOT null
             AND d.browser_type IS NOT null
    ),
       today AS (
           SELECT *
           FROM today_distinct
           GROUP BY user_id, browser_type, date_active
       )
SELECT
       COALESCE(t.user_id, y.user_id) AS user_id,
       CASE WHEN y.device_activity_datelist IS NULL
       THEN ARRAY[t.date_active]
       WHEN t.date_active IS NULL THEN y.device_activity_datelist
       ELSE ARRAY[t.date_active] || y.device_activity_datelist
       END
       AS devices_activity_datelist,
       COALESCE(t.date_active, y.date + INTERVAL '1 day') AS date,
       COALESCE(t.browser_type, y.browser_type) AS browser_type
FROM yesterday y
    FULL OUTER JOIN
    today t ON t.user_id = y.user_id and t.browser_type = y.browser_type; -- use browser_type and user_id to ensure there's no duplicate rows based on those values
