#!/usr/bin/perl

# Copyright 2016 Vaara-kirjastot
#

use Modern::Perl;
use Carp;
use Getopt::Long qw(:config no_ignore_case);

use RTTTL::Player;

my $help;
my $verbose = 0;
my $operation;
my $pin;
my $dir;

GetOptions(
    'h|help'                      => \$help,
    'v|verbose:i'                 => \$verbose,
    'p|pin:i'                     => \$pin,
    'd|dir:s'               => \$dir,
    'o|operation:s'               => \$operation,
);

my $usage = <<USAGE;


A crappy RTTTL-player to play RTTTL-songs from the given directory

  -v --verbose            Defaults to 0, minimal output.
                          1, some output

  -h --help               HELP!

  -o --operation
                  list    list all songs in the directory
                  song    play the target
                  random
                          play a random song

  -d --dir                Which directory to use as the song base?

  -p --pin                Which wiringPi pin to use for playback?

EXAMPLES:

  perl scripts/play.pl -p 1 -d rtttl -o list
  perl scripts/play.pl -p 1 -d rtttl -o song-nyancat
  perl scripts/play.pl -p 1 -d rtttl -o random

USAGE

if ($help) {
  print $usage;
  exit 0;
}
unless ($operation =~ /(^list$)|(^song-\w+)|(^random$)/) {
  print $usage."\n".
        "You must define the --operation. Your --operation is '$operation'\n";
  exit 1;
}
unless ($pin && $pin =~ /^\d+$/) {
 print $usage."\n".
       "You must define the wiringPi --pin to send electricity from";
}
unless ($dir) {
 print $usage."\n".
       "You must define the directory --dir to play from";
}


my $player = RTTTL::Player->new({pin => $pin, dir => $dir});

if ($operation eq 'list') {
  print(join("\n",@{$player->getSongs()}));
}
elsif ($operation eq 'random') {
  my $songs = $player->getSongs();
  my $songIndex = int(rand(scalar(@$songs)));
  print "Playing a random song index '$songIndex'\n" if $verbose > 0;
  $player->playSongIndex($songIndex);
}
elsif ($operation =~ /^song/) {
  if ($operation =~ /^song-(.+)$/) {
    my $song = $1;
    print "Playing '$song'\n" if $verbose > 0;
    $player->playSong($song);
  }
  else {
    die "Operation $operation given but not prefixed with a song name?";
  }
}
else {
  die "Unknown operation '$operation'";
}
