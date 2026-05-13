{{ config(materialized='table') }}

with stage as (
	select * from {{ ref('stage') }}
),
zip as (
	select * from {{ ref('dim_zipcode') }}
),
veh as (
	select * from {{ ref('dim_vehicles') }}
)

select 
s.id as id,
coalesce(z.zip_id, -1) as zip_fk,
coalesce(v.vehicle_id, -1) as vehicle_fk,
s.price_sold,
s.year_sold,
s.mile_age
from stage s
left join zip z on s.zip_code = z.zip_code
left join veh v on s.brand_name = v.brand_name
and s.model_name = v.model_name
and s.year = v.year
and s.body_type = v.body_type
and s.drive_type = v.drive_type
