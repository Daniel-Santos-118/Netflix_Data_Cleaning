-- handling foreign characters
--select * from netflix_raw
--where show_id='s5023'

-- REMOVE DUPLICATES
select show_id,COUNT(*)
from netflix_raw
group by show_id
having COUNT(*)>1

select * from netflix_raw
select title,COUNT(*)
from netflix_raw
group by title
having COUNT(*)>1

order by title

select * from netflix_raw
where upper(title) in(
select upper(title)
from netflix_raw
group by upper(title)
having COUNT(*)>1
)
order by title

select * from netflix_raw
where concat(upper(title), type) in(
select concat(upper(title), type)
from netflix_raw
group by upper(title), type
having COUNT(*)>1
)

-- query for removing duplicates
/*with cte as (
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix_raw
)
select 8 from cte
where rn=1*/

-- data type conversion
with cte as (
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix_raw
)
select show_id,type,title,cast(date_added as date) as date_added, release_year
,rating,case when duration is null then rating else duration end as duration,description
into netflix
from cte
-- where rn=1 and date_added is null

-- Final Table
select * from netflix

-- new table for listed in, director, country, cast
select show_id, trim(value) as director
into netflix_directors
from netflix_raw
cross apply string_split(director, ',')

select * from netflix_directors

select show_id, trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country, ',')

select * from netflix_country

select show_id, trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast, ',')

select * from netflix_cast

select show_id, trim(value) as genre
into netflix_genre
from netflix_raw
cross apply string_split(listed_in, ',')

select * from netflix_genre


--populate missing values in country, duration columns
select * --show_id,country
from netflix_raw
where country is null

select 8 from netflix_country where show_id='s1001'

select * from netflix_raw where director='Ahishor Solomon'

select director,country
from netflix_country nc
inner join netflix_directors nd on nc.show_id=nd.show_id
group by director,country
order by director

-- THIS POPULATES
insert into netflix_country
select show_id,m.country
from netflix_raw nr
inner join(select director,country
from netflix_country nc
inner join netflix_directors nd on nc.show_id=nd.show_id
group by director,country) m on nr.director=m.director
where nr.country is null
-- THIS POPULATES

----------------------------
select * from netflix_raw where duration is null

