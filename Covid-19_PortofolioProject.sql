Select * From [Covid-19]..CovidDeath
where continent is not null 
Order by 3,4

--Select * From [Covid-19]..CovidVaccinate Order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Covid-19]..CovidDeath
Order by 1, 2

--Looking for Total Cases vs Total Deaths
--Show Death Percentage in Indonesia

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) as DeathPercentage
From [Covid-19]..CovidDeath
where location like '%Indonesia%'
Order by 1, 2

--Looking at Total Cases vs Population

Select location, date, total_cases, population, (total_cases/population) as PopulationGotCovidPercentage
From [Covid-19]..CovidDeath
--where location like '%indo%'
Order by 1, 2

--Looking at Country with highest infection rate compared to population

Select location, MAX(total_cases) as HighestInfectionCountry, population, MAX((total_cases/population)) as HighestCountryGotCovidPercentage
From [Covid-19]..CovidDeath
Group by location, population
Order by HighestCountryGotCovidPercentage desc

--Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Covid-19]..CovidDeath
where continent is not null 
Group by location
Order by TotalDeathCount desc

-- DOWN BY CONTINENT

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Covid-19]..CovidDeath
where continent is null 
Group by location
Order by TotalDeathCount desc

--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Covid-19]..CovidDeath
where continent is not null 
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
From [Covid-19]..CovidDeath
--where location like '%Indonesia%'
where continent is not null
--Group by date
Order by 1, 2


--Looking for total population vs total vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated,

From [Covid-19]..CovidDeath dea
join [Covid-19]..CovidVaccinate vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Covid-19]..CovidDeath dea
join [Covid-19]..CovidVaccinate vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Covid-19]..CovidDeath dea
join [Covid-19]..CovidVaccinate vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Covid-19]..CovidDeath dea
join [Covid-19]..CovidVaccinate vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *
From PercentPopulationVaccinated