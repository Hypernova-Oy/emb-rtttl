#!/usr/bin/perl

use Modern::Perl;
use Test::More;

use RTTTL::Player;

my $player = RTTTL::Player->new({pin => 18, dir => './rtttl', cverbose => 6});

subtest "Listing RTTTLs", \&listRTTTLs;
sub listRTTTLs {
    my ($songs, $songNames) = $player->getSongs();
    ok(grep( /^X-files/, @$songNames ), "X-files found");
    ok(grep( /^Sweet Home Alabama/, @$songNames ), "Sweet Home Alabama found");
    ok(grep( /^Top Gun - Theme/, @$songNames ), "Top Gun - Theme found");
}

ok($player->playSong("ToveriAccessGranted"), "Played Toveri access granted");


$player->{idx} = 14;
ok($player->dispatchOperation(), "Played song index 14");


$player->{idx} = undef;
$player->{random} = 1;
ok($player->dispatchOperation(), "Played a random song");


done_testing;
