#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

my ($config,$source,$remote,$cmd,@files);
$config = 'IPv6-Lifecycle.conf';
GetOptions(
            'config=s' => \$config,
          );

do "$config";

$cmd = 'gfal-ls -l';
foreach $source ( @Lifecycle::Sources ) {
  print "Source: ",$source->{Name},"\n";
  undef @files;
  $remote = 'srm://' .
            $source->{RemoteHost} .
            $source->{RemotePath};
  print "$cmd $remote\n";
  open CMD, "$cmd $remote 2>&1 |" or die "$cmd: $!\n";
  while ( <CMD> ) {
    print;
    if ( m%^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(file-.*.gz)\s*$% ) {
      push @files, $1;
    }
  }
  close CMD;
  foreach ( @files ) {
    print "Delete $_\n";
    open CMD, "gfal-rm $remote/$_ 2>&1|" or die "gfal-rm: $!\n";
    while ( <CMD> ) { print; }
    close CMD;
  }
}

print "All done\n";
