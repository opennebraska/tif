#! env perl

use 5.22.0;
use WWW::Mechanize;
use Carp qw(longmess);

my $mech = WWW::Mechanize->new(onerror => sub { print longmess @_ });
my $url = "https://cityclerk.cityofomaha.org/images/journal";

# Sigh. This program used to be able to scrape the whole archive,
# but their site requires Javascript now for some reason, so here's
# an incomplete list of files you can retrieve:
my @files = qw(
  j17-02-14w.pdf
  j17-02-07w.pdf
  j17-01-31w.pdf
  j17-01-24w.pdf
  j17-01-10w.pdf
  j16-12-20w.pdf
  j16-12-13w.pdf
  j16-12-06w.pdf
  j16-11-22w.pdf
  j16-11-08w.pdf
  j16-11-01w.pdf
  j16-10-25w.pdf
  j16-10-18w.pdf
  j16-10-04w.pdf
  j16-09-27w.pdf
  j16-09-20w.pdf
  j16-09-13w.pdf
  j16-08-30w.pdf
  j16-08-23w.pdf
  j16-08-16w.pdf
  j16-08-09w.pdf
  j16-07-26w.pdf
  j16-07-19w.pdf
  j16-07-12w.pdf
  j16-06-28w.pdf
  j16-06-21w.pdf
  j16-06-14w.pdf
  j16-06-07w.pdf
  j16-05-24w.pdf
  j16-05-17w.pdf
  j16-05-10w.pdf
  j16-05-03w.pdf
  j16-04-26w.pdf
  j16-04-19w.pdf
  j16-04-12w.pdf
  j16-04-05w.pdf
  j16-03-22w.pdf
  j16-03-15w.pdf
  j16-03-08w.pdf
  j16-03-01w.pdf
  j16-02-23w.pdf
  j16-02-09w.pdf
  j16-02-02w.pdf
  j16-01-26w.pdf
  j16-01-12w.pdf
);
# Feel free to fill that list out all the way back to November 4 2008 if you want.

foreach my $file (@files) {
  process_journal($url, $file);
}

say "Exiting";


sub process_journal {
  my ($url, $file) = @_;
  say "process_journal(): $file";

  unless ($file =~ /\.pdf$/) {
  	say "  Not a PDF! $file";
    return 0;
  }
  my $local_filename = "dump/$file";
  if (-r $local_filename) {
    say "  Already downloaded.";
    return 1;
  }
  say "  Downloading $file";
  my $mech2 = WWW::Mechanize->new(onerror => sub { print longmess @_ } );
  my $res = $mech2->mirror("$url/$file", $local_filename);
  say "  " . $res->status_line;
}


