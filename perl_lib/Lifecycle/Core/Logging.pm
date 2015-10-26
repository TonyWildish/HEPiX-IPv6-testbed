package Lifecycle::Core::Logging;
use Sys::Hostname;

use strict;
use warnings;
use base 'Exporter';
our @EXPORT = qw( Hdr new Logmsg Warn Dbgmsg Fatal );
use POSIX;
use File::Basename;
use IO::Socket;

our $shared_me = ''; # for log4perl subroutine, set by me()

# 'new' is declared as a dummy routine, just in case it ever gets called...
sub new
{
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my %h = @_;
  my $self = \%h;
  bless $self, $class;
  return $self;
}

my $config_file;
sub Logmsg
{
  my $self = shift; me($self);
  # my $logger = get_logger("PhEDEx");
  # $logger->info(@_);
  print "I: ",join(' ',@_),"\n";
}

# Notify(msg) -- log through udp socket to remote -- not using Log4perl
# This is a quick'n'dirty debugging aid, get all the alerts and fatals in
# one place.
# sub Notify
# {
#   my $self = shift; me($self);
#   my ($port,$server);
#   if ( ref($self) eq 'HASH' || ref($self) =~ m%^Lifecycle::% )
#   {
#     $port = $self->{NOTIFICATION_PORT};
#     $server = $self->{NOTIFICATION_HOST};
#   }
#   if ( !$port )
#   {
#     eval {
#       $port = $self->{ENVIRONMENT}->getExpandedParameter('PHEDEX_NOTIFICATION_PORT');
#     };
#     eval { $port = $ENV{PHEDEX_NOTIFICATION_PORT}; } unless $port;
#     $self->{NOTIFICATION_PORT} = $port if $port;
#   }
#   return unless defined $port;

#   if ( !$server )
#   {
#     eval {
#       $server = $self->{ENVIRONMENT}->getExpandedParameter('PHEDEX_NOTIFICATION_HOST');
#     };
#     eval { $server = $ENV{PHEDEX_NOTIFICATION_HOST}; } unless $server;
#     $self->{NOTIFICATION_HOST} = $server if $server;
#   }
#   $server ||= hostname;

#   my $message = join('',Lifecycle::Core::Logging::Hdr($self),@_);
#   chomp $message;
#   $message .= "\n";
#   eval
#   {
#     eval("use IO::Socket");
#     my $socket = IO::Socket::INET->new( Proto		=> 'udp',
# 				        PeerPort	=> $port,
# 				        PeerAddr	=> $server );
#     $socket->send( $message );
#   };
# }

# Alert(msg) -- log as ERROR
# sub Alert
# {
#   my $self = shift; me($self);
#   my $logger = get_logger("PhEDEx");
#   $logger->error("alert: ",@_);
#   Lifecycle::Core::Logging::Notify($self,'alert: ',@_);
# }

# Warn(msg) -- log as WARN
sub Warn
{
  my $self = shift; me($self);
  # my $logger = get_logger("PhEDEx");
  # $logger->warn("warning: ", @_);
  print "W: ",join(' ',@_),"\n";
}

# Dbgmsg(msg) -- log as DEBUG
sub Dbgmsg
{
  my $self = shift; me($self);
  # my $logger = get_logger("PhEDEx");
  # $logger->debug("debug: ", @_);
  print "D: ",join(' ',@_),"\n";
}

# fatal(msg) -- log as FATAL and exit
sub Fatal
{
  my $self = shift; me($self);
  # my $logger = get_logger("PhEDEx");
  # $logger->fatal("fatal: ", @_);
  # Lifecycle::Core::Logging::Notify($self,'fatal: ',@_);
  print "F: ",join(' ',@_),"\n";
  exit(1);
}

# Note(msg) -- log as INFO
sub Note
{
  die "Logger::Node is deprecated\n"
}

# Attempts to get a short package name
# Agents set this in their $self
# For standalone scripts, we just use the last part of $0
# This also sets the $shared_me which can be used in %N of log4perl
sub me
{
  my $self = shift;
  my $me;
  if ( $self ) { $me  = $self->{ME} };
  if ( !$me ) { $me = $0; $me =~ s|.*/||; }
  $Lifecycle::Core::Logging::shared_me = $me;
  return $me;
}

# Hdr() -- make up header
sub Hdr
{ 
  my $self = shift;
  my $me = me($self);
  my $date = strftime ("%Y-%m-%d %H:%M:%S", gmtime);
  return "$date: $me\[$$]: ";
}

# get_log_level -- get current logging level
# sub get_log_level
# {
#   my $logger = get_logger("PhEDEx");

#   if    ( $logger->level == $DEBUG ) { return "DEBUG" }
#   elsif ( $logger->level == $INFO )  { return "INFO" }
#   elsif ( $logger->level == $WARN )  { return "WARN" }
#   elsif ( $logger->level == $ERROR ) { return "ERROR" }
#   elsif ( $logger->level == $FATAL ) { return "FATAL" }
#   return "UNKNOWN";
# }

# set_log_level -- set current logging level
# sub set_log_level
# {
#   # only interested in level
#   if ($#_ > 0)
#   {
#      # called as a method
#      shift;
#   }

#   my $level = shift;
#   my $logger = get_logger("PhEDEx");

#   if ( $level eq "DEBUG" ) { $logger->level($DEBUG) }
#   elsif ( $level eq "INFO" ) { $logger->level($INFO) }
#   elsif ( $level eq "WARN" ) { $logger->level($WARN) }
#   elsif ( $level eq "ERROR" ) { $logger->level($ERROR) }
#   elsif ( $level eq "FATAL" ) { $logger->level($FATAL) }
# }

# logger_stat -- dump internal information of the logger
# sub logger_stat
# {
# 	use Data::Dumper;
# 	my $logger = get_logger("PhEDEx");
# 	my $appender;
# 	print "Dumping internal state of the logger ...\n";
# 	print "config_file =", $config_file, "\n";
# 	print Dumper($logger);
# 	foreach $appender (@{$logger->{'appender_names'}})
# 	{
# 		print "Appender: ", $appender, "\n";
# 		print Dumper(${Log::Log4perl::Logger::APPENDER_BY_NAME}{$appender});
# 	}
# }

1;
