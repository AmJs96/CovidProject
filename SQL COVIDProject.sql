Select *
From COVIDProject..CovidDeaths$
Order by 3,4       


Select location, date, total_cases,new_cases,total_deaths,population
From COVIDProject..CovidDeaths$ 
Order by 1,2      

--total cases vs total deaths
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From COVIDProject..CovidDeaths$
where location like '%Thai%'
Order by 1,2
                        

-- total cases vs population  
-- show percentage of population got covid 
Select location, date, total_cases,population, (total_cases/population)*100 as DeathPercentage
From COVIDProject..CovidDeaths$
where location like '%thai%'
Order by 1,2    

Select location, date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
From COVIDProject..CovidDeaths$
Order by 1,2   

--Countries with hieghest infetion rate compared to population     
Select location,population, max(total_cases) as HighestInfection,max((total_cases/population))*100 as PercentLocationInfected
From COVIDProject..CovidDeaths$
Group by location,population
Order by PercentLocationInfected desc   

-- Countries with highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From COVIDProject..CovidDeaths$
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Break down by continent
-- Continent with highest death count per population    

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From COVIDProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc     

--Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From COVIDProject..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2    


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From COVIDProject..CovidDeaths$
Where continent is not null
Order by 1,2 

-- join 
Select *
From COVIDProject..CovidDeaths$ d
Join COVIDProject..CovidVaccinations$ v 
    on d.location = v.location
    and d.date = v.date     
	
-- total population vs vaccination 
Select d.continent, d.location, d.date , d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location,d.date)
as RollingPeopleVaccinated
From COVIDProject..CovidDeaths$ d
Join COVIDProject..CovidVaccinations$ v 
    on d.location = v.location
    and d.date = v.date
Where d.continent is not null
Order by 2,3      


-- use CTE       
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDProject..CovidDeaths$ d
Join COVIDProject..CovidVaccinations$ v 
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
)
Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac 



-- Temp Table
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
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated

From COVIDProject..CovidDeaths$ d
Join COVIDProject..CovidVaccinations$ v
	On d.location = v.location
	and d.date = v.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 



--  Create view to store data for visualizations 
Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From COVIDProject..CovidDeaths$ d
Join COVIDProject..CovidVaccinations$ v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
           
Select *
From PercentPopulationVaccinated                                                                                                                                                                                                                                                                                                                                