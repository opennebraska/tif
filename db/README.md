# Database

Read a CSV file, normalize it into 2 tables
in a sqlite3 database.

Rebuild from scratch:

    sqlite3 db.sqlite3 < db.sql
    perl -Ilib refresh_schema.pl
    perl -Ilib load_db.pl

    
