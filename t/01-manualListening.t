#!/usr/bin/perl

use Test::More;

use RTTTL::XS;


print "These are manual tests and there is no convenient way of automatically confirming that the piezoelectric beeper is actually producing sounds.\n";
print "Connect the beeper to wiringPi pin 1 aka. physical pin 12\n";
print "\n\n";
print "Test begins...\n";

ok(1, "Initializing the wiringPi library\n");
RTTTL::XS::init(1);

my @tones = ([3000,500],[2250,500],[1500,500],[750, 500],[3750,500]);
foreach my $tone (@tones) {
  ok(1, "Playing some tones...");
  RTTTL::XS::play_tone(1, $tone->[0], $tone->[1]);
}

ok(1, "A two second break");
RTTTL::XS::play_tone(1, 0, 2000);

ok(1, "Playing a tune of Simpsons");
RTTTL::XS::play_rtttl(1, "The Simpsons:d=4,o=5,b=160:c.6,e6,f#6,8a6,g.6,e6,c6,8a,8f#,8f#,8f#,2g,8p,8p,8f#,8f#,8f#,8g,a#.,8c6,8c6,8c6,c6");

done_testing();
