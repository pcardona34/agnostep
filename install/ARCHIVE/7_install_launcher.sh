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
### Install a Desktop Launcher
### This will start the desktop after login
####################################################

_PWD=`pwd`
clear

. SCRIPTS/colors.sh

####################################################
### Copy the template into the home directory

TITLE="Installing the launcher"
title "$TITLE"

LAUNCHER=RESOURCES/SCRIPTS/_bash_profile
cp --remove-destination $LAUNCHER $HOME/.bash_profile
ok "Done"

info "You must log out now and then log in again to use the auto-launcher. Type:"
cli "exit"

