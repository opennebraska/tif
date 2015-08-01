#! env perl

use 5.22.0;

my $last_date;
open my $in, "-|", "grep -ni ' tif ' dump/*txt";
while (<$in>) {
  chomp;
  my ($date, $line_number) = ($_ =~ m!dump/j(\d\d-\d\d-\d\d)\.txt:(\d+)!);
  my $line = $_;
  $line =~ s/.*?\.txt:\d+://;
  $date = "20$date";

  if ($date ne $last_date) {
  	say "\n# $date\n";
  	$last_date = $date;
  }
  # say "Line number: $line_number";
  say "$line\n";
}

