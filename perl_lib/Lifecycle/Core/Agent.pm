package Lifecycle::Core::Agent;

use strict;
use warnings;
use base 'Lifecycle::Core::Logging';
use POSIX;
use File::Path;
use File::Basename;
use Time::HiRes qw / time /;
use Lifecycle::Core::Command;
use Lifecycle::Core::Timing;
use Lifecycle::Core::Config;                                                       
use Lifecycle::Core::Loader;
use Data::Dumper;

our %params =
	(
	  ME		=> undef,
	  DBH		=> undef,
	  # SHARED_DBH	=> 0,
	  # DBCONFIG	=> undef,
	  # DROPDIR	=> undef,
	  # NEXTDIR	=> undef,
	  # INBOX		=> undef,
	  # WORKDIR	=> undef,
	  # OUTBOX	=> undef,
	  STOPFILE	=> undef,
	  PIDFILE	=> undef,
	  LOGFILE	=> undef,
	  # NODES		=> undef,
	  # IGNORE_NODES	=> undef,
	  # ACCEPT_NODES	=> undef,
	  WAITTIME	=> 7,
	  # AUTO_NAP      => 1,
	  # JUNK		=> undef,
	  # BAD		=> undef,
	  STARTTIME	=> undef,
	  NWORKERS	=> 0,
	  WORKERS	=> undef,
	  CONFIG_FILE	=> $ENV{PHEDEX_CONFIG_FILE},
	  LABEL		=> $ENV{PHEDEX_AGENT_LABEL},
	  ENVIRONMENT	=> undef,
	  AGENT		=> undef,
	  DEBUG         => $ENV{PHEDEX_DEBUG} || 0,
 	  VERBOSE       => $ENV{PHEDEX_VERBOSE} || 0,
	  # NOTIFICATION_HOST   => undef,
	  # NOTIFICATION_PORT   => undef,
	  # _DOINGSOMETHING     => 0,
	  # _DONTSTOPME	      => 0,
	  # STATISTICS_INTERVAL => 3600,	# reporting frequency
	  # STATISTICS_DETAIL   => 1,	# reporting level: 0, 1, or 2
          # LOAD_DROPBOX        => 1,     # Load Dropbox module...
          # LOAD_DROPBOX_WORKDIRS => 0,   # ...but not all the directories...
          # LOAD_CYCLE          => 1,     # Load Cycle module
          # LOAD_DB             => 1,     # Load DB module
	);

our (@required_params,@writeable_dirs,@writeable_files);
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
    my ($config,$cfg,$label,$key,$val);
    $config = $args{CONFIG_FILE} || $p{CONFIG_FILE};
    $label = $self->{LABEL} = $args{LABEL} || $p{LABEL} || $me;
    if ( $config && $label )
    {
      $cfg = Lifecycle::Core::Config->new();
      foreach ( split(',',$config) ) { $cfg->readConfig($_); }
      $self->{AGENT} = $cfg->select_agents($label);
      $self->{CONFIGURATION} = $cfg;

#     Is it really an error to not find the agent label in the config file?
      die "Cannot find agent \"$label\" in $config\n"
		unless $self->{AGENT} && ref($self->{AGENT});
      $self->{ENVIRONMENT} = $cfg->ENVIRONMENTS->{$self->{AGENT}->ENVIRON};
      die "Cannot find environment for agent \"$label\" in $config\n"
		unless $self->{ENVIRONMENT};

#     options from the configuration file override the defaults
      while (my ($k,$v) = each %{$self->{AGENT}->{OPTIONS}} )
      {
        $k =~ s%^-+%%;
        $k = uc $k;
#       Historical, mapping command-line option to agent-internal representation
        $k = 'DBCONFIG' if $k eq 'DB';
        $v = $self->{ENVIRONMENT}->getExpandedString($v);
        $p{$k} = $v;
      }

#     Some parameters are derived from the environment
      if ( $self->{AGENT} && $self->{ENVIRONMENT} )
      {
        foreach ( qw / DROPDIR LOGFILE PIDFILE / )
        {
          my $k = $self->{AGENT}->$_();
          $p{$_} = $self->{ENVIRONMENT}->getExpandedString($k);
        }
      }
    }

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

