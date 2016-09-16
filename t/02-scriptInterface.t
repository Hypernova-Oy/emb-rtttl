#!/usr/bin/perl

use Modern::Perl;
use Test::More;

use RTTTL::Player;

my $player = RTTTL::Player->new({pin => 1, dir => './rtttl'});

subtest "Listing RTTTLs", \&listRTTTLs;
sub listRTTTLs {
    my $songs = $player->getSongs();
    ok(grep( /^The_Simpsons.rtttl$/, @$songs ), "The Simpsons found");
    ok(grep( /^Star_wars.rtttl$/, @$songs ), "Star wars found");
    ok(grep( /^Top_Gun.rtttl$/, @$songs ), "Top Gun found");
}

print "Playing Bond\n";
ok($player->playSong("Bond"), "Played Bond");


print "Playing song index 7, indiana\n";
ok($player->playSongIndex(7), "Played song index 7, indiana");


done_testing;
