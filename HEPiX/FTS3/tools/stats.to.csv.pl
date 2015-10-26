#!/usr/bin/perl -w
use strict;

my (@files,$file,$output,$dir,$src,$dst,$i,$I,$nOK,$lastDay,$nLastDay,$zipped);
$dir = '/tmp/wildish/results';
chdir $dir or die "chdir $dir: $!\n";

$output = $ENV{HOME} . '/www/Data/IPv6/transfer-data.csv';
open OUT, ">$output" or die "open $output: $!\n";
print OUT "From,To,Start,Stop,Status,Duration,JobTime,Filesize\n";
@files = <putFile*.log*>;
$I = $nOK = $nLastDay = 0;
$lastDay = time() - 86400;
foreach ( @files ) {
  $zipped = 0;
  m%^putFile\.([^_]+)_to_(.+)\.log(\.\d+.gz)?$% or die "$_: cannot parse\n";
  $src = $1;
  $dst = $2;
  $zipped = $3;
  print "from $src to $dst, ";
  $i = 0;
  if ( $zipped ) {
    open FILE, "cat $_ | gzip -d - |" or die "open $_: $!\n";
  } else {
    open FILE, "<$_" or die "open $_: $!\n";
  }
  while ( <FILE> ) {
    m%^(\d+)\S*\s+\S+\s+(-?\d+)\s%;
    if ( ! $2 ) {
      $nOK++;
      $nLastDay++ if $1 > $lastDay;
    }
    m%(\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+)(\s+\S+)?$%;
    $_ = $1;
    s/ /,/g;
    print OUT "$src,$dst,$_\n";
    $i++;
  }
  close FILE;
  print "$i entries\n";
  $I += $i;
}
close OUT;
print "data written to $output, $I entries total\n";
print "$nOK successful transfers (",int(1000*$nOK/$I)/10,"%)\n";
print "$nLastDay successful transfers in the last 24 hours\n";
$i = int(100 * $nOK/1024/1024)/100;
print "Transferred $i PB so far\n";
if ( $nLastDay ) {
  $i = (2 * 1024*1024 - $nOK) / $nLastDay;
  $i = int($i*100)/100;
  print "Estimate $i days left to the next petabyte\n";
  if ( $i < 1 ) {
    $i = (2 * 1024*1024 - $nOK) / $nLastDay;
    $i = int($i*24*100)/100;
    print "That's ",int($i)," hours and ",int( ($i-int($i)) * 24 * 10 )/10," minutes!\n";
  }
} else {
  print "No transfers in the last day...?\n";
}
