package Lifecycle::Core::Agent;

use strict;
use warnings;
use base 'Lifecycle::Core::Logging';
use POSIX;
use File::Path;
use File::Basename;
use Lifecycle::Core::Command;
# use Lifecycle::Core::Timing;
use Lifecycle::Core::Loader;

our %params =
	(
	  ME		=> undef,
	  STOPFILE	=> undef,
	  PIDFILE	=> undef,
	  LOGFILE	=> undef,
	  LABEL		=> $ENV{PHEDEX_AGENT_LABEL},
	  AGENT		=> undef,
	  DEBUG         => $ENV{PHEDEX_DEBUG} || 0,
 	  VERBOSE       => $ENV{PHEDEX_VERBOSE} || 0,
	);

sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = $class->SUPER::new(@_);
    my %p = %params;

    my %args = (@_);
    my $me = $self->AgentType($args{ME});

    my @agent_module_reject = ( qw / Template Agent AgentLite/ );
    my $agent_module_loader = Lifecycle::Core::Loader->new( NAMESPACE => 'Lifecycle',
                                                            REJECT    => \@agent_module_reject );

#   Retrieve the agent environment, if I can.
    my ($label,$key,$val);
    $label = $self->{LABEL} = $args{LABEL} || $p{LABEL} || $me;

#   Now set the %args hash, from environment or params if not the command-line
    foreach $key ( keys %p )
    {
      next if defined $args{$key};
      if ( $self->{ENVIRONMENT} )
      {
        $val = $self->{ENVIRONMENT}->getExpandedParameter($key);
        if ( defined($val) )
        {
          $args{$key} = $val;
          next;
        }
      }
      $args{$key} = $p{$key};
    }

    while (my ($k, $v) = each %args)
    { $self->{$k} = $v unless defined $self->{$k}; }

    $self->{NODAEMON} = 1 unless $args{LOGFILE};
    $self->{PIDFILE}  = $self->{LABEL} . '.pid'  unless $args{PIDFILE};

    if ( !defined($self->{LOGFILE}) && !$self->{NODAEMON} )
    {
      $self->Fatal("PERL_FATAL: LOGFILE not set but process will run as a daemon");
    }

#   If required, daemonise, write pid file and redirect output.
    $self->daemon();
     
#   Announce myself...
    $self->Logmsg("label=$label");

    bless $self, $class;
    return $self;
}

# Check if the agent should stop.  If the stop flag is set, cleans up
# and quits.  Otherwise returns.
# sub maybeStop
# {
#     my $self = shift;

#     # Check for the stop flag file.  If it exists, quit: remove the
#     # pidfile and the stop flag and exit.
#     return if ! -f $self->{STOPFILE};
#     $self->Note("exiting from stop flag");
#     $self->Logmsg("exiting from stop flag");
#     $self->doStop();
# }

sub doExit{ my ($self,$rc) = @_; exit($rc); }

sub daemon
{
    my ($self, $me) = @_;
    my $pid;

    # Open the pid file.
    open(PIDFILE, "> $self->{PIDFILE}")
	|| die "$me: fatal error: cannot write to PID file ($self->{PIDFILE}): $!\n";
    $me = $self->{ME} unless $me;
    if ( $self->{NODAEMON} )
    {
#     I may not be a daemon, but I still have to write the PIDFILE, or the
#     watchdog may start another incarnation of me!
      ((print PIDFILE "$$\n") && close(PIDFILE))
      	or die "$me: fatal error: cannot write to PID file ($self->{PIDFILE}): $!\n";
      close PIDFILE;
      return;
    }

    # Fork once to go to background
    die "failed to fork into background: $!\n"
  	if ! defined ($pid = fork());
    close STDERR if $pid; # Hack to suppress misleading POE kernel warning
    exit(0) if $pid;

    # Make a new session
    die "failed to set session id: $!\n"
	  if ! defined setsid();

    # Fork another time to avoid reacquiring a controlling terminal
    die "failed to fork into background: $!\n"
  	if ! defined ($pid = fork());
    close STDERR if $pid; # Hack to suppress misleading POE kernel warning
    exit(0) if $pid;

    # Write our pid to the pid file while we still have the output.
    ((print PIDFILE "$$\n") && close(PIDFILE))
	  or die "$me: fatal error: cannot write to $self->{PIDFILE}: $!\n";

    # Close/redirect file descriptors
    $self->{LOGFILE} = "/dev/null" if ! defined $self->{LOGFILE};
    open (STDOUT, ">> $self->{LOGFILE}")
  	or die "$me: cannot redirect output to $self->{LOGFILE}: $!\n";
    open (STDERR, ">&STDOUT")
  	or die "Can't dup STDOUT: $!";
    open (STDIN, "</dev/null");
    $|=1; # Flush output line-by-line
}

# sub checkConfigFile
# {
#   my $self = shift;
#   my ($config,$mtime,$Config);
#   return unless $self->can('reloadConfig');

#   $config = $self->{CONFIG_FILE};
#   $mtime = (stat($config))[9];
#   if ( $mtime > $self->{CONFIGURATION}{_readTime} )
#   {
#     $self->Logmsg("Config file has changed, re-reading...");
#     $Config = Lifecycle::Core::Config->new();
#     $Config->readConfig( $self->{CONFIG_FILE} );
#     $self->{CONFIGURATION} = $Config;
#     $self->reloadConfig($Config);
#   }
# }

sub AgentType
{
  my ($self,$agent_type) = @_;

  if ( !defined($agent_type) )
  {
    $agent_type = (caller(1))[0];
    $agent_type =~ s%^Lifecycle::%%;
    $agent_type =~ s%::Agent%%;
    $agent_type =~ s%::%%g;
  }
  return $self->{ME} = $agent_type;
}

1;