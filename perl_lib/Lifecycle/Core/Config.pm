package Lifecycle::Core::Config;

sub new
{
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {};
  $self  = ref($proto) ? $class->SUPER::new(@_) : {};

  bless $self, $class;
  return $self;
}

1;