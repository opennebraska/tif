#! env perl

use 5.40.1;
use WWW::Mechanize;
use Carp qw(longmess);

my $mech = WWW::Mechanize->new(onerror => sub { print longmess @_ });
# URL and filename pattern changed sometime between 2017 and 2024.
# Looks like they moved to Wordpress.
my $url = "https://cityclerk.cityofomaha.org/wp-content/uploads/images";

# Sigh. This program used to be able to scrape the whole archive,
# but their site requires Javascript now for some reason, so here's
# an incomplete list of files you can retrieve:
my @files = qw(
  2025-04-29j.pdf
  2025-04-22j.pdf
  2025-04-15j.pdf
  2025-04-08j.pdf
  2025-03-25j.pdf
  2025-03-18j.pdf
  2025-03-11j.pdf
  2025-03-04j.pdf
  2025-02-25j.pdf
  2025-02-11j.pdf
  2025-02-04j.pdf
  2025-01-28j.pdf
  2025-01-21j.pdf
  2025-01-14j.pdf
  
  2024-12-17j.pdf
  2024-12-10j.pdf
  2024-11-26j.pdf
  2024-11-19j.pdf
  2024-11-05j.pdf
  2024-10-29j.pdf
  2024-10-22j.pdf
  2024-10-08j.pdf
  2024-10-01j.pdf
  2024-09-24j.pdf
  2024-09-17j.pdf
  2024-09-10j.pdf
  2024-08-27j.pdf
  2024-08-20j.pdf
  2024-08-13j.pdf
  2024-08-06j.pdf
  2024-07-30j.pdf
  2024-07-23j.pdf
  2024-07-16j.pdf
  2024-06-25j.pdf
  2024-06-11j.pdf
  2024-06-04j.pdf
  2024-05-21j.pdf
  2024-05-14j.pdf
  2024-05-07j.pdf
  2024-04-30j.pdf
  2024-04-23j.pdf
  2024-04-16j.pdf
  2024-04-09j.pdf
  2024-04-02j.pdf
  2024-03-19j.pdf
  2024-03-12j.pdf
  2024-03-05j.pdf
  2024-02-27j.pdf
  2024-02-20j.pdf
  2024-02-13j.pdf
  2024-02-06j.pdf
  2024-01-30j.pdf
  2024-01-23j.pdf
  2024-01-09j.pdf

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

  # UGH! They've made it so hard to download PDFs that now we have to
  # use a headless Chromium browser via Node.js
  
  # The old simple way:
  # my $mech2 = WWW::Mechanize->new(onerror => sub { die longmess @_ } );
  # $mech2->agent_alias('Mac Safari');  # Lie to not get 403 Forbidden from AkamaiGHost?
  # my $res = $mech2->mirror("$url/$file", $local_filename);
  # say "  " . $res->status_line;

  # The new way:
  my $cmd = "node download-omaha-pdf.js $file";
  say $cmd;
  system($cmd) == 0 or die $!;
}

