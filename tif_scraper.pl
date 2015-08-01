#! env perl

use 5.22.0;
use WWW::Mechanize;

my $mech = WWW::Mechanize->new(onerror => sub { warn @_ } );

my $url = "http://www.cityofomaha.org/cityclerk/city-council/journals-a-videos";
$mech->get($url);
foreach my $link ($mech->find_all_links( text_regex => qr/Journal/i )) {
  process_journal($link);
}
while ($mech->follow_link(text => "Next")) {
  say "Next page";
  foreach my $link ($mech->find_all_links( text_regex => qr/Journal/i )) {
	  process_journal($link);
  }
}

say "Moving to archive";
$url = "http://www.cityofomaha.org/cityclerk/archived-city-council-documents";
$mech->get($url);
foreach my $link ($mech->find_all_links( url_regex => qr!archived-city-council-documents/!i )) {
  process_archive_page($link);
}
while ($mech->follow_link(text => "Next")) {
  say "Next page";
	foreach my $link ($mech->find_all_links( url_regex => qr!archived-city-council-documents/!i )) {
	  process_archive_page($link);
  }
}



say "Exiting";


sub process_archive_page {
  my ($link) = @_;
  say $link->text . " " . $link->url;
  my $mech2 = $mech->clone;
  $mech2->get($link->url_abs);
  my $link2 = $mech2->find_link( text_regex => qr/Journal/i );
  if ($link2) {
	  say "  " . $link2->text . " " . $link2->url;
    process_journal($link);
	} else {
  	say "  No journal here? :(";
  }
}

sub process_journal {
	my ($link) = @_;
  say $link->text . " " . $link->url;

  my $pdf_filename = $link->url;
  unless ($pdf_filename =~ /\.pdf$/) {
  	say "Not a PDF! $pdf_filename";
  } 
  $pdf_filename =~ s!.*/!!;
  $mech->mirror($link->url_abs, "dump/$pdf_filename");
}


