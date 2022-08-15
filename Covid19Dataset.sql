/*

Working with covid 19 live data

Content: Windows Functions, Aggregate Functions, Creating Views, Converting Data Types, Joins, CTE's, Temp Tables, 

*/



SELECT *
FROM hypnotic-pier-353714.Portfolio1.covidDeaths
ORDER BY 3, 4

SELECT *
FROM hypnotic-pier-353714.Portfolio1.covidVaccinations
ORDER BY 3, 4



--to select the data we will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM hypnotic-pier-353714.Portfolio1.covidDeaths
WHERE continent is not null
ORDER BY 1, 2


--LOOKING AT TOTAL CASES VS TOTAL DEATH
--Shows likelihood of dying if you contact covid 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathPercentage
FROM hypnotic-pier-353714.Portfolio1.covidDeaths
WHERE continent is not null
ORDER BY 1, 2


--Looking at the total cases vs population
--shows the percentage that got covid
Select location, date, population, total_cases, (total_cases/population)* 100 AS PercentagePopulationInfected
From hypnotic-pier-353714.Portfolio1.covidDeaths
WHERE continent is not null
Order BY 1, 2



--Looking at countries with the highest infetion rate compared to population
SELECT location, population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM hypnotic-pier-353714.Portfolio1.covidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 desc



--Looking at countries with the highest death rate compared to population
SELECT location, MAX(total_deaths) AS totalDeathCount
FROM hypnotic-pier-353714.Portfolio1.covidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 desc

--BY CASTING OR CONVERTING
SELECT location, MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM hypnotic-pier-353714.Portfolio1.covidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 desc
--...
--CONVERTING
SELECT location, MAX(CONVERT(int,total_deaths)) AS totalDeathCount
FROM hypnotic-pier-353714.Portfolio1.covidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 desc
 

--BEARKING THINGS DOWN BY CONTINENT
--Showing exact death count per continent
--showing the continents with the most highest death count
SELECT location, MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM hypnotic-pier-353714.Portfolio1.covidDeaths
WHERE continent is null
GROUP BY location
ORDER BY 2 desc




--GLOBAL NUMBERS
--To show the total number of cases and deaths per date with the daily death percentage
SELECT date, SUM(new_cases) AS New_Cases, SUM(CAST(new_deaths AS INT)) AS New_Deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS deathPercentage
FROM hypnotic-pier-353714.Portfolio1.covidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


--To show the total number of both cases and death globally 
SELECT SUM(new_cases) AS New_Cases, SUM(CAST(new_deaths AS INT)) AS New_Deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS deathPercentage
FROM hypnotic-pier-353714.Portfolio1.covidDeaths
WHERE continent is not null
ORDER BY 1, 2



--Looking at total vaccination vs population
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(CAST(vacc.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM hypnotic-pier-353714.Portfolio1.covidDeaths dea
JOIN hypnotic-pier-353714.Portfolio1.covidVaccinations vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is not null
ORDER BY 2, 3



--Using CTE

WITH popvsvacc ( continent, location, date, population, RollingPeopleVaccinated )
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(CAST(vacc.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM hypnotic-pier-353714.Portfolio1.covidDeaths dea
JOIN hypnotic-pier-353714.Portfolio1.covidVaccinations vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is not null)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM popvsvacc




--Create Temp Table

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated





--creating view to store data for later vizualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
