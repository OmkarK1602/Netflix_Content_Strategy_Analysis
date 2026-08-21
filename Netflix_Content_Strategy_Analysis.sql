-- ============================================================
-- Netflix Content Strategy Analysis Using SQL
-- Dataset: netflix_titles.csv (8807 rows)
-- ============================================================


-- ============================================================
-- 1. DATABASE AND TABLE SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS netflix_db;
USE netflix_db;


CREATE TABLE netflix_titles (
    show_id      VARCHAR(10) PRIMARY KEY,
    type         VARCHAR(20),
    title        VARCHAR(255),
    director     VARCHAR(255),
    cast_members TEXT,
    country      VARCHAR(255),
    date_added   DATE,
    release_year INT,
    rating       VARCHAR(20),
    duration     VARCHAR(50),
    listed_in    VARCHAR(255),
    description  TEXT
);

SELECT COUNT(*) FROM netflix_titles;


-- ============================================================
-- 2. DATA CLEANING
-- ============================================================

-- Fill missing director values
UPDATE netflix_titles
SET director = 'Not Specified'
WHERE director IS NULL OR TRIM(director) = '';

-- Fill missing country values
UPDATE netflix_titles
SET country = 'Not Specified'
WHERE country IS NULL OR TRIM(country) = '';

-- Check remaining nulls across key columns
SELECT
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_rating,
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS missing_duration,
    SUM(CASE WHEN date_added IS NULL THEN 1 ELSE 0 END) AS missing_date_added
FROM netflix_titles;


-- ============================================================
-- 15 BUSINESS PROBLEMS AND SOLUTIONS
-- ============================================================

-- 1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows

SELECT type, rating, total_titles
FROM (
    SELECT
        type,
        rating,
        COUNT(*) AS total_titles,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix_titles
    GROUP BY type, rating
) ranked
WHERE rnk = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT title, type, release_year
FROM netflix_titles
WHERE type = 'Movie' AND release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

SELECT country, COUNT(*) AS total_titles
FROM netflix_titles
WHERE country <> 'Not Specified'
GROUP BY country
ORDER BY total_titles DESC
LIMIT 5;

-- Note: the country field can hold multiple comma separated
-- countries per title (e.g. "United States, India"). For an
-- accurate per-country count each country needs to be split
-- out into its own row first:

SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1)) AS single_country,
    COUNT(*) AS total_titles
FROM netflix_titles
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) numbers
    ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) >= numbers.n - 1
WHERE country <> 'Not Specified'
GROUP BY single_country
ORDER BY total_titles DESC
LIMIT 5;


-- 5. Identify the longest movie

SELECT title, duration
FROM netflix_titles
WHERE type = 'Movie' AND duration LIKE '%min%'
ORDER BY CAST(REPLACE(duration, ' min', '') AS UNSIGNED) DESC
LIMIT 1;


-- 6. Find content added in the last 5 years

SELECT title, type, date_added
FROM netflix_titles
WHERE date_added >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
ORDER BY date_added DESC;


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT title, type, release_year
FROM netflix_titles
WHERE director LIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons

SELECT title, duration
FROM netflix_titles
WHERE type = 'TV Show'
  AND duration LIKE '%Season%'
  AND CAST(REPLACE(REPLACE(duration, ' Seasons', ''), ' Season', '') AS UNSIGNED) > 5
ORDER BY CAST(REPLACE(REPLACE(duration, ' Seasons', ''), ' Season', '') AS UNSIGNED) DESC;


-- 9. Count the number of content items in each genre

SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre,
    COUNT(*) AS total_titles
FROM netflix_titles
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3) numbers
    ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1
GROUP BY genre
ORDER BY total_titles DESC;


-- 10. Find each year and the average number of content releases in
-- India on Netflix, then return the top 5 years with the highest
-- average content release

SELECT
    release_year,
    COUNT(*) AS total_release,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles WHERE country LIKE '%India%'),
        2
    ) AS avg_release_percentage
FROM netflix_titles
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_release_percentage DESC
LIMIT 5;


-- 11. List all movies that are documentaries

SELECT title, release_year, listed_in
FROM netflix_titles
WHERE type = 'Movie' AND listed_in LIKE '%Documentaries%';


-- 12. Find all content without a director

SELECT title, type
FROM netflix_titles
WHERE director = 'Not Specified';


-- 13. Find how many movies actor 'Salman Khan' appeared in during
-- the last 10 years

SELECT COUNT(*) AS total_movies
FROM netflix_titles
WHERE cast_members LIKE '%Salman Khan%'
  AND type = 'Movie'
  AND release_year >= YEAR(CURDATE()) - 10;


-- 14. Find the top 10 actors who have appeared in the highest
-- number of movies produced in India

SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast_members, ',', numbers.n), ',', -1)) AS actor,
    COUNT(*) AS total_movies
FROM netflix_titles
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) numbers
    ON CHAR_LENGTH(cast_members) - CHAR_LENGTH(REPLACE(cast_members, ',', '')) >= numbers.n - 1
WHERE country LIKE '%India%'
  AND type = 'Movie'
  AND cast_members IS NOT NULL AND cast_members <> ''
GROUP BY actor
ORDER BY total_movies DESC
LIMIT 10;


