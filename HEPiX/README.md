# Tools for the HEPiX IPv6 testbed

## the FTS3 testbed
Tools and analysis code for the FTS3 testbed are in the FTS3 directory. 

### FTS3/tools
This directory contains the code to actually run the testbed. The testbed last ran on lxplus0012 at CERN. This is a node in the lxplus-ipv6 cluster, where the tools are not always the most up-to-date, but at least the environment is installed cleanly.

To run on your own node, install the prerequisite Perl modules (see the top-level README in this package), plus make sure you have the FTS clients installed. You will need at least:
   * voms-proxy-init, voms-proxy-info
   * gfal-ls, gfal-rm
   * fts-transfer-submit, fts-transfer-status

I don't have much experience of installing these, if someone wants to contribute back instructions that would be really helpful.

The testbed is configured by the **IPv6-Lifecycle.conf** file. This is executable Perl code which is loaded at run-time by the Lifecycle agent. It's documented, so just go through and read the comments, following the instructions.

### FTS3/analysis
This directory contains the R code for analysing the output from the testbed to produce the plots. There's also an interactive 'shiny' app that lets you play with it without having to know R.

## the gridFTP testbed
The gridFTP testbed ran for about 3 years, but is decommissioned as of late 2014. The scripts for running the testbed are in the 'gridFTP/tools' directory, and the R script for producing the plots are in the 'gridFTP/analysis' directory.

The logfiles from the full three years of running were archived on AFS at CERN in ~wildish/work/public/IPv6, but have been removed. Mail me if you want them.

Since the gridFTP testbed hasn't run for a long time it might not work readily if someone tried to restart it. It would be better to start from the EBI gridFTP testbed, which is more current, and adapt it for whatever purpose you require.