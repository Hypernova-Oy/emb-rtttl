#!/usr/bin/perl

use Modern::Perl;
use Test::More;

use Proc::PID::File;

use RTTTL::Player;

my $pin = 18;
my $rtttlPlayerName = 'rtttl-player';
my $song = "Star Wars - Force Theme";

subtest "Check pid", \&checkPid;
sub checkPid {

    my $pid = Proc::PID::File->new({dir => '.', name => RTTTL::Player::_makePidFileName($pin), verify => $rtttlPlayerName});
    forkExec($pin, $song);
    ok($pid->alive(), "Pid wrote and alive");
    RTTTL::Player::_killExistingPlayer($pid);

}


subtest "Play two songs in staggered parallel order sharing the same GPIO-pin and kill the first one to let the second one play.", \&parallellKill;
sub parallellKill {

    my $pid = Proc::PID::File->new({dir => '.', name => RTTTL::Player::_makePidFileName($pin), verify => $rtttlPlayerName});
    ok(! $pid->alive(), "No process running");

    forkExec($pin, $song);
    ok($pid->alive(), "First play is running");
    my $firstPlayPid = $pid->read();

    forkExec($pin, $song);
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
        exec "perl -Ilib scripts/$rtttlPlayerName -p $pin -d ./rtttl --song='$song'";
        exit 0;
    }
    else {
        sleep 1; #Sleep a bit to give time for the forked process to execute
    }
}
