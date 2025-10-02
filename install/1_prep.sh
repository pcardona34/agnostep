#!/bin/bash

####################################################
### AGNoStep Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

################################
### Sanity check, update, deps...
################################

###############################################################
### Vars
THERE=`pwd`
LOG="$HOME/AGNOSTEP_DEPS.log"
SPIN='/-\|'
STATUS=0
CONF=RESOURCES/AGNOSTEP.conf

### End of Vars
###############################################################

###############################################################
### include functions
. /etc/os-release
. ${CONF}
. SCRIPTS/colors.sh
. SCRIPTS/spinner.sh
. SCRIPTS/size.sh
. SCRIPTS/functions_prep.sh
### end of include functions
###############################################################

### Here it really begins...

echo "AGNoStep Desktop: init log" >>$LOG

clear

title "A G N o S t e p    D e s k t o p"

sleep 1

#########################

sanity_check || exit 1
debian_update || exit 1
sudo apt autoremove -y &>/dev/null

LIST="build" && install_deps

sudo ldconfig

########################

info "The System is up to date.\nYou may go on with step 2."
print_size
sleep 3

cd
