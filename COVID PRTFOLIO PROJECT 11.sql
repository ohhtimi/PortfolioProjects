select *
from PortfolioProject_new..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject_new..CovidDeaths$
--order by 4,5

-- select data that we are goin to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject_new..CovidDeaths$
order by 1,2


-- Looking at the total cases vs total deaths
-- shows the likelihood of dying if you contacted covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject_new..CovidDeaths$
where location like '%Nigeria%'
order by 1,2


-- looking at Total cases vs population
-- shows what percentage of population got covid
select location, date, total_cases, population,(total_deaths/population)*100 as DeathPercentage
from PortfolioProject_new..CovidDeaths$
where location like '%Nigeria%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestinfectionCount,MAX((total_deaths/population))*100 as PercentagePopulationInfected
from PortfolioProject_new..CovidDeaths$
--where location like '%Nigeria%'
group by location, population
order by PercentagePopulationInfected desc

-- showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject_new..CovidDeaths$
--where location like '%Nigeria%'
where continent is null
group by location
order by TotalDeathCount desc

-- showing continenets with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject_new..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject_new..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2


-- looking at total populoation vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject_new..CovidDeaths$ dea
join PortfolioProject_new..covidvaccinations$ vac
      on dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE 

with PopvsVac (continent, Location, Data, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject_new..CovidDeaths$ dea
join PortfolioProject_new..covidvaccinations$ vac
      on dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From popvsVac


--TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject_new..CovidDeaths$ dea
join PortfolioProject_new..covidvaccinations$ vac
      on dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated


--creating view to store data for later
Create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject_new..CovidDeaths$ dea
join PortfolioProject_new..covidvaccinations$ vac
      on dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
--order by 2,3