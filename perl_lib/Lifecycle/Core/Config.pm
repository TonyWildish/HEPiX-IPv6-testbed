package Lifecycle::Core::Config;
# use Lifecycle::Core::Config::Environment;
# use Lifecycle::Core::Config::Agent;
# use Cwd;

# our %params = (
    # AGENTS       => undef,
    # ENVIRONMENTS => undef,
    # PARANOID     => 1,
# );

# our %commands =
# (
  # terminate => "[ -f \$pidfile ] && kill \$(cat \$pidfile)",
  # kill      => "[ -f \$pidfile ] && kill -9 \$(cat \$pidfile)",
  # hup       => "[ -f \$pidfile ] && kill -HUP \$(cat \$pidfile)",
# stop      => "[ -d \$dropdir ] && touch \$dropdir/stop",
  # stop      => '#',
  # start     => '#',
  # show      => '#',
# );

sub new
{
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {};
  $self  = ref($proto) ? $class->SUPER::new(@_) : {};

  # my %args = (@_);
  # map {
  #       $self->{$_} = defined($args{$_}) ? $args{$_} : $params{$_}
  #     } keys %params;
  bless $self, $class;

  # if ( ! exists($self->{ENVIRONMENTS}{common}) )
  # {
  #   $self->{ENVIRONMENTS}{common} = Lifecycle::Core::Config::Environment->new
  #     (
  #       NAME  => 'common',
  #       CONFIG  => $self,
  #      );
  # }
  return $self;
}

# sub readConfig
# {
#   my ($self,$file, $fhpattern) = @_;
#   -f $file || die "$file: no such file\n";
#   -r $file || die "$file: not readable\n";

# # Record initial config-files (i.e. not recursively-opened files)
#   my $depth = $fhpattern || 0;
#   if ( $file !~ m%^/% )
#   {
#     my $cwd = getcwd();
#     $file = $cwd . '/' . $file;
#   }
#   push @{$self->{CONFIG_FILES}}, $file unless $depth;

#   $fhpattern++; # Avoid stomping over recursed files
#   open($fhpattern, "< $file") || die "$file: cannot read: $!\n";
#   while (<$fhpattern>)
#   {
#     while (defined $_ && /^\#\#\#\s+([A-Z]+)(\s+(.*)|$)/)
#     {
#       chomp; s/\s+$//;
#       # Here we process ENVIRON sections, defined as follows:
#       # ### ENVIRON [optional label]
#       if ($1 eq "ENVIRON")
#       {
#         print STDERR "$file: $.: Unlabelled ENVIRONs are",
#              " deprecated, treating as 'common'\n"
#       if ! $3;

#         my ($label,$env,$environment);
#         $label = $3 || "common";

# #       The environment may already exist, in which case append to it...
#         $env = $self->{ENVIRONMENTS}{$label} ||
#                Lifecycle::Core::Config::Environment->new
#         (
#           NAME  => $label,
#           CONFIG  => $self,
#         );
#         if ( $label ne 'common' && exists $self->{ENVIRONMENTS}{common} )
#         {
#           $env->PARENT('common');
#         }
#         $environment = $env->Environment();
#         while (<$fhpattern>)
#         {
#            last if /^###/; chomp; s/#.*//; s/^\s+//; s/\s+$//;
#            $environment .= "$_\n" if ($_ ne "");
#         }
#         $env->Environment($environment);
#         $self->{ENVIRONMENTS}{$label} = $env;
#       }

#       # Here we process AGENT sections, defined as follows:
#       # ### AGENT LABEL=<label> PROGRAM=<executable> [ENVIRON=<label>
#       elsif ($1 eq "AGENT")
#       {
#         my %params = map { m|([^=]+)=(\S+)|g } split(/\s+/, $3);
#         my $opts;
#         while (<$fhpattern>)
#         {
#           last if /^###/; chomp; s/#.*//; s/^\s+//; s/\s+$//;
#           next if m%^\s*$%;
#           $opts .= " $_";
#           next unless m%^\s*(\S+)\s+(.*)\s*$%;
#           my $k = $1;
#           my $v = $2;
#           $k =~ s%^-+%%;
#           $k = uc $k;
#           if ( exists($params{OPTIONS}{$k}) )
#           {
#             if ( ref($params{OPTIONS}{$k}) ne 'ARRAY' )
#             {
#               my $v1 = $params{OPTIONS}{$k};
#               $params{OPTIONS}{$k} = [];
#               push @{$params{OPTIONS}{$k}},$v1;
#             }
#             push @{$params{OPTIONS}{$k}},$v;
#           }
#           else
#           {
#             $params{OPTIONS}{$k} = $v;
#           }
#         }
#         my $agent = Lifecycle::Core::Config::Agent->new
#         (
#           %params,
#           OPTS  => $opts,
#         );
#         push @{$self->{AGENTS}}, $agent;
#       }

#       # Here we process IMPORT sections, defined as follows:
#       # ### IMPORT FILE
#       elsif ($1 eq "IMPORT")
#       {
#         my $dirpart = $file;
#         my $newfile = $3;
#         $dirpart =~ s|/[^/]+$||;
#         $dirpart = "." if $dirpart eq $file;
#         $self->readConfig ("$dirpart/$newfile", $fhpattern);
#       }
#       else
#       {
#         die "unrecognised section $1\n";
#       }
#     }
#   }

#   close ($fhpattern);

# # Now add the config files to the common environment!
#   if ( defined $self->{ENVIRONMENTS}{common} && !$depth )
#   {
#     my $e = $self->{ENVIRONMENTS}{common}->Environment();
#     $e .= "export PHEDEX_CONFIG_FILE=" .
#      join(',',@{$self->{CONFIG_FILES}}) .
#           "\n";
#     $self->{ENVIRONMENTS}{common}->Environment($e);
#   }
#   $self->{_readTime} = time();
# }

1;