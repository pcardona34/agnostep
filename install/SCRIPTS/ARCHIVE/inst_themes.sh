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
### Install Themes
################################

################################
### ENV

LOG="$HOME/PISIN_THEMES.log"
_PWD=`pwd`
SPIN='/-\|'

### End of VARS
################################

################################
### Include functions

. SCRIPTS/colors.sh
. SCRIPTS/spinner.sh
. SCRIPTS/functions_inst_themes.sh

### End of Include functions
################################

################################

echo "$0" >$LOG

###############################################
install_wm_theme
install_gs_theme
