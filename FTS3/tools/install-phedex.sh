#!/bin/sh

export TESTBED_ROOT=/data/TESTBED_ROOT
if [ ! -d "$TESTBED_ROOT" ]; then
  echo "TESTBED_ROOT not defined or not a directory..."
  exit 0
fi
cd $TESTBED_ROOT
if [ `pwd` != $TESTBED_ROOT ]; then
  echo "Cannot cd to $TESTBED_ROOT"
  exit 0
fi

export SCRAM_ARCH=slc6_amd64_gcc481
export repo=comp.pre
export sw=$TESTBED_ROOT/sw
[ -d $sw ] && echo "Removing old sw installation..." && rm -rf $sw
mkdir -p $sw

# Base installation
wget -O $sw/bootstrap.sh http://cmsrep.cern.ch/cmssw/cms/bootstrap.sh
sh -x $sw/bootstrap.sh setup -path $sw -arch $SCRAM_ARCH -repository $repo
. $sw/$SCRAM_ARCH/external/apt/*/etc/profile.d/init.sh

# N.B. This is not guaranteed to pick up the latest version. Sorting doesn't
# find the '-compnnn' sufficex correctly
rpm=`apt-cache search 'PHEDEX-micro' | grep -v pre | sort | tail -1 | awk '{ print $1 }'`
echo Installing $rpm
apt-get -y install $rpm

rpm=`apt-cache search 'PHEDEX-lifecycle' | sort | tail -1 | awk '{ print $1 }'`
echo Installing $rpm
apt-get -y install $rpm

echo "All done!"
