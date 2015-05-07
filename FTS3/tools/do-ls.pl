#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

my ($config,$source,$remote,$cmd,$src);
$config = 'IPv6-Lifecycle.conf';
GetOptions(
            'config=s' => \$config,
            'src'      => \$src
          );

do "$config";

$cmd = 'gfal-ls -l';
foreach $source ( @Lifecycle::Sources ) {
  print "Source: ",$source->{Name},"\n";
# print join(', ', sort keys %{$source}),"\n";
  $remote = 'srm://' .
            $source->{RemoteHost} .
            $source->{RemotePath};
  if ( $src ) { $remote .= '/src'; }
  print "$cmd $remote\n";
  open CMD, "$cmd $remote 2>&1 |" or die "$cmd: $!\n";
  while ( <CMD> ) { print; }
  close CMD;
}

print "All done\n";
