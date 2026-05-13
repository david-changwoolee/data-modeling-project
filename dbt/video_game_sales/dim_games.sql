{{ config(materialized='table') }}

with distinct_games as (
	select distinct title, platform, year, genre, publisher
	from {{ ref('stage') }}
),
ranked_games as (
	select row_number() over (order by title, platform, year, genre, publisher) as id,
	title, platform, year, genre, publisher
	from distinct_games
)

select id, title, platform, year, genre, publisher from ranked_games
union all
select -1 as id, 'UNKNOWN' as title, 'UNKNOWN' as platform, -1 as year, 'UNKNOWN' as genre, 'UNKNOWN' as publisher
