---BONUS---

--1.a.First,write a query utilizing a correlated subquery to find the team with the most wins from each league in 2016.
SELECT lgid,teamid,w 
FROM teams t1
WHERE t1.w =(SELECT MAX(t2.w)
FROM teams t2
WHERE yearid=2016 
	AND t1.yearid=t2.yearid
	AND t1.lgid=t2.lgid);


--2.a. Write a query which, for each player in the player table, assembles their birthyear, birthmonth, and birthday
--into a single column called birthdate which is of the date type.

SELECT playerid, make_date(birthyear,birthmonth,birthday)AS birthday
FROM people;
--b.Use your previous result inside a subquery using LATERAL to 
--calculate for each player their age at debut and age at retirement.
SELECT DISTINCT p.playerid,
		FLOOR((p.debut::date-dob.birthday )/365.25) AS debut_age,
		FLOOR((p.finalgame::date-dob.birthday )/365.25) AS retirement_age
FROM people p,
LATERAL(
SELECT playerid, make_date(birthyear,birthmonth,birthday)AS birthday
FROM people) AS dob;


--c.Who is the youngest player to ever play in the major leagues?
SELECT DISTINCT p.playerid,
		FLOOR((p.debut::date-dob.birthday )/365.25) AS debut_age,
		FLOOR((p.finalgame::date-dob.birthday )/365.25) AS retirement_age
FROM people p,
LATERAL(
SELECT playerid, make_date(birthyear,birthmonth,birthday)AS birthday
FROM people) AS dob
WHERE p.finalgame is not null and p.debut is not null
ORDER BY debut_age ASC NULLS LAST
LIMIT 1;

--d. Who is the oldest player to player in the major leagues? 
--You'll likely have a lot of null values resulting in your age at retirement calculation
SELECT DISTINCT p.playerid,
		FLOOR((p.debut::date-dob.birthday )/365.25) AS debut_age,
		FLOOR((p.finalgame::date-dob.birthday )/365.25) AS retirement_age
FROM people p,
LATERAL(
SELECT playerid, make_date(birthyear,birthmonth,birthday)AS birthday
FROM people) AS dob
ORDER BY debut_age DESC NULLS LAST
LIMIT 1;

--3.
--a.Willie Mays holds the record of the most All Star Game starts with 18. 
--How many players started in an All Star Game with Willie Mays? 
--(A player started an All Star Game if they appear in the allstarfull table with a non-null startingpos value
SELECT DISTINCT a2.playerid
FROM allstarfull a1
JOIN allstarfull a2
  ON a1.yearid = a2.yearid
WHERE a1.playerid = (
        SELECT playerid
        FROM people
        WHERE namefirst = 'Willie'
          AND namelast  = 'Mays'
      )
  AND a1.startingpos IS NOT NULL
  AND a2.startingpos IS NOT NULL
  AND a2.playerid <> a1.playerid;
