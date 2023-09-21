
Select * from Census.dbo.Data1; --here we have to write database name then dot(.) then dbo then again dot(.)then your dataset name(table name)

Select * from Census.dbo.Data2;

--Number of rows in Dataset 1

Select count(*) from Census..Data1; --here we you don't want to use dbo then use 2 dots after database name and then dataset name or table name
Select count(*) from Census..Data2;

--Dataset for Jharkhand and Bihar

select * from census..data1 where state in ('Jharkhand', 'Bihar')

--Population of India

Select Sum(Population) as Population from Census..Data2;

--Average Growth Percentage

select avg(growth)*100 Average_Growth from Census..Data1;

--Average Growth Percentage by state, here we need to use Group by clause to combine the result in column b for each state's different values in dataset 1.
--For Example: If we need to aggregate each entry of Jharkhand then we need to group it to get result in single value

select state,avg(growth)*100 Average_Growth from Census..Data1 --Multiply by 100 to get average in percentage
group by state;

--Average Sex Ratio
select state,round(avg(Sex_Ratio),0) Average_SexRatio from Census..Data1 --Getting Average in Integer
group by state
order by Average_SexRatio desc;

select state,avg(Sex_Ratio) as Average_SexRatio from Census..Data1 --Getting average in decimal
group by state;

--Average Literacy Rate
select state,round(avg(Literacy),0) Average_Literacy_Ratio from Census..Data1
group by state
having round(avg(Literacy),0)>90
order by Average_Literacy_Ratio desc;

--Top 3 states have highest growth rate

select Top 3 state,avg(growth)*100 Average_Growth from Census..Data1
group by state
order by Average_Growth;

--Bottom 3 states in lowest sex ratio

select Top 3 state,round(avg(Sex_Ratio),0) Average_SexRatio from Census..Data1
group by state
order by Average_SexRatio asc;

--Top and Bottom 3 states in Literacy rate 

drop table if exists Top3states;
create table Top3states
(
state nvarchar(255),
topstate float
)
insert into Top3states select state,round(avg(Literacy),0) Average_Literacy from Census..Data1
group by state
order by Average_Literacy desc;

select top 3 * from Top3states
order by Top3states.topstate desc;


drop table if exists Bottom3states;
create table Bottom3states
(
state nvarchar(255),
bottomstate float
)
insert into Bottom3states select state,round(avg(Literacy),0) Average_Literacy from Census..Data1
group by state
order by Average_Literacy;

select top 3 * from Bottom3states
order by Bottom3states.bottomstate;


--Adding new column in the existing table
Alter table Bottom3states
Add New_column varchar(100)
select * from Bottom3states

--Modify datatype and size of existing column
select * from census..data1

Alter table census..data1
Alter column Literacy integer;
select * from census..data1

 
--Union Operator

select * from (
select top 3 * from Top3states
order by Top3states.topstate desc)a

union

select * from (
select top 3 * from Bottom3states
order by Bottom3states.bottomstate asc)b;


--States starting with Letter a 
select distinct state from Census..Data1 
where state like 'A%' or state like 'B%';

--States starting with Letter a and ends with letter d

select distinct state from Census..Data1 
where state like 'A%' and state like '%D';

--States starting with Letter a or ends with letter d

select distinct state from Census..Data1 
where state like 'A%' or state like '%D';

--joining both table
--Inner join returns rows when there is a match in both the tables
select a.District, a.State, a.Sex_Ratio/1000 Sex_Ratio, b.Population from Census..Data1 a inner join Census..Data2 b on a.District = b.District 
---Divided by 1000 to get sex ratio in decimals according to the formula of Indian Census

--Display Males and Females data on District level

 select c.district, c.state, round(c.Population/(c.sex_Ratio +1),0) TotalMales, round(c.Population*(c.sex_Ratio)/c.sex_ratio+1,0) TotalFemales from
(select a.District, a.State, a.Sex_Ratio, b.Population from Census..Data1 a inner join Census..Data2 b on a.District = b.District) c


--Dispaly Males and Females data on State level

 select d.state, sum(d.Males) Total_Males,sum(d.Females) Total_Females from
 (select c.district, c.state, round(c.Population/(c.sex_Ratio +1),0) Males, round(c.Population*(c.sex_Ratio)/c.sex_ratio+1,0) Females from
(select a.District, a.State, a.Sex_Ratio, b.Population from Census..Data1 a inner join Census..Data2 b on a.District = b.District) c) d
group by d.state;


--Total Literacy Rate
select c.state, sum(c.literate_people)Total_Literate_People, sum(c.Illiterate_people)Total_Illiterate_People from
(select d.District,d.State,round(d.literacy_ratio*d.population,0) literate_People, round((1-d.literacy_ratio)* d.population,0) Illiterate_People from
(select a.District, a.State, a.Literacy/b.Population Literacy_Ratio, b.Population from Census..Data1 a inner join Census..Data2 b on a.District = b.District) d)c
group by c.state


--Population in previous census

select sum(e.Total_previouscensus)Total_previouscensus,sum(e.Total_currentcensus) Total_currentcensus from
(
select c.state, sum(c.Previous_Census) Total_previouscensus , sum(c.Current_Census) Total_currentcensus from
(
select d.district, d.state , d.Growth, d.Population Current_Census, round(d.Population/(1+Growth),0) Previous_Census from 
(
select a.district, a.state, a.Growth,b.Population from Census..Data1 a inner join Census..Data2 b on a.District=b.District) d)c

group by c.state) e


  