SELECT *
FROM ProjectCovid..CovidDeaths
ORDER BY 3, 4;

--SELECT *
--FROM ProjectCovid..CovidVaccination
--ORDER BY 3, 4;

-- Select data that i going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectCovid..CovidDeaths
ORDER BY 1, 2;

-- Looking at total cases vs total deaths in indonesia

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentages
FROM ProjectCovid..CovidDeaths
WHERE location = 'indonesia'
ORDER BY 1, 2;

-- Looking at total cases vs population in indonesia

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM ProjectCovid..CovidDeaths
WHERE location = 'indonesia'
ORDER BY 1, 2;

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM ProjectCovid..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing country with highest Death Count Per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Data by continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentages
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Total deaths globaly

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentages
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Population vs vaccination

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProjectCovid..CovidDeaths dea
JOIN ProjectCovid..CovidVaccination vac
  ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinationPercentage
FROM PopvsVac;

-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population BIGINT,
new_vaccinations BIGINT,
RollingPeopleVaccinated BIGINT
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProjectCovid..CovidDeaths dea
JOIN ProjectCovid..CovidVaccination vac
  ON dea.location = vac.location
   AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL

SELECT *
FROM #PercentPopulationVaccinated;

-- Creating View to store data

CREATE VIEW PercentPopulationVaccinated
 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProjectCovid..CovidDeaths dea
JOIN ProjectCovid..CovidVaccination vac
  ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated;