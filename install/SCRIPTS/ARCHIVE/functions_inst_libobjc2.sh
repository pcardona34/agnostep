#!/bin/bash

####################################################
### P i S i N    Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

################################
### Functions for Install LIBOBJC2
################################

###################################
### Install objc2
function install_libobjc2
{
LOG=$HOME/PISIN_BUILD_LIBOBJC2.log
### Dependency
title "Robin Map Dev dependency"
sudo apt-get install -qq robin-map-dev &>/dev/null &
PID=$!
spinner
ok "\rDone"

if [ -d ../build ];then
	cd ../build
else
	mkdir -p ../build && cd ../build
fi

title "Lib OBJC2"
echo "Lib OBJC2" >$LOG

printf "Fetching...\n"
if [ -d libobjc2 ];then
	cd libobjc2
	git submodule update &>/dev/null
else
	git clone https://github.com/gnustep/libobjc2 &>/dev/null
	cd libobjc2
	git submodule init && git submodule update
fi

sudo rm -Rf build
mkdir build && cd build

printf "Configuring...\n"
C_FLAGS="-Wno-error=unused-but-set-variable"
cmake .. \
	-DCMAKE_C_COMPILER=${CC} \
	-DCMAKE_CXX_COMPILER=${CXX} \
	-DCMAKE_ASM=${CC} \
	-DCMAKE_LINKER=${LD} \
	-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS} \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_STATIC_LIBOBJC=1 \
	-DTESTS=OFF &>>$LOG &
PID=$!
spinner

printf "\rBuilding...\n"
cmake --build &>>$LOG &
PID=$!
spinner

printf "\rInstalling...\n"
sudo -E make install &>>$LOG &
PID=$!
spinner

sudo ldconfig

cd $_PWD

ok "\rDone."

}
### end of function
###########################

################################
### test of CMake release
################################

function testcmake
{
CMV=`cmake --version | grep -e "version"`
MAJOR=`echo $CMV | awk '{print $3}' | awk -F. '{print $1}'`
if [ $MAJOR -eq 4 ];then
	info "Cmake version is now ok."
else
	warning "Cmake version seems not good. \nMaybe a PATH issue?"
	sleep 1
	echo $PATH | grep -e ".local/bin" &>/dev/null
	if ! [ $? -eq 0 ];then
		export PATH=$HOME/.local/bin:$PATH
		### recursive call
		testcmake
	else
		alert "Cmake version could not been solved. Aborting. Please report this issue."
		exit 1
	fi

fi

}

