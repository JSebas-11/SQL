#Calcula el total, promedio y la mediana del total de despidos por industria. 
SELECT ls.industry, SUM(ls.total_laid_off) total, m.Median AS median, ROUND(AVG(ls.total_laid_off), 1) AS average
FROM layoffs_staging ls
INNER JOIN 
	(WITH CTE1 AS
		(SELECT industry, total_laid_off,
			ROW_NUMBER() OVER (PARTITION BY industry ORDER BY total_laid_off) AS row_num,
			COUNT(*) OVER (PARTITION BY industry) AS total_rows
		FROM layoffs_staging
		WHERE total_laid_off IS NOT NULL),
		CTEMedians AS
		(SELECT industry, total_laid_off
		FROM CTE1
		WHERE row_num IN (FLOOR((total_rows + 1) / 2), FLOOR((total_rows + 2) / 2)))
	SELECT industry, FLOOR(AVG(total_laid_off)) AS Median
	FROM CTEMedians
	GROUP BY industry) m 
ON ls.industry = m.industry
GROUP BY ls.industry
ORDER BY industry;

#Analiza cómo han cambiado los despidos por país a lo largo del tiempo. Usa una ventana de tiempo de 6 meses.
WITH CTE2 AS
	(SELECT country, YEAR(date) AS year_num, MONTH(date) AS month_num, SUM(total_laid_off) AS layoffs
	FROM layoffs_staging
	GROUP BY country, year_num, month_num HAVING layoffs IS NOT NULL
	ORDER BY 1 ASC, 2 ASC, 3 ASC)
SELECT country, SUM(layoffs) AS total6months
FROM CTE2
GROUP BY country, year_num, month_num BETWEEN 1 AND 6 OR month_num BETWEEN 7 AND 12;

SELECT country, date, SUM(total_laid_off) AS total6months
FROM layoffs_staging
WHERE date - INTERVAL 6 MONTH
GROUP BY country, date HAVING total6months IS NOT NULL
ORDER BY country ASC, date ASC;


/*Filtra las empresas donde el total de despidos parece inconsistente con los fondos recaudados. Aquellas donde 
el porcentaje de despidos es mayor al 50% pero la compañía ha recaudado más de 100 millones*/
SELECT company, country, location, industry, total_laid_off, percentage_laid_off, funds_raised_millions
FROM layoffs_staging
WHERE percentage_laid_off > .50 AND funds_raised_millions > 100
ORDER BY company ASC, percentage_laid_off DESC;

/*Encuentra los registros donde los valores de fondos recaudados o porcentaje de despidos parezcan sospechosos, 
como valores negativos o extremadamente altos*/
SELECT *
FROM layoffs_staging
WHERE (funds_raised_millions <= 0 AND percentage_laid_off <= .5) 
	OR (funds_raised_millions > 150 AND percentage_laid_off > .55)
    OR (total_laid_off <= 10 AND funds_raised_millions <= 1);

#Identifica cómo ha cambiado la industria más afectada por despidos en los ultimos 12 meses registrados.
SELECT industry, YEAR(date) AS yearr, Month(DATE) AS monthh, SUM(total_laid_off) AS layoffs 
FROM layoffs_staging
WHERE industry = (SELECT industry FROM 
									(SELECT industry, SUM(total_laid_off) FROM layoffs_staging 
									GROUP BY industry ORDER BY 2 DESC
									LIMIT 1) most_layoffs)
GROUP BY industry, yearr, monthh HAVING layoffs IS NOT NULL
ORDER BY yearr DESC, monthh DESC
LIMIT 12;

#Realiza un análisis de correlación entre los fondos recaudados y el porcentaje de despidos por industria.
WITH funds_perCTE AS 
	(SELECT industry, SUM(funds_raised_millions) AS total_funds, ROUND(SUM(percentage_laid_off), 5) AS layoffs_percentage, 
		ROUND(AVG(funds_raised_millions), 5) AS funds_avg, ROUND(AVG(percentage_laid_off), 5) AS layoffs_avg
	FROM layoffs_staging
	GROUP BY industry)
SELECT industry, SUM((total_funds - funds_avg) * (layoffs_percentage - layoffs_avg)) /
				SQRT((SUM(POW((total_funds - funds_avg), 2)) * SUM(POW((layoffs_percentage - layoffs_avg), 2)))) AS corr
FROM funds_perCTE
GROUP BY industry;

#Calcula el ratio entre el total de despidos y los fondos recaudados para cada empresa y clasifícalas en orden descendente.
WITH CTE3 AS 
	(SELECT company, SUM(total_laid_off) total_layoffs, SUM(funds_raised_millions) AS total_raised
	FROM layoffs_staging
	WHERE total_laid_off IS NOT NULL AND funds_raised_millions IS NOT NULL 
	GROUP BY company)
SELECT *, ROUND(total_layoffs/total_raised, 2) AS layoffsPerMillion
FROM CTE3
GROUP BY company
ORDER BY 4 DESC;