-- 15. Categorize the content based on the presence of the keywords
-- 'kill' and 'violence' in the description field. Label content
-- containing these keywords as 'Bad' and all other content as
-- 'Good'. Count how many items fall into each category.

SELECT
    category,
    COUNT(*) AS total_titles
FROM (
    SELECT
        CASE
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%'
                THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_titles
) categorized
GROUP BY category;

-- 16. Find the top 5 years with the highest number of titles added to Netflix
 
SELECT
    YEAR(date_added) AS year_added,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY YEAR(date_added)
ORDER BY total_titles DESC
LIMIT 5;
 
 
-- 17. List all TV shows that do not have a director listed
 
SELECT title, release_year, country
FROM netflix_titles
WHERE type = 'TV Show'
  AND (director IS NULL OR director = '' OR director = 'Not Specified');
 
 
-- 18. Find how many movies longer than 150 minutes were released each year
 
SELECT
    release_year,
    COUNT(*) AS total_movies
FROM netflix_titles
WHERE type = 'Movie'
  AND duration LIKE '%min%'
  AND CAST(REPLACE(duration, ' min', '') AS UNSIGNED) > 150
GROUP BY release_year
ORDER BY release_year DESC;
 
 
-- 19. Find all content that was added to Netflix within the same year it was released
 
SELECT title, type, release_year, date_added
FROM netflix_titles
WHERE date_added IS NOT NULL
  AND YEAR(date_added) = release_year;
 
 
-- 20. Find the top 5 genres with the highest average movie duration
 
SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre,
    ROUND(AVG(CAST(REPLACE(duration, ' min', '') AS UNSIGNED)), 2) AS avg_duration
FROM netflix_titles
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3) numbers
    ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1
WHERE type = 'Movie' AND duration LIKE '%min%'
GROUP BY genre
ORDER BY avg_duration DESC
LIMIT 5;
 
 
-- 21. Find all countries where Netflix has added only Movies and no TV Shows
 
SELECT country, GROUP_CONCAT(DISTINCT type) AS content_types
FROM (
    SELECT
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1)) AS country,
        type
    FROM netflix_titles
    JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) numbers
        ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) >= numbers.n - 1
    WHERE country <> 'Not Specified'
) split_countries
GROUP BY country
HAVING content_types = 'Movie';
 
 
-- 22. Categorize movies as Short (under 90 min), Medium (90-150 min) or Long
-- (above 150 min), and count how many fall into each category
 
SELECT
    CASE
        WHEN CAST(REPLACE(duration, ' min', '') AS UNSIGNED) < 90 THEN 'Short'
        WHEN CAST(REPLACE(duration, ' min', '') AS UNSIGNED) BETWEEN 90 AND 150 THEN 'Medium'
        ELSE 'Long'
    END AS duration_category,
    COUNT(*) AS total_movies
FROM netflix_titles
WHERE type = 'Movie' AND duration LIKE '%min%'
GROUP BY duration_category;
 
 
-- 23. Find the director who has directed the highest number of TV Shows
 
SELECT director, COUNT(*) AS total_shows
FROM netflix_titles
WHERE type = 'TV Show'
  AND director <> 'Not Specified'
GROUP BY director
ORDER BY total_shows DESC
LIMIT 1;
 
 
-- 24. Find how many total seasons exist across all TV shows combined
 
SELECT
    SUM(CAST(REPLACE(REPLACE(duration, ' Seasons', ''), ' Season', '') AS UNSIGNED)) AS total_seasons
FROM netflix_titles
WHERE type = 'TV Show' AND duration LIKE '%Season%';
 
 
-- 25. Find the top 5 actors who have appeared in the highest number of TV Shows
 
SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast_members, ',', numbers.n), ',', -1)) AS actor,
    COUNT(*) AS total_shows
FROM netflix_titles
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) numbers
    ON CHAR_LENGTH(cast_members) - CHAR_LENGTH(REPLACE(cast_members, ',', '')) >= numbers.n - 1
WHERE type = 'TV Show'
  AND cast_members IS NOT NULL AND cast_members <> ''
GROUP BY actor
ORDER BY total_shows DESC
LIMIT 5;
 
 
-- 26. Find all content that took more than 5 years to be added to Netflix
-- after its original release
 
SELECT
    title,
    release_year,
    YEAR(date_added) AS year_added,
    YEAR(date_added) - release_year AS years_gap
FROM netflix_titles
WHERE date_added IS NOT NULL
  AND (YEAR(date_added) - release_year) > 5
ORDER BY years_gap DESC;
 
 
-- 27. Find the most frequently used genre combination in the listed_in column
 
SELECT listed_in, COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY listed_in
ORDER BY total_titles DESC
LIMIT 5;
 
 
-- 28. Find how many titles have the word 'family' mentioned in their description
 
SELECT COUNT(*) AS total_titles
FROM netflix_titles
WHERE LOWER(description) LIKE '%family%';
 
 
-- 29. Find the number of titles added to Netflix each month, regardless of year
 
SELECT
    MONTHNAME(date_added) AS month_added,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY MONTH(date_added), MONTHNAME(date_added)
ORDER BY total_titles DESC;
 
 
-- 30. Find all movies that are also listed as a TV Show with the exact same title
 
SELECT title, COUNT(DISTINCT type) AS content_types
FROM netflix_titles
GROUP BY title
HAVING content_types > 1;