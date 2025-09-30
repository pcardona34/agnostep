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
# set -v


### End of vars
####################################################

####################################################
### Include functions

. SCRIPTS/colors.sh
. SCRIPTS/spinner.sh
. SCRIPTS/environ.sh
. SCRIPTS/functions_prep.sh
. SCRIPTS/functions_inst_gnustep.sh
. SCRIPTS/functions_inst_libdispatch.sh
. SCRIPTS/functions_inst_libobjc2.sh

### End of include functions
####################################################

LOG="$HOME/PISIN_PREP_GNUSTEP.log"

clear
title "Prepare the GNUstep installation"
echo "Prepare the GNUstep installation" > $LOG

if ! [ -d ../build ];then
	mkdir ../build
fi

##########################################
### Install CMake 4
### Dependencies
##########################################

title "CMake 4.x"
echo "CMake 4.x" >> $LOG

cd $PISIN

if ! [ -f $HOME/.local/bin/cmake ];then
	install_cmake
fi
test_cmake || exit 1

cd $PISIN
LIST="gnustep" && install_deps

###############################
### GNUstep Make (1/2)
###############################

cd $PISIN
install_gnustep_make || exit 1
is_gnustep_ok || exit 1
sudo ldconfig


#########################################
### Install GRAND CENTRAL DISPATCH	#
#########################################

### About
# Grand Central Dispatch (GCD or libdispatch) provides comprehensive
# support for concurrent code execution on multicore hardware.
###

#########################################
### VARS
LOG="$HOME/PISIN_BUILD_GCD.log"

#########################################
title "Grand Central Dispatch"
echo "Installing GCD..." > $LOG

cd $PISIN
install_libdispatch || exit 1
sudo ldconfig

### Checking for GCD
GCD=/usr/local/lib/libdispatch.so

if ! [ -f $GCD ];then
	alert "The installation of Grand Central Dispatch failed."
	exit 1
else
	info "Check of Grand Central Dispatch..."
	ok "Done"
fi

is_gnustep_ok || exit 1
sudo ldconfig


################################
### Install LIBOBJC2
################################

################################
### VARS
LOG="$HOME/PISIN_BUILD_OBJC2.log"
cd $PISIN
################################

title "LIBOBJC2"
echo "Installing Libobjc2..." > $LOG

#testcmake
install_libobjc2 || exit 1
sudo ldconfig

### Ckecking for LIBOBJC2
OBJC=/usr/local/lib/libobjc.so

if ! [ -f $OBJC ];then
	alert "The installation of Objc2 failed."
	exit 1
else
	info "Check of Objc2..."
	ok "Done"

fi

is_gnustep_ok || exit 1
sudo ldconfig

################################
### Install all GNUstep libs and Tools
################################

################################
### VARS
LOG="$HOME/PISIN_BUILD_GNUstep.log"

cd $PISIN
################################

title "Installing all GNUstep libs and Tools"
echo "Installing all GNUstep libs and Tools" > $LOG

###############################
### GNUstep Make (2/2)
###############################

install_gnustep_make || exit 1

###############################
### Other libs...
###############################
cd $PISIN
install_gnustep_base || exit 1
is_gnustep_ok || exit 1

cd $PISIN
install_gnustep_corebase || exit 1
is_gnustep_ok || exit 1

cd $PISIN
install_gnustep_gui || exit 1
is_gnustep_ok || exit 1

cd $PISIN
install_gnustep_back || exit 1
is_gnustep_ok || exit 1


cd $PISIN
is_gnustep_ok || exit 1
