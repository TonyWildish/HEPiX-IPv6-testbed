#!/usr/bin/perl -w
use strict;
use JSON::XS;
use Getopt::Long;
use Clone qw(clone);

my ($in,$out,$json,$workflow,$payload,$src,$dst,@tmp,$status,$node);
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
print "Delete $dst\n";

open GFAL, "gfal-rm $dst 2>&1 |" or die "gfal-rm: $!\n";
@tmp = <GFAL>;
close GFAL or do {
  $status = $!;
  print "close gfal-rm: $status\n";
  $payload->{report} = { status => 'error', reason => $status };
};

open  OUT, ">$out" or die "open output $out: $!\n";
print OUT encode_json($payload);
close OUT;

exit 0;
