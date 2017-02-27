#! env perl

use 5.22.0;
use File::Next;

my $out_dir = "tif_pretty";
unlink glob "$out_dir/*.md";

my $header = <<EOT;
All mentions of "TIF" in all available journals.

* [Source code](https://github.com/opennebraska/pri-tif/tree/master/cityofomaha.org)
* [All PDF, text files in Dropbox](https://www.dropbox.com/sh/lb1kwtfou7b2kg4/AACAZrrrBOnzRUmgK6ek14a1a\?dl\=0)

EOT

open my $out, ">", "$out_dir/README.md";
say $out $header;

my ($date, $last_date);
my $files = File::Next::files( 
  { file_filter => sub { /\.txt$/ } },
  'dump'
);
while ( defined ( my $file = $files->() ) ) {
  ($date) = ($file =~ /j(\d\d-\d\d-\d\d)w?\.txt/);
  $date = "20$date";

  my @item;
  open my $in, "<", $file;
  while (<$in>) {
    chomp;
#say "debug: [$_]";
    s/[^ -~]//g;   # Discard stupid double-dash extended dashes
    my $line = $_;
    if (/^([A-Z ]+)?(\d+)\./) {
#say "debug: TIME TO SPLIT";
      # A new item number has begun. Print the previous, if TIF
      my $item_number = $2;
      process_item(\@item);
      @item = ("Item $item_number");
      push @item, $line if ($line =~ /[a-z]/i);
#say "debug: our item is " . scalar(@item) . " lines long";
    } else {
      next if (/^[\- ]+\d+[\- ]+$/);   # Discard page breaks
      push @item, $line;
    }
  }
  process_item(\@item);
}

sub process_item {
  my ($item) = @_;
  my $all = join "\n", @$item;
  if ($all =~ s/(\btif\b|tax increment financing)/\*\*$1\*\*/gi) {   # ** is bold in markdown
    $all =~ s/(\$[\.\,0-9]+)/\*\*$1\*\*/g;    # also bold the $ amounts
    if ($date ne $last_date) {
      my $year = substr $date, 0, 4;
      my $existed = -r "$out_dir/$year.md";
      open $out, ">>", "$out_dir/$year.md" or die;
      unless ($existed) {
        say $out $header;
      }
      say $out "\n# $date\n";
      $last_date = $date;
    }
    say $out $all;
  }
}


