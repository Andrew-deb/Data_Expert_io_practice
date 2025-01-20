--QUESTION 7
CREATE TABLE host_activity_reduced(
    host TEXT,
    month DATE,
    site_hits TEXT,
    unique_site_hits TEXT,
    hit_array REAL[], --think COUNT(1).
    unique_visitors_array REAL[], -- think COUNT(DISTINCT user_id)
    PRIMARY KEY (host, month, site_hits, unique_site_hits)
);