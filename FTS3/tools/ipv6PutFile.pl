#!/usr/bin/perl -w
use strict;
use JSON::XS;
use Getopt::Long;
use Clone qw(clone);
use Time::HiRes qw ( time );
use Data::Dumper;

my ($in,$out,$json,$workflow,$payload,$src,$dst,@tmp,$status);
my ($start,$stop,$duration,$command);
GetOptions(
		'in=s'	=> \$in,
		'out=s'	=> \$out,
	  );
$in  || die "No input file specified\n";
$out || die "No output file specified\n";

open IN, "<$in" or die "open input $in: $!\n";

$json = <IN>;
close $in;
$payload = decode_json($json);
$workflow = $payload->{workflow};

# Find the files in the source directory
$src = $workflow->{InputFile};
($dst = $workflow->{OutputFile}) =~ s|%ID%|$payload->{id}|;
$dst = $workflow->{RemoteProtocol} .
       $workflow->{RemoteHost} .
       $workflow->{RemotePath} . '/' . $dst;
$payload->{start} = time();
print "Send $src to $dst\n";

$status = 0;
if ( $src !~ m%://% ) {
  $src = 'file://' . $src;
}
$command = 'fts-transfer-submit -s ' . $workflow->{FTSService};
if ( $workflow->{Options} ) {
  $command .= ' ' . $workflow->{Options};
}
print "$command $src $dst\n";
open FTS, "$command $src $dst 2>&1 |" or
     die "fts-transfer-submit: $!\n";
while ( <FTS> ) {
  print;
  chomp;
  if ( m%^[0-9,a-f,-]+$% ) {
    $payload->{FTSJobId} = $_;
  }
}
close FTS or do {
  $status = $! || $?;
  print "close fts-transfer-submit: $status\n";
  $payload->{report} = { status => 'error', reason => $status };
};

# Reset the delay that was originally put in for transfers...
$payload->{workflow}{Intervals}{putFile} = 0;
open  OUT, ">$out" or die "open output $out: $!\n";
print OUT encode_json($payload);
close OUT;

exit 0;
