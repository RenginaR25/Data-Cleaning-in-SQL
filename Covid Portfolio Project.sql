Select *
From [dbo].[CovidDeaths_SQL]
	Order by 3,4

Select *
From [dbo].[CovidVaccinations_SQL]
	order by 3,4

--Select data that will be used in this project

Select location, date, total_cases, New_cases, Total_deaths, population
From [dbo].[CovidDeaths_SQL]
	Order by 1,2

--Total Cases vs Total Deaths
Select location, date, total_cases, Total_deaths, (cast(total_deaths as float)/cast(Total_cases as float))*100 as DeathPercentage
From [dbo].[CovidDeaths_SQL]
where location like '%Cana%'
	Order by 1,2

---Highest # of Deaths
Select location, max(Total_deaths)
From [dbo].[CovidDeaths_SQL]
group by location
Order by 1

--Total Cases vs Population
--Shows what % of Population got Covid
Select location, date, population, total_cases, (convert(float, total_cases)/population)*100 as PercentPopulationInfected
From [dbo].[CovidDeaths_SQL]
--where location like '%Cana%'
	Order by 1,2

--Highest Infection Rates compared to Population
Select location, population, max(total_cases) as HighestInfectionCount, (max(cast(total_cases as float))/population)*100 as InfectionRate
From [dbo].[CovidDeaths_SQL]
--where location like '%Cana%'
group by location, population
Order by InfectionRate DESC

--Countries with Highest Death Count per Population
Select location, max(Total_deaths) as HighestDeathsCount
From [dbo].[CovidDeaths_SQL]
where continent is not null
group by location
Order by HighestDeathsCount DESC

---Highest Death Count by Continent
Select location, max(Total_deaths) as HighestDeathsCount
From [dbo].[CovidDeaths_SQL]
where continent is null
group by location
Order by HighestDeathsCount DESC

--Global Numbers 
Select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 
as DeathPercentage
From [dbo].[CovidDeaths_SQL]
where continent is not null
--group by date
	Order by 1,2

--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths_SQL] as dea
Join [dbo].[CovidVaccinations_SQL] as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null --and dea.location like '%cana%'
	order by 2,3

--CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths_SQL] as dea
Join [dbo].[CovidVaccinations_SQL] as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and dea.location like '%cana%'
	--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentRollingPeopleVaccinated
From PopvsVac

Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths_SQL] as dea
Join [dbo].[CovidVaccinations_SQL] as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and dea.location like '%cana%'
	--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentRollingPeopleVaccinated
From #PercentPopulationVaccinated

--Creating view to store data for later visualization

Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths_SQL] as dea
Join [dbo].[CovidVaccinations_SQL] as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and dea.location like '%cana%'
	--order by 2,3