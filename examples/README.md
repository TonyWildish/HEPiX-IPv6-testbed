# The examples directory...

This directory contains a few example config files to show what the Lifecycle agent can do. You can run these to check that your installation is correctly configured. Not all of them have been tested/debugged lately, the ones which are known to work are:

- example-backoff.conf
- example-fork-counter-perl-scripts.conf
- example-fork-counter-python-scripts.conf
- example-fork-counter.conf
- example-make-report.conf
- example-make-statistics.conf
- example-ping-pong.conf

You can run any of these as follows:

> Lifecycle.pl --config example-XYZ.conf

To stop execution, hit CTRL-C

The others, listed below, are specific to environments that need proxy certificates. Don't bother with them yet unless you know what you're doing.
- example-Auth-proxy.conf
- example-Auth-self-signed-cert.conf
- example-Auth.conf
- example-CheckProxy.conf
