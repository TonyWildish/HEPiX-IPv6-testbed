export TESTBED_ROOT=`pwd`
if [ ! -d $TESTBED_ROOT/EBI ] && [ ! -d $TESTBED_ROOT/HEPiX ]; then
	echo "Looks like you're not in the root directory of the git repository...?"
	exit 0
fi

export PERL5LIB=${PERL5LIB}:$TESTBED_ROOTperl_lib
export PATH=${PATH}:$TESTBED_ROOT/bin