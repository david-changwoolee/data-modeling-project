import duckdb
con = duckdb.connect('/root/data/duckdb/video_game_sales.db')

### the top sales between na, eu, and jp by year and platform
query = """
select g.year, g.platform
, round(sum(f.na_sales + f.eu_sales + f.jp_sales),2) as total_sales_sum
from fact f
join dim_games g
on f.game_fk = g.id and g.year != 'N/A'
group by g.year, g.platform
order by 3 desc, g.year asc, g.platform asc
"""
con.sql(query).show()


