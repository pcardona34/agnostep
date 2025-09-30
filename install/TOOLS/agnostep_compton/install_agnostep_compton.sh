#!/bin/bash

####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

################################
### Install the Compton conf file
### herited from B. Deconinck
################################

################################
### VARS

AUTO=$HOME/GNUstep/Library/WindowMaker/autostart
HOME_DIR_CONF=$HOME/.config

if ! [ -d $HOME_DIR_CONF ];then
	mkdir -p "${HOME_DIR_CONF}"
fi

cp -u compton.conf $HOME_DIR_CONF/

grep -e "compton" $AUTO &>/dev/null
if [ $? -eq 0 ];then
	printf "\nAlready set in $AUTO\n"
fi
printf "\nCompton has been set.\n"
