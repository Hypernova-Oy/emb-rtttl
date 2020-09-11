package RTTTL::Daemon;

use Modern::Perl;
use base qw(Net::Server::Single);

use RTTTL::Player;
my $player;

# over-ride the default echo handler
sub process_request {
  my $self = shift;
  eval {

    local $SIG{'ALRM'} = sub { die "Timed Out!\n" };
    my $timeout = 30; # give the user 30 seconds to type some lines

    my $previous_alarm = alarm($timeout);
    while (<STDIN>) {
      s/\r?\n$//;
      eval {
          $player->dispatchOperation($_);
      };
      if ($@) {
          print STDOUT ($@);
      }
      alarm($timeout);
    }
    alarm($previous_alarm);
  };
  if ($@ =~ /timed out/i) {
    print STDOUT "Timed Out.\r\n";
    return;
  }
}

sub start_daemon {
    my ($player_) = @_;
    $player = $player_ || RTTTL::Player->new({});
    $player->init(); # Init the wiringpi c-layer before stripping privileges
    my $server = RTTTL::Daemon->new(
        pid_file => $player->{rundir} . '/pid',
        port => $player->{rundir} . '/sock|unix',
        user => $player->{user},
        group => $player->{group},
    );
    $server->run();
}

1;
