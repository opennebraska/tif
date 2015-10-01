use 5.22.0;
use Text::CSV_XS;

my %columns = (
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
  20 => "total_tif_base_value",
  21 => "total_tif_excess_value",
  22 => "total_tax_rate",
  23 => "total_tif_excess_taxes",
  24 => "total_tif_base_taxes",
);

my $tif_id = {};
my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1 });
open my $fh, "<:encoding(utf8)", "TIF_Report_2014.csv" or die $!;
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
}
close $fh;

$csv->eol("\n");
open my $fh, ">:encoding(utf8)", "new.csv" or die "new.csv: $!";
foreach my $id (keys %$tif_id) {
  my $data = $tif_id->{$id};
  say join "|", $id, $data->{name}, $data->{location}, $data->{description};
  $csv->print($fh, [$id, $data->{name}, $data->{location}, $data->{description}]);
}
close $fh or die "new.csv: $!";




