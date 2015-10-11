#! env perl

use 5.22.0;
use File::Next;

say <<EOT;
All mentions of "TIF" in all available journals.

* [Source code](https://github.com/opennebraska/pri-tif)
* [All PDF, text files in Google Drive](https://drive.google.com/open?id=0B05-hZg07jbMfmN3dkdiXzJzOTg4Y3pVUjhXUXg1VlFTVjV0dGF2Yk9PRGlDajNCUExrTjg)

EOT

my ($date, $last_date);
my $files = File::Next::files( 
  { file_filter => sub { /\.txt$/ } },
  'dump'
);
while ( defined ( my $file = $files->() ) ) {
  ($date) = ($file =~ /j(\d\d-\d\d-\d\d)\.txt/);
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
      say "\n# $date\n";
      $last_date = $date;
    }
    say $all;
  }
}


