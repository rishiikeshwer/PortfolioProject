Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at Total cases Vs Total deaths
Select Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%India'
order by 1,2

--total cases vs population
-- percentage of populatuion got covid

Select Location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%India'
order by 1,2

-- countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as Percentepopulationinfected
From PortfolioProject..CovidDeaths
--Where location like '%India'
Group by Location, population 
order by Percentepopulationinfected desc

--countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..CovidDeaths
--Where location like '%India'
where continent is not null
Group by Location 
order by totaldeathcount desc


--by continent


--showing continents with highest death counts
Select continent, MAX(cast(total_deaths as bigint)) as totaldeathcount
From PortfolioProject..CovidDeaths
--Where location like '%India'
where continent is not null
Group by continent 
order by totaldeathcount desc


--global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%India'
where continent is not null
--Group by date
order by 1,2



--looking at total population vs vaccinations
--use cte (no. of colums should be same in cte and query)

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
AND vac.new_vaccinations is not null
--order by 2,3
)
Select *, (rollingpeoplevaccinated/population)*100
From popvsvac


--temp table

DROP Table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinationa numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--AND vac.new_vaccinations is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100
From #percentpopulationvaccinated


--creating view to store data for later visualizations

Create View percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
From percentpopulationvaccinated
