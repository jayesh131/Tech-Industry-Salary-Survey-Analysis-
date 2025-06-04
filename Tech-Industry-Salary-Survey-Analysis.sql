create database dps1

use dps1

select * from survey;

alter table survey
drop column Browser,
drop column OS,
drop column City,
drop column Country,
drop column Referrer;

-- Get Total Records and Missing Values
SELECT 
  COUNT(*) AS total_records,
  SUM(CASE WHEN salary_usd IS NULL THEN 1 ELSE 0 END) AS missing_salaries
FROM survey;

-- Average Salary by Role
SELECT role, ROUND(AVG(salary_usd), 2) AS avg_salary, 
FROM survey
GROUP BY role
ORDER BY avg_salary desc;

-- Count of Roles by Country
SELECT host_country, COUNT(DISTINCT role) AS unique_roles
FROM survey
GROUP BY host_country
ORDER BY unique_roles DESC;

-- Avg Salary Comparison to Education, Industry, Country
SELECT 
    Education, 
    Industry,
    host_country,
    ROUND(AVG(salary_usd), 2) AS Avg_Salary
FROM 
    survey
GROUP BY 
     Education, Industry, host_country
ORDER BY 
    Avg_Salary DESC;

-- Highest Paying Roles Per Country
SELECT host_country, role, ROUND(AVG(salary_usd), 2) AS avg_salary
FROM survey
GROUP BY host_country, role
ORDER BY host_country, avg_salary DESC;

-- Gender Pay Gap by Role
SELECT role,
  ROUND(AVG(CASE WHEN gender = 'Male' THEN salary_usd END), 2) AS male_avg,
  ROUND(AVG(CASE WHEN gender = 'Female' THEN salary_usd END), 2) AS female_avg
FROM survey
GROUP BY role
HAVING male_avg IS NOT NULL AND female_avg IS NOT NULL;

-- Salary Category by Role
SELECT 
    role,
    salary_usd,
    CASE 
        WHEN salary_usd <= '0-40k' THEN 'Low'
        WHEN salary_usd BETWEEN '41k-65k' AND '66k-85k' THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM 
    survey;
    
-- Career Switcher Count by Role
SELECT role, COUNT(*) AS total, 
       SUM(CASE WHEN switching_career = 'Yes' THEN 1 ELSE 0 END) AS switchers
FROM survey
GROUP BY role;

-- Most Common Role by Education Level
SELECT 
    education,
    role,
    COUNT(*) AS count,
    RANK() OVER(PARTITION BY education ORDER BY COUNT(*) DESC) rnk
FROM 
    survey
GROUP BY 
    education, role
HAVING COUNT(*) > 5
ORDER BY 
    education, rnk;
    
-- Outlier Detection (Z-Score Based)
WITH stats AS (
  SELECT AVG(salary_usd) AS avg_sal, STDDEV(salary_usd) AS std_sal FROM survey
)
SELECT *,
       (salary_usd - stats.avg_sal) / stats.std_sal AS z_score
FROM survey, stats
WHERE salary_usd IS NOT NULL
HAVING ABS(z_score) > 3;

SELECT
  Role,
  salary_usd,
  SUM(salary_usd) OVER (
	partition by Role 
    ORDER BY role
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total_salary
FROM survey