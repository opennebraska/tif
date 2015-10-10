# PRI TIF API

REST JSON API is TODO

## Database

Read a CSV file, normalize it into 2 tables
in a sqlite3 database.

Rebuild from scratch:

    sqlite3 db/db.sqlite3 < db/db.sql
    perl -Ilib script/refresh_schema.pl
    perl -Ilib script/load_db.pl

    
