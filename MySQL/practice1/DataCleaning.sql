#Proyecto DataCleaning

#1. Eliminar duplicados
	#Identificar duplicados
WITH DuplicatesCTE AS 
	(SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY company, country, location, industry, stage, funds_raised_millions, total_laid_off, percentage_laid_off, date) AS duplicates
	FROM layoffs),
    #Identificar compañias con duplicados 
    dupCompanies AS 
    (SELECT * FROM 
		(SELECT *,
		ROW_NUMBER() OVER (PARTITION BY company, country, location, industry, stage, funds_raised_millions, total_laid_off, percentage_laid_off, date) AS duplicates
		FROM layoffS
		WHERE company IN (SELECT company FROM DuplicatesCTE WHERE duplicates >=2)) sub 
        WHERE sub.duplicates >= 2)
SELECT * FROM dupCompanies;
	#Creamos tabla identica a original pero con columna de duplicados para ser borrados
CREATE TABLE layoffs_staging AS
(WITH DuplicatesCTE AS 
	(SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY company, country, location, industry, stage, funds_raised_millions, total_laid_off, percentage_laid_off, date) AS duplicates
	FROM layoffs)
SELECT * FROM DuplicatesCTE);
    #Eliminamos duplicados
DELETE FROM layoffs_staging WHERE duplicates >=2;

#2. Estandarizar tabla
	#Eliminar espacios en columna
UPDATE layoffs_staging SET company = TRIM(company);
	#Labels distintas pero de la misma industria
UPDATE layoffs_staging SET industry = 'Crypto' WHERE industry LIKE "%crypto%";
	#Labels distintas pero de mismo pais
UPDATE layoffs_staging SET country = TRIM(TRAILING '.' FROM country) WHERE country = 'United States.';
	#Actualizar columna de fecha con el formato adecuado
UPDATE layoffs_staging SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y");
	#Cambiamos tipo de dato de la columna date
ALTER TABLE layoffs_staging MODIFY COLUMN `date` DATE;

#3. Valores nulos y vacios en columnas 
	#Industry tiene valores en null y vacios
UPDATE layoffs_staging SET industry = NULL WHERE industry IS NULL OR industry = 'No identify';
	#Modificamos valores Nulls por los correspondientes a su industria segun la compañia y localizacion
UPDATE layoffs_staging t1
INNER JOIN layoffs_staging t2 
	ON t1.company = t2.company AND t1.location = t2.location
SET t1.industry = t2.industry WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;
	#Columnas sin match las definiremos como no identificadas
UPDATE layoffs_staging SET industry = 'No identify' WHERE industry IS NULL;

#4.Eliminar columnas y registros innecesarios
	#Registros sin informacion numerica
DELETE FROM layoffs_staging 
WHERE total_laid_off IS NULL 
	AND percentage_laid_off IS NULL 
    AND funds_raised_millions IS NULL;
    #Columna de duplicados
ALTER TABLE layoffs_staging DROP COLUMN duplicates;

#5.Tabla util con num de empleados
CREATE VIEW layoffs_emplo AS
	(SELECT *, ROUND((total_laid_off*1)/percentage_laid_off) AS total_employees
	FROM layoffs_staging
	WHERE percentage_laid_off IS NOT NULL AND total_laid_off IS NOT NULL
	ORDER BY percentage_laid_off DESC);
    
#Resultado final
SELECT * FROM layoffs_staging;
