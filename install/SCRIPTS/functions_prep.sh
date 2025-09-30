#!/bin/bash

####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

################################
### Functions for 1_prep.sh
################################

#############################################
### Sanity check
function sanity_check
{

title "Checking your environment"

TEST=1

. /etc/os-release
ARCHI=`uname -a | awk '{print $10}'`
MSG="On $ID - $VERSION_ID - ${ARCHI}\nYou are welcome!\n\n"

if [ "$ID" == "$REQUIRED_OS" ] && [ $VERSION_ID -eq $REQUIRED_RELEASE ];then
	TEST=0
fi

if [[ $TEST -eq 0 ]];then
	info "$MSG"
else
	alert "A G N o S t e p  Desktop should not be installed without $REQUIRED_OS ${REQUIRED_RELEASE}.\nAborting!\n"
	exit 1
fi
}
#############################################
### Is GNUstep already built ?
function not_again
{
### We should not reinstall GNUstep
### To avoid side effects...
GSPATH=/System
if [ -d $GSPATH ];then
	alert "GNUstep has been already built. DO NOT build again."
	info "To install apps, use instead the script:"
	cli "./5_install_AGNOSTEP.sh"
	exit 1
fi
}

#############################################
### Debian update
function debian_update
{

info "It is time to have a cup of tea or coffee. ;-)"

title "Updating Debian Lite OS"

printf "Updating...\n"

sudo apt update
sudo apt -y upgrade

ok "Done"
}
### End of Debian update
#############################################

#############################################
### Core dependencies for GNUstep
### and Window Maker Desktop
### Use: LIST="name" && install_deps
### See in RESOURCES available lists of deps
function install_deps
{
REF="${LIST:-build}"
OPTIONS="--no-show-upgraded --no-upgrade --yes"
title "Installing Dependencies"
. /etc/os-release
prefix="#"
local STATUS=0

FILE="${THERE}/RESOURCES/dep_${REF}_debian_${VERSION_ID}.txt"
if ! [ -f $FILE ];then
	alert "The file ${FILE} was not found."
	exit 1
fi
STRING=""
while read DEP
do
if [ -z "$DEP" ];then
	# This line is empty...
	continue
fi
echo "$DEP" | grep -e "$prefix" &>/dev/null
if [ $? -eq 0 ];then
	# This line is commented out...
	continue
else
	STRING="${DEP} ${STRING}"
fi
done < $FILE

if [ ! -z "STRING" ];then
	sudo apt-get ${OPTIONS} install ${STRING}
	if [ $? -ne 0 ];then
		alert "ERROR: a dependency was not resolved.\nAborting!!!" | tee -a $LOG
		warning "You must resolve this dependency trap.\nSee and fix ${FILE}. Then execute again:\n\n\t ${0}\n\n"
	else
		ok "\nDone"
	fi
else
	alert "The dependency list was empty."
	warning "You must check ${FILE}."
	exit 1
fi

}

#############################################
### A more up to date CMAKE
function install_cmake
{

TARGET=$HOME/.local
BUILD=../build

for DIR in $TARGET $BUILD
do
	if ! [ -d $DIR ];then
		mkdir -p $DIR
	fi
done

cd ../build || exit 1

if ! [ -f cmake-4.0.2-linux-aarch64.sh ];then
	printf "\nfetching: CMake-4.0.2...\n"
	wget --quiet https://github.com/Kitware/CMake/releases/download/v4.0.2/cmake-4.0.2-linux-aarch64.sh
fi

printf "Installing...\n"
bash ./cmake-4.0.2-linux-aarch64.sh --skip-license --exclude-subdir --prefix="$TARGET" &>/dev/null &
PID=$!
spinner

ok "\rDone"
}
### End of up to date CMake
#############################################

################################
### test of CMake release
################################

function test_cmake
{
CMV=`cmake --version | grep -e "version"`
MAJOR=`echo $CMV | awk '{print $3}' | awk -F. '{print $1}'`
if [ $MAJOR -eq 4 ];then
	info "Cmake version is ok:\n `cmake --version`"
else
	warning "Cmake is too old. Maybe a path issue..."
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

