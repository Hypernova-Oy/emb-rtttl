#!/usr/bin/perl
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

    $self->{pin} = $params->{pin} || $self->{'default.pin'};
    $self->{dir} = $params->{dir} || $self->{'default.dir'};

    die "You must give parameter 'pin' to tell which wiringPi GPIO-pin we play as the beeper.\n$confOrParamHelperText" unless ($self->{pin});
    die "You must give parameter 'dir' to tell in which directory we look for the rtttl-songs.\n$confOrParamHelperText" unless ($self->{dir});

    bless $self, $class;
    $self->_checkPid();

    RTTTL::XS::init($self->{pin});
    return $self;
}

sub _loadConfig {
    my $c = Config::Simple->new($confFile)->vars() or die(Config::Simple->error());
    return $c;
}

=head2 _checkPid

Checks if a RTTTL::Player is already playing in the given pin.
If a RTTTL::PLayer is using the pin, the existing play is killed and this
play is started.

=cut

sub _checkPid {
    my ($self) = @_;

    $self->{pid} = Proc::PID::File->new({name => _makePidFileName($self->{pin})});
    _killExistingPlayer($self->{pid}) if $self->{pid}->alive();
    $self->{pid}->touch();
}

sub _killExistingPlayer {
    my ($pid) = @_;
    kill 'KILL', $pid->read();
}

sub _makePidFileName {
    my ($pin) = @_;
    return __PACKAGE__.'-'.$pin;
}

sub getSongs {
    my ($self) = @_;

    opendir(D, $self->{dir}) || die "Can't open directory ".$self->{dir}.": $!\n";
    my @list = readdir(D);
    pop @list; pop @list;
    @list = sort @list;
    closedir(D);
    return \@list;
}

sub playSong {
    my ($self, $songFile) = @_;

    unless ($songFile =~ /.rtttl$/) {
        $songFile .= '.rtttl';
    }

    my $rtttlCode = File::Slurp::read_file($self->{dir}.'/'.$songFile, binmode => 'utf8');
    RTTTL::XS::play_rtttl($self->{pin}, $rtttlCode);
    return 1;
}

sub playSongIndex {
    my ($self, $index) = @_;

    my $songs = $self->getSongs();
    return $self->playSong($songs->[$index]);
}




1;
