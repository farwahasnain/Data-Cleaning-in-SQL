-- DATA CLEANING

SELECT *
FROM layoffs;

-- 1. Remove Duplicates (if any)
-- 2. Standardize the Data
-- 3 Check for Null or Blank Values
-- 4. Remove any irrelevant Columns

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- STEP 1: Find Duplicates

WITH duplicate_cte AS(
	SELECT *,
    ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
    )
    
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Validating our results

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Deleting the Duplicates

WITH duplicate_cte AS(
	SELECT *,
    ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
    )
    
DELETE 
FROM duplicate_cte
WHERE row_num > 1;

-- However, deleting from CTE doesn't work. 
-- And, therefore, we will create another table just to delete the duplicates.

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- STEP 2 : Standardizing data

-- Inspecting colum 'company'

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Inspecting column 'industry'

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Crypto and Cryptocurrency seems to be one industry and should not be counted two separate industries. 
-- Therefore, attempting to standardize it. 

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'CRYPTO%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Validating

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'CRYPTO%';

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Inspecting Location

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET location = 'Dusseldorf'
WHERE location LIKE '%dorf';

UPDATE layoffs_staging2
SET location = 'Malmö'
WHERE location LIKE 'Malm%';

-- Inspecting Country
-- Removing '.' from 'United States'

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country  LIKE 'United States%'
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Validating the updates

SELECT DISTINCT country, location
FROM layoffs_staging2
ORDER BY 1;

-- Changing 'date' column from text into datetime format. 

SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

-- The date column is still text although it has been converted to datetime format. 
-- To convert the column into date :

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- STEP 3: Handling Null and Missing Values

-- Populating 'Travel' in 'industry' column for 'Airbnb'.
-- We will do it through self-join. 

SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL;


SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;
    

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Validating the updates made.

SELECT company, industry
FROM layoffs_staging2
where company = 'Airbnb';

-- Inspecting Bally's data

SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL;

-- The reason why Bally's industry couldn't be populated because it has only one record, 
-- and our sql query populates the null value if it has another similar record with non-null values.

SELECT *
FROM layoffs_staging2;

-- We can't populate the remaining NULL values in total_laid_off and in percentage_laid_off. 
-- We could have populated if total employees before laid off was given to us.


-- STEP 4: Remove Columns and Rows

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

-- Delete row_num Column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;