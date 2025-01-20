--QUESTION 2
--CREATING DDL
CREATE TABLE user_device_cumulated(
    user_id NUMERIC,
    device_activity_datelist DATE[],
    date DATE,
    browser_type TEXT,
    PRIMARY KEY (user_id, date, browser_type)
);
DROP TABLE user_device_cumulated;