-- CREATING TABLE 

CREATE TABLE Netflix 
	(
	show_id	VARCHAR (10),
	type VARCHAR (15),
	title VARCHAR (500),
	director VARCHAR (500),
	casts VARCHAR (1000),
	country	VARCHAR (1000),
	date_added DATE,
	release_year INT,
	rating VARCHAR (10),
	duration VARCHAR (30),
	listed_in VARCHAR (500),
	description VARCHAR (1000)
	);

SELECT * FROM netflix

-- Changing Column "date_added" to VARCHAR from data_type DATE
	
ALTER TABLE netflix
ALTER COLUMN date_added TYPE VARCHAR(20)
USING date_added::VARCHAR;

-- Updating Character Length in table

DROP TABLE IF EXISTS Netflix;
CREATE TABLE Netflix 
	(
	show_id	VARCHAR (10),
	type VARCHAR (15),
	title VARCHAR (500),
	director VARCHAR (500),
	casts VARCHAR (1000),
	country	VARCHAR (1000),
	date_added DATE,
	release_year INT,
	rating VARCHAR (10),
	duration VARCHAR (30),
	listed_in VARCHAR (500),
	description VARCHAR (1000)
	);

SELECT * FROM netflix

-- Verifying Data

SELECT COUNT (*) total_count 
	FROM netflix;

SELECT DISTINCT type 
FROM Netflix;

-- Business Problems & Analysis

/* Count of the Number of Movies vs TV Shows 
Objective: Determine the distribution of content types on Netflix */

SELECT type, COUNT (*)
FROM netflix
GROUP BY type;

/* Find the Most Common Rating for Movies and TV Shows
Objective: Identify the most frequently occurring rating for each type of content.*/


SELECT type, rating
FROM (SELECT type, 
	rating, 
	COUNT (*) rating_count,
	RANK() OVER (PARTITION BY type ORDER BY COUNT (*) DESC) Movie_Rank
FROM netflix
GROUP BY type, rating) sub
WHERE Movie_Rank = 1

/* List All Movies Released in a Specific Year (e.g., 2020)
Objective: Retrieve all movies released in a specific year. */

SELECT *
FROM netflix 
WHERE release_year = '2020'

/* Find the Top 5 Countries with the Most Content on Netflix
Objective: Identify the top 5 countries with the highest number of content items.
*/

SELECT *
FROM(
	SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
        COUNT(*) AS total_content,
		RANK () OVER (ORDER BY COUNT(*) DESC) country_rank
    FROM netflix
    GROUP BY 1) sub
WHERE country_rank BETWEEN 1 AND 5

/* Identify the Longest Movie 
Objective: Find the movie with the longest duration. */

SELECT title,
	duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;


/* Find Content Added in the Last 5 Years
Objective: Retrieve content added to Netflix in the last 5 years
*/

SELECT * 
FROM netflix
WHERE date_added >= CURRENT_DATE - INTERVAL '5 year';

/* Find All Movies/TV Shows by Director 'Rajiv Chilaka'
Objective: List all content directed by 'Rajiv Chilaka'.
*/

SELECT * 
FROM netflix 
WHERE director LIKE '%Rajiv Chilaka%'

SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';

/* List All TV Shows with More Than 5 Seasons
Objective: Identify TV shows with more than 5 seasons.
*/


SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;


/* Count the Number of Content Items in Each Genre
Objective: Count the number of content items in each genre.
*/

SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) genre, 
	COUNT (*) genre_count
FROM netflix
GROUP BY 1

/*Find each year and the average numbers of content release in India on netflix.
return top 5 year with highest avg content release
*/


SELECT 
	release_date,
	average
FROM( 
	SELECT *,
		RANK () OVER (ORDER BY average DESC) year_rank
	FROM (
		SELECT
			EXTRACT (Year FROM date_added) release_date,
			COUNT (*) movie_count,
			ROUND(COUNT (*)::numeric/(SELECT COUNT (*)
								FROM netflix 
								WHERE country = 'India')::numeric * 100, 0) average
		FROM netflix
		WHERE country = 'India'
		GROUP BY 1
		)sub
	)sub2
WHERE year_rank BETWEEN 1 AND 5
ORDER BY average DESC

/* List All Movies that are Documentaries
Objective: Retrieve all movies classified as documentaries.
*/

SELECT * 
FROM netflix
WHERE listed_in ILIKE '%Documentaries';

/* Find All Content Without a Director
Objective: List content that does not have a director.
*/

SELECT * 
FROM netflix
WHERE director IS NULL;

/* Find How Many Movies Has Actor 'Salman Khan' Appeared in the Last 10 Years
Objective: Count the number of movies featuring 'Salman Khan' in the last 10 years.
*/

SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%' 
	 AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

/* Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
Objective: Identify the top 10 actors with the most appearances in Indian-produced movies.
*/

SELECT casts AS actors,
	actors_count
FROM (
	SELECT TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) casts,
	COUNT (*) actors_count,
	RANK () OVER (ORDER BY COUNT (*) DESC) actors_rank
FROM (
		SELECT * 
		FROM netflix
		WHERE country = 'India'
	)sub
GROUP BY 1)sub2
WHERE actors_rank BETWEEN 1 AND 10

/* Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. 
Count the number of items in each category.
*/

SELECT movie_category,
	COUNT (*) category_count
FROM (SELECT *,
	CASE
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
	END AS movie_category
FROM netflix)sub
GROUP BY 1




















