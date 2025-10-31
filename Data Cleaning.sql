-- Data Cleaning
-- 1. Remove duplicates
-- 2. Standardize the data
-- 3. Null values or blank values
-- 4. Remove any columns or rows

-- 1. Remove duplicates
SELECT *
FROM layoffs;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_updated` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_updated
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs;

DELETE
FROM layoffs_updated
WHERE row_num > 1;

-- 2. Standardize the data
SELECT company, TRIM(company)
FROM layoffs_updated;

UPDATE layoffs_updated
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_updated
ORDER BY 1;

SELECT *
FROM layoffs_updated
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_updated
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_updated
ORDER BY 1;

SELECT *
FROM layoffs_updated
WHERE country LIKE 'United States%'
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_updated
ORDER BY 1;

UPDATE layoffs_updated
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_updated;

UPDATE layoffs_updated
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_updated
MODIFY COLUMN `date` DATE;

-- 3. Null values or blank values
SELECT *
FROM layoffs_updated
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_updated t1
JOIN layoffs_updated t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_updated
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_updated t1
JOIN layoffs_updated t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL; 

SELECT *
FROM layoffs_updated
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_updated
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

-- 4. Remove any columns or rows
ALTER TABLE layoffs_updated
DROP COLUMN row_num;

SELECT *
FROM layoffs_updated;