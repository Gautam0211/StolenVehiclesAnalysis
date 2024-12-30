# Stolen Vehicles Analysis

This project contains SQL queries and analyses performed on a dataset related to vehicle thefts over a rough 6 Month Period(2021-22) . The analysis aims to extract insights such as the most stolen vehicle types, regions with the highest theft rates, and trends over time.

## Dataset Overview

The project involves three main tables:

- **stolen_vehicles**: Contains details of stolen vehicles such as vehicle type, model year, and date of theft.
- **locations**: Contains location-specific details like region, population, and density.
- **make_details**: Contains information about vehicle makes, including make name and type.

  **This dataset is sourced from Maven Analytics.**

## Objectives

- Clean and prepare the dataset for analysis, including handling missing data, standardizing formats, and ensuring data consistency.
- Perform Exploratory Data Analysis (EDA) to uncover patterns and insights.
- Provide recommendations for security measures based on findings.

## SQL Analysis Workflow

### Data Cleaning

- Check for duplicate records in all tables.
- Validate data consistency, such as standardized formats and appropriate `NULL` handling.

### Exploratory Data Analysis (EDA)

#### Temporary Tables

- Created temporary tables **stolen_join_locations** and **stolen_join_make** to combine relevant information for easier analysis.

#### Yearly and Monthly Trends

- Analyzed yearly and monthly theft trends to identify peak periods.

#### Day of the Week Analysis

- Determined which days of the week have the highest and lowest theft counts.

#### Vehicle-Specific Analysis

- Examined theft counts by:
  - Model year
  - Color
  - Vehicle type
  - Vehicle description
  - Vehicle make

#### Location Analysis

- Analyzed theft counts by region and population density.
- Used window functions to identify top regions by thefts.

### Advanced Insights Using CTEs

- Identified the top 3 stolen vehicle types by region.
- Identified the top 3 stolen vehicle descriptions by region.

## Key Findings

- **Yearly Trends**: 2022 saw a significant increase in thefts compared to 2021, especially in the first quarter (a 53% rise from Q4 2021 to Q1 2022).
- **Monthly Trends**: March had the highest thefts, while October had the lowest (excluding incomplete April data).
- **Day of the Week**: Mondays and Tuesdays had the most thefts, while Saturdays had the least.

### Vehicle Characteristics

- Most stolen model years: 2005-06.
- Most stolen colors: Silver and white.
- Most stolen vehicle types: Station Wagon, Saloon, Hatchback.

### Regional Analysis

- Auckland had the most thefts, driven by high population and density.

## Recommendations for NZ Police

- Focus on regions with high theft counts like Auckland and Canterbury.
- Enhance security measures for high-risk vehicle types and descriptions.
- Increase patrols and awareness campaigns during peak theft periods (e.g., March, Mondays).

## Technologies Used

- **SQL**
- **MySQL** for database management
