--Looking At TotalCases Vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathVCases
From SQL_Project..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2


--Total cases by population
--Shows what percentage of population contracted covid
Select location,date, population,total_cases,(total_cases/population)*100 As PercentOfPopulation
From SQL_Project..CovidDeaths$
Where location like '%states%'
Order by 1,2

--Countries with highest Infection Rate compared to Population
--Shows what percentage of population was infected by covid
Select location, population,max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 As ContractionPercentage
From SQL_Project..CovidDeaths$
Group by location, population
Order by ContractionPercentage desc


--Showing countries with highest Death Count by Population
Select location,MAX(CAST(Total_Deaths as Int)) as TotalDeathCount
From SQL_Project..CovidDeaths$
--Where location like '%states%'
Where continent is not NULL
Group by location
Order by TotalDeathCount desc


--Showing Continent with highest Death Count by Population
Select location,MAX(CAST(Total_Deaths as Int)) as TotalDeathCount
From SQL_Project..CovidDeaths$
--Where location like '%states%'
Where continent is NULL
Group by location
Order by TotalDeathCount desc


--Global Numbers
Select sum(new_cases) as TotalCases sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(New_deaths as int))/sum(new_cases)*100 as DeathPercentage
From SQL_Project..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2



--Looking at Total Population Vs Total Vaccination

--Using CTE
With PopVsVac (continent, location, date, population,New_Vaccinations, NewTotalVac)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date) as NewTotalVac
from SQL_Project..CovidDeaths$ dea
Join SQL_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (NewTotalVac/population)*100 as PercentPopulationVaccinated
from PopVsVac
order by 2

--Using TempTable
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
NewTotalVac numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date) as NewTotalVac
from SQL_Project..CovidDeaths$ dea
Join SQL_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (NewTotalVac/population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated
order by 2



--Creating View to store data for later visualizaton
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date) as NewTotalVac
from SQL_Project..CovidDeaths$ dea
Join SQL_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
