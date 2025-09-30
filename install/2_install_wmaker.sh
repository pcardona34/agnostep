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
### WMaker and dockapps
################################

### Install Window Maker
### And some DockApps...

################################
### ENV

LOG="$HOME/PISIN_BUILD_WM.log"
PISIN=`pwd`
SPIN='/-\|'
. /etc/os-release

### End of VARS
################################

################################
### Include functions

. SCRIPTS/colors.sh
. SCRIPTS/spinner.sh
. SCRIPTS/functions_prep.sh
. SCRIPTS/functions_inst_wmaker.sh

### End of Include functions
################################

################################

if ! [ -d ../build ];then
	mkdir -p ../build
fi

echo "$0" >$LOG

##############################################
## If you do not want any app to be installed
## Just comment the relevant line, below,
## save and run...
##############################################

### The DockApps must be built after wmaker and Wings libs.
clear
TITLE="Window Maker"
echo "$TITLE" >> $LOG
title "$TITLE"

########### !!! We do not build ############
#LIST="wmaker" && install_deps
#check_LD_LIB_PATH
#install_wmaker || exit 1
############################################

### We install regular deb #################
sudo apt -y install wmaker wmaker-utils
#sudo ldconfig

###############

###############################################
### REMOVED: the Dock of wmaker is hidden!
### Relevant services are done within Conky now.
#install_wmifs
#install_wmclock
#install_alsamixer_dot_app
