use Template;

my $tt = Template->new({
  INCLUDE_PATH => 'templates',
  INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";

my $vars = {
    name     => 'Count Edward van Halen',
    debt     => '3 riffs and a solo',
    deadline => 'the next chorus',
};

$tt->process('chart.tt2', $vars, 'www/index.html')
    || die $tt->error(), "\n";
close $out;

