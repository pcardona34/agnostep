#!/bin/bash

####################################################
### P i S i N     Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

####################################################
### PISIN Desktop Prep installation of GNUstep
####################################################

####################################################
### Vars

PISIN=`pwd`
SPIN='/-\|'
GS_ERRORS=0
. /etc/os-release
GSBUILD="../build/GNUstep_Build"
#set -v #For debugging the script only

### End of vars
####################################################

####################################################
### Include functions

. SCRIPTS/colors.sh
. SCRIPTS/spinner.sh
. SCRIPTS/environ.sh
. SCRIPTS/functions_prep.sh
. SCRIPTS/functions_install_gnustep.sh

### End of include functions
####################################################

#not_again || exit 1


LOG="$HOME/PISIN_PREP_GNUSTEP.log"

clear
title "Prepare the GNUstep installation"
echo "Prepare the GNUstep installation" > $LOG

##########################################
### DEPENDENCIES

##########################################
### Install of CMake 4.x
### Needed with OBJC2 and clang
##########################################

### Remove old cmake if installed
sudo apt -y remove cmake &>/dev/null

if ! [ -f $HOME/.local/bin/cmake ];then
	install_cmake
fi

test_cmake || exit 1

#########################################
### Dependencies (end)

cd $PISIN
LIST="gnustep" && install_deps

################################
### VARS
# Log
LOG=$HOME/GNUSTEP_BUILD.log
GS_SCRIPT=/usr/GNUstep/System/Library/Makefiles/GNUstep.sh

################################

title "Installing all GNUstep libs and Tools"
echo "Installing all GNUstep libs and Tools" > $LOG

# Create build directory

cd ${PISIN}
sudo rm -fR ${GSBUILD}
mkdir -p ${GSBUILD}
cd ${GSBUILD} || exit 1

#################################################
# Checkout sources
fetch_sources

#################################################
### Install Make (1)

install_make

if [ -f $GS_SCRIPT ];then
	. $GS_SCRIPT
else
	exit 1
fi

grep -e "$GS_SCRIPT" ~/.bashrc &>/dev/null
if [ $? -ne 0 ];then
	echo "export PATH=/usr/GNUstep/Local/Tools:$PATH" >> ~/.bashrc
	echo "export RUNTIME_VERSION=$RUNTIME_VERSION" >> ~/.bashrc
	echo "export LD=/usr/bin/ld.lld" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=/usr/GNUstep/Local/Library/Libraries:$LD_LIBRARY_PATH" >> ~/.bashrc
	echo ". $GS_SCRIPT" >> ~/.bashrc
fi

#################################################
## Build libDispatch

cd ${PISIN}
cd ${GSBUILD} || exit 1
install_GCD

#################################################
## Build libobjc2

cd ${PISIN}
cd ${GSBUILD} || exit 1
install_objc2

#################################################
## Install make (2)

cd ${PISIN}
cd ${GSBUILD} || exit 1
install_make

. $GS_SCRIPT

#################################################
## Build GNUstep base

cd ${PISIN}
cd ${GSBUILD} || exit 1
install_base

. $GS_SCRIPT

#################################################
## Build GNUstep GUI

cd ${PISIN}
cd ${GSBUILD} || exit 1
install_gui

. $GS_SCRIPT

#################################################
## Build GNUstep back

cd ${PISIN}
cd ${GSBUILD} || exit 1
install_back

. $GS_SCRIPT

export LDFLAGS="-fuse-ld=/usr/bin/ld.lld"
sudo ldconfig

#################################################
## GNUstep-Make: last stage

cd ${PISIN}
cd ${GSBUILD} || exit 1
install_make

info "Building of GNUstep is done."

#################################################
### Checking...

cd $PISIN
is_gnustep_ok || exit 1

