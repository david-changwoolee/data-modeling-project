{{ config(materialized='table') }}

with distinct_veh as (
	select distinct
	brand_name,
	model_name,
	year,
	body_type,
	drive_type
	from {{ ref('stage') }}
	where 1=1
	and year >= 1900
	and brand_name != 'UNKNOWN'
	and model_name != 'UNKNOWN'
),
ranked_veh as (
	select
	row_number() over (order by brand_name, model_name, year) as vehicle_id,
	brand_name,
	model_name,
	year,
	body_type,
	drive_type
	from distinct_veh
)

select vehicle_id, brand_name, model_name, year, body_type, drive_type from ranked_veh
union all
select -1, 'UNKNOWN', 'UNKNOWN', -1, 'UNKNOWN', 'UNKNOWN'
