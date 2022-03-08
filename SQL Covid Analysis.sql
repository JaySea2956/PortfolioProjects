--Select *
--from PortfolioProject.dbo.COVIDDeaths
--where continent is not null
--order by 3,4


--Select *
--from PortfolioProject.dbo.COVIDVaccinations
--where continent is not null
--order by 3,4 

-- Select the data 

Select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from
	PortfolioProject..COVIDDeaths

where continent is not null

order by 1,2


-- looking at Total Cases vs Total Deaths - Likelihood of dying if you contract COVID
Select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as deathpercentage
from
	PortfolioProject..COVIDDeaths
Where location like '%Canada%',
where continent is not null
order by 1,2


--Looking at Total Cases vs Population - shows what percentage of population got COVID

Select 
	location,
	date,
	population,
	total_cases,	
	(total_cases/ population)*100 as PopulationCOVIDPercent
from
	PortfolioProject..COVIDDeaths
Where location like '%Canada%',
Where continent is not null
order by 1,2

--looking for countries with highest infection rate vs population

Select 
	location,
	population,
	max(total_cases) as HighestInfectionCount,	
	max(total_cases/ population)*100 as MaxPopulationCOVIDPercent
from
	PortfolioProject..COVIDDeaths

where continent is not null

Group by 
	population,
	location
	
order by MaxPopulationCOVIDPercent desc

--showing the countries with the Highest Death Count per Population

Select 
	location,
	max(cast(total_deaths as int)) as TotalDeathCount	

from
	PortfolioProject..COVIDDeaths

where continent is not null

Group by 
	location
	
order by TotalDeathCount desc


--BREAK THINGS DOWN BY CONTINENT
--showing the Continent with the Highest Death Count per Population

--Select 
--	location,
--	max(cast(total_deaths as int)) as TotalDeathCount	

--from
--	PortfolioProject..COVIDDeaths

--where continent is null

--Group by 
--	location
	
--order by TotalDeathCount desc

Select 
	continent,
	max(cast(total_deaths as int)) as TotalDeathCount	

from
	PortfolioProject..COVIDDeaths

where 
	continent is not null

Group by 
	continent
	
order by
	TotalDeathCount desc


-- Global Numbers

--Select 
--	location,
--	date,
--	total_cases,
--	total_deaths,
--	(total_deaths/total_cases)*100 as deathpercentage
--from
--	PortfolioProject..COVIDDeaths
--Where location like '%World%'

--order by 1,2

Select
	--date,
	sum(new_cases) as TotalCases,
	sum(cast(new_deaths as int)) as TotalDeaths,
	sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage

from
	PortfolioProject..COVIDDeaths

where 
	continent is not null
		
--group by date

order by 1,2



--Select 
--	*
--from
--	PortfolioProject..COVIDVaccinations dea
--join
--	PortfolioProject..COVIDVaccinations vac
--	on 
--		dea.location = vac.location
--		and 
--		dea.date = vac.date

--Where dea.continent is not null

--order by 1,2,3

--Looking at Total Population vs Vaccinations

Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100 as RollingVaccinationRatePopulation

from
	PortfolioProject..COVIDDeaths dea
join
	PortfolioProject..COVIDVaccinations vac
	on 
		dea.location= vac.location
	and 
		dea.date = vac.date

where dea.continent is not null

order by 2,3

--USE CTE

with PopVsVac (
	Continent, 
	Location, 
	date, 
	population,
	new_vacinations, 
	RollingPeopleVaccinated)
as
(
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100 as RollingVaccinationRatePopulation

from
	PortfolioProject..COVIDDeaths dea
join
	PortfolioProject..COVIDVaccinations vac
	on 
		dea.location= vac.location
	and 
		dea.date = vac.date

where dea.continent is not null

--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100 as RollPeopVaxdPop
from PopVsVac



--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100 as RollingVaccinationRatePopulation

from
	PortfolioProject..COVIDDeaths dea
join
	PortfolioProject..COVIDVaccinations vac
	on 
		dea.location = vac.location
	and 
		dea.date = vac.date

where dea.continent is not null

--order by 2,3

Select 
	*,
	(RollingPeopleVaccinated/Population)*100 as rollingpplvaxdperpopulation

from #PercentPopulationVaccinated



--Creating View to store data for late visualizations

create view PercentPopulationVaccinated as 

Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	
from
	PortfolioProject..COVIDDeaths dea
join
	PortfolioProject..COVIDVaccinations vac
	on 
		dea.location= vac.location
	and 
		dea.date = vac.date

where dea.continent is not null

--

select 
	*
from PercentPopulationVaccinated