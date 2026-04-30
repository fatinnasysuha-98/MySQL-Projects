-- Exploratory Data Analysis --

SELECT *
FROM layoffs_staging2;

-- working with total_laid_off and percentage_laid_off column --

SELECT MAX(total_laid_off), MAX(percentage_laid_off) 						-- To check the max of total_laid_off and percentage_laid_off table from the whole data --
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1 												-- To check what company that have 100% percentage_laid_off --
ORDER BY total_laid_off DESC;  												-- Can check which company have the largest number of total_laid_off--

SELECT company, SUM(total_laid_off)  										-- To check the sum of total_laid_off for each company --
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;  															-- The output will come in descending order based on column 2 --

SELECT MIN(`date`), MAX(`date`) 											-- To check date ranges of laid off happen --
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off)  										-- To check which industry is affected the most --
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;  															-- The output will come in descending order based on column 2 --

SELECT country, SUM(total_laid_off)  										-- To check which country is affected the most --
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;  															-- The output will come in descending order based on column 2 --

SELECT `date`, SUM(total_laid_off)  										-- To check how many total_laid_off on individul date --
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;  															-- The output will come in descending order based on column 1, which is will come out from the recent to the oldest date --

SELECT YEAR(`date`), SUM(total_laid_off)  									-- To check how many total_laid_off on each year --
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;  															-- The output will come in descending order based on column 1, which is will come out from the recent to the oldest year --

SELECT stage, SUM(total_laid_off)  											-- To check how many total_laid_off in every stage --
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- EDA based on percentage_laid_off --

SELECT company, AVG(percentage_laid_off)  									-- To check the average percentage_laid_off for each company --
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) 				-- Can check how many total_laid_off for each month in each year --
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;

-- USING CTEs to check each month how many total laid off and also can check month by month progression --

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- To check how much each company were laying off per year --

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- USING CTEs : To check which company laid off the most people per year --

WITH Company_YEAR (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *
FROM Company_Year;

-- To check and rank the company, which having laid off the most people per year --

WITH Company_YEAR (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL  																		-- Will not take it the null values --
ORDER BY Ranking ASC;

-- Filter on the ranking to be only the top 5 companies per year --

WITH Company_YEAR (company, years, total_laid_off) AS
(																	
SELECT company, YEAR(`date`), SUM(total_laid_off)												-- The first CTE --
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), 
Company_Year_Rank AS  																			-- Give a Rank to the company --
(SELECT *, 																						-- The Second CTE --
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL   -- Will not take it the null values --
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5																				-- To filter on just Top 5 company in the rank for each year --
;








