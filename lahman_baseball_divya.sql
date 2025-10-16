--1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(year) AS first_year,
	   Max(year) AS last_year
FROM homegames;
--(1871-2016)-

--2. Find the name and height of the shortest player in the database. 
SELECT playerid,namefirst,namelast,namegiven,height FROM people
WHERE height = (SELECT MIN(height) FROM people);

--How many games did he play in? What is the name of the team for which he played?
SELECT DISTINCT playerid,
		namefirst,
		namelast,
		namegiven,g_all AS games_played,
		teamid,
		teams.name AS team_name
FROM people  
INNER JOIN appearances
	USING (playerid)
INNER JOIN teams 
	USING(teamid)
WHERE height =(SELECT MIN(height) FROM people);

--3. Find all players in the database who played at Vanderbilt University.  
SELECT playerid,
		namefirst,
		namelast,
		schoolname 
FROM people 
INNER JOIN collegeplaying
	USING(playerid)
INNER JOIN schools
	USING(schoolid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY playerid,namefirst,namelast,schoolname;

--Create  list showing each player’s first and last names as well as the total salary they earned in major leagues.
--Sort this list in descending order by total salary.Which Vanderbilt player earned the most money in the majors?
SELECT 
		namefirst,
		namelast,            
		SUM(salary) AS total_salary
FROM schools
INNER JOIN collegeplaying
	USING(schoolid)
INNER JOIN people
	USING(playerid)         
LEFT JOIN salaries
	USING(playerid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY namefirst,namelast
ORDER BY total_salary DESC NULLS LAST;
-- playerid : priceda01 --

--4.Using the fielding table, group players into three groups based on their position: 
--label players with position OF as "Outfield", 
--those with position "SS", "1B", "2B", and "3B" as "Infield", 
--and those with position "P" or "C" as "Battery". 
SELECT *,
		CASE WHEN pos = 'OF' THEN 'Outfield'
			 WHEN pos IN ('SS','1B', '2B', '3B') THEN 'Infield'
			 WHEN pos IN ('P','C') THEN 'Battery' 
			 ELSE 'None' END AS position_type 			  
FROM fielding;

--Determine the number of putouts made by each of these three groups in 2016.
SELECT CASE WHEN pos = 'OF' THEN 'Outfield'
			WHEN pos IN ('SS','1B', '2B', '3B') THEN 'Infield'
			WHEN pos IN ('P','C') THEN 'Battery' 
			ELSE 'None' END AS position_type, SUM(po) AS putouts_2016		  
FROM fielding
WHERE yearid = 2016
GROUP BY position_type;

--5.Find the average number of strikeouts per game by decade since 1920. 
--Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT 
    (yearid / 10) * 10 AS decade,
    ROUND(SUM(so::decimal) / SUM(g), 2) AS avg_so_game,
    ROUND(SUM(hr::decimal) / SUM(g), 2) AS avg_hr_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

--6. Find the player who had the most success stealing bases in 2016, 
--where __success__ is measured as the percentage of stolen base attempts which are successful. 
--(A stolen base attempt results either in a stolen base or being caught stealing.) 
--Consider only players who attempted _at least_ 20 stolen bases
SELECT playerid, namefirst, namelast,
		SUM(sb) AS total_sb,
		SUM(cs) AS total_cs,
		CASE 
		WHEN SUM(SB) +SUM(CS) <> 0 THEN ROUND((SUM(SB)::DECIMAL)/(SUM(SB) + SUM(CS))*100, 2)
    	ELSE 0 END AS success_percent
FROM batting
LEFT JOIN people
USING(playerid)
WHERE yearid=2016 	
GROUP BY playerid,namefirst,namelast
	HAVING SUM(sb)+SUM(cs) >= 20
ORDER BY success_percent DESC
LIMIT 1;
--owingch01, Chris Owings, 91.30

--7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
SELECT teams.name,MAX(w)
FROM teams 
WHERE yearid BETWEEN 1970 AND 2016
	  AND wswin ='N'
GROUP BY teams.name
ORDER BY MAX(w) DESC;

--What is the smallest number of wins for a team that did win the world series? 
SELECT teams.name,MIN(w)
FROM teams 
WHERE yearid BETWEEN 1970 AND 2016
	  AND wswin ='Y'
GROUP BY teams.name
ORDER BY MIN(w) ASC;

--Doing this will probably result an unusually small number of wins for a world series champion–determine why this is the case. 
SELECT * 
FROM teams
WHERE (yearid BETWEEN 1970 AND 2016) AND wswin ='Y' AND teamid='LAN';

--Then redo your query, excluding the problem year.
SELECT teams.name, MIN(w) FROM teams
WHERE yearid <> 1981 
	  AND yearid BETWEEN 1970 AND 2016
	  AND wswin ='Y'
GROUP BY teams.name
ORDER BY MIN(w) ASC;

--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
--What percentage of the time?
WITH maxwins AS (
    SELECT 
        yearid, 
        MAX(w) AS max_w
    FROM teams 
    WHERE yearid BETWEEN 1970 AND 2016
      AND yearid <> 1981
    GROUP BY yearid
)
SELECT 
    SUM(ws_win) AS count_ws_wins,
    COUNT(*) AS count_wins,
    ROUND((SUM(ws_win)::DECIMAL / COUNT(*)) * 100, 2) AS percent_ws_wins
FROM 
(SELECT m.yearid,
         MAX(CASE WHEN t.wswin='Y' THEN 1 ELSE 0 END) AS ws_win
FROM teams t
INNER JOIN maxwins m
	ON t.yearid=m.yearid AND t.w=m.max_w
	GROUP BY m.yearid) AS table_ws
   
--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
--(where average attendance is defined as total attendance divided by number of games). 
--Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. 
SELECT teams.name AS team_name,park_name,ROUND((SUM(h.attendance)/SUM(h.games::DECIMAL)),2) AS avg_att
FROM homegames h
INNER JOIN teams
	ON team=teamid
INNER JOIN parks
	ON h.park=parks.park
WHERE year = 2016 AND games<>0 
AND h.park IN(SELECT park 
			FROM homegames
			GROUP BY park
			HAVING SUM(games)>=10)           
GROUP BY teams.name,park_name
ORDER BY avg_att DESC
LIMIT 5;
--Repeat for the lowest 5 average attendance.
SELECT teams.name AS team_name,park_name,ROUND((SUM(h.attendance)/SUM(h.games::DECIMAL)),2) AS avg_att
FROM homegames h
INNER JOIN teams
	ON team=teamid
INNER JOIN parks
	ON h.park=parks.park
WHERE year = 2016 AND games<>0 
AND h.park IN(SELECT park 
			FROM homegames
			GROUP BY park
			HAVING SUM(games)>=10)           
GROUP BY teams.name,park_name
ORDER BY avg_att ASC
LIMIT 5;
--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.
SELECT playerid,namefirst,namelast,
				t.name AS team_name,a.yearid,a.lgid
FROM awardsmanagers AS a
INNER JOIN managers AS m USING(playerid,yearid)
INNER JOIN people AS p USING(playerid)
INNER JOIN teams AS t USING(teamid,yearid)
WHERE awardid='TSN Manager of the Year'
	  AND 
	  a.playerid IN (select playerid
	  				FROM awardsmanagers 
					WHERE awardid ='TSN Manager of the Year' 
						  AND lgid='NL' 
					INTERSECT 
					select playerid
	  				FROM awardsmanagers 
					WHERE awardid ='TSN Manager of the Year' 
						  AND lgid='AL');						

--10. Find all players who hit their career highest number of home runs in 2016. 
SELECT 
	playerid,
	hr
FROM batting b
WHERE yearid = 2016 
	  AND hr =( SELECT MAX(hr)
			    FROM batting
			    WHERE playerid=b.playerid );			

--Consider only players who have played in league for atleast 10 years, and who hit atleast one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.
WITH player_hr AS
(
SELECT 
	b.playerid,
	p.namefirst,
	p.namelast,
	b.hr,
	FLOOR((finalgame::DATE-debut::DATE)/365.25) AS years_played
FROM batting b
LEFT JOIN people p
	ON b.playerid=p.playerid
WHERE yearid = 2016 
	  AND hr>=1
	  AND hr =( SELECT MAX(hr)
			    FROM batting
			    WHERE playerid=b.playerid )			
)
SELECT * from player_hr
WHERE years_played>=10 ;

--11. Is there any correlation between number of wins and team salary? 
----Use data from 2000 and later to answer this question.
--As you do this analysis, keep in mind that salaries across the whole league tend to increase together, 
--so you may want to look on a year-by-year basis
WITH teamsalaries AS 
(SELECT t.yearid, t.teamid, t.w, SUM(s.salary) AS total_salary
  FROM teams t
  JOIN salaries s
    ON t.teamid = s.teamid AND t.yearid = s.yearid
  WHERE t.yearid >= 2000
  GROUP BY t.yearid, t.teamid, t.w
  ORDER BY yearid) 
SELECT 
    yearid,
    corr(w, total_salary) AS co_salary
FROM teamsalaries
GROUP BY yearid
ORDER BY yearid;
--correlation is positive every year,with drop during 2007-2008,2011-2012

--12. In this question, you will explore the connection between number of wins and attendance.
--<ol type="a">
-- <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
SELECT CORR(attendance,w) AS wins_attendance
FROM teams

-- <li>Do teams that win the world series see a boost in attendance the following year? 
SELECT t1.teamid,t1.yearid,
	   t1.wswin,t1.attendance,
	   t2.yearid AS year_next,
	   t2.attendance AS attendance_next,
	   (t2.attendance -t1.attendance) AS boost_attendance
FROM teams t1
JOIN teams t2
ON t1.teamid=t2.teamid
   AND t1.yearid=t2.yearid-1
WHERE t1.wswin='Y'
	AND t1.attendance IS NOT NULL
	AND t2.attendance IS NOT NULL;
	
--What about teams that made the playoffs? 
--Making the playoffs means either being a division winner or a wild card winner.</li>
-- </ol>
SELECT t1.teamid,t1.yearid,
	   t1.wcwin,t1.divwin,t1.attendance,
	   t2.yearid AS year_next,
	   t2.attendance AS attendance_next,
	   (t2.attendance -t1.attendance) AS boost_attendance
FROM teams t1
JOIN teams t2
ON t1.teamid=t2.teamid
   AND t1.yearid=t2.yearid-1
WHERE t1.wcwin='Y' OR t1.divwin='Y'
	AND t1.attendance IS NOT NULL
	AND t2.attendance IS NOT NULL;

--13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective.
--Investigate this claim and present evidence to either support or dispute this claim. 
--First, determine just how rare left-handed pitchers are compared with right-handed pitchers. 
SELECT *,
		ROUND((left_pitchers::DECIMAL/(left_pitchers+right_pitchers))*100,2) AS leftpitchers_percent
FROM (SELECT
		COUNT(CASE WHEN throws='L' THEN 'left' END) AS left_pitchers,
		COUNT(CASE WHEN throws='R' THEN 'right' END) AS right_pitchers
FROM people) AS pitcher_hand;

--Are left-handed pitchers more likely to win the Cy Young Award? 
SELECT *,
		ROUND((left_pitchers::DECIMAL/(left_pitchers+right_pitchers))*100,2) AS leftpitchers_cyyoung_percent
FROM (SELECT
		COUNT(CASE WHEN awardid='Cy Young Award' AND throws='L' THEN 'left' END) AS left_pitchers,
		COUNT(CASE WHEN awardid='Cy Young Award' AND throws='R' THEN 'right' END) AS right_pitchers
FROM people
INNER JOIN awardsplayers
	USING(playerid)
	);
		
--Are they more likely to make it into the hall of fame?
WITH pitchers_halloffame AS
(
SELECT 
	COUNT(CASE WHEN throws='L' THEN 'left' END) AS left_pitchers,
	COUNT(CASE WHEN throws='R' THEN 'right' END) AS right_pitchers
from people 
WHERE playerid IN (SELECT DISTINCT playerid FROM halloffame)
)
SELECT *,
		ROUND((left_pitchers::DECIMAL/(left_pitchers+right_pitchers))*100,2) AS left_halloffame_percent
FROM  pitchers_halloffame;


