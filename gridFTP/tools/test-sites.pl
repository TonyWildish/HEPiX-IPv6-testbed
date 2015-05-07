#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my ($dir,$config,$cmd,$file,$h,@output,$doRM,$site);
my ($help,$debug,$verbose);
$help = $verbose = $debug = 0;
$dir  = '/data/ipv6/PHEDEX/Testbed/LifeCycle/IPV6/';
$file = 'data/file-100.gz';
$config = 'IPv6-Lifecycle.conf';

GetOptions(
	    "file=s"	=> \$file,
	    "config=s"	=> \$config,
	    "site=s"	=> \$site,
	    "help",	=> \$help,
	    "debug"	=> \$debug,
	    "verbose"	=> \$verbose,
	  );

$help && die "Help...less :-(\n";
print "Config file: $config\n";

eval {
  do "$config";
};
die $@ if $@;

foreach $h ( sort { $a->{Name} cmp $b->{Name} } @Lifecycle::Sources ) {
  print "\n------------------------------------------\n";
  print "Test $h->{Name}\n";
  next if ( $site && ( $h->{Name} ne $site ) );

  $cmd = "ping6 -c 3 -i 1 " . $h->{RemoteHost};
  open CMD, "$cmd |" or die "$cmd: $!\n";
  @output = <CMD>;
  if ( !close CMD ) {
    warn scalar localtime, ": Error from\n$cmd:\n$!\n";
    print @output;
    print "\n\n";
  } else {
    print scalar localtime, ": ping6: OK\n";
  }

  $doRM = 1;
  $cmd = "globus-url-copy -vb -ipv6 " .
	  ( $h->{Options}{To} ? $h->{Options}{To} . ' ' : '' ) .
          "file://$dir$file " .
          "gsiftp://" . $h->{RemoteHost} . $h->{RemotePath} . "/file-test.gz";
  open CMD, "$cmd |" or die "$cmd: $!\n";
  @output = <CMD>;
  if ( !close CMD ) {
    warn scalar localtime, ": Error from\n$cmd:\n$!\n";
    print @output;
    print "\n\n";
    $doRM = 0;
  } else {
    print scalar localtime, ": globus-url-copy: OK\n";
    print $cmd,"\n";
  }

  print "\n";
  $cmd = "echo dir " . $h->{RemotePath} . " | uberftp " .
	 ( $h->{UberFTPHost} || $h->{RemoteHost} );
  open CMD, "$cmd |" or die "$cmd: $!\n";
  @output = <CMD>;
  if ( !close CMD ) {
    warn scalar localtime, ": Error from\n$cmd:\n$!\n";
    print @output;
    print "\n\n";
  } else {
    print scalar localtime, ": uberftp dir: OK\n";
  }

  print "\n";
  next unless $doRM;
  $cmd = "echo rm " . $h->{RemotePath} . "/file-test.gz | uberftp " .
	 ( $h->{UberFTPHost} || $h->{RemoteHost} );
  open CMD, "$cmd |" or die "$cmd: $!\n";
  @output = <CMD>;
  if ( !close CMD ) {
    warn scalar localtime, ": Error from\n$cmd:\n$!\n";
    print @output;
    print "\n\n";
    next;
  } else {
    print scalar localtime, ": uberftp rm: OK\n";
  }
}

print "All done!\n";
