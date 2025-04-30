#!/usr/bin/env perl

use 5.22.0;
use DBI;
use Template;
use File::Path qw(make_path);
use Memoize;
use JSON;

=head1 NAME

generate_www.pl - Read SQLite, generate Github Pages

=head1 DESCRIPTION

After load_db.pl creates an SQLite database you can use this
program to generate a static website, the current copy of which
is sitting in branch static-www.

=cut

my $dbh = DBI->connect("dbi:SQLite:dbname=db/db.sqlite3");
my $out_root = "static-www/www";
my $url_root = "http://nebraska.tif.report";

my $tt = Template->new({
  INCLUDE_PATH => 'static-www/templates',
  INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";

memoize('fetch_total');

generate_about();
generate_homepage();
generate_county_pages();
generate_city_pages();
generate_tif_pages();
generate_search_index();

# end main

sub generate_about {
  my $vars = {
    title => "A Brief Introduction to Tax Increment Financing",
    url   => "$url_root/about.html",
  };

  my $outfile = "$out_root/about.html";
  make_path($out_root);
  say "Generating $outfile";
  $tt->process('about.tt2', $vars, $outfile) || die $tt->error(), "\n";
}

sub generate_homepage {
  my $county_list = county_list();
  my $this_total = fetch_total("and 'foo' = ?", 'foo');
  my $vars = {
    chart_data => fetch_chart_data(),
    this_total => $this_total,
    children   => $county_list,
    title      => "2024 TIF Report",
    url        => $url_root,
  };
  my $outfile = "$out_root/index.html";
  make_path($out_root);
  say "Generating $outfile";
  $tt->process('index.tt2', $vars, $outfile) || die $tt->error(), "\n";
}

sub county_list {
  my $strsql = <<EOT;
select distinct county_name from project order by 1
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute;
  my @rval;
  while (my ($name) = $sth->fetchrow) {
    my ($directory_name, $pretty_name) = names($name);
    push @rval, qq{<a href="$directory_name/index.html" class="px-3 py-1.5 shadow bg-white rounded-full text-sm font-medium hover:bg-black hover:text-white transition">$pretty_name</a>};
  }
  return '<div class="flex flex-wrap gap-3 items-center justify-center">' . join('', @rval) . '</div>';
}

sub generate_county_pages {
  my $strsql = <<EOT;
select distinct county_name from project order by 1
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute;
  my @counties;
  while (my ($name) = $sth->fetchrow) {
    my ($directory_name, $pretty_name) = names($name);
    my $city_list = city_list("where county_name = '$name'");
    my $this_total = fetch_total("and county_name = ?", $name);
    my $vars = {
      chart_data   => fetch_chart_data("and county_name = '$name'"),
      this_total   => $this_total,
      children     => $city_list,
      title        => "$pretty_name County",
      url          => "$url_root/$directory_name/index.html",
    };
    my $outfile = "$out_root/$directory_name/index.html";
    make_path("$out_root/$directory_name");
    say "Generating $outfile";
    $tt->process('index.tt2', $vars, $outfile) || die $tt->error(), "\n";
  }
  return join ", \n", @counties;
}

sub generate_city_pages {
  my $strsql = <<EOT;
select distinct county_name, city_name from project order by 1
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute();

  my @cities;
  while (my ($county, $city) = $sth->fetchrow) {
    my ($co_directory, $co_pretty) = names($county);
    my ($ci_directory, $ci_pretty) = names($city);

    my $tif_names  = tif_names("and city_name = ?", $city);
    my $this_total = fetch_total("and city_name = ?", $city);
    my $vars = {
      chart_data => fetch_chart_data("and city_name = ?", $city),
      tif_names  => $tif_names,
      this_total => $this_total,
      title      => $ci_pretty,
      url        => "$url_root/$co_directory/$ci_directory/index.html",
    };
    my $outfile = "$out_root/$co_directory/$ci_directory/index.html";
    make_path("$out_root/$co_directory/$ci_directory");
    say "Generating $outfile";
    $tt->process('index.tt2', $vars, $outfile) || die $tt->error(), "\n";
  }
  return join ", \n", @cities;
}

sub tif_names {
  my ($additional_where, $city) = @_;
  my $strsql = <<EOT;
select distinct p.tif_id, p.name, sum(y.total_tif_base_taxes) paid, sum(y.total_tif_excess_taxes) refunded
from project p, year y 
where p.tif_id = y.tif_id
$additional_where
group by 1
order by 4 desc
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute($city);
  return $sth->fetchall_arrayref({});
}

sub fetch_total {
  my ($additional_where, $placeholder) = @_;
  my $strsql = <<EOT;
select sum(y.total_tif_base_taxes) paid, sum(y.total_tif_excess_taxes) refunded
from project p, year y 
where p.tif_id = y.tif_id
$additional_where
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute($placeholder);
  my $row = $sth->fetchrow_hashref;
}

sub city_list {
  my ($where) = @_;
  my $strsql = <<EOT;
select distinct city_name 
from project
$where
order by 1
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute;
  my @rval;
  while (my ($name) = $sth->fetchrow) {
    my ($directory_name, $pretty_name) = names($name);
    push @rval, qq{<a href="$directory_name/index.html" class="px-3 py-1.5 shadow bg-white rounded-full text-sm font-medium hover:bg-black hover:text-white transition">$pretty_name</a>};
  }
  return '<div class="flex flex-wrap gap-3 items-center justify-center">' . join('', @rval) . '</div>';
}

sub generate_tif_pages {
  my $strsql = <<EOT;
select * from project
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute();
  while (my $row = $sth->fetchrow_hashref) {
    my ($co_directory,  $co_pretty)  = names($row->{county_name});
    my ($ci_directory,  $ci_pretty)  = names($row->{city_name});
    my $tif_total = fetch_total("and p.tif_id = ?", $row->{tif_id});
    my $vars = {
      chart_data => fetch_chart_data("and p.tif_id = ?", $row->{tif_id}),
      title      => $row->{name},
      detail_row => $row,
      tif_total  => $tif_total,
      url        => "$url_root/$co_directory/$ci_directory/" . $row->{tif_id} . ".html",
    };
    my $outfile = "$out_root/$co_directory/$ci_directory/" . $row->{tif_id} . ".html";
    make_path("$out_root/$co_directory/$ci_directory");
    say "Generating $outfile";
    $tt->process('index.tt2', $vars, $outfile) || die $tt->error(), "\n";
  }
}

sub generate_search_index {
  my @search_data;

  my $county_sql = "select distinct county_name from project order by 1";
  my $county_sth = $dbh->prepare($county_sql);
  $county_sth->execute or die "Error (counties): " . $dbh->errstr;
  while (my ($name) = $county_sth->fetchrow) {
    my ($directory_name, $pretty_name) = names($name);
    push @search_data, {
      id   => "county_$directory_name",
      name => $pretty_name,
      type => "County",
      url  => "/$directory_name/index.html",
    };
  }

  my $city_sql = "select distinct county_name, city_name from project order by 1";
  my $city_sth = $dbh->prepare($city_sql);
  $city_sth->execute or die "Error (cities): " . $dbh->errstr;
  while (my ($county, $city) = $city_sth->fetchrow) {
    my ($co_directory, $co_pretty) = names($county);
    my ($ci_directory, $ci_pretty) = names($city);
    push @search_data, {
      id   => "city_${co_directory}_${ci_directory}",
      name => $ci_pretty,
      type => "City",
      url  => "/$co_directory/$ci_directory/index.html",
    };
  }

  my $tif_sql = "select county_name, city_name, tif_id, name from project";
  my $tif_sth = $dbh->prepare($tif_sql);
  $tif_sth->execute or die "Error (TIF projects): " . $dbh->errstr;
  while (my $row = $tif_sth->fetchrow_hashref) {
    my ($co_directory, $co_pretty) = names($row->{county_name});
    my ($ci_directory, $ci_pretty) = names($row->{city_name});
    push @search_data, {
      id   => "tif_$row->{tif_id}",
      name => $row->{name},
      type => "TIF Project",
      url  => "/$co_directory/$ci_directory/$row->{tif_id}.html",
    };
  }

  my $json = JSON->new->pretty->encode(\@search_data);
  my $outfile = "$out_root/search-index.json";
  open my $fh, '>', $outfile or die "error: $!";
  print $fh $json;
  close $fh;
  say "Generated search index: $outfile";
}

sub names {
  my ($name) = @_;
  my $directory_name = $name;
  $directory_name =~ s/ /_/g;
  my $pretty_name = $name;
  $pretty_name = join ' ', map({ ucfirst() } split / /, lc $name);
  return $directory_name, $pretty_name;
}

sub fetch_chart_data {
  my ($more_where, @args) = @_;
  my $strsql = <<EOT;
select tax_year, sum(total_tif_base_taxes), sum(total_tif_excess_taxes)
from project p, year y
where p.tif_id = y.tif_id
$more_where
group by tax_year
EOT
  my $sth = $dbh->prepare($strsql);
  $sth->execute(@args);

  my @js_data;
  while (my @row = $sth->fetchrow) {
    push @js_data, sprintf("['%s', %s, %s, '']", @row);
  }
  return join ",", @js_data;
}