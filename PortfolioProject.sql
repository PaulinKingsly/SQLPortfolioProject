--SELECT * FROM PortfolioProject.dbo.CovidDeaths 
--ORDER BY 3, 4

--SELECT * FROM PortfolioProject.dbo.CovidVaccinations
--order by 3, 4  

-- Select data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths 
ORDER BY 1, 2

-- Looking at the total_cases vs total_deaths

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS deaths_percentage
FROM PortfolioProject.dbo.CovidDeaths 
WHERE location = 'Russia'
ORDER BY 1, 2

-- Looking at the total_cases vs population

SELECT location, date, total_cases, population, (total_cases / population) * 100 AS percentage
FROM PortfolioProject.dbo.CovidDeaths 
--WHERE location = 'Russia'
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared with population

SELECT location, population, MAX(total_cases) AS highest_infection, MAX((total_cases/population)) * 100 AS percent_of_population_infected
FROM PortfolioProject.dbo.CovidDeaths 
GROUP BY location, population
ORDER BY percent_of_population_infected DESC

-- Showing the countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as total_deaths_count
FROM PortfolioProject.dbo.CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths_count desc

-- Let's break things down by continents

SELECT continent, MAX(cast(total_deaths as int)) as total_deaths_count
FROM PortfolioProject.dbo.CovidDeaths 
WHERE continent IS  NULL
GROUP BY continent
ORDER BY total_deaths_count desc


-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as total_deaths_count
FROM PortfolioProject.dbo.CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths_count desc


-- Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as deaths_percentage
FROM PortfolioProject.dbo.CovidDeaths 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


-- total vaccination vs population

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS deaths
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
ON deaths.location = vac.location
AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL
ORDER BY  2, 3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 