SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4

--Select data that going to be use

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases VS Total Deaths
-- Shows The Likekihood dying in India
SELECT location, date, total_cases, total_deaths,FORMAT (total_deaths/total_cases,'P', 'en-us') AS 'Death_Percentage'
FROM PortfolioProject..CovidDeaths
WHERE location='India'
AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases VS Population
-- What % of population got Covid
SELECT location, date, total_cases, population,FORMAT (total_cases/population,'P', 'en-us') AS 'Infction_Percentage'
FROM PortfolioProject..CovidDeaths
WHERE location='India'
AND continent IS NOT NULL
ORDER BY 1,2

--Countires With Infaction Rate to Population 
SELECT location, population, MAX(total_cases) AS 'HighestInfactionCount',MAX(FORMAT (total_cases/population,'P', 'en-us')) AS 'Infction_Percentage'
FROM PortfolioProject..CovidDeaths
--WHERE location='India'
--AND continent IS NOT NULL
GROUP BY location, population
ORDER BY Infction_Percentage desc

--Countries witn Highest Death Count Per Population

SELECT location, MAX(CAST (total_deaths AS INT)) AS 'TotalDeaths'
FROM PortfolioProject..CovidDeaths
--WHERE location='India'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths desc+

--BY CONTINENT With highest Death count

SELECT continent, MAX(CAST (total_deaths AS INT)) AS 'TotalDeaths'
FROM PortfolioProject..CovidDeaths
--WHERE location='India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths desc


-- Globle Number
SELECT date, SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS INT)) AS TotalDeaths, (FORMAT (SUM(CAST(new_deaths AS INT))/SUM(new_cases),'P', 'en-us')) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location='India'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Covid Vaccinations Work

-- Total Population VS Vacctinations

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(NUMERIC,vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CumulativeVaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
CumulativeVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(NUMERIC,vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CumulativeVaccinations
--,(CumulativeVaccinations/Population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, FORMAT(CumulativeVaccinations/Population,'P', 'en-us') AS MMM
FROM #PercentPopulationVaccinated

--Creating View For Store Data

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(NUMERIC,vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CumulativeVaccinations
--,(CumulativeVaccinations/Population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated