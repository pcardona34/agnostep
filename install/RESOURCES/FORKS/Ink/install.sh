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
### Install a Fork of Ink
### Purpose: a French localization
################################

################################
### VARS
STR="${PWD##*/}"
APP="${STR}"
HERE=`pwd`
DEP="" # 

################################
### include functions
. ../../../SCRIPTS/colors.sh
. ../../../SCRIPTS/log.sh
. ../../../SCRIPTS/find_app.sh
. ../../../SCRIPTS/check_app.sh
. ../../../SCRIPTS/functions_remove_app.sh

################################
### You must be superuser to install
sudo -v

titulo

STR="Purge old release";subtitulo
remove_ifx_app ${APP}

STR="Building and installing ${APP}";subtitulo
cd ${HERE} || exit 1

make clean &>/dev/null
make && ok "Build done"
sudo -E env PATH="$PATH:/System/Tools" make install && ok "Install done"

check "${APP}"
make clean &>/dev/null
sleep 2

ok "All was done for ${APP}"
sleep 3
