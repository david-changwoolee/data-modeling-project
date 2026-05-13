{{ config(materialized='table') }}

with stage as (
	select * from {{ ref('stage') }}
),
games as (
	select * from {{ ref('dim_games') }}
)

select 
s.id as id,
coalesce(g.id, -1) as game_fk,
s.na_sales,
s.eu_sales,
s.jp_sales,
s.other_sales,
s.global_sales
from stage s
left join games g on s.title = g.title and s.platform = g.platform and s.year = g.year and s.genre = g.genre and s.publisher = g.publisher