#   ensure parameters (PIDFILE, DROPDIR, LOGFILE, NODAEMON) are coherent
    if ( $args{LOGFILE} ) {
      push @writeable_files,'LOGFILE';
    } else {
      $self->{NODAEMON} = 1;
    }
    if ( $args{DROPDIR} ) {
      $self->{LOAD_DROPBOX} = 1;
      $self->{PIDFILE}  = $args{DROPDIR} . '/pid'  unless $args{PIDFILE};
      $self->{STOPFILE} = $args{DROPDIR} . '/stop' unless $args{STOPFILE};
    } else {
      $self->{LOAD_DROPBOX} = 0;
      $self->{PIDFILE}  = $self->{LABEL} . '.pid'  unless $args{PIDFILE};
      $self->{STOPFILE} = $self->{LABEL} . '.stop' unless $args{STOPFILE};
    }
    push @writeable_files,'PIDFILE';

#   Load the Dropbox modules. _Dropbox subclass is create and attach to self
    if ( $self->{LOAD_DROPBOX} ) {
      my $dropbox_module = $agent_module_loader->Load('Dropbox')->new( $self );
    }

    if ( !defined($self->{LOGFILE}) && !$self->{NODAEMON} )
    {
      $self->Fatal("PERL_FATAL: LOGFILE not set but process will run as a daemon");
    }

#   If required, daemonise, write pid file and redirect output.
    $self->daemon();

#   Load the Cycle modules. _Cycle subclass is create and attach to self
    my $cycle_module = $agent_module_loader->Load('Cycle')->new( $self ) if $self->{LOAD_CYCLE};
     
#   Announce myself...
    $self->Logmsg("label=$label");

    bless $self, $class;
    return $self;
}

# Dummy functions for Dropbox module
# sub readInbox {}
# sub readPending {}
# sub readOutbox {}
# sub renameDrop {}
# sub inspectDrop {}
# sub markBad {}
# sub processInbox {}
# sub processOutbox {}
# sub processWork {}
# sub processIdle {}
# sub cleanDropbox { }

# Dummy functions for DB module
# sub connectAgent {}
# sub disconnectAgent {}
# sub rollbackOnError {}
# sub checkNodes {}
# sub identifyAgent {}
# sub updateAgentStatus {}
# sub checkAgentMessages {}
# sub expandNodes {}
# sub myNodeFilter {}
# sub otherNodeFilter {}

# Dummy functions for Cycle module
sub preprocess {}
sub _start {}
sub _preprocess {}
sub _process_start {}
sub _process_stop {}
sub _maybeStop {}
sub _stop {}
# sub _make_stats { my $self = shift; $self->make_stats(); }
sub _child {}
sub _default { }

# Check if the agent should stop.  If the stop flag is set, cleans up
# and quits.  Otherwise returns.
sub maybeStop
{
    my $self = shift;

    # Check for the stop flag file.  If it exists, quit: remove the
    # pidfile and the stop flag and exit.
    return if ! -f $self->{STOPFILE};
    $self->Note("exiting from stop flag");
    $self->Logmsg("exiting from stop flag");
    $self->doStop();
}

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

    # Clear umask
    # umask(0);

    # Write our pid to the pid file while we still have the output.
    ((print PIDFILE "$$\n") && close(PIDFILE))
	  or die "$me: fatal error: cannot write to $self->{PIDFILE}: $!\n";

    # Indicate we've started
    print "$me: pid $$", ( $self->{DROPDIR} ? " started in $self->{DROPDIR}" : '' ), "\n";

    # Close/redirect file descriptors
    $self->{LOGFILE} = "/dev/null" if ! defined $self->{LOGFILE};
    open (STDOUT, ">> $self->{LOGFILE}")
  	or die "$me: cannot redirect output to $self->{LOGFILE}: $!\n";
    open (STDERR, ">&STDOUT")
  	or die "Can't dup STDOUT: $!";
    open (STDIN, "</dev/null");
    $|=1; # Flush output line-by-line
}

