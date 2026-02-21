USE College5;

SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;

---#Identify the player with the best batting average 
---#(total runs scored divided by the number of matches played) across all matches.

SELECT a.playerid,a.playername,SUM(b.runsscored) / COUNT(DISTINCT b.playerid) AS Batting_Average
FROM Perform b
JOIN players a on b.playerid = a.playerid
GROUP BY a.playerid, a.playername;

---#Find the team with the highest win percentage in matches played across all locations.
SELECT (count(a.winner)*100/(SELECT COUNT(*) FROM Matches)) as win_percentage,winner
FROM Matches a
GROUP BY a.winner;

SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;

---#Identify the player who contributed the highest percentage of their team's total runs in any single match.
SELECT a.playerid,a.playername,SUM(b.runsscored)*100/COUNT(DISTINCT b.matchid,2) as highest_conntributed
FROM Perform b
JOIN Players a on b.playerid = a.playerid
GROUP BY a.playerid;

SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;

---#Determine the most consistent player, defined 
---#as the one with the smallest standard deviation of runs scored across matches.
SELECT a.playerid,a.playername,stddev(b.runsscored) as stdv_score
FROM perform b
JOIN players a on b.playerid = a.playerid
GROUP BY playerid
ORDER BY stdv_score ASC;

SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;

---#Find all matches where the combined total of runs scored, wickets taken, and catches exceeded 500.
SELECT 
    b.matchid,
    SUM(b.runsscored) AS total_runs,
    SUM(b.wicketstaken) AS total_wicket,
    SUM(b.catches) AS total_cateches,
    (SUM(b.runsscored) + SUM(b.wicketstaken) + SUM(b.catches)) AS Total_contribute
FROM
    perform b
GROUP BY b.matchid
HAVING Total_contribute < 500;

SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;

---#Identify the player who has won the most "Player of the Match" awards 
---#(highest runs scored or wickets taken in a match). 
SELECT a.playerid,a.playername,COUNT(*) as Match_Award
FROM Players a
JOIN Perform b on a.playerid = b.playerid
WHERE b.runsscored = (SELECT MAX(runsscored) FROM Perform  WHERE matchid = b.matchid) 
or b.wicketstaken = (SELECT MAX(wicketstaken) FROM Perform  WHERE matchid = b.matchid)
GROUP BY b.playerid,a.playername
ORDER BY Match_Award DESC;

---#Determine the team that has the most diverse player roles in their squad.
SELECT playerid,playername,Role
FROM Players
WHERE Role = ("Wicket-Keeper") 
GROUP BY playerid;

SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;


----#Identify matches where the runs scored by both teams were unequal and 
---#sort them by the smallest difference in total runs between the two teams.
SELECT a.matchid,(MAX(b.runsscored) - MIN(b.runsscored)) as diffrence_runs
FROM Perform b
JOIN Matches a on b.matchid = a.matchid
GROUP BY a.matchid
ORDER BY diffrence_runs ASC;

SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;

---#Find players who contributed (batted, bowled, or fielded) in every match 
---#that their team participated in.
SELECT a.matchid,b.playerid,b.playername,b.role,c.batted,c.bowled,c.fielded
FROM Perform a
JOIN (
	SELECT matchid,playerid,SUM(runsscored) as batted,SUM(stumpings) as bowled,SUM(Catches) as fielded
    FROM Perform 
    GROUP BY matchid,playerid
) c on a.matchid = c.matchid
AND a.playerid = c.playerid
JOIN Players b ON a.playerid = b.playerid;
 


---#Identify the match with the closest margin of victory,
---#based on runs scored by both teams.
SELECT MatchID, 
       ABS(MAX(TotalRuns) - MIN(TotalRuns)) AS RunMargin
FROM (
    SELECT MatchID, Playerid, SUM(runsscored) AS TotalRuns
    FROM Perform
    GROUP BY MatchID, Playerid
) AS MatchRuns
GROUP BY MatchID
ORDER BY RunMargin ASC
LIMIT 1;



SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;


---#Calculate the total runs scored by each team across all matches.
SELECT c.matchid,SUM(b.runsscored) as total_runs
FROM perform b
JOIN matches c on b.matchid = c.matchid
GROUP BY b.matchid;

---#List matches where the total wickets taken by the winning team exceeded 2.
SELECT a.matchid,a.winner,SUM(b.wicketstaken) as total_wickets
FROM Matches a
JOIN Perform b on a.matchid = b.matchid
GROUP BY a.matchid
HAVING SUM(b.wicketstaken) > 2;

SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;

---#Retrieve the top 5 matches with the highest individual scores by any player.
SELECT b.matchid,a.playername,MAX(b.runsscored) as highest_score
FROM perform b
JOIN Players a on b.playerid = a.playerid
GROUP BY b.matchid,a.playername
ORDER BY highest_score DESC
LIMIT 5;

---#Identify all bowlers who have taken at least 5 wickets across all matches.
SELECT b.matchid,a.playerid,playername,role,sum(b.wicketstaken) as total_wicket
FROM perform b
JOIN players a on b.playerid = a.playerid
WHERE role = "bowler"
GROUP BY b.matchid,a.playerid,playername
HAVING total_wicket > 1;



---#Find the total number of catches taken by players from the team that won each match.
SELECT a.matchid,a.winner,b.playerid,b.playername,
SUM(c.catches) AS total_catches
FROM Perform c
JOIN Players b ON c.playerid = b.playerid
JOIN Matches a ON c.matchid = a.matchid
GROUP BY a.matchid,a.winner,b.playerid,b.playername;

----#Identify the player with the highest combined impact score in all matches.
----#The impact score is calculated as:
----#Runs scored × 1.5 + Wickets taken × 25 + Catches × 10 + Stumpings × 15 + Run outs × 10.
----#Only include players who participated in at least 3 matches.
SELECT COUNT(DISTINCT(b.matchid)) as patrticpate,a.playerid,a.playername,SUM(b.runsscores)*25,SUM(b.wicketstaken)*25,SUM(b.catches)*10,SUM(b.stumping)*15 as impacted_score
FROM perform b
JOIN players a on b.playerid = a.playerid
GROUP BY a.playerid,a.playername
HAVING patrticpate >= 3
ORDER BY impacted_runs DESC
LIMIT 1;

SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;

---#Find the match where the winning team had the narrowest margin of 
---#victory based on total runs scored by both teams.
---#If multiple matches have the same margin, list all of them.
SELECT c.matchid,c.winner,(MAX(b.runsscored) - MIN(b.runsscored)) as narrowest_margin 
FROM Perform b
JOIN matches c on b.matchid = c.matchid
GROUP BY c.matchid,c.winner;    

---#List all players who have outperformed their teammates in terms of total runs scored in 
---#more than half the matches they played.
---#This requires finding matches where a player scored the most runs among their 
---#teammates and calculating the percentage.


SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;

----#Rank players by their average impact per match, considering only those who played at least three matches.
----#The impact is calculated as:
---#Runs scored × 1.5 + Wickets taken × 25 + Catches × 10 + Stumpings × 15 + Run outs × 10.
---#Players with the same average impact should share the same rank.
SELECT COUNT(DISTINCT b.matchid) as match_played,a.playerid,a.playername,(SUM(b.runsscored)*1.5 + SUM(b.wicketstaken)*25 + SUM(b.catches)*10 + SUM(b.stumpings)*15 + SUM(b.runouts)*10) as impact_score,
RANK()OVER(ORDER BY (SUM(b.runsscored)*1.5 + SUM(b.wicketstaken)*25 + SUM(b.catches)*10 + SUM(Stumpings)*15 + SUM(b.runouts)*10) DESC) AS "RANK"
FROM Perform b 
JOIN Players a on b.playerid = a.playerid
GROUP BY a.playerid,a.playername
HAVING match_played >= 1;

---#Identify the top 3 matches with the highest cumulative total runs scored by both teams.
---#Rank the matches based on total runs using window functions. If multiple matches have the same total runs, they should share the same rank.
SELECT matchid,SUM(b.runsscored) as total_runs,
RANK()OVER(ORDER BY SUM(b.runsscored) DESC) AS "RANK"
FROM Perform b
GROUP BY matchid
ORDER BY "RANK" DESC
LIMIT 5;

SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Perform;
SELECT * FROM Teams;

----#For each player, calculate their running cumulative impact score across all matches they’ve played,
----#ordered by match date.
----#Include only players who have played in at least 3 matches.
SELECT c.matchid,c.matchdate,b.playerid,a.playername,SUM(b.runsscored) as Imapcat_Score,
RANK()OVER(ORDER BY SUM(runsscored) DESC) AS player_rank
FROM players a
JOIN Perform b on a.playerid = b.playerid
JOIN Matches c on b.matchid = c.matchid
GROUP BY b.playerid,a.playername,c.matchid
ORDER BY player_rank,c.matchid DESC;






















