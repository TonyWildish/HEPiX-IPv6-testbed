package Lifecycle::Util;
use strict;
use warnings;

use Sys::Hostname;
use Exporter;
use Carp;
use POE;

our $VERSION = 1.00;
our @ISA     = qw/ Exporter /;
our @EXPORT  = qw/ Print /;

my ( $debug, $quiet, $verbose );

our $hdr = __PACKAGE__ . ":: ";
sub Croak { croak $hdr, @_; }
sub Carp  { carp $hdr,  @_; }

sub Print {
  my $time = time;
  print scalar localtime($time), ': ', @_;
}
sub Verbose { my $verbose = shift; $verbose && Print @_; }
sub Debug   { my $debug   = shift; $debug   && Print @_; }
sub Quiet   { my $quiet   = shift; $quiet   || Print @_; }

# sub check_host {
#   my $required = shift;
#   return unless $required;
#   return if $required =~ m%localhost%i;

#   my $host = hostname;
#   if ( $host ne $required ) {
#     Croak "Wrong machine (" . $host . " != " . $required . ")\n";
#   }
# }

# sub reroute_event {
#   $_ = shift;
#   my ( $kernel, $session ) = @_[ KERNEL, SESSION ];
#   s%^.*::_%%;
#   $kernel->yield( $_, @_[ ARG0 .. $#_ ] );
# }

sub ReadConfig {
  my ( $this, $hash, $file ) = @_;

  $file = $this->{Config} unless $file;
  defined($file) && -f $file or return;
  eval { require "$file"; };
  if ($@) {
    carp "ReadConfig: $file: $@\n";
    exit(1) if $this->{_config_first_read};
    return;
  }

  {
    no strict 'refs';
    if ( !$hash ) {
      ( $hash = $this->{Name} ) =~ s%^Lifecycle::%%;
      $hash =~ s%-.*$%%;
    }
    @$this{ keys %$hash } = values %$hash;

    foreach $hash ( keys %{ $this->{Partners} } ) {
      @{ $this->{$hash} }{ keys %{ $this->{Partners}->{$hash} } } =
        values %{ $this->{Partners}->{$hash} };
    }
  }

  $this->{ConfigRefresh} = 10 unless $this->{ConfigRefresh};
  if ( !defined( $this->{Node} ) ) {
    my $node = $this->{Name};
    $node =~ s%::.*$%%;
    $this->{Node} = $node;
  }
}

sub strhash {
  my $ref = shift;
  return join ', ', map { "$_ => $ref->{$_}" } sort keys %$ref;
}

1;
