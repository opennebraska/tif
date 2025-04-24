# Database

The latest database is [in Dropbox](https://www.dropbox.com/sh/lb1kwtfou7b2kg4/AACAZrrrBOnzRUmgK6ek14a1a?dl=0). You can just download it, and you're done. 

If you want to build the database yourself, continue reading.

`load_db.pl` reads the CSV files in this directory, normalizing them into 2 tables in a sqlite3 database:

    sqlite3 db.sqlite3 < db.sql
    perl refresh_schema.pl
    perl -Ilib load_db.pl | tee load_db.log

## Sample queries

10 largest TIF rebates of 2024:

```sql
.mode box
select p.tif_id, printf("%,d", total_tif_excess_taxes) "rebate ($)", county_name, city_name, name
from project p, year y
where p.tif_id = y.tif_id
and tax_year = 2024
order by total_tif_excess_taxes desc
limit 10;
```

```
┌─────────┬────────────┬─────────────┬──────────────┬─────────────────────────────────────────────────┐
│ tif_id  │ rebate ($) │ county_name │  city_name   │                      name                       │
├─────────┼────────────┼─────────────┼──────────────┼─────────────────────────────────────────────────┤
│ 27-6678 │ 2,505,233  │ DODGE       │ FREMONT      │ COSTCO POULTRY COMPLEX PRJ 1                    │
│ 55-9413 │ 2,136,430  │ LANCASTER   │ LINCOLN      │ GREATER DOWNTOWN PRINC CRDR PROJ  9413          │
│ 28-2390 │ 2,064,685  │ DOUGLAS     │ OMAHA        │ HDR-Aksarben Zone 6                             │
│ 28-2405 │ 2,029,151  │ DOUGLAS     │ OMAHA        │ The Landing                                     │
│ 77-3013 │ 1,817,289  │ SARPY       │ GRETNA       │ NE CROSSINGS OUTLET MALL                        │
│ 28-2246 │ 1,781,421  │ DOUGLAS     │ OMAHA        │ Quad Tech, LLC (Blue Cross Blue Shield Headqtr) │
│ 55-9416 │ 1,565,163  │ LANCASTER   │ LINCOLN      │ SOUTH OF DOWNTOWN                               │
│ 55-9400 │ 1,558,053  │ LANCASTER   │ LINCOLN      │ WEST O REVITALIZATION 9400                      │
│ 40-5076 │ 1,349,349  │ HALL        │ GRAND ISLAND │ PRATARIA VENTURES-HOSPITAL 3533 PRAIRIEVW       │
│ 28-2366 │ 1,087,980  │ DOUGLAS     │ OMAHA        │ Capitol District                                │
└─────────┴────────────┴─────────────┴──────────────┴─────────────────────────────────────────────────┘
```

10 largest cumulative TIF rebates all time:

```sql
WITH data as (
    SELECT p.tif_id, sum(total_tif_excess_taxes) rebate, county_name, city_name, name
    FROM project p, year y
    WHERE p.tif_id = y.tif_id
    GROUP BY 1
)
SELECT tif_id, printf("%,d", rebate) "rebate ($)", county_name, city_name, name
FROM data
ORDER BY rebate desc
LIMIT 10;
```

```
┌─────────┬────────────┬─────────────┬───────────┬─────────────────────────────────────────────────────────────┐
│ tif_id  │ rebate ($) │ county_name │ city_name │                            name                             │
├─────────┼────────────┼─────────────┼───────────┼─────────────────────────────────────────────────────────────┤
│ 28-2218 │ 41,329,091 │ DOUGLAS     │ OMAHA     │ East Campus Realty, LLC                                     │
│ 28-2126 │ 40,221,583 │ DOUGLAS     │ OMAHA     │ 1st National Office Tower                                   │
│ 28-2246 │ 24,870,238 │ DOUGLAS     │ OMAHA     │ Quad Tech, LLC (Blue Cross Blue Shield Headqtr)             │
│ 28-2163 │ 24,413,952 │ DOUGLAS     │ OMAHA     │ Second Amendment Convent.Cntr/Arena Redv.                   │
│ 28-2087 │ 19,595,967 │ DOUGLAS     │ OMAHA     │ Ak-sar-ben Business & Education Campus I (First Data, Corp) │
│ 77-3013 │ 18,560,283 │ SARPY       │ GRETNA    │ NE CROSSINGS OUTLET MALL                                    │
│ 27-6678 │ 16,679,701 │ DODGE       │ FREMONT   │ COSTCO POULTRY COMPLEX PRJ 1                                │
│ 28-2123 │ 14,670,575 │ DOUGLAS     │ OMAHA     │ Gallup University Riverfront Development                    │
│ 28-2390 │ 12,385,815 │ DOUGLAS     │ OMAHA     │ HDR-Aksarben Zone 6                                         │
│ 28-2405 │ 11,379,295 │ DOUGLAS     │ OMAHA     │ The Landing                                                 │
└─────────┴────────────┴─────────────┴───────────┴─────────────────────────────────────────────────────────────┘
```

Walmart TIFs:

```sql
select p.tif_id, printf("%,d", sum(total_tif_excess_taxes)) "rebate ($)", county_name, city_name, name
from project p, year y
where p.tif_id = y.tif_id
and (
       name like '%walmart%'
    or name like '%wal-mart%'
)
group by 1
order by sum(total_tif_excess_taxes) desc;
```
