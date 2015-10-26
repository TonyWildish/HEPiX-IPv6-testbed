#!/bin/sh

export X509_USER_PROXY=/tmp/wildish/proxy/voms.ipv6.cert
export X509_USER_CERT=/tmp/wildish/proxy/voms.ipv6.cert
export X509_USER_KEY=/tmp/wildish/proxy/voms.ipv6.cert

echo "Run this on lxplus0012"

tmp=/tmp/wildish
base=$phedex/Testbed/LifeCycle
$base/Lifecycle.pl --config IPv6-Lifecycle.conf --log $tmp/ipv6.log
