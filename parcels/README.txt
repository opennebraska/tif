
This data came from here?:

https://www.arcgis.com/home/item.html?id=585efa4ff1b84a3b8b936df2fbfda801#data

Douglas County Assessor / Register of Deeds Office, Nebraska.

Somehow Jack Dunn downloaded the whole dataset as CSV. This code
loads that CSV into SQLite.


sqlite3 db.sqlite3
.mode csv
.import DCParcels_by_ownerzip.csv parcels
.schema parcels
sqlite> select count(*) from parcels;
204424

sqlite> select owner_name, count(*) from parcels group by 1 order by count(*) desc limit 5;
"CITY OF OMAHA",2016
"EAST CAMPUS REALTY LLC",571
"OMAHA MUNICIPAL LAND BANK",527
"CELEBRITY HOMES INC",502
"OMAHA HOUSING AUTHORITY",489


