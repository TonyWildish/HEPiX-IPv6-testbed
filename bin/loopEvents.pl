#!/usr/bin/perl -w
use strict;
use JSON::XS;
use Getopt::Long;

my ($in,$out,$json,$workflow,$payload,$event);
$payload = {};
GetOptions(
                'in=s'    => \$in,
                'out=s'   => \$out,
          );

if ( $in ) {
  open IN, "<$in" or die "open input $in: $!\n";

  $json = <IN>;
  close IN;
  $payload = decode_json($json);
  $workflow = $payload->{workflow};
}

foreach $event ( @{$workflow->{EventLoop}} ) {
  push @{$workflow->{Events}}, $event;
}
open  OUT, ">$out" or die "open output $out: $!\n";
print OUT encode_json($payload);
close OUT;

exit 0;
