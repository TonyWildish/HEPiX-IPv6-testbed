#!/usr/bin/perl -w
use strict;
use JSON::XS;
use Getopt::Long;
use Clone qw(clone);
use Time::HiRes qw ( time );
use Data::Dumper;

my ($in,$out,$json,$workflow,$payload,$jobID,$status,$reportStatus,$log);
my ($jobtime,$start,$stop,$duration,$command);
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
$jobID = $payload->{FTSJobId};
$start = $payload->{start};

$status = 0;
$command = 'fts-transfer-status -l -s ' . $workflow->{FTSService};
if ( $workflow->{Options} ) {
  $command .= ' ' . $workflow->{Options};
}
$reportStatus = 0;
open FTS, "$command $jobID 2>&1 |" or die "fts-transfer-status: $!\n";
while ( <FTS> ) {
  chomp;
  if ( m%^[A-Z]+$% ) {
    $payload->{FTSJobStatus} = $_;
    if ( m%^FINISHED$% || m%^FAILED$% ) {
      $reportStatus = 1;
    } else {
      unshift @{$workflow->{Events}}, 'pollJob';
    }
  }
  if ( m%^\s+Duration:\s+(\d+)\s*$% ) {
    $duration = $1;
  }
}
close FTS or do {
  $status = $! || $?;
  print "close fts-transfer-status: $status\n";
  $payload->{report} = { status => 'error', reason => $status };
};
print "Poll job $jobID, status=",$payload->{FTSJobStatus}, ($reportStatus ? ", duration=$duration" : ''),"\n";

if ( $payload->{FTSJobStatus} eq 'FAILED' ) {
# Something went wrong, get full output
  $status = -1;
  open FTS, "$command -v -l $jobID 2>&1 |" or die "fts-transfer-status: $!\n";
  while ( <FTS> ) { print; }
  close FTS;
}

if ( $reportStatus ) {
  $stop = time();
  $jobtime = int(($stop-$start)*1000)/1000;
  $log = $workflow->{TmpDir} . 'results/putFile.' . $workflow->{Name} . '.log';
  $log =~ s% %_%g;
  $status = 0 unless defined $status;
  open LOG, ">>$log";
  my $size = $workflow->{InputFileSize};
  if ( !defined($size) ) {
    print Dumper($workflow),"\n";
  }
  print LOG "$start $stop $status $duration $jobtime $workflow->{InputFileSize} $jobID\n";
  close LOG;
}
  
# Reset the delay that was originally put in for transfers...
$payload->{workflow}{Intervals}{putFile} = 0;
open  OUT, ">$out" or die "open output $out: $!\n";
print OUT encode_json($payload);
close OUT;

exit 0;
