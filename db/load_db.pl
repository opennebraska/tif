#! env perl

use warnings;
use diagnostics;
use 5.36.0;
use Text::CSV_XS;
use Data::Printer;  # imports p and np
use TIF;
use DBI;
use FileHandle;
STDOUT->autoflush();
STDERR->autoflush();

=head1 NAME

load_db.pl - Load CSV files into SQLite

=head1 DESCRIPTION

After you download multiple Excel files (one per tax year)
from the Nebraska Department of Revenue (NDOR)
Property Assessment Division (PAD):

http://www.revenue.nebraska.gov/PAD/research/tif_reports.html

You can use this program to create a single, normalized SQLite 
database containing all the tax years you downloaded.

=cut

my $connect_info = 'dbi:SQLite:dbname=db.sqlite3';
my $schema = TIF->connect($connect_info);
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
foreach my $file (sort @files) {
  say "\n\n$file...";
  # next unless ($file eq "TIF_REPORT_2024.csv");
  process_file($file);
}
purge_0s();   #26

# end main


sub process_file { 
  my ($file) = @_;
  open my $fh, "<:encoding(utf8)", $file or die $!;

  while (my $row = $csv->getline($fh)) {
    my $id = $row->[0];
    next unless ($id =~ /\d\d\-\d\d\d\d/);  # Skip headers
    # next unless ($id =~ /(28-2376)/);
    # $DB::single = 1 if ($row->[0] eq "28-2208");
    # p $row;
    my ($name, $location, $description);
    if ($file =~ /TIF_REPORT_20(18|19|2\d)\.csv/) {   # They added a column in 2018
      $name = $row->[3];
      $name =~ s/^TIF (\d\d\d\d )?//;
      $location = $row->[10];
      $description = $row->[11];
      splice(@$row, 10, 1);   # Throw the extra column away so the column count matches the other files
    } else {
      my @split = split /[\r\n]+/s, $row->[10];
      $name = shift @split;
      $name && $name =~ s/Name of Project[\s+]?: //i;
      $name && $name =~ s/Project Name[\s+]?: //i;
      $location = shift @split;
      $description = join " ", @split;
      $description && $description =~ s/Note[\s+]?: //i;
      $description && $description =~ s/Description[\s+]?: //i;
    }
    $name =~ s/\R//g;  # Ugh. Some of the data has Windows newlines in it.

    if ($file eq "TIF_REPORT_2019.csv") {
      # In the 2019 file the PROJDATE field doesn't make any sense. Throw it away.
      $row->[4] = undef;
    }
    $tif_id->{$id} = {
      name        => $name,
      location    => $location,
      description => $description,
    };
  
    unless ($project && $project->id eq $id) {
      print "\n$id ";
      $project = $schema->resultset('Project')->find($id);
    }
    if ($project) {
      # Audit existing data
      my %db_row = ();
      foreach my $col (0..9) {
        $db_row{$column_names{$col}} = $row->[$col] if ($row->[$col]);
      }
      $db_row{name}        = $name;
      $db_row{location}    = $location;
      $db_row{description} = maybe_update_description($project, $description);
      $db_row{tif_name} =~ s/\R//g;  # Ugh. Some of the data has Windows newlines in it.
      $project->set_columns(\%db_row);
      if (my %dc = $project->get_dirty_columns) {
        print "\n";
        say np %dc;   # p goes to STDERR, with colors... good for humans, bad for log files.
        say "WARNING historic Project data changed for $file $id";
        #9: Modify the database anyway:
        $project->update;
      }
    } else {
      # Create this project
      my %db_row = ();
      foreach my $col (0..9) {
        $db_row{$column_names{$col}} = $row->[$col];
      };
      $db_row{name}        = $name;
      $db_row{location}    = $location;
      $db_row{description} = $description;
      $db_row{tif_name} =~ s/\R//g;  # Ugh. Some of the data has Windows newlines in it.
  
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
        say np %dc;   # p goes to STDERR, with colors... good for humans, bad for log files.
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


=head2 maybe_update_description

#24 .xls has truncated descriptions

Unfortunately, the 2016 .xls file truncated descriptions on us.

So, if the description is the same, only shorter, then ignore it, and retain
the description from previous years.

=cut

sub maybe_update_description {
  my ($project, $description) = @_;
  if (
    $description &&
    $project->description &&
    $project->description =~ /^\Q$description\E/ 
    && length($description) < length($project->description)
  ) {
    say "WARNING ignoring truncated description";
    # say "  Old: " . $project->description;
    # say "  New: $description";
    return $project->description;
  } else {
    return $description;
  }
}


=head2 purge_0s

#26 Suppress TIFs whose sum(total_tif_excess_taxes) = $0

https://github.com/opennebraska/tif/issues/26

=cut

sub purge_0s {
  say "Purging 0s";
  my $dbh = DBI->connect($connect_info);
  my $sql = <<SQL;
    select tif_id
    from year
    group by tif_id
    having sum(total_tif_excess_taxes) = 0
SQL
  say $sql;
  my $delete_these = $dbh->selectall_arrayref($sql);
  $dbh->disconnect;

  foreach my $row (@$delete_these) {
    my ($tif_id) = @$row;
    say "  Purging $tif_id";
    $schema->resultset('Year')->search({   tif_id => $tif_id})->delete;
    $schema->resultset('Project')->search({tif_id => $tif_id})->delete;
  }
}

