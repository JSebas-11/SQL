#Empresas que nunca han realizado despidos: Encuentra empresas que nunca han realizado despidos a pesar de haber recaudado fondos significativos.
CREATE VIEW company_stats AS
	SELECT company, SUM(total_laid_off) AS Layoffs, SUM(percentage_laid_off) PercenLayoffs, SUM(funds_raised_millions) AS TotalFunds
	FROM layoffs_staging
    GROUP BY company;
    
SELECT * 
FROM company_stats
WHERE ((Layoffs = 0 OR Layoffs IS NULL) 
	AND (PercenLayoffs = 0 OR PercenLayoffs IS NULL)) 
    AND TotalFunds > 50
ORDER BY TotalFunds DESC;

/*Tendencia de despidos por tamaño de empresa: Clasifica las empresas por tamaño (según fondos recaudados) 
y analiza si las más grandes tienden a realizar más despidos.*/
WITH CTE1 AS
	(SELECT *,
		CASE 
			WHEN TotalFunds >= 10000 THEN "Huge"
			WHEN TotalFunds BETWEEN 1000 AND 9999 THEN "Big"
			WHEN TotalFunds BETWEEN 100 AND 999 THEN "Medium"
			WHEN TotalFunds BETWEEN 10 AND 99 THEN "Small"
			WHEN TotalFunds < 10 THEN "Tiny"
		END AS Size
	FROM company_stats
	WHERE Layoffs IS NOT NULL AND PercenLayoffs IS NOT NULL AND TotalFunds IS NOT NULL
	ORDER BY Layoffs DESC, PercenLayoffs DESC
	LIMIT 50)
SELECT Size, count(size) AS MostLayoffs
FROM CTE1
GROUP BY Size
ORDER BY 2 DESC;

/*Impacto de la localización en los despidos: Examina si existe una diferencia significativa
 en los despidos según la ubicación (por ejemplo, entre paises)*/
SELECT country, SUM(total_laid_off) Layoffs FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY 2 DESC;

#Empresas con crecimiento en despidos: Identifica empresas donde el total de despidos ha crecido constantemente.

/*Empresas que incrementaron sus fondos antes de realizar despidos: Identifica empresas que incrementaron significativamente sus fondos 
recaudados (más de 50%) justo antes de realizar despidos importantes (más del 20%).*/

/*Proyección de despidos futuros: Usa el porcentaje de despidos históricos y los fondos recaudados para predecir qué empresas podrían
realizar más despidos en el próximo año.*/

#Análisis de duración entre despidos: Calcula el tiempo promedio entre despidos dentro de una misma compañía.

#Distribución de porcentajes de despidos: Analiza cómo se distribuyen los porcentajes de despidos entre todas las empresas.