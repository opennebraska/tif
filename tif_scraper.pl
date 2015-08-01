#! env perl

use 5.22.0;
use WWW::Mechanize;
use Carp qw(longmess);

my $mech = WWW::Mechanize->new(onerror => sub { print longmess @_ } );

my $url = "http://www.cityofomaha.org/cityclerk/city-council/journals-a-videos";
$mech->get($url);
foreach my $link ($mech->find_all_links( text_regex => qr/Journal/i )) {
  process_journal($link);
}
while ($mech->follow_link(text => "Next")) {
  say "Next page: " . $mech->uri;
  foreach my $link ($mech->find_all_links( text_regex => qr/Journal/i )) {
	  process_journal($link);
  }
}

say "Moving to archive";
$url = "http://www.cityofomaha.org/cityclerk/archived-city-council-documents";
say $url;
$mech->get($url);
foreach my $link ($mech->find_all_links( url_regex => qr!archived-city-council-documents/!i )) {
  process_archive_page($link);
}
while ($mech->follow_link(text => "Next")) {
  say "Next page: " . $mech->uri;
	foreach my $link ($mech->find_all_links( url_regex => qr!archived-city-council-documents/!i )) {
	  process_archive_page($link);
  }
}



say "Exiting";


sub process_archive_page {
  my ($link) = @_;
  say $link->text . " " . $link->url;
  # New mech so we don't mess up the Next navigation of the main one
  my $mech2 = WWW::Mechanize->new(onerror => sub { print longmess @_ } );
  $mech2->get($link->url_abs);
  my $link2 = $mech2->find_link( text_regex => qr/Journal/i );
  if ($link2) {
	  say "  " . $link2->text . " " . $link2->url;
    process_journal($link2);
	} else {
  	say "  No journal here? :(";
  }
}

sub process_journal {
	my ($link) = @_;
  say "    process_journal(): " . $link->text . " " . $link->url;

  my $pdf_filename = $link->url;
  unless ($pdf_filename =~ /\.pdf$/) {
  	say "    Not a PDF! $pdf_filename";
    return 0;
  }
  $pdf_filename =~ s!.*/!dump/!;
  if (-r $pdf_filename) {
    say "    Already downloaded.";
    return 1;
  }
  say "    Downloading $pdf_filename";
  my $mech2 = WWW::Mechanize->new(onerror => sub { print longmess @_ } );
  my $res = $mech2->mirror($link->url_abs, $pdf_filename);
  say "    " . $res->status_line;
}


