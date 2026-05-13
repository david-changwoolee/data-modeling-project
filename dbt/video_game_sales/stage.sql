with source as (select * from {{ source('main', 'lake') }})

select
  "Rank" as id,
  upper("Name") as title,
  upper("Platform") as platform,
  "Year" as year,
  upper("Genre") as genre,
  upper("Publisher") as publisher,
  "NA_Sales" as na_sales,
  "EU_Sales" as eu_sales,
  "JP_Sales" as jp_sales,
  "Other_Sales" as other_sales,
  "Global_Sales" as global_sales
from source
where 1 = 1
  and "Rank" is not null
