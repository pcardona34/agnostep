#!/bin/bash

####################################################
###A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

####################################################
### Functions for AGNoStep installation main script
####################################################

####################################################
### Vars

_PWD=`pwd`

### End of vars
####################################################

####################################################
### Include functions

. SCRIPTS/colors.sh

### End of include functions
####################################################

####################################################
### install main apps

function install_apps()
{
. SCRIPTS/inst_apps.sh
. SCRIPTS/inst_rpi_tools.sh
}
### End of apps
####################################################

####################################################
### install devel apps

function install_devel()
{
. SCRIPTS/inst_devel.sh
}
### End of devel
####################################################

####################################################
### Install the extra apps and games

function install_extra()
{
. SCRIPTS/inst_extra.sh
}

function install_games()
{
. SCRIPTS/inst_games.sh
}

### end of extra
####################################################

####################################################
###
function help()
{
clear
title "Main   A G N o S t e p   install script: Help"
printf "You can install AGNoStep applications like this:"
cli "./2_install_AGNOSTEP.sh <OPTION>"
printf "\n- OPTION could be one of: apps, devel, extra, games"

MESSAGE="- apps: means GWorkspace, Terminal, TextEdit, GNUMail, etc.\n \
(i) - You must use these options: 'apps' (mandatory) for a daily use. \n \
(i) - 'devel' for a GNUstep Workshop. \n \
(i) - 'extra' for more apps. \n \
(i) - 'Games' for the fun.\n \
(i) - Read 'RELEASE' for a detailed explanation."
info "$MESSAGE"
}
### end of help
####################################################

### End of functions
##############################################

