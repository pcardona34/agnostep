#!/bin/bash

# Install GRAND CENTRAL DISPATCH

_PWD=`pwd`
. ./SCRIPTS/environ.sh
LOG="$HOME/PISI_BUILD.log"

if [ -f $LOG ];then
	rm $LOG
fi
touch $LOG

SPIN='/-\|'

cd ../build || exit 1

echo "Lib DISPATCH - Grand Central Dispatch" >> $LOG
printf "\nBuilding Lib DISPATCH - Grand Central Dispatch"
printf "\nPlease, wait...\n"

if [ -d swift-corelibs-libdispatch ];then
	cd swift-corelibs-libdispatch
	git pull origin master &>/dev/null
else
	git clone --branch=main "https://github.com/apple/swift-corelibs-libdispatch" &>/dev/null
	cd swift-corelibs-libdispatch
fi

if [ -d build ];then
	cd build
else
	mkdir build && cd build
fi

cmake -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ ./
ninja
ninja install
sh autogen.sh
./configure
make
sudo make install
#cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DINSTALL_PRIVATE_HEADERS=YES
##&>>$LOG
#make clean
#&>/dev/null
#sudo make install &>>$LOG &
#sudo make install
#PID=$!

#i=1
#printf "Building...\n"
#echo -n ' '
#while [ -d /proc/$PID ]
#do
#	sleep 0.25
#	printf "\b${SPIN:i++%${#SPIN}:1}"
#done

cd $_PWD
printf "\nInstallation of Lib DISPATCH - Grand Central Dispatch"
printf "\nDone.\n"

################################

install_libdispatch

################################

sudo ldconfig
