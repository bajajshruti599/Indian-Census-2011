Select * from ProjectCensus.dbo.Data1;

Select * from ProjectCensus.dbo.Data2;

--Number of rows into our dataset

Select count(*) from ProjectCensus..Data1;
Select count(*) from ProjectCensus..Data2;

--Dataset for Jharkhand and Bihar

Select * from ProjectCensus..Data1 Where State in ('Jharkhand','Bihar');

--Population of India

Select sum(Population) as Total_Population from ProjectCensus..Data2;

--Average Growth

Select AVG(Growth) as Average_Growth from ProjectCensus..Data1;

--Average Growth %

Select AVG(Growth)*100 Average_Growth from ProjectCensus..Data1;

--Average Growth % by State 

Select State, AVG(Growth)*100 Average_Growth from ProjectCensus..Data1
group by State;

--Average Sex Ratio

Select State, round(AVG(Sex_Ratio),0) Average_SexRatio from ProjectCensus..Data1
group by state
order by Average_SexRatio desc;

--Average Literacy Rate

Select State, Round(Avg(Literacy),0) Average_Literacy from ProjectCensus..Data1
Group by State
Having Round(Avg(Literacy),0)>90
order by Average_Literacy desc;

--Top 3 states showing highest Average Growth %

Select Top 3 State, (Avg(Growth)*100) as Maximum_Growth from ProjectCensus..Data1
Group by state
Order by maximum_Growth desc;

--Bottom 3 states showing lowest Sex Ratio

Select Top 3 State, AVG(Sex_Ratio) Average_SexRatio from ProjectCensus..Data1
Group by State
Order by Average_SexRatio asc;

--Top states in literacy Ratio

Drop table if exists #Topstates;

Create table #TopStates
(
  State nvarchar(255),
  topstates float
  )

insert into #TopStates
Select state, ROUND(Avg(literacy),0) Average_Literacy_Ratio from ProjectCensus..Data1
Group by state
Order by ROUND(Avg(literacy),0) desc;

Select Top 3 * from #TopStates
order by #TopStates.topstates desc;


--Bottom States in Literacy Ratio

Drop table if exists #Bottomstates;

Create table #BottomStates
(
  State nvarchar(255),
  Bottomstates float
  )

insert into #BottomStates
Select state, ROUND(Avg(literacy),0) Average_Literacy_Ratio from ProjectCensus..Data1
Group by state
Order by ROUND(Avg(literacy),0) desc;

Select Top 3 * from #BottomStates
order by #BottomStates.Bottomstates asc;

--UNION OPERATOR

