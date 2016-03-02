#!/usr/bin/perl -w
use strict;

my ($log,$f,$dir,$s,$r,$debug);
my ($index,$bytes,$mean,$inst,$file);

$debug = 0;
$log = "stdout.log";
$index = 0;
open LOG, "<$log" or die "open $log: $!\n";

print "Id,Name,Bytes,Mean,Inst\n";

while ( <LOG> ) {
  chomp;

  if ( m%^.*STDOUT\s+Dest:\s+gsiftp://[^/]*(/\S+)\s*$% ) {
    $dir = $1;
    $debug && print "Found $dir\n";
    $_ = <LOG>;
    chomp;
    m%^.*STDOUT\s+(\S+)\s*% or die "Expected a filename!\n";
    $f = $1;
    $debug && print "Found $f\n";
    $file = $dir . $f;
    $index++;
  }

  if ( m%^.*STDOUT\s+(\d+)\s+bytes\s+(\S+)\s+MB/sec avg\s+(\S+)\s+MB/sec inst\s*$% ) {
    $bytes = $1;
    $mean  = $2;
    $inst  = $3;
    $debug && print $bytes,', ',$mean,', ',$inst,"\n";
    print "$index,$file,$bytes,$mean,$inst\n";
  }
}
