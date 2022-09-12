--Ordering data by country and datetime columns
SELECT * 
FROM CovidDeaths
ORDER BY 3, 4

SELECT *
FROM CovidVaccinations
ORDER BY 3, 4

-- Columns that will be used in the exploration of this data

SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeaths
ORDER BY 1, 2

-- Perecentage of Covid Cases by Deaths per day

SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	round((total_deaths/total_cases)*100,2) as Death_Percentage	
FROM CovidDeaths
ORDER BY 1, 2

--- Infection chances in each country
SELECT 
	location,
	date,
	total_cases,
	population,
	round((total_cases/population)*100,2) as Infection_Percentage
FROM CovidDeaths
---WHERE location like '%Pakistan%'
ORDER BY location, date


-- HIGHEST INFECTION RATE

SELECT 
	location,
	population,
	MAX(total_cases) as total_cases,
	round(MAX((total_cases/population))*100,2) as Infection_Rate
FROM CovidDeaths
GROUP BY location, population
ORDER BY Infection_Rate desc

-- COUNTRIES WITH HIGHEST DEATH RATE

SELECT 
	location,
	population,
	MAX(total_deaths) as max_deaths,
	round(MAX((total_deaths/population))*100,2) as Death_Rate
FROM CovidDeaths
GROUP BY location, population
ORDER BY Death_Rate desc


-- Highest death count

SELECT 
	location,
	population,
	MAX(cast(total_deaths as int)) as max_deaths	
FROM 
	CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location, population
ORDER BY
	max_deaths desc

-- TOTAL DEATHS IN CONTINENTS

SELECT 
	location,
	population,
	MAX(cast(total_deaths as int)) as max_deaths	
FROM 
	CovidDeaths
WHERE 
	continent IS NULL
GROUP BY 
	location, population
ORDER BY
	max_deaths desc

-- DEATHS GLOBALLY BY EACH DATE

SELECT 
	TOP(90)
	date,
	SUM(new_cases) as cases,
	SUM(cast(new_deaths as int)) as total_deaths,
	round((SUM(cast(new_deaths as int))/SUM(new_cases))*100,4) as death_percent
	
FROM 
	CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	date 
ORDER BY
	date,cases

--- Total Vaccination and Total Cases
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.total_cases,
	dea.population,
	vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY 
	dea.continent,dea.location, dea.date


-- First date where vaccination is recorded in a country

SELECT 
	MIN(date), 
	location
FROM 
	CovidVaccinations
WHERE 
	new_vaccinations IS NOT NULL
-- and location = 'Pakistan'
GROUP BY 
	location
ORDER BY 
	location

--- Total new vccinations by each country

SELECT 
	SUM(cast(new_vaccinations as int)),
	location
FROM 
	CovidVaccinations
--WHERE location = 'Albania'
GROUP BY 
	location
ORDER BY 
	location

-- Percentage of vaccinated population in each country
-- CTE

WITH PopVsVac (Continent, Date, Location,  Population, New_Vaccinations, RollingCount)
AS 
(
	SELECT 
		TOP(50)
		dea.continent,
		dea.date,
		dea.location,
		dea.population,
		vac.new_vaccinations,
		SUM(convert(int, vac.new_vaccinations)) 
			OVER (PARTITION BY dea.location 
					ORDER BY 
						dea.location, dea.date) AS RollingCount
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
	WHERE
		dea.continent IS NOT NULL

	
)

SELECT *,ROUND((RollingCount/Population)*100, 4) AS VaccinatedPerecntage
FROM PopVsVac



