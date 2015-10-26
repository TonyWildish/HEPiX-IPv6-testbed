package Lifecycle::Core::Config::Agent;
# use File::Basename;

# our %params = (
# 	LABEL     => undef,
# 	DEFAULT   => 'on',
# );

# sub new
# {
#   my $proto = shift;
#   my $class = ref($proto) || $proto;
#   my $self = {};
#   $self  = ref($proto) ? $class->SUPER::new(@_) : {};

#   # my %args = (@_);
#   # defined($args{LABEL}) or die "Unnamed Agents are not allowed\n";

#   # map {
#   #       $self->{$_} = defined($args{$_}) ? $args{$_} : $params{$_}
#   #     } keys %params;

#   bless $self, $class;
#   return $self;
# }

# sub LOGDIR
# {
#   my ($self,$dir) = @_;
#   $self->{LOGDIR} = $dir ||
# 		      $self->{LOGDIR} ||
# 		      "\${PHEDEX_LOGS}/";
#   $self->{LOGDIR} .= '/' unless $self->{LOGDIR} =~ m%\/$%;
#   return $self->{LOGDIR};
# }

# sub LOGFILE
# {
#   my ($self,$file) = @_;
#   die "Cannot set LOGFILE, can only set LOGDIR\n" if $file;
#   $self->{LOGFILE} = $self->LOGDIR . $self->{LABEL};
#   return $self->{LOGFILE};
# }

# sub PIDFILE
# {
#   my ($self,$file) = @_;
#   $self->{PIDFILE} = $$file if $file;
#   $self->{PIDFILE} = $self->DROPDIR . 'pid' unless $self->{PIDFILE};
#   return $self->{PIDFILE};
# }

1;
