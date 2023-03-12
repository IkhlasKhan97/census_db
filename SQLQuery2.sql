select District , State , Growth , Sex_Ratio , round (Literacy ,0) Literacy
from indian_census.dbo.first;

select *
from indian_census.dbo.second;



/* No of Rows in our data set*/

select count (*) from indian_census..first;
select count (*) from indian_census..second;

/* Select condition */

select count (*) from indian_census..first where State in ('Jammu and Kashmir');
select * from indian_census..first where State in ('Jammu and Kashmir');

/* population */
select * from indian_census..second;

select sum(population) as Population from indian_census..second;

/* Average Function */

select avg(growth)*100 Average_Growth from indian_census..first;

select state , avg(growth)*100 Average_Growth from indian_census..first group by state;

DELETE FROM indian_census..first where State = 'State' ;

select state as State, round(avg(Sex_Ratio),0) as Average_Sex_Ratio from indian_census..first
group by state order by Average_Sex_Ratio desc;

/* Average Literacy rate of Country*/
select AVG(Literacy) Average_Literacy from indian_census..first;

/*Average literacy rate of all states in descending order */
select state as State , round(avg(Literacy),0) as Average_Literacy_Rate from indian_census..first
group by state order by Average_Literacy_Rate desc;

/* Where clause is used to filter out the rows and Having clause is used on aggregated rows */
select * from indian_census..first where State = 'Kerala';

/* State having literacy rate less than 90 */
select state as State , round(avg(Literacy),0) as Average_Literacy_Rate from indian_census..first
group by state having round (avg (literacy),0) < 90 order by Average_Literacy_Rate ASC  ;

/* State having literacy rate more than 90 */
select state as State , round(avg(Literacy),0) as Average_Literacy_Rate from indian_census..first
group by state having round (avg (literacy),0) > 90 order by Average_Literacy_Rate DESC  ;

/* Three states having highest growth rate*/
select top 3 state , round (avg(growth)*100 , 0) Average_Growth from indian_census..first group by state order by Average_Growth desc;

/* Three states having lowest growth rate*/
select top 3 state , round (avg(growth)*100 , 0) Average_Growth from indian_census..first group by state order by Average_Growth asc;


/* Three states having the highest literacy rate */
select top 3 state , round (avg(Literacy) , 0) as Average_Literacy_Rate from indian_census..first group by state order by Average_Literacy_Rate desc; 

/* Three states having the lowest literacy rate */
select top 3 state , round (avg(Literacy) , 0) as Average_Literacy_Rate from indian_census..first group by state order by Average_Literacy_Rate asc; 

/* Three states having the highest sex ratio*/
select top 3 state , round (avg(sex_ratio) , 0) as Average_Sex_ratio from indian_census..first group by state order by Average_Sex_ratio desc;

/* Three states having the lowest sex ratio*/
select top 3 state , round (avg(sex_ratio) , 0 ) as Average_Sex_ratio from indian_census..first group by state order by Average_Sex_ratio asc;


/* Temporary Tables Concept*/

drop table if exists #top_states
create table #top_states

(state nvarchar (255),
  topstate float
)
insert into #top_states 
select state , round (avg(Literacy) , 0) as Average_Literacy_Rate from indian_census..first group by state order by Average_Literacy_Rate desc;

SELECT top 3 * FROM #top_states order by #top_states.topstate desc;


drop table if exists #bottom_states
create table #bottom_states

(state nvarchar (255),
  bottomstate float
)
insert into #bottom_states 
select state , round (avg(Literacy) , 0) as Average_Literacy_Rate from indian_census..first group by state order by Average_Literacy_Rate asc;

SELECT top 3 * FROM #bottom_states order by #bottom_states.bottomstate asc;


SELECT * from (select top 3 * FROM #top_states order by #top_states.topstate desc) a 
UNION
SELECT * from (select top 3 * FROM #bottom_states order by #bottom_states.bottomstate asc) b ;


/* States satarting with letter A */

select distinct State from indian_census..first where state like 'a%'  or   state like 'b%';


select distinct State from indian_census..first where state like '%a'  or   state like '%b';


/*
female/male = sex_ratio  --------1 
female+male = population --------2

female = population-male --------3 adding value in equation 1
(population-male) = sex_ratio*male

population = male(sex_ratio + 1 )

male = population/(sex_ratio + 1)  for calculating no of males 

Adding value of male in equation 3 

female = population - population/(sex_ratio + 1)
female = population (1 - 1/(sex_ratio + 1))
female = (population * (sex_ratio))/(sex_ratio + 1)
*/

 /* total male and female of each state */
select d.state , sum(d.male) total_males , sum(d.female) total_females from 
(select c.district , c.state , round (c.population/(c.sex_ratio + 1) , 0) Male , round ((c.population * (c.sex_ratio))/(c.sex_ratio + 1) , 0) Female from 
(select a.district , a.state , a.sex_ratio/1000 sex_ratio, b.population from indian_census.. first a  join
indian_census..second b on a.district = b.district ) c ) d
group by d.state;

 /* total male and female of each district */
select c.district , c.state , round (c.population/(c.sex_ratio + 1) , 0) Male , round ((c.population * (c.sex_ratio))/(c.sex_ratio + 1) , 0) Female from 
(select a.district , a.state , a.sex_ratio/1000 sex_ratio, b.population from indian_census.. first a  join
indian_census..second b on a.district = b.district ) c 

/*
total_literate_people/population = literacy_ratio
total_literate_people = population*literacy_ratio
total_illiterate_people = (1- literacy_ratio)*population
total_illiterate_people = d.population- (d.literacy_ratio*d.population)

*/

/* total Literate and Illiterate people of each district */

select d.state , sum(Total_Literate_People) as Total_Literate_People ,sum(Total_Illiterate_People) as Total_Illiterate_People from 
(select c.district as District , c.state as State ,round (c.literacy_ratio*c.population , 0) as Total_Literate_People , round ((1- c.literacy_ratio)*c.population,0) Total_Illiterate_People from 
(select  a.District , a.State , a.literacy/100 Literacy_ratio, b.Population from indian_census.. first a  join
indian_census..second b on a.District = b.District) c) d
group by d.state

/*

population = previous_census + growth*previous_census
population= previous_census(1+growth)
previous_census = population / 1 + growth

*/
/* State wise Previous Population */ 

select d.state as State  , sum (d.Previous_Population) as Previous_Population , sum (d.Current_Population) as Current_Population  from 
(select c.district  , c.state , round (c.population / (1 + c.growth) , 0) as Previous_Population , c.Population as Current_Population from 
(select a.district , a.state , a.growth as growth , b.population from indian_census..first a inner join
indian_census..second b on a.district = b.district) c) d 
group by d.state

/* Total Previous Population of India*/


select sum(e.Previous_Population) as Total_Previous_Population , sum(e.Current_Population) as Total_Current_Population from (
select d.state as State  , sum (d.Previous_Population) as Previous_Population , sum (d.Current_Population) as Current_Population  from 
(select c.district  , c.state , round (c.population / (1 + c.growth) , 0) as Previous_Population , c.Population as Current_Population from 
(select a.district , a.state , a.growth as growth , b.population from indian_census..first a inner join
indian_census..second b on a.district = b.district) c) d 
group by d.state ) e 