#!/bin/bash

####################################################
### P i S i N    Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

#################################################
### Funtions for Install GRAND CENTRAL DISPATCH	 #
#################################################

####################################################
### Install GCD
function install_libdispatch
{

LOG=$HOME/PISIN_BUILD_GCD.log
if ! [ -d ../build ];then
	mkdir -p ../build
fi
cd ../build || exit 1

TITLE="Lib DISPATCH - Grand Central Dispatch"
echo "$TITLE" >$LOG
title "$TITLE"

printf "Fetching...\n"

if [ -d swift-corelibs-libdispatch ];then
	cd swift-corelibs-libdispatch
	git pull &>/dev/null
else
	git clone --branch=main "https://github.com/apple/swift-corelibs-libdispatch" &>/dev/null
	cd swift-corelibs-libdispatch
fi

sudo rm -fR build
mkdir build && cd build

printf "Configuring...\n"

### Cleaning
sudo make clean &>/dev/null

C_FLAGS="-Wno_error=unused-but-set-variable"
cmake .. \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_C_FLAGS=${C_FLAGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_GOLD_LINKER=YES &>>$LOG &
PID=$!
spinner

printf "\rBuilding...\n"
make clean &>/dev/null
make ${MKARGS} &>>$LOG &
PID=$!
spinner

printf "\rInstalling...\n"
sudo -E make install &>>$LOG &
PID=$!
spinner

sudo ldconfig

cd $_PWD

ok "\rDone"

}
### End of function
################################
