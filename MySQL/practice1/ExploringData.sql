WITH CTE1 AS 
	(SELECT YEAR(date) AS Year, MONTH(date) AS month, SUM(total_laid_off) AS totalLayoffs
	FROM layoffs_staging
	WHERE YEAR(date) IS NOT NULL OR MONTH(date)
	GROUP BY YEAR(date), month
	ORDER BY Year ASC, month ASC),
    CTEAcum AS
	(SELECT *, SUM(totalLayoffs) OVER (ORDER BY Year, month ASC) AS AcumLayoffs
	FROM CTE1)
SELECT Year, CASE WHEN month = 01 THEN "January" WHEN month = 02 THEN "February" WHEN month = 03 THEN "March" WHEN month = 04 THEN "April" WHEN month = 05 THEN "May"
				WHEN month = 06 THEN "June" WHEN month = 07 THEN "July" WHEN month = 08 THEN "August" WHEN month = 09 THEN "September" WHEN month = 10 THEN "October"
				WHEN month = 11 THEN "November" WHEN month = 12 THEN "December"
	END AS month,
	totalLayoffs, AcumLayoffs
FROM CTEAcum;

WITH CTE2 AS
	(SELECT company, YEAR(date) AS yearr, SUM(total_laid_off) AS total_layoffs
	FROM layoffs_staging
	GROUP BY company, yearr),
    CTE2_ranks AS
	(SELECT *, ROW_NUMBER() OVER (PARTITION BY yearr ORDER BY total_layoffs DESC) AS rank_layoffs
	FROM CTE2)
SELECT * FROM CTE2_ranks
WHERE rank_layoffs <= 5;
    
   