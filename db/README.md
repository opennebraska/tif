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
and tax_year = 2025
order by total_tif_excess_taxes desc
limit 10;
```

```
┌─────────┬────────────┬─────────────┬──────────────┬───────────────────────────────────────────┐
│ tif_id  │ rebate ($) │ county_name │  city_name   │                   name                    │
├─────────┼────────────┼─────────────┼──────────────┼───────────────────────────────────────────┤
│ 27-6678 │ 2,877,484  │ DODGE       │ FREMONT      │ COSTCO POULTRY COMPLEX PRJ 1              │
│ 56-0035 │ 2,437,565  │ LINCOLN     │ NORTH PLATTE │ SUSTAINABLE BEEF, LLC REDEV PROJ          │
│ 55-9413 │ 2,205,030  │ LANCASTER   │ LINCOLN      │ GREATER DOWNTOWN PRINC CRDR PROJ  9413    │
│ 28-2390 │ 2,088,003  │ DOUGLAS     │ OMAHA        │ HDR-Aksarben Zone 6                       │
│ 28-2405 │ 2,052,068  │ DOUGLAS     │ OMAHA        │ The Landing                               │
│ 55-9400 │ 1,812,319  │ LANCASTER   │ LINCOLN      │ WEST O REVITALIZATION 9400                │
│ 77-3013 │ 1,805,197  │ SARPY       │ GRETNA       │ NE CROSSINGS OUTLET MALL                  │
│ 55-9416 │ 1,687,572  │ LANCASTER   │ LINCOLN      │ SOUTH OF DOWNTOWN                         │
│ 28-2458 │ 1,447,378  │ DOUGLAS     │ OMAHA        │ River Crossing Phase 1a                   │
│ 40-5076 │ 1,289,838  │ HALL        │ GRAND ISLAND │ PRATARIA VENTURES-HOSPITAL 3533 PRAIRIEVW │
└─────────┴────────────┴─────────────┴──────────────┴───────────────────────────────────────────┘
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
│ 77-3013 │ 20,365,480 │ SARPY       │ GRETNA    │ NE CROSSINGS OUTLET MALL                                    │
│ 28-2087 │ 19,595,967 │ DOUGLAS     │ OMAHA     │ Ak-sar-ben Business & Education Campus I (First Data, Corp) │
│ 27-6678 │ 19,557,186 │ DODGE       │ FREMONT   │ COSTCO POULTRY COMPLEX PRJ 1                                │
│ 28-2123 │ 14,670,575 │ DOUGLAS     │ OMAHA     │ Gallup University Riverfront Development                    │
│ 28-2390 │ 14,473,818 │ DOUGLAS     │ OMAHA     │ HDR-Aksarben Zone 6                                         │
│ 28-2405 │ 13,431,364 │ DOUGLAS     │ OMAHA     │ The Landing                                                 │
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

```
┌─────────┬────────────┬─────────────┬──────────────┬──────────────────────────────┐
│ tif_id  │ rebate ($) │ county_name │  city_name   │             name             │
├─────────┼────────────┼─────────────┼──────────────┼──────────────────────────────┤
│ 56-0008 │ 4,917,028  │ LINCOLN     │ NORTH PLATTE │ Walmart                      │
│ 24-0920 │ 2,519,418  │ DAWSON      │ LEXINGTON    │ WAL-MART STORES INC          │
│ 28-2290 │ 2,250,365  │ DOUGLAS     │ OMAHA        │ 50th & Ames Avenue, Wal-mart │
│ 51-8529 │ 1,052,895  │ KEITH       │ OGALLALA     │ WALMART                      │
└─────────┴────────────┴─────────────┴──────────────┴──────────────────────────────┘
```

Dollar General TIFs:

```sql
SELECT city_name, printf("%,d", sum(total_tif_excess_taxes)) "rebate ($)", name, p.tif_id
FROM project p, year y
WHERE p.tif_id = y.tif_id
AND (
  name LIKE    '%DOLLAR GEN%'
  OR name LIKE '%DOLLARGEN%'
  OR name LIKE '%RED OAK PROPERTIES%'
  OR name LIKE '%Triple C Development%'
)
GROUP BY 1,3,4
ORDER BY city_name;
```

```
┌────────────┬────────────┬────────────────────────────────┬─────────┐
│ city_name  │ rebate ($) │              name              │ tif_id  │
├────────────┼────────────┼────────────────────────────────┼─────────┤
│ ARAPAHOE   │ 121,322    │ DOLLAR GENERAL STORE PROJ      │ 33-8621 │
│ BAYARD     │ 45,612     │ Dollar General Store           │ 62-0081 │
│ BAYARD     │ 76,142     │ PROP.VENTURES - DOLLAR GENERAL │ 62-9515 │
│ BROKEN BOW │ 9,479      │ Dollar General                 │ 21-9901 │
│ CAMBRIDGE  │ 59,536     │ DOLLAR GENERAL PROJECT         │ 33-8618 │
│ FAIRBURY   │ 160,270    │ RED OAK PROPERTIES             │ 48-9510 │
│ HEBRON     │ 55,721     │ Dollar General                 │ 85-0333 │
│ OGALLALA   │ 189,484    │ OGALL. DNP VIII DOLLAR GEN     │ 51-8528 │
│ OMAHA      │ 168,053    │ Triple C Development           │ 28-2320 │
│ TEKAMAH    │ 186,411    │ IND. PAVING DOLLAR GENERAL     │ 11-1001 │
│ WAYNE      │ 140,930    │ WESTERN RDGE DOLLARGEN 20      │ 90-8734 │
└────────────┴────────────┴────────────────────────────────┴─────────┘
```
