
select *
from [Portfolio Projects]..CovidDeaths
Where continent is not null
order by 3,4

--select *
--from [Portfolio Projects]..CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Projects]..CovidDeaths
order by 1,2


-- Looking at Toal Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Projects]..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2



-- Looking at Totak Cases vs Population
-- Shows what percentage of population got covid

Select location, date, total_cases, Population, total_deaths, (total_deaths/population)*100 as PercentPopulationInfected
from [Portfolio Projects]..CovidDeaths
--Where location like '%States%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Projects]..CovidDeaths
--Where location like '%States%'
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio Projects]..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by location, population
order by TotalDeathCount desc



-- Let's BREAK THINGS DOWN BY CONTINENT


-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio Projects]..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by continent
order by TotalDeathCount desc 



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2



-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
Join [Portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
Join [Portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
Join [Portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
Join [Portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

DROP VIEW [PercentPopulationVaccinated];

Select *
From PercentPopulationVaccinated