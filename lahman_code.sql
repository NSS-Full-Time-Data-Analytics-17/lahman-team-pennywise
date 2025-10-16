--8. Using the attendance figures from the homegames table,
--find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games)
-- Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
SELECT 
parks.park_name, 
teams.name,
(SUM(homegames.attendance)/SUM(homegames.games)) as average_attendance

FROM homegames 
JOIN parks 
USING(park) 
JOIN teams 
  ON teams.teamid = homegames.team
 AND teams.yearid = homegames.year  
WHERE homegames.year=2016
GROUP BY parks.park_name,teams.name
HAVING SUM(homegames.games)>=10
ORDER BY average_attendance DESC
LIMIT 5;


SELECT --lowest 5 average attendance
parks.park_name, 
teams.name,
(SUM(homegames.attendance)/SUM(homegames.games)) as average_attendance

FROM homegames 
JOIN parks 
USING(park) 
JOIN teams 
  ON teams.teamid = homegames.team
 AND teams.yearid = homegames.year  
WHERE homegames.year=2016
GROUP BY parks.park_name,teams.name
HAVING SUM(homegames.games)>=10
ORDER BY average_attendance ASC
LIMIT 5;


--10. Find all players who hit their career highest number of home runs in 2016.
--Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.

--MASTER - Player names, DOB, and biographical info
--Batting - batting statistics
--Pitching - pitching statistics
--Fielding - fielding statistics

SELECT * FROM people;
SELECT * FROM teams;
SELECT * FROM pitching;
SELECT * FROM appearances;
SELECT * FROM pitchingpost;
SELECT * FROM battingpost;
SELECT * FROM batting;
SELECT * FROM awardsplayers;
SELECT * FROM allstarfull;
SELECT * FROM fieldingpost;
SELECT * FROM collegeplaying;


--10. Find all players who hit their career highest number of home runs in 2016.
--Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.

SELECT 
p.namefirst,
p.namelast,
SUM(batting.hr) as homeruns_2016
FROM people as p
JOIN batting
USING (playerid)
--contains players 
JOIN(SELECT batting.playerid FROM batting 
GROUP BY playerid							--one row per player per season 
HAVING COUNT(DISTINCT yearid)>=10) 
as league_years
ON league_years.playerid=batting.playerid
--Find all players who hit their career highest number of home runs in 2016.


WHERE batting.yearid=2016
GROUP BY p.namefirst, p.namelast,batting.playerid
HAVING SUM(batting.hr)>0
ORDER BY homeruns_2016 DESC,p.namefirst,p.namelast
;







--3. Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

--Joining collegeplaying,people,salaries

SELECT p.namefirst,p.namelast,

SUM(salary) as total_salary
FROM people as p

JOIN collegeplaying
USING(playerid)

JOIN salaries
ON salaries.playerid=p.playerid

JOIN schools
ON schools.schoolid=collegeplaying.schoolid

WHERE schools.schoolname ILIKE'Vanderbilt University'
GROUP BY p.namefirst,p.namelast
ORDER BY total_salary DESC
LIMIT 1;

--2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT
namefirst,namelast,MIN(height) as lowest_height,people.playerid,teams.name,batting.g as total_games

FROM people
JOIN batting
USING(playerid)
JOIN teams
ON batting.teamid=teams.teamid
GROUP BY namefirst,namelast,people.playerid,teams.name,batting.g 
ORDER BY MIN(weight) ASC
LIMIT 1;

--1. What range of years for baseball games played does the provided database cover? 
SELECT * FROM batting;

