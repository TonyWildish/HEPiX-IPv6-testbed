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
  my $self = shift;
  my $line = $self->Hdr() . 'I: ' .join(' ',@_);
  chomp $line;
  print $line,"\n";
}

sub Warn
{
  my $self = shift;
  my $line = $self->Hdr() . 'W: ' .join(' ',@_);
  chomp $line;
  print $line,"\n";
}

sub Alert
{
  my $self = shift;
  my $line = $self->Hdr() . 'A: ' .join(' ',@_);
  chomp $line;
  print $line,"\n";
}

sub Dbgmsg
{
  my $self = shift;
  my $line = $self->Hdr() . 'D: ' .join(' ',@_);
  chomp $line;
  print $line,"\n";
}

sub Fatal
{
  my $self = shift;
  my $line = $self->Hdr() . 'F: ' .join(' ',@_);
  chomp $line;
  print $line,"\n";
  exit(1);
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

sub Hdr
{ 
  my $self = shift;
  my $me = me($self);
  my $date = strftime ("%Y-%m-%d %H:%M:%S", gmtime);
  return "$date: $me\[$$]: ";
}

1;