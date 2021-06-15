
-- Checking the coviddeaths dataset 

SELECT
	*
FROM
	coviddeaths;


-- Sorting the tables by location 

SELECT
    *
FROM
    coviddeaths
WHERE    
    continent is not NULL
ORDER BY
    3,4;
 

-- covidvacc is Covid Vaccinations

SELECT
    *
FROM
    covidvacc
WHERE
    continent is not NULL
ORDER BY
    3,4;   
    

-- Selecting the data I'll be using

SELECT
    location, date, population, total_cases, new_cases, total_deaths
FROM
    coviddeaths
ORDER BY 
    1,2;


/* 
Looking at Total Cases vs. Total Deaths
deathper is Death Percentage
Cast the total_deaths as Real to get a floating percentage 
*/

SELECT
    location, date, total_deaths, total_cases, 
    (CAST(total_deaths as REAL) / total_cases) * 100 AS deathper
FROM
    coviddeaths
ORDER BY
    1,2;
 

/*   
Looking only at the United States Total Deaths and Total Cases
Death percentage shows a likelihood of an individual dying if they contracted covid in their country.
*/

SELECT
    location, date, total_deaths, total_cases, 
    (CAST(total_deaths as REAL) / total_cases) * 100 AS deathper
FROM
    coviddeaths
WHERE
    location like '%United States%'
ORDER BY 
    1,2;


/*
Looking at the Total Cases and the Population
perpopinfected is Percentage of Population Infected with Covid
Percentage of Population Infected shows the population who contracted Covid
*/

SELECT
    location, date, population, total_cases, 
    (CAST(total_cases as REAL) /population) * 100 AS perpopinfected
FROM
    coviddeaths
WHERE
    location = 'United States'
ORDER BY 
    1;

/*
Looking at Countries with the Highest Infection Rate compared to Population
highinfection is Highest Infection of max Total Cases
*/

SELECT
    location, population, MAX(CAST(total_cases AS REAL)) AS highinfection, 
    (MAX(CAST(total_cases AS REAL)) /population) * 100 AS perpopinfected
FROM
    coviddeaths
GROUP BY    
    location,
    population
ORDER BY 
    perpopinfected DESC;


/*
Looking at Countries with the Highest Death count per Population
totaldeathcount is the total number of deaths per countries
*/

SELECT
    location, MAX(CAST(total_deaths AS INT)) AS totaldeathcount
FROM
    coviddeaths 
WHERE
    continent is not NULL
GROUP BY    
    location 
ORDER BY 
    totaldeathcount DESC;
    


/*
Let's break down things by continent
Showing continents with the highest death counts per population
*/

SELECT
    continent, MAX(CAST(total_deaths AS REAL)) AS totaldeathcount
FROM
    coviddeaths
WHERE
    continent is not null 
GROUP BY    
    continent
ORDER BY 
    totaldeathcount DESC;
    

-- Global Numbers of Total New Cases, Total New Deaths and Death Percentage by Days


SELECT
    date, SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, 
	SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathsPer
FROM
    coviddeaths
WHERE
    continent is not null
GROUP BY
    date
ORDER BY 
    1,2;


-- Global Number of Total New Cases, Total New Deaths and Death Percentage 

SELECT
    SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, 
	SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathsPer
FROM
    coviddeaths
WHERE
    continent is not null
ORDER BY 
    1,2;



-- Checking the covidvacc dataset 

SELECT 
	*
FROM
	covidvacc;


-- Joining coviddeaths and covidvacc 

SELECT
	*
FROM
	coviddeaths dea
JOIN
	covidvacc vac
ON
	dea.location = vac.location 
AND
	dea.date = vac.date;



-- Looking at Total Populations vs. Vaccinations 
	
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
	--(RollingTotalVaccinations/ dea.population) * 100 AS PopulationVaccinationPer
FROM
	coviddeaths dea
JOIN
	covidvacc vac
	ON
		dea.location = vac.location 
	AND
		dea.date = vac.date
WHERE
	dea.continent is not null
ORDER BY
	2,3;
    

/*
Use CTE
CTE is common table expression - a temporary table
*/

WITH 
	PopvsVac (continent, location, date, population, new_vaccinations, RollingTotalVaccinations)
AS
(
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
	--(RollingTotalVaccinations/ dea.population) * 100 AS PopulationVaccinationPer
FROM
	coviddeaths dea
JOIN
	covidvacc vac
	ON
		dea.location = vac.location 
	AND
		dea.date = vac.date
WHERE
	dea.continent is not null
)
SELECT
	*, (RollingTotalVaccinations/ population) * 100 AS PopulationVaccinationsPer
FROM
	PopvsVac



-- Temp Table

DROP TABLE IF EXISTS #PopulationVaccinateionsPer
CREATE TABLE #PopulationVaccinateionsPer
(
continent nvarchar(50),
location nvarchar(50),
date date,
population numeric,
new_vaccinations numeric,
RollingTotalVaccinations numeric
)


INSERT INTO #PopulationVaccinateionsPer
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
	--(RollingTotalVaccinations/ dea.population) * 100 AS PopulationVaccinationPer
FROM
	coviddeaths dea
JOIN
	covidvacc vac
	ON
		dea.location = vac.location 
	AND
		dea.date = vac.date
WHERE
	dea.continent is not null

SELECT
	*, (RollingTotalVaccinations/ population) * 100 AS PopulationVaccinationsPer
FROM
	#PopulationVaccinateionsPer


-- Creating View to store data for later visualization 

CREATE VIEW PopulationVaccinateionsPer AS
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
FROM
	coviddeaths dea
JOIN
	covidvacc vac
	ON
		dea.location = vac.location 
	AND
		dea.date = vac.date
WHERE
	dea.continent is not null


SELECT 
	*
FROM
	PopulationVaccinateionsPer



