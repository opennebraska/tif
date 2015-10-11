use 5.22.0;
use DBI;
use Template;

my $tt = Template->new({
  INCLUDE_PATH => 'templates',
  INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";

# Generate homepage:
my $vars = {
  data => fetch_chart_data(),
};
$tt->process('chart.tt2', $vars, 'www/index.html')
  || die $tt->error(), "\n";


# end main


sub fetch_chart_data {
  my $dbh = DBI->connect("dbi:SQLite:dbname=../db/db.sqlite3");
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