# Actually make the agent stop and exit.
sub doStop
{
    my ($self) = @_;

    # Run agent cleanup
    eval { $self->stop(); };
    # Remove stop flag and pidfile
    unlink($self->{PIDFILE});
    #unlink($self->{STOPFILE});

    POE::Kernel->alarm_remove_all();
    $self->doExit(0);
}

sub stop {}
sub processDrop {}

sub process
{
  my $self = shift;
# TW
die "Don't want this, do I?\n";
  # Work.

  $self->processInbox();
  my @pending = $self->processWork();
  $self->processOutbox();
  $self->processIdle(@pending);
  # Check to see if the config-file should be reloaded
  $self->checkConfigFile();
}

sub checkConfigFile
{
  my $self = shift;
  my ($config,$mtime,$Config);
  return unless $self->can('reloadConfig');

  $config = $self->{CONFIG_FILE};
  $mtime = (stat($config))[9];
  if ( $mtime > $self->{CONFIGURATION}{_readTime} )
  {
    $self->Logmsg("Config file has changed, re-reading...");
    $Config = Lifecycle::Core::Config->new();
    $Config->readConfig( $self->{CONFIG_FILE} );
    $self->{CONFIGURATION} = $Config;
    $self->reloadConfig($Config);
  }
}

# Agents should override this to do their work. It's an unfortunate name
# now, the work is done in the 'idle' routine :-(
sub idle { }

=head2 reloadConfig

Declare this in an agent subclass to reload the configuration after the
config-file has changed. Do not declare it if you don't want the config
file monitored.

=cut

#sub reloadConfig {}

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

# Print statistics
# sub make_stats
# {
#   my $self = shift;
  
  # my ($delay,$totalWall,$totalOnCPU,$totalOffCPU,$summary);
  # my ($h,$onCPU,$offCPU,$count);

  # $totalWall = $totalOnCPU = $totalOffCPU = 0;
  # $summary = '';
  # $h = $self->{stats};
  # if ( exists($h->{maybeStop}) )
  # {
  #   $summary .= ' maybeStop=' . $h->{maybeStop};
  #   $self->{stats}{maybeStop}=0;
  # }

  # $onCPU = $offCPU = 0;
  # $delay = 0;

  # if ( $summary )
  # {

  #   $summary = 'AGENT_STATISTICS' . $summary;
  #   $self->Logmsg($summary) if $self->{STATISTICS_DETAIL};
  #   $self->Logmsg($summary);
  # }
  # my $now = time;
  # $totalWall = $now - $self->{stats}{START}+.00001;
  # my $busy= 100*$totalOnCPU/$totalWall;
  # $summary = 'AGENT_STATISTICS';
  # $summary=sprintf('TotalCPU=%.2f busy=%.2f%%',$totalOnCPU,$busy);
  # ($self->Logmsg($summary),$self->Logmsg($summary)) if $totalOnCPU;

  # $summary .= "\n";

  # $self->Logmsg($summary);
  # $self->Logmsg($summary);
  # return $summary;
# }

sub StartedDoingSomething
{
  my ($self,$num) = @_;
  $num = 1 unless defined $num;
  $self->{_DOINGSOMETHING} += $num;
  return $self->{_DOINGSOMETHING};
}

sub FinishedDoingSomething
{
  my ($self,$num) = @_; 
  $num = 1 unless defined $num;
  $self->{_DOINGSOMETHING} -= $num;
  if ( $self->{_DOINGSOMETHING} < 0 )
  {
    $self->Logmsg("FinishedDoingSomething too many times: ",$self->{_DOINGSOMETHING}) if $self->{DEBUG};
    $self->{_DOINGSOMETHING} = 0;
  }
  return $self->{_DOINGSOMETHING};
}

1;
