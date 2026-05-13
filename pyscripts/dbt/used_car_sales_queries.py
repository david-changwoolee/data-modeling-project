import duckdb
con = duckdb.connect('/root/data/duckdb/used_car_sales.db')

### the best-selling car brand
query = """
select v.brand_name, count(v.brand_name) as cnt
from fact f
join dim_vehicles v
on f.vehicle_fk = v.vehicle_id and v.vehicle_id != -1
group by v.brand_name
order by 2 desc
limit 20
"""
#con.sql(query).show()

### the best-selling by region
query = """
select * from(select z.zip_code, v.brand_name, count(*) as cnt
from fact f
join dim_vehicles v
on f.vehicle_fk = v.vehicle_id and v.vehicle_id != -1
join dim_zipcode z
on f.zip_fk = z.zip_id and z.zip_id != -1
group by z.zip_code, v.brand_name)
where cnt>=20
order by zip_code, brand_name
"""
con.sql(query).show()
