select *
From ProjectSql..CovidDeaths
order by 3,4

select *
From ProjectSql..CovidVaccinations
order by 3,4

-- Selecionando os dados que usaremos

select location, date, total_cases, new_cases, total_deaths, population
From ProjectSql..CovidDeaths
order by 1,2

-- Analisando o Total cases vs Total Deaths
-- Analidando a probabilidade de morte se você contrair covid no brasil
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectSql..CovidDeaths
Where location like '%brazil%'
order by 1,2


-- Analisando o Total Cases vs Population
-- Mostrando qual porcentagem da população pegou Covid
select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From ProjectSql..CovidDeaths
order by 1,2

-- Olhando para os países com a maior taxa de infecção em comparação com a população

select location, population, MAX(total_cases) as HighestInfectationCount, Max(total_cases/ population)*100 as PercentPopulationInfected
From ProjectSql..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


-- Países com maior contagem de mortes por população

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectSql..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- DIVIDINDO AS COISAS POR CONTINENTE

-- Continentes com a maior contagem de mortes por população

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectSql..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Números Globais

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectSql..CovidDeaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Porcentagem da população que recebeu pelo menos uma vacina Covid

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectSql..CovidDeaths dea
Join ProjectSql..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Usando CTE para realizar cálculo na partição por na consulta anterior

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectSql..CovidDeaths dea
Join ProjectSql..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Usando a tabela temporária para realizar o cálculo na partição por na consulta anterior

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
From ProjectSql..CovidDeaths dea
Join ProjectSql..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

GO
-- Criando View para armazenar dados para visualizações posteriores

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectSql..CovidDeaths dea
Join ProjectSql..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
