use 5.22.0;
use DBI;
use Template;

my $dbh = DBI->connect("dbi:SQLite:dbname=../db/db.sqlite3");

my $tt = Template->new({
  INCLUDE_PATH => 'templates',
  INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";

generate_homepage();
generate_county_list();


# end main

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
    push @counties, "<a href='$directory_name/'>$name</a>";
  }
  return join ", \n", @counties;
}

sub generate_homepage {
  my $counties = generate_county_list();
  my $vars = {
    chart_data => fetch_chart_data(),
    counties   => $counties,
  };
  $tt->process('index.tt2', $vars, 'www/index.html')
    || die $tt->error(), "\n";
}

sub fetch_chart_data {
  my $strsql = <<EOT;
select tax_year, sum(total_tif_base_taxes), sum(total_tif_excess_taxes)
from year
group by tax_year
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute;

  my @js_data;
  while (my @row = $sth->fetchrow) {
    say join " ", @row;
    # Our series are each a string in javascript syntax like this:
    # ['2010', 10, 24, ''],
    push @js_data, sprintf("['%s', %s, %s, '']", @row);
  }
  # Squish the series together with another comma
  return join ",", @js_data;
}


