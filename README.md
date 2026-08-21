# 📺 Netflix Content Strategy Analysis (SQL)

A SQL-based exploratory analysis of Netflix's content catalog, covering ~8,800 movies and TV shows. The project cleans the raw dataset, loads it into a relational table, and answers 30 real-world business questions about Netflix's content strategy — genre trends, country-wise output, ratings, cast/director patterns, and content-addition timelines.

## 📂 Repository Contents

| File | Description |
|---|---|
| `Netflix_Content_Strategy_Analysis_F.sql` | Main SQL script — table setup, data cleaning, and 30 business-problem queries |
| `netflix_titles.csv` | Source dataset (8,807 titles) used to populate the table |

## 🗂️ Dataset

The dataset (`netflix_titles.csv`) contains one row per title with the following fields:

`show_id`, `type`, `title`, `director`, `cast`, `country`, `date_added`, `release_year`, `rating`, `duration`, `listed_in` (genres), `description`

## 🛠️ Tech Stack

- **SQL (MySQL syntax)** — table creation, data cleaning, window functions, string splitting, aggregation

## 🚀 How to Run

1. Create the database and table, and load `netflix_titles.csv` into `netflix_titles` (e.g. via MySQL Workbench's **Table Data Import Wizard**, or `LOAD DATA INFILE`).
2. Run `Netflix_Content_Strategy_Analysis_F.sql` top to bottom — it will:
   - Create the `netflix_db` database and `netflix_titles` table
   - Clean missing `director` and `country` values
   - Run 30 analytical queries against the data

```sql
CREATE DATABASE IF NOT EXISTS netflix_db;
USE netflix_db;
-- then import netflix_titles.csv into the netflix_titles table
-- then run the rest of Netflix_Content_Strategy_Analysis_F.sql
```

## 🔍 Business Questions Answered

The script walks through 30 questions, including:

1. Count of Movies vs. TV Shows
2. Most common rating per content type
3. Movies released in a specific year
4. Top 5 countries by content volume (with proper handling of multi-country rows)
5. The longest movie on the platform
6. Content added in the last 5 years
7. All titles by a specific director
8. TV shows with more than 5 seasons
9. Content count by genre
10. Years with the highest average content releases in India
11. All documentary movies
12. Titles missing a director
13. Movie appearances by a specific actor in the last 10 years
14. Top 10 actors in movies produced in India
15. Content categorized as "Good" / "Bad" based on description keywords
16. Top 5 years by number of titles added
17. TV shows with no director listed
18. Movies over 150 minutes, by release year
19. Titles added in the same year they were released
20. Top 5 genres by average movie duration
21. Countries where Netflix has added Movies but no TV Shows
22. Movie duration buckets: Short / Medium / Long
23. Director with the most TV Shows
24. Total TV show seasons across the catalog
25. Top 5 actors by TV Show appearances
26. Titles that took more than 5 years to reach Netflix after release
27. Most frequently used genre combinations
28. Titles mentioning "family" in their description
29. Titles added per calendar month, across all years
30. Titles that exist as both a Movie and a TV Show under the same name

## 💡 Key Techniques Used

- **Data cleaning**: handling `NULL`/blank values in `director` and `country`
- **String splitting**: exploding comma-separated `country`, `listed_in`, and `cast` fields into individual rows using a numbers-table join
- **Window functions**: `RANK() OVER (PARTITION BY ...)` to find top ratings per content type
- **Date functions**: `YEAR()`, `MONTHNAME()`, `DATE_SUB()` for time-based trend analysis
- **Conditional aggregation**: `CASE WHEN` for categorizing content (duration buckets, keyword-based labeling)

## 📌 Notes

- SQL is written for **MySQL** syntax (`SUBSTRING_INDEX`, `GROUP_CONCAT`, etc.).
- Some queries (e.g., "content added in the last 5 years") are relative to the date the query is run.

---

*Feel free to fork this repo and extend it — e.g., visualize the results in Tableau/Power BI, or port the queries to PostgreSQL/BigQuery.*
