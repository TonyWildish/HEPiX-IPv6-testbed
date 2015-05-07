#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

my ($config,$source,$remote,$cmd,$src,$dst,$from,$to,$job,$service,$proxy);
$config = 'IPv6-Lifecycle.conf';
GetOptions(
            'config=s' => \$config,
            'src=s'    => \$src,
            'dst=s'    => \$dst
          );

defined $src or die "--src obligatory\n";
defined $dst or die "--dst obligatory\n";
do "$config";

$service = $Lifecycle::Lite{Templates}{IPv6MeshWorkflow}{FTSService};
$proxy = $Lifecycle::Lite{Templates}{IPv6MeshWorkflow}{Proxy};
$cmd = 'fts-transfer-submit -s ' . $service;
if ( $proxy ) {
  print "Setting proxy to be $proxy\n";
  $ENV{X509_USER_PROXY} = $proxy;
  $ENV{X509_USER_CERT}  = $proxy;
  $ENV{X509_USER_KEY}   = $proxy;
}
foreach $source ( @Lifecycle::Sources ) {
  if ( $src eq $source->{Name} ) {
    $from = 'srm://' .
            $source->{RemoteHost} .
            $source->{RemotePath} .
            '/src/file-100.gz';
  }
  if ( $dst eq $source->{Name} ) {
    $to = 'srm://' .
          $source->{RemoteHost} .
          $source->{RemotePath} .
          "/file-$src-$dst.gz";
  }
}

if ( ! $from ) { die "Cannot find $src in map\n"; }
if ( ! $to   ) { die "Cannot find $dst in map\n"; }
print "$cmd $from $to\n";
open CMD, "$cmd $from $to 2>&1 |" or die "$cmd: $!\n";
while ( <CMD> ) {
  print;
  if ( m%^[0-9,a-f,-]+$% ) { $job = $_; }
}
close CMD;

die "No job to monitor!\n" unless $job;
while ( 1 ) {
  sleep 10;
  open CMD, "fts-transfer-status -s $service -l $job |" or die "monitor: $!\n";
  while ( <CMD> ) { print; }
  close CMD;
}

print "All done\n";
