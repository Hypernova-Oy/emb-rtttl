#!/usr/bin/perl

use Test::More;

use RTTTL::XS;


print "These are manual tests and there is no convenient way of automatically confirming that the piezoelectric beeper is actually producing sounds.\n";
print "Connect the beeper to wiringPi pin 7\n";
print "\n\n";
print "Test begins...\n";

my $pin = 1;
my $verbose = 1;

ok(1, "Initializing the wiringPi library\n");
RTTTL::XS::init($pin, ,$verbose);

my @tones = ([2250,500],[1500,500],[750, 500]);
foreach my $tone (@tones) {
  ok(1, "Playing some tones...");
  RTTTL::XS::play_tone($pin, $tone->[0], $tone->[1]);
}

ok(1, "A one second break");
RTTTL::XS::play_tone($pin, 0, 1000);

ok(1, "Playing a tune of Toveri access denied");
RTTTL::XS::play_rtttl($pin, "ToveriAccessDenied:d=4,o=4,b=100:32e,32d,32e,4c");

done_testing();
