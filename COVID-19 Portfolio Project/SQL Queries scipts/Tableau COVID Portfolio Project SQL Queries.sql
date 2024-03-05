-- Table 1. Global Numbers

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%Viet%'
Where continent is not null
--Group by date
Order by 1,2



-- Table 2. Total Death Count per Continent

Select continent, Max(total_deaths) as TotalDeathCount
From CovidDeaths
--Where location like '%Viet%' --optional
Where continent is not Null
and location not in ('World', 'European Union', 'International')
Group by continent
Order by TotalDeathCount desc



-- Table 3 Total Infection by Country

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From CovidDeaths
--Where location like '%Viet%' --optional
Group by location, population
Order by PercentagePopulationInfected desc



-- Table 4 Percentage Population Infected

Select Location, Population, date, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From CovidDeaths
--Where location like '%Viet%' --optional
Group by location, population, date
Order by PercentagePopulationInfected desc
