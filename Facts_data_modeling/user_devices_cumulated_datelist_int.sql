WITH users AS(
    SELECT *
    FROM user_device_cumulated
    WHERE date = DATE('2023-01-31')
),
    series AS (
        SELECT *
            FROM
        generate_series('2023-01-01', '2023-01-31', INTERVAL '1 day')
            AS series_date
    ),
    place_holder_ints AS(
        SELECT
            CASE WHEN
            device_activity_datelist @> ARRAY[DATE(series_date)]
        THEN CAST(POW(2, 32 - (date - DATE(series_date))) AS BIGINT)
        ELSE 0
            END AS place_holder_ints,
        *
        FROM users CROSS JOIN series
    )
    SELECT
    user_id,
    CAST(CAST(SUM(place_holder_ints) AS BIGINT) AS BIT(32)),
    BIT_COUNT(CAST(CAST(SUM(place_holder_ints) AS BIGINT) AS BIT(32))), -- A way to check the number of active days from each device
    BIT_COUNT(CAST(CAST(SUM(place_holder_ints) AS BIGINT) AS BIT(32))) > 0
        AS dim_monthly_active, -- Checking if the user's devices is active at least once within a month

    --Checking if the user is active for at least a week, by placing a criteria of the first seven 1's.
    --Also, we achieve this by using the '&' operator to compare the bits at the month and the 7 days range making sure that the users are active all the days of the week to fit into the category.

    BIT_COUNT(CAST('11111110000000000000000000000000' AS BIT(32)) &
            CAST(CAST(SUM(place_holder_ints) AS BIGINT) AS BIT(32))) >0
                    AS dim_weekly_active,
     BIT_COUNT(CAST('10000000000000000000000000000000' AS BIT(32)) &
            CAST(CAST(SUM(place_holder_ints) AS BIGINT) AS BIT(32))) >0
                AS dim_daily_active--Checking if the suer is active within a week, by placing a criteria of at least a 1.
FROM place_holder_ints
GROUP BY user_id;