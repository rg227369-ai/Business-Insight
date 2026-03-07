-- SCHEMAS of Netflix

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);


SELECT * FROM netflix;
----------------------------------------------------------------------
---#Count the number of Movies vs TV Shows
SELECT type,COUNT(*) as TV_MOVIE_SHOW_COUNT
FROM netflix
GROUP BY Type;
---------------------------------------------------------------------
---#Find the most common rating for movies and TV shows
DROP TABLE IF EXISTS rank_rate;
CREATE TABLE rank_rate as SELECT type,rating,COUNT(*) as rating_count
FROM netflix
GROUP BY type,rating;

DROP TABLE IF EXISTS rate;
CREATE TABLE rate as SELECT type,rating,rating_count,RANK()OVER(PARTITION BY type ORDER BY rating_count DESC) as Rank
FROM rank_rate
GROUP BY type,rating,rating_count
ORDER BY rating,rating_count DESC;

SELECT type,rating as most_frquent_rating,rating_count,Rank
FROM rate
WHERE rank = 1;
------------------------------------------------------------------------
SELECT * FROM netflix;
---#List all movies released in a specific year (e.g., 2020)
SELECT *
FROM netflix
WHERE type = 'Movie' and release_year = 2020;
-----------------------------------------------------------------------
DROP TABLE IF EXISTS totali;
---#Find the top 5 countries with the most content on Netflix
SELECT trim(unnest(string_to_array(country, ','))) as country_name,count(*) as total_content_consume
FROM netflix
WHERE Country is NOT NULL
GROUP BY country_name
ORDER BY total_content_consume DESC
LIMIT 5;

SELECT * FROM netflix;
------------------------------------------------------------------------
---#Identify the longest movie
SELECT type,title as movie_name,duration
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INT) DESC
limit 1;

---------------------------------------------------------------------
---#Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

----------------------------------------------------------------------
DROP TABLE IF EXISTS ly;
---#Find all the movies/TV shows by director 'Rajiv Chilaka'!
CREATE TABLE ly as SELECT *,trim(unnest(string_to_array(director, ','))) as director_name
FROM netflix
WHERE director IS NOT NULL;

SELECT *
FROM ly
WHERE director_name ILIKE '%Rajiv Chilaka%';

-----------------------------------------------------------------
SELECT * FROM netflix;

---#List all TV shows with more than 5 seasons

SELECT type, duration
FROM netflix
WHERE type = 'TV Show'
AND CAST(SPLIT_PART(duration,' ',1) AS INT) > 5
ORDER BY CAST(SPLIT_PART(duration,' ',1) AS INT) DESC;

-----------------------------------------------------------------

---Count the number of content items in each genre
SELECT trim(unnest(string_to_array(listed_in, ','))) as genre,COUNT(*) as total_content
FROM netflix
GROUP BY genre
ORDER BY total_content DESC;

SELECT * FROM netflix;

---Find each year and the average numbers of content release in India on netflix. 
---return top 5 year with highest avg content release!



SELECT * FROM netflix;
---List all movies that are documentaries
SELECT count(*) as total_documentaries_count
FROM (SELECT type,trim(unnest(string_to_array(listed_in, ','))) as genre from netflix) as t
WHERE type = 'Movie' AND genre ILIKE '%Documentaries%';

----#Find all content without a director
SELECT director,COUNT(*) as Total_content
FROM netflix
GROUP BY director
ORDER BY Total_content DESC;

---Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT  *
FROM netflix
WHERE type = 'Movie' and 
casts ILIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM current_date) - 10;

SELECT * FROM netflix;
---Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT trim(unnest(string_to_array(casts, ','))) as actor , COUNT(*) as total_number
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY total_number DESC
LIMIT 10;








DELETE FROM netflix
WHERE country is null;






---------------------------------------------------------------------------
DELETE FROM netflix
where director is null;



SELECT COUNT(*) as null_count
FROM netflix
WHERE director is null;

DELETE FROM netflix
WHERE duration is null;


SELECT COUNT(*) as null_count
FROM netflix
WHERE country IS null;

DELETE FROM netflix
WHERE country is Null;

