--Q1
	--A: 1871-2016
SELECT DISTINCT year
FROM homegames
ORDER BY year;
	--All Star Full: 1933-2016
SELECT DISTINCT yearid
FROM allstarfull
ORDER BY yearid;

--Q2
	--A: Eddie Gaedel, 43 in. , 1 game, Team SLA
SELECT playerid,
	namefirst,
	namelast,
	height,
	a.teamid,
	g_all
FROM people
INNER JOIN appearances a USING (playerid)
ORDER BY height
LIMIT 1;

--Q3
	--A: David Price
SELECT DISTINCT playerid,
	namefirst,
	namelast,
	schoolname,
	SUM(salary) as total_salary
FROM people 
INNER JOIN collegeplaying USING(playerid)
INNER JOIN schools USING (schoolid)
INNER JOIN salaries USING (playerid)
WHERE schoolname ILIKE '%Vanderbilt%'
GROUP BY playerid, schoolname
ORDER BY total_salary DESC;

--Q5
	--Strikeouts: Avg strikeouts increase as the decades increase
SELECT (yearid / 10) * 10 AS decade,
	ROUND(SUM(so)::numeric / (SUM(g)/2), 2) AS avg_strikeouts_per_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;
	--Homeruns: Avg homeruns increase as years increase until 1960 and picks up again in 1980
SELECT (yearid / 10) * 10 AS decade,
	ROUND(SUM(hr)::numeric / (SUM(g)/2), 2) AS avg_homeruns_per_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

--Q7
	--Largest # of wins for team that did not win the world series: 116
SELECT yearid,
    teamid,
    name,
    w
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'N'
ORDER BY w DESC
LIMIT 1;
	--Smallest # of wins for team that won the world series: 2006 with 83 wins
		--Problem Year: 1981 with 63 wins
SELECT yearid,
	teamid,
	name, 
	w
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND yearid <> 1981
	AND wswin = 'Y'
ORDER BY w
LIMIT 1;
	--% of time of teams with most wins that won the world series from 1970-2016
		--A: 25.53%
WITH yearly_winners as (
	SELECT yearid,
        MAX(w) AS max_wins
    FROM teams
    WHERE yearid BETWEEN 1970 AND 2016
    GROUP BY yearid
),
top_teams as (
    SELECT t.yearid,
        t.teamid,
        t.name,
        t.w,
        t.wswin
    FROM teams t
    INNER JOIN yearly_winners y ON t.yearid = y.yearid
								AND t.w = y.max_wins
)
SELECT COUNT(CASE WHEN wswin = 'Y' THEN 1 END) AS years_most_wins_won_ws,
    COUNT(DISTINCT yearid) AS total_years,
    ROUND(100.0 * COUNT(CASE WHEN wswin = 'Y' THEN 1 END) / COUNT(DISTINCT yearid), 2) AS percent_success
FROM top_teams;

--Q9
	--Managers that have won award in National and American League. Full name and team name. 
WITH tsn_awards AS (
    SELECT a.playerid,
        a.yearid,
        a.lgid,
        m.teamid
    FROM AwardsManagers a
    INNER JOIN Managers m ON a.playerid = m.playerid AND a.yearid = m.yearid
    WHERE a.awardid = 'TSN Manager of the Year'
),
dual_league_winners AS (
    SELECT playerid
    FROM tsn_awards
    GROUP BY playerid
    HAVING COUNT(DISTINCT lgid) = 2
)
SELECT namefirst,
	namelast,
    t.lgid AS league,
    t.yearid,
    t.teamid
FROM tsn_awards t
INNER JOIN dual_league_winners d ON t.playerid = d.playerid
INNER JOIN people p ON t.playerid = p.playerid
ORDER BY t.yearid;

--Q11
WITH team_salaries AS (
    SELECT yearid,
        teamid,
        SUM(salary) AS total_salary
    FROM salaries
    WHERE yearid >= 2000
    GROUP BY yearid, teamid
)
SELECT t.yearid,
    t.teamID,
    t.name AS team_name,
    t.w AS wins,
    s.total_salary
FROM teams t
INNER JOIN team_salaries s ON t.yearid = s.yearid AND t.teamid = s.teamid     
WHERE t.yearid >= 2000;
