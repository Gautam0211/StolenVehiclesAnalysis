USE stolen_vehicles_db;

--  Viewing all records from individual tables
SELECT * FROM stolen_vehicles;
SELECT * FROM locations;
SELECT * FROM make_details;

SELECT * FROM stolen_vehicles
where vehicle_type=Null and vehicle_desc=NULL;

DELETE
FROM stolen_vehicles
where vehicle_type=Null and vehicle_desc=NULL;

-- Retrieving data from the three tables into one place
SELECT * 
FROM stolen_vehicles
JOIN locations 
ON stolen_vehicles.location_id = locations.location_id
JOIN make_details
ON stolen_vehicles.make_id = make_details.make_id;

--  DATA CLEANING  --


-- 1.REMOVING DUPLICATES

--  Describing table structures 
DESCRIBE stolen_vehicles;
DESCRIBE stolen_vehicles_db.make_details;
DESCRIBE stolen_vehicles_db.locations;
 
-- All the tables have a primary key as a column, hence, there cannot be any duplicates in any of the tables. 
-- Also, date_stolen has the type 'date'and formats are good to go.

-- Standardising Data

select distinct vehicle_type
from stolen_vehicles;

SELECT * 
FROM stolen_vehicles
WHERE vehicle_desc LIKE 'elite%';

-- The data looks standardised as there are no abrupt spaces and no unnecessaries unique values.
-- Date is standardised too.

-- 3.Dealing with Nulls and Blanks

SELECT * FROM stolen_vehicles
where vehicle_type=Null and vehicle_desc=NULL;

 -- There are no nulls in our dataset to be populated or such nulls that are making any rows or columns useless.

-- SUMARRY: 
-- The data appears clean with no duplicate records, standardized formats, appropriate date formats, and no unnecessary NULL values.


-- **EXPLORATORY DATA ANALYSIS (EDA)**--

-- Creating a temporary table to analyze vehicle theft with location details
CREATE TEMPORARY TABLE stolen_join_locations AS
SELECT 
    vehicle_id, 
    make_id, 
    vehicle_type, 
    vehicle_desc, 
    model_year,
    color, 
    date_stolen, 
    stolen_vehicles.location_id, 
    locations.region, 
    locations.population,
    locations.density
FROM stolen_vehicles
JOIN locations 
ON stolen_vehicles.location_id = locations.location_id;

SELECT * FROM stolen_join_locations; -- Viewing the new temporary table

-- Creating another temporary table to analyze vehicle theft by make details
CREATE TEMPORARY TABLE stolen_join_make AS
SELECT 
    vehicle_id, 
    vehicle_type,
    vehicle_desc, 
    model_year,
    color, 
    date_stolen, 
    stolen_vehicles.make_id, 
    make_details.make_name,
    make_details.make_type
FROM stolen_vehicles
JOIN make_details
ON stolen_vehicles.make_id = make_details.make_id;

SELECT * FROM stolen_join_make; -- Viewing the new temporary table

-- Time-Series Analysis

-- Query 1: Yearly analysis of vehicle thefts
SELECT YEAR(date_stolen) AS Year, COUNT(DISTINCT vehicle_id) AS Total_Thefts
FROM stolen_vehicles
GROUP BY YEAR(date_stolen)
ORDER BY Year;

-- Query 2: Comparing thefts in quarters (excluding April data)
SELECT YEAR(date_stolen) AS Year, COUNT(DISTINCT vehicle_id) AS Total_Thefts
FROM (
    SELECT *
    FROM stolen_vehicles
    WHERE MONTH(date_stolen) != 4
) AS only_quarters
GROUP BY YEAR(date_stolen)
ORDER BY Year;
-- Result: Thefts in the first quarter of 2022 have increased by around 53% as compared to last quarter of 2021.


-- Query 3: Monthly analysis of vehicle thefts
SELECT MONTH(date_stolen) AS Month, COUNT(DISTINCT vehicle_id) AS Total_Thefts
FROM stolen_vehicles
GROUP BY MONTH(date_stolen)
ORDER BY Total_Thefts DESC;
-- Result:March'22 has the most number of thefts where as October'21 has least, (not taking April has It has only 5 days data ) 


-- Query 4: Analyzing thefts by day of the week
SELECT DAYNAME(date_stolen) AS Day, COUNT(*) AS Total_Thefts
FROM stolen_vehicles
GROUP BY DAYNAME(date_stolen)
ORDER BY Total_Thefts DESC;
-- Result: Mondays and Tuesdays have the most number of thefts and Saturdays have the least no of thefts.





