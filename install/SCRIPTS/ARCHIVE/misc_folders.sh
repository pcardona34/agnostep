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
### Miscellaneous for Home Folders
################################

################################
### ENV

LOG="$HOME/PISIN_MISC_FOLDERS.log"
_PWD=`pwd`
SPIN='/-\|'

### End of VARS
################################

################################
### Include functions

. SCRIPTS/colors.sh
. SCRIPTS/spinner.sh
. SCRIPTS/functions_misc_folders.sh

### End of Include functions
################################

################################

echo "$0" >$LOG

###############################################
for FOLD in Books Favorites GNUstep Mailboxes Samples SOURCES
do
	printf "Setting Folder ${FOLD}\n"
	icon_folder $FOLD
	ok "Done"
done
