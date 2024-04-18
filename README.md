# COVID-19-Project

## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning](#data-cleaning)
- [Data Analysis](#data-analysis)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Visualization](#data-visualization)
- [Results and Findings](#results-and-findings)
- [Limitations](#limitations)
- [References](#references)

### Project Overview
---
The objective of this final group project was to develop a tool to find the number of bikes to stock in a selection of stations at the beginning of the day to maximize the number of daily bike trips. Applying the 4-step analytics process to solve this problem, our group constructed a data-driven narrative prepared in a pitch presentation for the Citi Bike executives. In RStudio, descriptive analyses helped to identify demand patterns, and predictive analyses were done through the use of a multiple linear regression model created to forecast daytime and evening demand for five stations. An optimization model created in Excel was used to find the optimal initial allocation of bikes as well as the number of trips.

### Data Sources
---
Citi Bike Demand Data: The primary dataset used for this analysis is the "citibikeDemand.csv" file, which contains a random sample of trips taken from June 1, 2017, to May 31, 2018 (31,452 out of 15.7 million rides). The information has been supplemented with demographic, economic, and weather information pulled from a variety of sources. 

[COVID-19 Data](https://github.com/markkachai/Citi-Bike-Case-Study/blob/77f82f7f3303236dab7e363c86df7467ab18d046/CitiBike%20Data%20Description.docx)

### Tools
---
- Excel - Data Cleaning and Preparation
- SQL - Data Preparation and Analysis (DML, DDL, EDA)
- Tableau - Data Visualization

### Data Cleaning
---
In the initial data preparation phase, the following tasks were performed:
1. Data loading and inspection.
2. Handling missing values.
3. Data cleaning and formatting.

### Data Analysis
---
Examples of SQL queries worked with

- Creating the CovidData table
```SQL
# Create new database

CREATE DATABASE IF NOT EXISTS CovidProject1;

USE CovidProject1;

# Creating CovidData Table

CREATE TABLE CovidData
(
code VARCHAR(255),
country VARCHAR(255),
date DATE,
population INT,
total_cases INT,
new_cases INT,
total_deaths INT,
new_deaths INT,
total_vaccinations INT,
new_vaccinations INT,
people_vaccinated INT,
people_fully_vaccinated INT,
total_boosters INT,
population_density DOUBLE,
median_age DOUBLE,
aged_65_older DOUBLE,
aged_70_older DOUBLE,
gdp_per_capita DOUBLE,
cardiovasc_death_rate DOUBLE,
diabetes_prevalence DOUBLE,
female_smokers DOUBLE,
male_smokers DOUBLE,
handwashing_facilities DOUBLE,
life_expectancy DOUBLE,
human_development_index DOUBLE
);

show variables like "local_infile";

set global local_infile = 1;

# Uploading .csv file containing the data

LOAD DATA LOCAL INFILE '/Users/markkachai/Downloads/owid-covid-data (2).csv'
INTO TABLE CovidData
FIELDS TERMINATED BY ','
IGNORE 1 ROWS; 

# Ensuring all rows were uploaded successfully

SELECT 
    COUNT(*)
FROM
    CovidData;
```

- Queries to create tables to be used in Tableau
```SQL
# SQL Queries for Tableau Project
# Looking over data from both tables
SELECT 
    *
FROM
    CovidProject1.CovidData
ORDER BY 2 , 3;

# Finding the date range of data
SELECT 
    MIN(date) AS Start_Date, MAX(date) AS End_Date
FROM
    CovidProject1.CovidData;

# The data in CovidData ranges from 2020-01-01 to 2024-04-11

# 1.
# Looking at total cases vs. total deaths in the world until 2024-04-11

SELECT 
    country AS Location,
    MAX(total_cases) AS Total_Cases,
    MAX(total_deaths) AS  Total_Deaths,
    (MAX(total_deaths) / MAX(total_cases)) * 100 AS Death_Percentage
FROM
    CovidProject1.CovidData
WHERE
    country = 'World';

# As of April 11, 2024:
# There have been 775,251,765 cases of COVID-19
# There have been 7,043,660 deaths due to COVID-19
# The likelihood of dying if you contract COVID-19 is 0.91%

# Looking at total cases vs. total deaths per day in the U.S.
SELECT 
    country,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS death_percentage
FROM
    CovidProject1.CovidData
WHERE
    country LIKE '%states'
ORDER BY 1, 2;

## The output of this query shows the likelihood of dying if you contract COVID-19 in the U.S. as of April 11, 2024.
SELECT 
    MAX(total_cases) AS Total_Cases,
    MAX(total_deaths) AS Total_Deaths,
    (MAX(total_deaths) / MAX(total_cases)) * 100 AS Death_Percentage
FROM
    CovidProject1.CovidData
WHERE
    country LIKE '%states'
ORDER BY 1, 2;

# As of April 11, 2024 in the United States:
## There have been 103,436,829 cases of COVID-19
## There have been 1,184,148 deaths due to COVID-19
## The likelihood of dying if you contract COVID-19 is 1.15%

# 2.
# Showing continents with highest death count per population as of April 11, 2024
## Using a nested query:
SELECT 
    continent, total_death_count
FROM
    (SELECT 
        country AS continent, MAX(total_deaths) AS total_death_count
    FROM
        CovidProject1.CovidData
    WHERE
        country IN ('Europe', 'North America', 'Asia', 'South America', 'Africa', 'Oceania')
    GROUP BY country) AS max_deaths_per_continent
WHERE
    total_death_count > 0
ORDER BY total_death_count DESC;

# 3.
# Showing countries with the highest cases per population as of April 11, 2024
## Using a nested query:
SELECT 
    *
FROM
    (SELECT 
        country, MAX(population) AS population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/MAX(population))*100 AS percent_population_infected
    FROM
        CovidProject1.CovidData
    WHERE
        country NOT IN ('World', 'Europe', 'North America', 'Asia', 'South America', 'Africa', 'Oceania')
        #AND date >= '2020-04-01'
        #AND date <= '2024-04-30'
    GROUP BY country) AS max_cases_per_country
WHERE
    highest_infection_count > 0
ORDER BY percent_population_infected DESC;

# 4.
# Showing countries' daily cases per population as of April 11, 2024
## Using a nested query:
SELECT 
    *
FROM
    (SELECT 
        country, MAX(population) AS population, date, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/MAX(population))*100 AS percent_population_infected
    FROM
        CovidProject1.CovidData
    WHERE
        country NOT IN ('World', 'Europe', 'North America', 'Asia', 'South America', 'Africa', 'Oceania')
        #AND date >= '2020-04-01'
        #AND date <= '2024-04-30'
    GROUP BY country, date) AS max_cases_per_country
WHERE
    highest_infection_count > 0
ORDER BY percent_population_infected DESC;
```

### Exploratory Data Analysis
---
EDA involved exploring the cleaned COVID-19 data to answer any key questions, such as:

- What share of the population has been partly or fully vaccinated against COVID-19?
- What continents have experienced the most COVID-19-related deaths?
- What percent of each country has been infected by COVID-19?
- How does GDP per capita affect vaccinations?

### Data Visualization
---
Data Visualizations were created in the form of dashboards in Tableau.
Two separate dashboards were created:
- The 'COVID-19 Global Vaccine Tracker' dashboard was created using the cleaned Excel file data. This dashboard mainly covers vaccinations.
- The 'COVID-19 Dashboard Project' dashboard was created using the tables queried from SQL. This dashboard mainly covers cases and deaths.

### Results and Findings
---
The analysis results are summarized as follows:
1. 70.6% of the world has received at least one dose of a COVID-19 vaccination.
2. 64.9% of the world has received both doses of a COVID-19 vaccination.
3. Europe, North America, Asia, and South America have experienced the most COVID-19-related deaths.
4. The number of people vaccinated tends to increase with GDP per capita.

### Limitations
---
Some countries showed an over 100% vaccination rate, which could be due to errors in the source data. These countries were removed from visualizations in which vaccination rate was ranked from highest to lowest.
That said, the stats covered in the dashboards rely on the accuracy of the source data.

### References
---
1. [COVID-19 Dataset (from ourworldindata.org)]([https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-data.csv])
