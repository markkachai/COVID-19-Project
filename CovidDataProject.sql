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

# SQL Queries for Tableau Project
# Looking over data from both tables
SELECT 
    *
FROM
    CovidProject1.CovidData
ORDER BY 2 , 3;

# Finding date range of data
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
# The the likelihood of dying if you contract COVID-19 is 0.91%

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
ORDER BY 1 , 2;

## The output of this query shows the likelihood of dying if you contract COVID-19 in the U.S. as of April 11, 2024.
SELECT 
    MAX(total_cases) AS Total_Cases,
    MAX(total_deaths) AS Total_Deaths,
    (MAX(total_deaths) / MAX(total_cases)) * 100 AS Death_Percentage
FROM
    CovidProject1.CovidData
WHERE
    country LIKE '%states'
ORDER BY 1 , 2;

# As of April 11, 2024 in the United States:
## There have been 103,436,829 cases of COVID-19
## There have been 1,184,148 deaths due to COVID-19
## The the likelihood of dying if you contract COVID-19 is 1.15%

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
# Showing countries with highest cases per population as of April 11, 2024
## Using a nested query:
SELECT 
    *
FROM
    (SELECT 
        country, MAX(population) AS population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/MAX(population))*100 AS percent_population_infected
    FROM
        CovidProject1.CovidData
    WHERE
        country NOT IN ('World' , 'Europe', 'North America', 'Asia', 'South America', 'Africa', 'Oceania')
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
        country NOT IN ('World' , 'Europe', 'North America', 'Asia', 'South America', 'Africa', 'Oceania')
        #AND date >= '2020-04-01'
        #AND date <= '2024-04-30'
    GROUP BY country, date) AS max_cases_per_country
WHERE
    highest_infection_count > 0
ORDER BY percent_population_infected DESC;

# Extra
# Showing gdp per capita, total cases, total deaths, and likelihood of dying if you contract COVID-19 for countries as of April 11, 2024
## Using a nested query:
SELECT 
    *
FROM
    (SELECT 
        country,
            MAX(gdp_per_capita) AS gdp_per_capita,
            MAX(total_cases) AS total_cases,
			MAX(total_deaths) AS total_deaths,
			(MAX(total_deaths) / MAX(total_cases))*100 AS death_percentage
    FROM
        CovidProject1.CovidData
    WHERE
        country NOT IN ('World' , 'Europe', 'North America', 'Asia', 'South America', 'Africa', 'Oceania')
    GROUP BY country) AS max_deaths_per_country
WHERE
    gdp_per_capita > 0 AND total_cases > 0
ORDER BY gdp_per_capita DESC;


