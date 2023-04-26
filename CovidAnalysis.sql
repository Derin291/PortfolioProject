select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4

-- Select Data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at the total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
where location like '%king%'
order by 1,2

--Total cases vs Population
-- Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%king%'
where continent is not null
order by 1,2

--Looking at countries with highest infection rate comared to population 
select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%king%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Countries with the highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%king%'
where continent is not null
group by location
order by TotalDeathCount desc

--Results by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%king%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Continents with the highest death count per population

select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%king%'
where continent is not null
order by 1,2

--GLOBAL NUMBERS

select date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%king%'
where continent is not null
Group by date
order by 1,2


--Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent  is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualisations

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated