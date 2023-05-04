--Quering the database
SELECT * 
FROM [Covid Project].[dbo].[CovidDeaths]
SELECT *
FROM [Covid Project].[dbo].CovidVaccinations


--Showing the highest and the lowsest percentage of death recored in Nigeria
SELECT location, date, total_cases, total_deaths, round(cast(total_deaths as float)/cast(total_cases as float)*100,3)  PercentageOfDeath
FROM [Covid Project].[dbo].[CovidDeaths]
WHERE location = 'Nigeria'
ORDER BY 5 desc


--Showing the country with the highest and the least death rate 
SELECT COUNT(location),
--date,
cast(total_deaths as int) totaldeath
FROM [Covid Project].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 3 desc


--Showing the percentage of population that got covid
SELECT location, population, date, total_cases, round(cast(total_cases as float)/(population)*100,3)  PerPopulationInfected
FROM [Covid Project].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL AND location = 'Nigeria'
ORDER BY 4 desc


--Showing the location with the maximum infection count and the percentage of pupulation infected
SELECT location, population, MAX(CAST(total_cases as int)) AS MaxInfectionCount,
MAX(round(cast(total_cases as int)/(population)*100,3))  PerPopulationInfected
FROM [Covid Project].[dbo].[CovidDeaths]
GROUP BY location, population
ORDER BY 3 desc


--Showing country with highest death per population
SELECT location, MAX(cast(total_deaths as int)) deathcount
FROM [Covid Project].[dbo].[CovidDeaths]
WHERE continent is NULL
GROUP BY location
ORDER BY 2 desc


--Showing continent with highest death per population
SELECT continent, MAX(cast(total_deaths as int)) deathcount
FROM [Covid Project].[dbo].[CovidDeaths]
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY 2 desc


--The world total cases and total death with the death percentage
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_death, (SUM(new_deaths)/SUM(new_cases)*100)  as deathpercentage
FROM [Covid Project].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
--ORDER BY 1,2


--Showing Total Population Vs Vaccination
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(int, vacc.new_vaccinations)) 
OVER(PARTITION BY death.location ORDER BY death.location, death.date) RollingPeopleVaccinated
FROM [Covid Project]..CovidDeaths death
JOIN [Covid Project]..CovidVaccinations vacc
ON death.location = vacc.location and death.date = vacc.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3


--USING CTE to get the percentage of people vaccinated in Nigeria
WITH PopVsVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(int, vacc.new_vaccinations)) 
OVER(PARTITION BY death.location ORDER BY death.location, death.date) RollingPeopleVaccinated
FROM [Covid Project]..CovidDeaths death
JOIN [Covid Project]..CovidVaccinations vacc
ON death.location = vacc.location and death.date = vacc.date
WHERE death.continent IS NOT NULL AND death.location = 'Nigeria'
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVacc


--CREATING TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(float, vacc.new_vaccinations)) 
OVER(PARTITION BY death.location ORDER BY death.location, death.date) RollingPeopleVaccinated
FROM [Covid Project]..CovidDeaths death
JOIN [Covid Project]..CovidVaccinations vacc
ON death.location = vacc.location and death.date = vacc.date
WHERE death.continent IS NULL
SELECT *, (RollingPeopleVaccinated/population)*100 PercentageOfVaccinated
FROM #PercentPopulationVaccinated


--Creating View to store the data
CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(float, vacc.new_vaccinations)) 
OVER(PARTITION BY death.location ORDER BY death.location, death.date) RollingPeopleVaccinated
FROM [Covid Project]..CovidDeaths death
JOIN [Covid Project]..CovidVaccinations vacc
ON death.location = vacc.location and death.date = vacc.date
WHERE death.continent IS NULL


SELECT * FROM PercentPopulationVaccinated