Select * from(Select Top 3 * from #TopStates
order by #TopStates.topstates desc) a

UNION

Select * from (Select Top 3 * from #BottomStates
order by #BottomStates.Bottomstates asc) b;

--States starting with letter a or b

Select distinct(state) from ProjectCensus.dbo.Data1
where state like 'a%' or  state like 'b%';

--States starting with letter a AND ends with letter s

Select distinct(state) from ProjectCensus.dbo.Data1
where state like 'a%' AND  state like '%S';

--Joining both tables

select a.district, a.state, a.sex_ratio, b.population from ProjectCensus..Data1 a inner join ProjectCensus..Data2 b
on a.district = b.District

---To Find the Total number of Males and Total Number of Females on District level

--Sex Ratio = Total Females / Total Males   ->(Equation 1)
--Total Population = Total Females + Total Males  ->(Equation 2)
--Total Females = Total Population - Total Males   ->(Equation 3)

--Putting Equation 3 in Equation 1
--Sex Ratio = (Total Population - Total Males)/Total Males
--(Sex Ratio)Total Males= Total Population - Total Males
--[(Sex Ratio)Total Males]+Total Males = Total Population
--Total Males(Sex Ratio + 1)=Total Population
--Total Males= Total Population / Sex Ratio+1  ->(Equation 4)

--Referring Equation 3 and 4 for calculating Total Females
--Total Females = Total Population - (Total Population / Sex Ratio+1)
--Total Females = Total Population(1-1/Sex Ratio+1)
--Total Females = Total Population * ( Sex Ratio /Sex Ratio + 1)  ->(Equation 5)


select c.district, c.state, ROUND(c.population/(c.Sex_Ratio+1),0) Males, ROUND(c.Population * (c.Sex_Ratio/c.Sex_Ratio+1),0) Females from 
(
select a.district, a.state, a.sex_ratio/1000 Sex_Ratio, b.population from ProjectCensus..Data1 a inner join ProjectCensus..Data2 b
on a.district = b.District
) c

---To Find the Total number of Males and Total Number of Females on State level

select d.state, sum(d.males) Total_Males, sum(d.females) Total_Females from 
(
select c.district, c.state, ROUND(c.population/(c.Sex_Ratio+1),0) Males, ROUND(c.Population * (c.Sex_Ratio/c.Sex_Ratio+1),0) Females from 
(
select a.district, a.state, a.sex_ratio/1000 Sex_Ratio, b.population from ProjectCensus..Data1 a inner join ProjectCensus..Data2 b
on a.district = b.District
) c)d
group by d.State

--LITERACY ON DISTRICT LEVEL
--Literacy Ratio = Total Literate People / Total Population
--Total Literate People = Literacy Ratio * Total Population

--Total Population = Total Literate People + Total Illiterate People
--Total Illiterate People = Total Population - Total Literate People
--Total Illiterate People = Total Population - (Literacy Ratio * Total Population)
--Total Illiterate People = Total Population(1-Literacy Ratio)

Select c.district, c.State, c.Literacy_Ratio * c.Population Literate_Population, c.Population * (1-c.Literacy_Ratio) Illiterate_Population from
(
select a.District, a.State, a.Literacy/100 Literacy_Ratio, b.Population from ProjectCensus..Data1 a inner join ProjectCensus..Data2 b
ON a.District = b.District)c


--LITERACY ON STATE LEVEL

select d.State, ROUND(sum(d.Literate_Population),0) Total_Literate_Population, ROUND(sum(d.Illiterate_Population),0) Total_Illiterate_Population from
(
Select c.district, c.State, c.Literacy_Ratio * c.Population Literate_Population, c.Population * (1-c.Literacy_Ratio) Illiterate_Population from
(
select a.District, a.State, a.Literacy/100 Literacy_Ratio, b.Population from ProjectCensus..Data1 a inner join ProjectCensus..Data2 b
ON a.District = b.District)c)d
GROUP BY d.State


--CALCULATION OF PREVIOUS CENSUS ON DISTRICT LEVEL
--Assume Previous Census was 100 and Growth rate is 10%, so, current census would be 100+10% of 100 = 110
--Current Census = Previous Census + Growth% of Previous Census
--Previous Census (1+Growth/100)= Current Census
--Previous Census = Current Census / (1+Growth/100)

--As per our current data
--Previous Census= Population / (1+Growth)

select c.district, c.state,c.Population/(1+c.Growth) Previous_Census_Population, c.Population Current_Census_Population from
(Select  a.District, a.State, a.Growth, b.Population from ProjectCensus..Data1 a inner join ProjectCensus..Data2 b
ON a.District = b.District)c

--PREVIOUS CENSUS ON STATE LEVEL

select d.state, ROUND(sum(d.Previous_Census_Population),0) PreviousCensus, sum(d.Current_Census_Population)currentCensus from
(
select c.district, c.state,c.Population/(1+c.Growth) Previous_Census_Population, c.Population Current_Census_Population from
(Select  a.District, a.State, a.Growth, b.Population from ProjectCensus..Data1 a inner join ProjectCensus..Data2 b
ON a.District = b.District)c)d
group by state;

--AGGREGATE TOTAL POPULATION OF INDIA OF PREVIOUS CENSUS AND CURRENT CENSUS

Select  sum(m.PreviousCensus) Total_Previous_Census_Population,  sum(m.currentCensus) Total_Current_Census_Population from
(select d.state, ROUND(sum(d.Previous_Census_Population),0) PreviousCensus, sum(d.Current_Census_Population)currentCensus from
(select c.district, c.state,c.Population/(1+c.Growth) Previous_Census_Population, c.Population Current_Census_Population from
(Select  a.District, a.State, a.Growth, b.Population from ProjectCensus..Data1 a inner join ProjectCensus..Data2 b
ON a.District = b.District)c)d
group by state)m


--With an increase of Population How much area has been reduced
--Population vs Area


select (g.Total_area/g.Total_Current_Census_Population) Current_Census_Population_vs_Area , 
(g.Total_area/g.Total_Previous_Census_Population)  Previous_Census_Population_vs_Area from
(select q.*,r.Total_area from
(select '1' as Keyy, n.* from
(Select  sum(m.PreviousCensus) Total_Previous_Census_Population,  sum(m.currentCensus) Total_Current_Census_Population from
(select d.state, ROUND(sum(d.Previous_Census_Population),0) PreviousCensus, sum(d.Current_Census_Population)currentCensus from
(select c.district, c.state,c.Population/(1+c.Growth) Previous_Census_Population, c.Population Current_Census_Population from
(Select  a.District, a.State, a.Growth, b.Population from ProjectCensus..Data1 a inner join ProjectCensus..Data2 b
ON a.District = b.District)c)d
group by d.state)m)n)q 

inner join

(
select '1' as keyy, z.* from(
select sum(area_km2) Total_area from ProjectCensus..Data2)z) r

on q.Keyy = r.keyy)g


--Top 3 districts from each state with highest literacy rate

select a.State, a.District,a.rnk from
(select  state, district, literacy, rank() over (partition by state order by literacy desc)rnk from ProjectCensus..Data1
)a
where a.rnk in (1,2,3)
order by state;

--Growth %
--Current Census = Previous Census * Growth%
--Growth% = Current Census / Previous Census

select ROUND((r.Total_Current_Census_Population / r.Total_Previous_Census_Population),0) Growth_Percentage from
(Select  sum(m.PreviousCensus) Total_Previous_Census_Population,  sum(m.currentCensus) Total_Current_Census_Population from
(select d.state, ROUND(sum(d.Previous_Census_Population),0) PreviousCensus, sum(d.Current_Census_Population)currentCensus from
(select c.district, c.state,c.Population/(1+c.Growth) Previous_Census_Population, c.Population Current_Census_Population from
(Select  a.District, a.State, a.Growth, b.Population from ProjectCensus..Data1 a inner join ProjectCensus..Data2 b
ON a.District = b.District)c)d
group by state)m)r