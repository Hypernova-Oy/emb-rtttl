#!/usr/bin/perl

use Modern::Perl;
use Test::More;

use RTTTL::Player;

my $player = RTTTL::Player->new({pin => 18, dir => './rtttl'});

subtest "Listing RTTTLs", \&listRTTTLs;
sub listRTTTLs {
    my $songs = $player->getSongs();
    ok(grep( /^Argentina/, @$songs ), "The Simpsons found");
    ok(grep( /^SuperMan/, @$songs ), "Star wars found");
    ok(grep( /^Canon/, @$songs ), "Top Gun found");
}

ok($player->playSong("ToveriAccessGranted"), "Played Toveri access granted");


ok($player->playSongIndex(0), "Played song index 0, ToveriAccessDenied");


ok($player->playRandomSong(), "Played a random song");


done_testing;
