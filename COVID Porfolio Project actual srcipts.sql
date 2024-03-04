Select *
From CovidDeaths
Where continent is not null --Continent is NULL means that continent replace in Location, we have to get rid of it.
Order by 3,4


Select *
From CovidVaccinations
Order by 3,4


-- Select Data that we are going to be using

--Because the data type is originally nvarchar, we have to change it to numeric for calculation
Alter Table CovidDeaths
Alter Column total_cases numeric

Alter Table CovidDeaths
Alter Column new_cases numeric

Alter Table CovidDeaths
Alter Column total_deaths numeric


Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1,2


--Looking at TotalCases vs TotalDeaths
--Shows likelihood of dying in Vietnam
Select Location, Date, total_cases, total_deaths--, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%Viet%'
and continent is not null
Order by 1,2

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%Viet%'
and continent is not null
Order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, Date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From CovidDeaths
--Where location like '%Viet%' --optional
Order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From CovidDeaths
--Where location like '%Viet%' --optional
Group by location, population
Order by PercentagePopulationInfected desc


--Show Countries with Highest Death Count per Population
Select Location, Max(total_deaths) as TotalDeathCount
From CovidDeaths
--Where location like '%Viet%' --optional
Where continent is not Null
Group by location
Order by TotalDeathCount desc


--Breaking things down by continent
--Showing continents with the highest death count
Select continent, Max(total_deaths) as TotalDeathCount
From CovidDeaths
--Where location like '%Viet%' --optional
Where continent is not Null
Group by continent
Order by TotalDeathCount desc



--Global Numbers
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%Viet%'
Where continent is not null
--Group by date
Order by 1,2
--We have an error 'Divide by zero error encountered'. So let's change 0 in new_cases to Null
	--Update CovidDeaths
	--Set new_cases = Case When new_cases = 0 then Null Else new_cases End
-----------------------------------------------------------------------------------------------------------------------------------------
 
 
 
 
 -- Now We come over CovidVaccinations


--Alter Table CovidVaccinations
--Alter Column new_vaccinations numeric

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --we do a rolling count at new_vaccinations, we do parttition by location cause we want the rolling only going within particular location.
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--We use CTE for that statement because this syntax's so long, we have to Replace that to one CTE name 'PopvsVac'
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --we do a rolling count at new_vaccinations, we do parttition by location cause we want the rolling only going within particular location.
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
From PopvsVac





--OR we can use TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --we do a rolling count at new_vaccinations, we do parttition by location cause we want the rolling only going within particular location.
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
From #PercentPopulationVaccinated



--Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --we do a rolling count at new_vaccinations, we do parttition by location cause we want the rolling only going within particular location.
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated