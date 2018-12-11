#!/usr/bin/perl

use Modern::Perl;
use Test::More;

use RTTTL::Player;

my $player = RTTTL::Player->new({pin => 18, dir => './rtttl'});

subtest "Listing RTTTLs", \&listRTTTLs;
sub listRTTTLs {
    my $songs = $player->getSongs();
    ok(grep( /^The_Simpsons.rtttl$/, @$songs ), "The Simpsons found");
    ok(grep( /^Star_wars.rtttl$/, @$songs ), "Star wars found");
    ok(grep( /^Top_Gun.rtttl$/, @$songs ), "Top Gun found");
}

ok($player->playSong("toveri_access_granted"), "Played Toveri access granted");
	

ok($player->playSongIndex(1), "Played song index 1, A-Team");


done_testing;
