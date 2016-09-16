#!/usr/bin/perl
# Copyright (C) 2016 Koha-Suomi
#
# This file is part of emb-buzzer.
#
# emb-buzzer is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# emb-buzzer is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with emb-buzzer.  If not, see <http://www.gnu.org/licenses/>.

package Buzzer;

our $VERSION = "0.01";

use Modern::Perl;
use Time::HiRes;

use GPIO;

use RTTTL::XS;

use constant {
    BUZZ_FREQUENCY => 3050
};

sub new {
    my ($class, $BUZZER_GPIO_PORT) = @_;
    my $self = {};

    $self->{buzzerPort} = $BUZZER_GPIO_PORT;

    return bless $self, $class;
}

sub buzz {
    my ($self, $herz, $playTime) = @_;

    RTTTL::XS::play_tone($self->{buzzerPort}, $herz, $playTime);
}

sub beepWithPauses {
    my ($self, $beepCount, $pauseInSec, $beebLengthInSec) = @_;

    while ($beepCount >= 1) {
	$self->buzz(BUZZ_FREQUENCY, $beebLengthInSec);
	Time::HiRes::sleep($pauseInSec);
	$beepCount--;
    }
}

1;
