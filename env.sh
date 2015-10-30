export TESTBED_ROOT=`pwd`
if [ ! -d $TESTBED_ROOT/EBI ] && [ ! -d $TESTBED_ROOT/HEPiX ]; then
	echo "Looks like you're not in the root directory of the git repository...?"
	exit 0
fi

[ -d data ] || mkdir data

if [ ! -f data/file-100.dat ] || [ ! -f data/file-1000.dat ]; then
	echo "Your 'data' directory doesn't have any big files in for testing. I'll make"
	echo "them now, please be patient for a couple of minutes"

# a 1 MB seed file
	if [ ! -f data/file-1.dat ]; then
		dd if=/dev/random of=data/file-1.dat bs=1024 count=1024
	fi

# a 100 MB file...
	if [ ! -f data/file-100.dat ]; then
		for i in 9 8 7 6 5 4 3 2 1 0; do
			for j in 9 8 7 6 5 4 3 2 1 0; do
				printf "  $i$j  \r"
				cat data/file-1.dat >> data/file-100.dat
			done
		done
	fi

# a 1 GB file
	if [ ! -f data/file-1000.dat ]; then
		for i in 9 8 7 6 5 4 3 2 1 0; do
			printf "  $i  \r"
			cat data/file-100.dat >> data/file-1000.dat
		done
	fi

fi

export PERL5LIB=${PERL5LIB}:$TESTBED_ROOTperl_lib
export PATH=${PATH}:$TESTBED_ROOT/bin