select *
from [dbo].[CoviedDeath$]
order by 3,4
select*
from CoviedVaccinations$
order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from CoviedDeath$
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Egypt

select location , date ,total_cases ,total_deaths ,(total_deaths /total_cases  ) * 100 as DeathPercentage
from CoviedDeath$
where location ='Egypt'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location , date ,population,total_cases,(total_cases/population)*100 PercentageOfCases
from CoviedDeath$
--where location ='Egypt'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location,population,MAX(total_cases),max((total_cases/population))*100 as PercentageOFIfectedPeople 
from CoviedDeath$
group by location,population 
order by PercentageOFIfectedPeople desc



-- Countries with Highest Death Count per Population

select location
, MAX(cast(total_deaths as int)) as DeathPercentage
from CoviedDeath$
where continent is not null 
group by location
order by DeathPercentage desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select date ,sum(new_cases)as totalcases,SUM(new_deaths) as totaldeaths,SUM(new_deaths)/sum(new_cases)*100 as DeathPerCasesPercentage
from CoviedDeath$
where new_cases >0   and continent is not null 
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from CoviedDeath$ dea
join CoviedVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
order by 2,3

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert (int,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location , dea.date) RollingPeopleVaccinated


from CoviedDeath$ dea
join CoviedVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
with popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert (int,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location , dea.date) RollingPeopleVaccinated


from CoviedDeath$ dea
join CoviedVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
--order by 2,3

)

select * ,(RollingPeopleVaccinated/population)*100
from popvsvac



-- Creating Temp Table 


drop table if exists  #PercentPopulationVccinated

create table #PercentPopulationVccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinated numeric

)



insert into #PercentPopulationVccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations

from CoviedDeath$ dea
join CoviedVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 


select * 
from #PercentPopulationVccinated



-- Creating View to store data for later uses

--drop view if exists PercentPopulationVccinated

create view PercentPopulationVccinated as

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location , dea.date) RollingPeopleVaccinated


from CoviedDeath$ dea
join CoviedVaccinations$ vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 

select*
from PercentPopulationVccinated
