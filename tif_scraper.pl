#! env perl

use 5.22.0;
use WWW::Mechanize;

my $mech = WWW::Mechanize->new(onerror => sub { warn @_ } );

my $url = "http://www.cityofomaha.org/cityclerk/city-council/journals-a-videos";
$mech->get($url);

foreach my $link ($mech->find_all_links( text_regex => qr/Journal/i )) {
  say $link->text . " " . $link->url;
}
while ($mech->follow_link(text => "Next")) {
  say "Next page";
  foreach my $link ($mech->find_all_links( text_regex => qr/Journal/i )) {
    say $link->text . " " . $link->url;
  }
}

say "Exiting";
