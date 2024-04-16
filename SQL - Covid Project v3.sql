-- Checking that the Covid Deaths table has been imported correctly
SELECT * 
FROM [db.Project1] . .CovidDeaths
ORDER BY 3,4;

-- Selecting data that'll be used 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [db.Project1] . .CovidDeaths
ORDER BY 1,2

-- Total cases vs total deaths
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM [db.Project1] . .CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

--Total cases vs total deaths in the sates. Liklohood of getting covid in the states 
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM [db.Project1] . .CovidDeaths
WHERE LOCATION like '%states%' and continent is not null
ORDER BY 1,2;

-- Total cases vs population in the states. Shows what % of the population in the states got Covid 
SELECT location, date, total_cases,population, (total_cases/population)*100 as cases_percentage
FROM [db.Project1] . .CovidDeaths
WHERE LOCATION like '%states%' and continent is not null
ORDER BY 1,2;


-- Total cases vs population in UK. Shows what % of UK population in the states got Covid 
SELECT location, date, total_cases,population, (total_cases/population)*100 as cases_percentage
FROM [db.Project1] . .CovidDeaths
WHERE LOCATION like '%United Kingdom%' and continent is not null
ORDER BY 1,2;

-- Total cases vs population in Zimbabwe. What % of Zimbabwean population that got covid 
SELECT location, date, total_cases,population, (total_cases/population)*100 as cases_percentage
FROM [db.Project1] . .CovidDeaths
WHERE LOCATION like '%Zimbabwe%' and continent is not null
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population 
SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX ((total_cases/population))*100 as Infected_Population_Percent
FROM [db.Project1] . . CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Infected_Population_Percent desc


-- Reviewing data where contient is not null 
SELECT * 
FROM [db.Project1] . .CovidDeaths
WHERE continent is not null
ORDER BY 3,4;


-- Countries with highest death count per population 
SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM [db.Project1] . . CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc 


-- Breaking data dowen by continent. No null continents included. Below shows continents with the highest death count per population 
SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM [db.Project1] . . CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count desc 



-- Global numbers of total cases, total deaths and the death % across the globe per day
SELECT date, SUM(new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM [db.Project1] . .CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- Joining CovidDeaths tables with the CovidVaccination table. Joining on location and date
SELECT *
FROM [db.Project1]. .CovidDeaths dea
JOIN [db.Project1]. .CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date; 

-- Total population vs vaccination 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [db.Project1]. .CovidDeaths dea
JOIN [db.Project1]. .CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3; 



-- Use CTE
With popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [db.Project1]. .CovidDeaths dea
JOIN [db.Project1]. .CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM popvsvac



-- Temp Table 
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [db.Project1]. .CovidDeaths dea
JOIN [db.Project1]. .CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualisations 
Use [db.Project1]
Go
create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [db.Project1]. .CovidDeaths dea
JOIN [db.Project1]. .CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3


SELECT *
FROM PercentPopulationVaccinated













