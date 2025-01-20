--QUESTION 5:

CREATE TABLE hosts_cumulated(
    host_name TEXT,
    date DATE,
    host_activity_datelist DATE[],
    PRIMARY KEY (host_name, date)
);

--QUESTION 6:
INSERT INTO hosts_cumulated(host_name, date, host_activity_datelist)
WITH
yesterday AS (
    SELECT
        *
    FROM hosts_cumulated
    WHERE date = DATE('2023-01-30')
),
today AS (
       SELECT
        host AS host_name,
        DATE(CAST(event_time AS TIMESTAMP)) AS event_date
    FROM events
    WHERE
        DATE(CAST(event_time AS TIMESTAMP)) = DATE('2023-01-31')
        AND host IS NOT NULL
        GROUP BY host_name, DATE(CAST(event_time AS TIMESTAMP))
)
SELECT
       COALESCE(t.host_name, y.host_name) AS host,
       COALESCE(t.event_date, y.date + INTERVAL '1 day') AS date,
       CASE
            WHEN y.host_activity_datelist IS NULL
                THEN ARRAY[t.event_date]
                WHEN t.event_date IS NULL THEN y.host_activity_datelist
                ELSE ARRAY[t.event_date] || y.host_activity_datelist
                END
                AS host_activity_datelist
FROM today t
FULL OUTER JOIN yesterday y
ON t.host_name = y.host_name
ON CONFLICT (host_name, date)
DO UPDATE SET host_activity_datelist = EXCLUDED.host_activity_datelist;