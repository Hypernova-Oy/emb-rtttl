#!/usr/bin/perl

use Modern::Perl;
use Test::More;

use RTTTL;

subtest "Listing RTTTLs", \&listRTTTLs;
sub listRTTTLs {
    my $songs = RTTTL::getSongs();
    ok(grep( /^The_Simpsons$/, @array ), "The Simpsons found");
    ok(grep( /^Star_wars$/, @array ), "Star wars found");
    ok(grep( /^Top_Gun$/, @array ), "Top Gun found");
}

print "Playing Bond\n";
ok(RTTTL::play_song("Bond"), "Played Bond");


print "Playing song number 7, indiana\n";
ok(RTTTL::play_song_number(7), "Played song number 7, indiana");


done_testing;
