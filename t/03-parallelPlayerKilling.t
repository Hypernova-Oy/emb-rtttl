#!/usr/bin/perl

use Modern::Perl;
use Test::More;

use Proc::PID::File;

use RTTTL::Player;

my $pin = 1;

subtest "Play two songs in staggered parallel order sharing the same GPIO-pin and kill the first one to let the second one play.", \&parallellKill;
sub parallellKill {

    my $pid = Proc::PID::File->new({name => RTTTL::Player::_makePidFileName($pin), verify => "play.pl"});
    ok(! $pid->alive(), "No process running");

    forkExec($pin, "Star_wars");
    ok($pid->alive(), "First play is running");
    my $firstPlayPid = $pid->read();

    forkExec($pin, "Top_Gun");
    my $secondPlayPid = $pid->read();
    ok($firstPlayPid != $secondPlayPid, "First play is killed");
    ok($pid->alive(), "Second play is running");

    RTTTL::Player::_killExistingPlayer($pid);
    ok(! $pid->alive(), "Second play is killed");
}


done_testing;

sub forkExec {
    my ($pin, $song) = @_;
    my $pid = fork();
    if ($pid == 0) { #I am a child
        exec "perl -Ilib scripts/rtttl-player -p $pin -d rtttl -o 'song-$song'";
        exit 0;
    }
    else {
        sleep 1; #Sleep a bit to give time for the forked process to execute
    }
}
