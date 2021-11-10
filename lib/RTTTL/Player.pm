#!/usr/bin/perl
# Copyright (C) 2021 Hypernova Oy
# Copyright (C) 2016 Koha-Suomi
#
# This file is part of emb-buzzer.
#
# emb-rtttl is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# emb-rtttl is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with emb-buzzer.  If not, see <http://www.gnu.org/licenses/>.

package RTTTL::Player;

our $VERSION = "0.01";

use Modern::Perl;

use Data::Dumper;
use Time::HiRes;
use File::Slurp;
use Proc::PID::File;
use Config::Simple;

use RTTTL::XS;

my $confFile = "/etc/emb-rtttl/config";
my $confOrParamHelperText = "You can do it in conf file '$confFile' or as a cli parameter.";

sub new {
    my ($class, $params) = @_;
    my $self = _loadConfig();

    $self->{pin}      = $params->{pin}      || $self->{'default.pin'} || 18;
    $self->{dir}      = $params->{dir}      || $self->{'default.dir'} || '/var/local/rtttl';
    $self->{cverbose} = $params->{cverbose} || $self->{'default.cverbose'} || 3;
    $self->{rundir}   = $params->{rundir}   || $self->{'default.rundir'} || '.';
    $self->{user}     = $params->{user}     || $self->{'default.user'} || 'pi';
    $self->{group}    = $params->{group}    || $self->{'default.group'} || 'gpio';

    die "You must give parameter 'pin' to tell which wiringPi GPIO-pin we play as the beeper.\n$confOrParamHelperText" unless ($self->{pin});
    die "You must give parameter 'dir' to tell in which directory we look for the rtttl-songs.\n$confOrParamHelperText" unless ($self->{dir});
    die "You must give parameter 'cverbose' to tell should we print debug information about the rtttl-play. The bigger the number the more verbosity. \n$confOrParamHelperText" unless ($self->{dir});

    bless $self, $class;
    $self->{songs} = undef; # {} lazy load songs here
    $self->{songNames} = undef; # []

    if ($self->{cverbose} >= 4) {
        warn(Data::Dumper::Dumper($self)."\n");
    }
    return $self;
}

sub _loadConfig {
    my $c = Config::Simple->new($confFile)->vars() or die(Config::Simple->error());
    return $c;
}

sub init {
    my ($self) = @_;
    if (! $self->{_inited}) {
        $self->{_inited} = 1;
        $self->_checkPid();
        RTTTL::XS::init($self->{pin}, $self->{cverbose});
    }
}

sub dispatchOperation {
    my ($self, $op) = @_;
    if ($op eq 'list') {
        my ($songs, $names) = $self->getSongs();
        print(join("\n",@$names));
        print("\n");
    }
    elsif ($op eq 'random') {
        $self->playRandomSong();
    }
    elsif ($op =~ /^rtttl-(.+)$/) {
        $self->_playSong($1);
    }
    elsif ($op =~ /^song/) {
        if ($op =~ /^song-(.+)$/) {
            my $song = $1;
            $self->playSong($song);
        }
        else {
            die "Operation '$op' given but not prefixed with a song name?";
        }
    }
    else {
        die "Unknown operation '$op'";
    }
    print STDOUT ("OK: $op\r\n");
    return $self;
}

=head2 _checkPid

Checks if a RTTTL::Player is already playing in the given pin.
If a RTTTL::PLayer is using the pin, the existing play is killed and this
play is started.

=cut

sub _checkPid {
    my ($self) = @_;

    $self->{pid} = Proc::PID::File->new({dir => $self->{rundir}, name => _makePidFileName($self->{pin})});
    _killExistingPlayer($self->{pid}) if $self->{pid}->alive();
    $self->{pid}->touch();
}

sub _killExistingPlayer {
    my ($pid) = @_;
    warn("Killing existing PID='".$pid->{path}."'");
    kill 'INT', $pid->read();
}

sub _makePidFileName {
    my ($pin) = @_;
    return __PACKAGE__.'-'.$pin;
}

sub getSongs {
    my ($self) = @_;

    unless ($self->{songs}) {
        my $list = do $self->{dir}.'/songs.pl';
        $self->{songs} = $list;
        my @names = sort(keys(%$list));
        $self->{songNames} = \@names;
    }
    return ($self->{songs}, $self->{songNames});
}

sub playRandomSong {
    my ($self, $maxLength) = @_;
    $maxLength //= 20000;
    my ($songs, $names) = $self->getSongs();

    my $songIndex = int(rand(scalar(@$names)));
    while (length($songs->{$names->[$songIndex]}) > $maxLength) {
        $songIndex = int(rand(scalar(@$names)));
    }
    return $self->playSongIndex($songIndex);
}

sub playSong {
    my ($self, $name) = @_;

    my ($songs, $names) = $self->getSongs();
    my @matches = grep { $_ =~ m/$name/ } @$names;
    for my $songName (@matches) {
        $self->_playSong($songs->{$songName});
    }
    return 1 if @matches;
    return 0;
}

sub playSongIndex {
    my ($self, $index) = @_;

    my ($songs, $names) = $self->getSongs();
    my $song = $songs->{$names->[$index]};
    return 0 unless $song;
    $self->_playSong($song);
    return 1;
}

sub _playSong {
    my ($self, $song) = @_;
    $self->init(); # Do the hardware init as late as possible to allow other than play operations in unprivileged mode.
    return RTTTL::XS::play_rtttl($song);
}


1;
