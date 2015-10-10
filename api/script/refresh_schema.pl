#! env perl

use DBIx::Class::Schema::Loader qw/ make_schema_at /;

make_schema_at(
    'TIF',
    { debug => 0,
      dump_directory => 'lib',
    },
    [ 'dbi:SQLite:dbname=db/db.sqlite3', '', '' ]
);


