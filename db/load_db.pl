#! env perl

use 5.22.0;
use Text::CSV_XS;
use Data::Printer;
use TIF;

usage() unless (-r $ARGV[0]);

my $schema = TIF->connect('dbi:SQLite:dbname=db.sqlite3');

my %column_names = (
  0  => "tif_id",
  1  => "county_name",
  2  => "county_number",
  3  => "tif_name",
  4  => "project_date",
  5  => "city_name",
  6  => "school_district",
  7  => "base_school",
  8  => "unified_lc",
  9  => "class", 
  10 => "tif_project_name_etc",
  11 => "tax_year",
  12 => "residential_base_value",
  13 => "residential_excess_value",
  14 => "commercial_base_value",
  15 => "commercial_excess_value",
  16 => "industrial_base_value",
  17 => "industrial_excess_value",
  18 => "other_base_value",
  19 => "other_excess_value",
  20 => "other_description",
  21 => "total_tif_base_value",
  22 => "total_tif_excess_value",
  23 => "total_tax_rate",
  24 => "total_tif_excess_taxes",
  25 => "total_tif_base_taxes",
);

my $tif_id = {};
my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1 });
open my $fh, "<:encoding(utf8)", $ARGV[0] or die $!;
$csv->getline($fh);     # Discard headers
my $project;
while (my $row = $csv->getline ($fh)) {
  my $id = $row->[0];
  my ($name, $location, $description) = 
    map { s#.*?: ##; $_ }                # discard "Prefix: " strings
    ( split /[\r\n]+/s, $row->[10] );
  $tif_id->{$id} = {
    name        => $name,
    location    => $location,
    description => $description,
  };

  unless ($project && $project->id eq $id) {
    $project = $schema->resultset('Project')->find($id);
  }
  unless ($project) {
    # Create this project
    my %db_row = ();
    foreach my $col (0..9) {
      $db_row{$column_names{$col}} = $row->[$col];
    };
    $db_row{name}        = $name;
    $db_row{location}    = $location;
    $db_row{description} = $description;

    my $p = $schema->resultset('Project')->new(\%db_row)->insert;
    print "\n" . $p->id . " ";
  }

  my $tax_year = $row->[11];
  my $year = $schema->resultset('Year')->find($id, $tax_year);
  my %db_row = (
    tif_id   => $id,
    tax_year => $tax_year,
  );
  foreach my $col (12..25) {
    my $val = $row->[$col];
    $val =~ s/,//g;
    $db_row{$column_names{$col}} = $val;
  };
  if ($year) {
    # Audit existing data
    $year->set_columns(\%db_row);
    if (my %dc = $year->get_dirty_columns) {
      p %dc;
      die "Aaaaa!! $id $tax_year";
    } else {
      say "\n$tax_year audit was clean";
    }
  } else {
    # Create new row in year table
    my $y = $schema->resultset('Year')->new(\%db_row)->insert;
    print $y->tax_year . " ";
  }
}
close $fh;

sub usage {
  print <<EOT;
$0 TIF_Report_2014.csv

Load that .csv file into the SQLite database.

EOT
  exit 1;
}


__END__

# Somebody asked for some CSV output. Generate that as 'new.csv':
$csv->eol("\n");
open my $fh, ">:encoding(utf8)", "new.csv" or die "new.csv: $!";
foreach my $id (keys %$tif_id) {
  my $data = $tif_id->{$id};
  say join "|", $id, $data->{name}, $data->{location}, $data->{description};
  $csv->print($fh, [$id, $data->{name}, $data->{location}, $data->{description}]);
}
close $fh or die "new.csv: $!";


