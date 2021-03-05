#! env perl

# https://stackoverflow.com/questions/1063125/how-can-i-parse-csv-files-on-the-linux-command-line
# cat TIF_REPORT_2020.csv | ./csvcut.pl --c 13 | sort | uniq -c

use strict;
use warnings;

use Getopt::Long;
my @opt_columns;
GetOptions("column=i@" => \@opt_columns)
  or die "Failed parsing options\n";
die "Must give at least one --column\n" if int(@opt_columns) == 0;
@opt_columns = map { $_-1 } @opt_columns; # convert 1-based to 0-based

use Text::CSV_XS;
my $csv = Text::CSV_XS->new ( { binary => 1 } );

open(my $stdin, "<-") or die "Couldn't open stdin\n";
open(my $stdout, ">-") or die "Couldn't open stdout\n";
while (my $row = $csv->getline($stdin)) {
    my @nrow = @{$row}[@opt_columns];
    $csv->print($stdout, \@nrow);
    print "\n";
}

