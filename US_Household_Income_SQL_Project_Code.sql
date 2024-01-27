# --- Data Cleaning


# RAW DATA

SELECT *
FROM us_household_project.us_household_income_statistics
;

SELECT *
FROM us_household_project.us_household_income
;

# Change Column Name 
ALTER TABLE us_household_income_statistics
RENAME COLUMN `ï»¿id` TO `ID`
;

#Performing Count

SELECT COUNT(id)
FROM us_household_project.us_household_income_statistics
;

SELECT COUNT(id)
FROM us_household_project.us_household_income
;

# Data Cleaning

SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(ID) > 1
;

SELECT *
FROM (SELECT row_id, id,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
FROM us_household_income) AS duplicates
WHERE row_num > 1
;

# Delete Duplicates 

DELETE FROM us_household_income
WHERE row_id IN (
	SELECT row_id
    FROM (
    SELECT row_id, id,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
	FROM us_household_income) AS duplicates
	WHERE row_num > 1)
;

SELECT id, COUNT(id)
FROM us_household_income_statistics
GROUP BY id
HAVING COUNT(ID) > 1
;

#No Duplicates

SELECT state_name, COUNT(state_name)
FROM us_household_income
GROUP BY state_name
;

SELECT DISTINCT state_name
FROM us_household_income
;

#Fixing Georgia Input Error

UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE state_name = 'georia'
;

#Standardizing lowercase alabama to Alabama
UPDATE us_household_income
SET state_name = 'Alabama'
WHERE state_name = 'alabama'
;

SELECT DISTINCT state_ab
FROM us_household_income
ORDER BY state_ab
;

SELECT * 
FROM us_household_income
WHERE place = ''
ORDER BY 1
;

# Fixing Null Value 
UPDATE us_household_income
SET place = 'Autaugaville'
WHERE row_id = 32
;

SELECT type, COUNT(type)
FROM us_household_income
GROUP BY type
ORDER BY type
;

# Fixing Type
UPDATE us_household_income
SET type = 'Borough'
WHERE type = 'Boroughs'
;

# --- Exploratory Data Analysis

SELECT * 
FROM us_household_income
;

SELECT * 
FROM us_household_income_statistics
;

# Size of State by Land and Water

SELECT state_name, SUM(aland), SUM(awater)
FROM us_household_income
GROUP BY state_name 
ORDER BY SUM(aland) DESC
;

SELECT state_name, SUM(aland), SUM(awater)
FROM us_household_income
GROUP BY state_name 
ORDER BY SUM(awater) DESC
;

# Combining Tables

SELECT * 
FROM us_household_income AS uhi
INNER JOIN us_household_income_statistics AS uhis
	ON uhi.id = uhis.id
;

# Filtering 'Zero' Values
SELECT * 
FROM us_household_income AS uhi
INNER JOIN us_household_income_statistics AS uhis
	ON uhi.id = uhis.id
WHERE mean <> 0
;

SELECT uhi.state_name, county, type, `Primary`, mean, median
FROM us_household_income AS uhi
INNER JOIN us_household_income_statistics AS uhis
	ON uhi.id = uhis.id
WHERE mean <> 0
;

# Average household income and average household median by state
SELECT uhi.state_name, ROUND(AVG(mean),1), ROUND(AVG(median),1)
FROM us_household_income AS uhi
INNER JOIN us_household_income_statistics AS uhis
	ON uhi.id = uhis.id
WHERE mean <> 0
GROUP BY uhi.state_name
ORDER BY ROUND(AVG(mean),1) DESC
;

# Average mean and median household income by type of living location, such as city, rural, etc.
SELECT type, ROUND(AVG(mean),1), ROUND(AVG(median),1)
FROM us_household_income AS uhi
INNER JOIN us_household_income_statistics AS uhis
	ON uhi.id = uhis.id
WHERE mean <> 0
GROUP BY type
ORDER BY ROUND(AVG(mean),1) DESC
;

# Checking number of entries for each type category. 
# municiality has 1 entry, CPD had 2 entries, county had 2 entries, urban has 8 entries
# few entries = higher averages
SELECT type, COUNT(type), ROUND(AVG(mean),1), ROUND(AVG(median),1)
FROM us_household_income AS uhi
INNER JOIN us_household_income_statistics AS uhis
	ON uhi.id = uhis.id
WHERE mean <> 0
GROUP BY type
ORDER BY ROUND(AVG(mean),1) DESC
;

# Top 10 Average Household Income by City 
SELECT uhi.state_name, city, ROUND(AVG(Mean),1)
FROM us_household_income AS uhi
INNER JOIN us_household_income_statistics AS uhis
	ON uhi.id = uhis.id
WHERE mean <> 0
GROUP BY uhi.state_name, uhi.city
ORDER BY ROUND(AVG(Mean),1) DESC
LIMIT 10
;
