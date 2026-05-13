with source as (select * from {{ source('main', 'lake') }})

select
  "ID" as id,
  pricesold as price_sold,
  yearsold as year_sold,
  regexp_replace(zipcode, '\s+', '', 'g') as zip_code,
  "Mileage" as mile_age,
  upper("Make") as brand_name,
  upper("Model") as model_name,
  "Year" as year,
  "BodyType" as body_type,
  "DriveType" as drive_type
from source
where 1 = 1
  and "ID" is not null
  and zipcode is not null
  and zipcode not like '%*%'