-- Query 5: Analyzing thefts by vehicle type
SELECT vehicle_type, COUNT(*) AS Total_Thefts
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY Total_Thefts DESC;
-- Result: Station-Wagon,Saloon and Hatchbacks are the top-3 most stolen type of vehicles whereas trucks,trail-bikes,tractor being the least

-- Query 6: Analyzing thefts by vehicle make
SELECT make_name, COUNT(*) AS Total_Thefts
FROM stolen_join_make
GROUP BY make_name
ORDER BY Total_Thefts DESC;
-- Result:Toyota, Trailer,Nissan-Top 3 brands of vehicles being stolen.


-- Query 7: Analyzing thefts by vehicle description and make_name
SELECT vehicle_desc, make_name, COUNT(*) AS Total_Thefts
FROM stolen_join_make
GROUP BY vehicle_desc,make_name
ORDER BY Total_Thefts DESC;
-- Result: 
-- The Top 3 Most Stolen Vehicles
-- HILUX	Toyota
-- COURIER	Ford
-- DEMIO	Mazda

-- **LOCATION-BASED ANALYSIS**--


-- Query 8: Analyzing thefts by region
SELECT region, COUNT(*) AS Total_Thefts
FROM stolen_join_locations
GROUP BY region
ORDER BY Total_Thefts DESC;
-- RESULT:Auckland has the most no. of thefts, followed by Canterbury, whereas Southland has the least.


-- Query 9: Using window functions to get theft counts by region and their characteristics
SELECT DISTINCT 
    region, 
    population,
    density, 
    COUNT(vehicle_id) OVER (PARTITION BY region) AS region_count
FROM stolen_join_locations
ORDER BY region_count DESC;
-- RESULT:
-- The top regions are the most populated ones, 
-- Specifically, Auckland has the highest popn of  1.69mn with the massive highest density of 343.09
-- CANTERBURY ; POPN-655K, with a low density-14.72
-- Seems popn has a direct relationship with no. of thefts whereas we cannot say anything with Density.


-- Creating a temporary table for the top 5 regions
CREATE TEMPORARY TABLE Top_5_Region AS
SELECT region, COUNT(*) AS Total_Thefts
FROM stolen_join_locations
GROUP BY region
ORDER BY Total_Thefts DESC
LIMIT 5;


-- Query 10: Top 3 most stolen vehicle types by region (Top 5 Regions)
WITH CTE_Vehicle_Type AS (
    SELECT DISTINCT 
        vehicle_type, 
        region,
        COUNT(vehicle_type) OVER (PARTITION BY region, vehicle_type ORDER BY region) AS times_stolen
    FROM stolen_join_locations
),
CTE_Ranking AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY region ORDER BY times_stolen DESC) AS ranking
    FROM CTE_Vehicle_Type
),
CTE_Top3 AS (
    SELECT *
    FROM CTE_Ranking
    WHERE ranking <= 3
)
SELECT vehicle_type, CTE_Top3.region, times_stolen, ranking
FROM CTE_Top3
JOIN Top_5_Region
ON CTE_Top3.region = Top_5_Region.region;

-- Recommendation to NZ Police: More Focus on improving security measures for these vehicle types in the top 5 regions.

-- Query 11: Top 3 most stolen vehicles by description for top 5 regions
WITH CTE_Vehicle_Desc AS (
    SELECT DISTINCT 
        vehicle_desc, 
        vehicle_type,
        region,
        COUNT(vehicle_id) OVER (PARTITION BY region, vehicle_desc) AS times_stolen
    FROM stolen_join_locations
),
CTE_Ranking AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY region ORDER BY times_stolen DESC) AS ranking
    FROM CTE_Vehicle_Desc
),
CTE_Top3 AS (
    SELECT *
    FROM CTE_Ranking
    WHERE ranking <= 3
)
SELECT vehicle_desc, vehicle_type, CTE_Top3.region, times_stolen, ranking
FROM CTE_Top3
JOIN Top_5_Region
ON CTE_Top3.region = Top_5_Region.region;

-- Recommendation to NZ Police: Focus on the specific vehicles being stolen in each region for targeted interventions.


-- SOME ADDITIONAL QUERIES:

-- Query 12 : Analyzing thefts by model year
SELECT model_year, COUNT(*) AS Total_Thefts
FROM stolen_vehicles
GROUP BY model_year
ORDER BY Total_Thefts DESC;
-- RESULT:2005-06 models most, least 1965,57,or before 1980's

-- Query 13: Analyzing thefts by vehicle color
SELECT color, COUNT(*) AS Total_Thefts
FROM stolen_vehicles
GROUP BY color
ORDER BY Total_Thefts DESC;
-- RESULT:Silver and white colored vehicles, most stolen, and cream and pink colored least






