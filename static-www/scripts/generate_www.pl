use 5.22.0;
use DBI;
use Template;

my $dbh = DBI->connect("dbi:SQLite:dbname=../db/db.sqlite3");

my $tt = Template->new({
  INCLUDE_PATH => 'templates',
  INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";

generate_homepage();
generate_county_pages();
generate_city_pages();


# end main

sub generate_county_pages {
  my $strsql = <<EOT;
select distinct county_name from project order by 1
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute;
  my @counties;
  while (my ($name) = $sth->fetchrow) {
    my $directory_name = $name;
    $directory_name =~ s/ /_/g;
    my $pretty_name = $name;
    $pretty_name = join ' ', map({ ucfirst() } split / /, lc $name);

    my $city_list = generate_city_list("where county_name = '$name'");
    my $vars = {
      chart_data => fetch_chart_data("and county_name = '$name'"),
      children   => $city_list,
      title      => "$pretty_name County TIF Report 2014",
    };
    my $outfile = "www/$directory_name/index.html";
    say "Generting $outfile";
    $tt->process('index.tt2', $vars, $outfile) || die $tt->error(), "\n";
  }
  return join ", \n", @counties;
}

sub generate_county_list {
  my $strsql = <<EOT;
select distinct county_name from project order by 1
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute;
  my @counties;
  while (my ($name) = $sth->fetchrow) {
    my $directory_name = $name;
    $directory_name =~ s/ /_/g;
    $name = join ' ', map({ ucfirst() } split / /, lc $name);
    push @counties, "<a href='$directory_name/index.html'>$name</a>";
  }
  return join ", \n", @counties;
}

sub generate_city_list {
  my ($where) = @_;
  my $strsql = <<EOT;
select distinct city_name 
from project
$where
order by 1
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute;
  my @cities;
  while (my ($name) = $sth->fetchrow) {
    my $directory_name = $name;
    $directory_name =~ s/ /_/g;
    $name = join ' ', map({ ucfirst() } split / /, lc $name);
    push @cities, "<a href='$directory_name/index.html'>$name</a>";
  }
  return join ", \n", @cities;
}

sub generate_homepage {
  my $county_list = generate_county_list();
  my $vars = {
    chart_data => fetch_chart_data(),
    children   => $county_list,
    title      => "Nebraska TIF Report 2014",
  };

  my $outfile = "www/index.html";
  say "Generting $outfile";
  $tt->process('index.tt2', $vars, $outfile) || die $tt->error(), "\n";
}

sub fetch_chart_data {
  my ($more_where) = @_;
  my $strsql = <<EOT;
select tax_year, sum(total_tif_base_taxes), sum(total_tif_excess_taxes)
from project p, year y
where p.tif_id = y.tif_id
$more_where
group by tax_year
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute;

  my @js_data;
  while (my @row = $sth->fetchrow) {
    # say join " ", @row;
    # Our series are each a string in javascript syntax like this:
    # ['2010', 10, 24, ''],
    push @js_data, sprintf("['%s', %s, %s, '']", @row);
  }
  # Squish the series together with another comma
  return join ",", @js_data;
}


