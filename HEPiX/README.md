# Tools for the HEPiX IPv6 testbed

## the FTS3 testbed
Tools and analysis code for the FTS3 testbed are in the FTS3 directory. 

FTS3/tools contains the code to actually run the testbed. Currently the testbed runs on lxplus0012 at CERN. This is a node in the lxplus-ipv6 cluster, where the tools are not always the most up-to-date, but at least the environment is installed cleanly. If you're lucky there will be a README.md there explaining how it all works.

FTS3/analysis contains the R code for analysing the output from the testbed to produce the plots. There's also an interactive 'shiny' app that lets you play with it without having to know R.

## the gridFTP testbed
The gridFTP testbed ran for about 3 years, but is decommissioned as of late 2014. The scripts for running the testbed are in the 'gridFTP/tools' directory, and the R script for producing the plots are in the 'gridFTP/analysis' directory.

The logfiles from the full three years of running are archived on AFS at CERN in ~wildish/work/public/IPv6.

## Using the testbed
first, source the env.sh script in this directory. This will put the perl libraries and the **Lifecycle.pl** script in your **PERL5LIB** and **PATH**, respectively.

First, you can check your installation is sane by running some of the examples in the **examples** directory.

Next, go to the appropriate subdirectory (HEPiX/gridFTP, HEPiX/FTS3, or EBI/gridFTP) and follow the instructions in the README there.