# Database

The latest database is [in Dropbox](https://www.dropbox.com/sh/lb1kwtfou7b2kg4/AACAZrrrBOnzRUmgK6ek14a1a?dl=0). You can just download it, and you're done. 

If you want to build the database yourself, continue reading.

`load_db.pl` reads the CSV files in this directory, normalizing them into 2 tables in a sqlite3 database:

    sqlite3 db.sqlite3 < db.sql
    perl refresh_schema.pl
    perl -Ilib load_db.pl | tee load_db.log

## Sample queries

10 largest TIF rebates 2024:

```sql
select p.tif_id, total_tif_excess_taxes, county_name, city_name, tif_name, county_number
from project p, year y
where p.tif_id = y.tif_id
and tax_year = 2024
order by total_tif_excess_taxes desc
limit 13;
```