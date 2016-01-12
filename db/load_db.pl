#! env perl

use 5.22.0;
use Text::CSV_XS;
use Data::Printer;
use TIF;
use FileHandle;
STDOUT->autoflush();
STDERR->autoflush();

my $schema = TIF->connect('dbi:SQLite:dbname=db.sqlite3');
# Nuke all existing data:
$schema->resultset('Project')->delete;
$schema->resultset('Year')->delete;

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

my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1 });
my $project;
my $tif_id = {};

my @files = glob("*.csv");
foreach my $file (@files) {
  say "\n\n$file...";
  process_file($file);
}

# end main


sub process_file { 
  my ($file) = @_;
  open my $fh, "<:encoding(utf8)", $file or die $!;

  while (my $row = $csv->getline ($fh)) {
    my $id = $row->[0];
    next unless ($id =~ /\d\d\-\d\d\d\d/);  # Skip headers
    my ($name, $location, $description) = 
      map { s#.*?: ##; $_ }                # discard "Prefix: " strings
      ( split /[\r\n]+/s, $row->[10] );
    $tif_id->{$id} = {
      name        => $name,
      location    => $location,
      description => $description,
    };
  
    unless ($project && $project->id eq $id) {
      print "\n$id ";
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
  
      $project = $schema->resultset('Project')->new(\%db_row)->insert;
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
        print "\n";
        p %dc;
        say "WARNING historic data changed for $file $id $tax_year";
        #9: Modify the database anyway:
        $year->update;
      }
    } else {
      # Create new row in year table
      $year = $schema->resultset('Year')->new(\%db_row)->insert;
    }  
    print $year->tax_year . " ";
  }
}


