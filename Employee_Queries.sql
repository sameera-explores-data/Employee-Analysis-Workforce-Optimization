create database June_Project;
-- import table 
select * from employee_details;
-- 1. Use SQL to clean inconsistencies, handle missing values, and transform data formats.
-- checking if there are missing values in the numeric columns 
SELECT 
    *
FROM
    employee_details
WHERE
    age IS NULL OR age_when_joined IS NULL
        OR years_in_the_company IS NULL
        OR salary IS NULL
        OR annual_bonus IS NULL
        OR prior_years_experience IS NULL
        OR full_time IS NULL
        OR part_time IS NULL
        OR employee_id is NULL
        OR company is NULL
        OR department IS NULL
        OR Gender IS NULL
        OR education_level IS NULL
        OR ethnicity IS NULL
        OR diversity_flag IS NULL;
-- there's inconsistencty in the year joined, update it by re calculating years in the company.
update employee_details set years_in_the_company = age-age_when_joined;

-- 2.	Use SQL to structure and extract clean subsets of the data for analysis.
alter table employee_details add column fulltime int;
update employee_details set fulltime = full_time;
alter table employee_details add column parttime int;
update employee_details set parttime = part_time;
-- created a stored procedure to acess the whole data easily
call employee;

-- convert the values to yes / no
-- change the datatypes before converting
alter table employee_details modify column fulltime text;
alter table employee_details modify column parttime text;

-- now change the values
update employee_details set fulltime = 'No' where fulltime = 0;
update employee_details set fulltime = 'Yes' where fulltime = 1;

-- for parttime
update employee_details set parttime = 'No' where parttime = 0;
update employee_details set parttime = 'Yes' where parttime = 1;

-- a.	Analyze gender, age, ethnicity and education level distribution across departments.
-- gender
SELECT 
    department,
    gender,
    COUNT(*) AS gender_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY department), 2) AS gender_percentage
FROM employee_details
GROUP BY department, gender
ORDER BY department, gender;

-- age distribution across departments
select max(age) from employee_details;
SELECT 
    department,
    CASE 
        WHEN age BETWEEN 30 AND 45 THEN '30-45'
        WHEN age BETWEEN 46 AND 50 THEN '46-50'
        ELSE '51+'
    END AS age_group,
    COUNT(*) AS employee_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY department), 2) AS percentage_in_department
FROM employee_details
GROUP BY department, age_group
ORDER BY department, age_group;

-- ethnicity distribution
SELECT 
    department,
    ethnicity,
    COUNT(*) AS ethnicity_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY department), 2) AS ethnicity_percentage
FROM employee_details
GROUP BY department, ethnicity
ORDER BY department, ethnicity;

-- education demographics
SELECT 
    department,
    education_level,
    COUNT(*) AS education_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY department), 2) AS education_percentage
FROM employee_details
GROUP BY department, education_level
ORDER BY department, education_level;

-- 3.	Salary & Compensation Analysis
-- Assess salary distribution by department, gender, and position.
SELECT 
    department,
    gender,
    position,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS average_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary
FROM employee_details
GROUP BY department, gender, position
ORDER BY department, gender, position;

-- Identify salary disparities using statistical comparisons (mean, median, standard deviation).
SELECT 
    department,
    gender,
    ROUND(AVG(salary), 2) AS mean_salary,
    ROUND(STDDEV(salary), 2) AS std_deviation
FROM employee_details
GROUP BY department, gender
ORDER BY department, gender;

-- 4.	Departmental & Performance Insights
-- Rank departments based on employee count, performance, and average salary.
-- Rank departments by employee count, average performance, and average salary
SELECT 
    department,
    COUNT(*) AS total_employees,
    ROUND(AVG(salary), 2) AS avg_salary,

    RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_by_employee_count,
    RANK() OVER (ORDER BY AVG(salary) DESC) AS rank_by_salary
FROM employee_details
GROUP BY department
ORDER BY department;

-- Identify high-performing departments vs. those needing training or resource support.
SELECT 
    department,
    COUNT(*) AS employee_count,
    ROUND(AVG(annual_bonus), 2) AS avg_bonus,
    ROUND(AVG(years_in_the_company), 2) AS avg_tenure,

    CASE 
        WHEN AVG(annual_bonus) >= 15000 AND AVG(years_in_the_company) >= 3 THEN 'High Performing'
        WHEN AVG(annual_bonus) BETWEEN 14000 AND 13000 THEN 'Moderate - May Need Support'
        ELSE 'Low - Needs Training or Review'
    END AS performance_category

FROM employee_details
GROUP BY department
ORDER BY avg_bonus DESC;
