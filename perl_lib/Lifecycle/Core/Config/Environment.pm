package Lifecycle::Core::Config::Environment;

our %params = (
		NAME	    => undef,
		PARENT      => undef,
		ENVIRONMENT => undef,
		CONFIG      => undef,
	      );

sub new
{
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {};
  $self  = ref($proto) ? $class->SUPER::new(@_) : {};

  my %args = (@_);
  defined($args{NAME}) or die "Unnamed Environments are not allowed\n";

  map {
        $self->{$_} = defined($args{$_}) ? $args{$_} : $params{$_}
      } keys %params;
  bless $self, $class;
  return $self;
}

# sub AUTOLOAD
# {
#   my $self = shift;
#   my $attr = our $AUTOLOAD;
#   $attr =~ s/.*:://;
#   if ( exists($params{$attr}) )
#   {
#     $self->{$attr} = shift if @_;
#     return $self->{$attr};
#   }

#   return unless $attr =~ /[^A-Z]/;  # skip DESTROY and all-cap methods
#   my $parent = "SUPER::" . $attr;
#   $self->$parent(@_);
# }

# sub getParameter
# {
#   my ($self,$parameter) = @_;
# # TW
# die "Getting parameter: $parameter\n";
#   return undef unless defined $parameter;

#   if ( ! defined($self->{KEYS}) )
#   {
#     foreach ( split("\n",$self->Environment || '') )
#     {
#       m%^([^=]*)=(.*)$%;
#       $self->{KEYS}{$1} = $2;
#     }
#   }
#   local $_ = $self->{KEYS}{$parameter};
#   if ( ! $_ && $self->{PARENT} )
#   {
#     $_=$self->{CONFIG}{ENVIRONMENTS}{$self->{PARENT}}->getParameter($parameter);
#   }
#   $_ = $ENV{$parameter} unless $_;
#   s%;*$%% if $_;
#   return $_;
# }

# sub getExpandedString
# {
#   my ($self,$string) = @_;
# # TW
# die "Getting expanded string: $string\n";
#   return undef unless defined $string;

#   my $done = 0;
#   while ( ! $done )
#   {
#     $done = 1;
#     if ( $string =~ m%^([^{]*)\${([^}]*)}(.*$)% )
#     {
#       $string = $1 . $self->getParameter($2) . $3;
#       $done = 0;
#       next;
#     }
#     if ( $string =~ m%^([^{]*)\$([A-Z,0-9,_-]*)(.*$)% )
#     {
#       $string = $1 . $self->getParameter($2) . $3;
#       $done = 0;
#     }
#   }
#   return $string;
# }

# sub getExpandedParameter
# {
#   my ($self,$parameter) = @_;
# # TW
# die print "Getting expanded parameter: $parameter\n";
#   return undef unless defined $parameter;

#   my $value = $self->getParameter($parameter);
#   return undef unless defined $value;

#   $value = $self->getExpandedString($value);
#   return $value;
# }

# sub Environment
# {
#   my ($self,$environment) = @_;
#   my $parent;
#   if ( ! $environment )
#   {
#     my $parent;
#     $parent = $self->{CONFIG}{ENVIRONMENTS}{$self->{PARENT}}->Environment if $self->{PARENT};
#     return $self->{ENVIRONMENT};
#   }
#   undef $self->{KEYS};
#   $self->{ENVIRONMENT} = $environment;
#   return $self->Environment;

#   $self->{ENVIRONMENT} = $environment;
# }

1;
