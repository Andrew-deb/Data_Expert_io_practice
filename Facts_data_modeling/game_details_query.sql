--Creating or DDL
CREATE TABLE  fct_game_details (
    dim_game_date DATE,
    dim_season INTEGER,
    dim_team_id INTEGER,
    dim_player_id INTEGER,
    dim_player_name TEXT,
    dim_start_position TEXT,
    dim_is_playing_at_home BOOLEAN,
    dim_did_not_play BOOLEAN,
    dim_did_not_dress BOOLEAN,
    dim_not_with_team BOOLEAN,
    m_minute REAL,
    m_fgm INTEGER,
    m_fga INTEGER,
    fg3m  INTEGER,
    m_fg3a INTEGER,
    m_ftm INTEGER,
    m_fta INTEGER,
    m_oreb INTEGER,
    m_dreb INTEGER,
    m_reb INTEGER,
    m_ast INTEGER,
    m_stl INTEGER,
    m_blk INTEGER,
    m_turnovers INTEGER,
    m_pf INTEGER,
    m_pts INTEGER,
    m_plus_minus INTEGER,
    PRIMARY KEY(dim_game_date, dim_team_id, dim_player_id)
);

-- Ordering the columns for insertion into the fct_game_details
INSERT INTO fct_game_details
WITH deduped AS(
    SELECT
        g.game_date_est,
        g.season,
        g.home_team_id,
        gd.*,
        row_number() OVER(PARTITION BY gd.game_id, gd.team_id, gd.player_id) AS row_num
    FROM game_details gd
        join games g ON gd.game_id = g.game_id
)
SELECT
    game_date_est as dim_game_date,
    season AS dim_season,
    team_id AS dim_team_id,
    player_id AS dim_player_id,
    player_name AS dim_player_name,
    start_position AS dim_start_position,
    team_id= home_team_id AS dim_is_playing_at_home, -- which takes handles the case where the team is away or at home using a boolean
    COALESCE(POSITION('DNP' IN comment)) >0 as dim_did_not_play,
    COALESCE(POSITION('DND' IN comment)) >0 as dim_did_not_dress,
    COALESCE(POSITION('NWT' IN comment)) >0 as dim_not_with_team,
    CAST(SPLIT_PART(min, ':', 1) AS REAL) + CAST(SPLIT_PART(min, ':', 2) AS REAL)/60 AS m_minutes,
    fgm AS m_fgm,
    fga AS m_fga,
    fg3a AS m_fg3a,
    fg3m AS m_fg3m,
    ftm AS m_ftm,
    fta AS m_fta,
    oreb AS m_oreb,
    dreb AS m_dreb,
    reb AS m_reb,
    ast AS m_ast,
    stl AS m_stl,
    blk AS m_blk,
    "TO" AS m_turnovers,
    pf AS m_pf,
    pts AS m_pts,
    plus_minus AS m_plus_minus
FROM deduped
WHERE row_num = 1;