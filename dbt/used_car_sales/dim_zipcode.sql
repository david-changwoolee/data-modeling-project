{{ config(materialized='table') }}

with distinct_zips as (
	select distinct zip_code
	from {{ ref('stage') }}
	where 1=1
	and zip_code not like '%*%'
	and zip_code != 'UNKNOWN'
),
ranked_zips as (
	select row_number() over (order by zip_code) as zip_id,
	zip_code
	from distinct_zips
)

select zip_id, zip_code from ranked_zips
union all
select -1 as zip_id, 'UNKNOWN' as zip_code
