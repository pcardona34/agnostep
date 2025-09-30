#!/bin/bash

####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################


####################################################
### W  A  R  N  I  N  G !
### We install GNUstep with the GNU Runtime
####################################################

####################################################
### Installation of GNUstep Core
####################################################

####################################################
### Vars

THERE=`pwd`
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
#. SCRIPTS/environ.sh
. SCRIPTS/functions_prep.sh
. SCRIPTS/functions_install_gnustep.sh

### End of include functions
####################################################

#not_again || exit 1


LOG="$HOME/AGNOSTEP_PREP_GNUSTEP.log"

clear
title "Prepare the GNUstep installation"
echo "Prepare the GNUstep installation" > $LOG

##########################################
### DEPENDENCIES

cd $THERE
LIST="gnustep" && install_deps

################################
### VARS
# Log
LOG=$HOME/GNUSTEP_BUILD.log
GS_SCRIPT=/System/Library/Makefiles/GNUstep.sh

################################

title "Installing all GNUstep libs and Tools"
echo "Installing all GNUstep libs and Tools" > $LOG

# Create build directory

cd ${THERE}
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
	alert "The path of GNUstep Makefiles is badly set."
	exit 1
fi

grep -e "$GS_SCRIPT" ~/.bashrc &>/dev/null
if [ $? -ne 0 ];then
#	echo "export PATH=/System/Tools:$PATH" >> ~/.bashrc
	echo ". $GS_SCRIPT" >> ~/.bashrc
fi

#################################################
## Build GNUstep base

cd ${THERE}
cd ${GSBUILD} || exit 1
install_base

sudo ldconfig
. $GS_SCRIPT

#################################################
## Build GNUstep GUI

cd ${THERE}
cd ${GSBUILD} || exit 1
install_gui

sudo ldconfig
. $GS_SCRIPT

#################################################
## Build GNUstep back

cd ${THERE}
cd ${GSBUILD} || exit 1
install_back

sudo ldconfig
. $GS_SCRIPT

info "Building of GNUstep is done."

#################################################
### Checking...

cd $THERE
is_gnustep_ok || exit 1

