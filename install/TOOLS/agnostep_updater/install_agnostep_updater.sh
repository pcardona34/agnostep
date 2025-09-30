#!/bin/bash

####################################################
### A G N o S t e p  -  Updater - by Patrick Cardona
### pcardona34 @ Github
###
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

################################
### Install the Updater Tool
################################

################################
### VARS

AUTO=$HOME/GNUstep/Library/WindowMaker/autostart

sudo cp -u Updater.sh /usr/local/bin/

###  Copy of dunstrc
DUNSTRC=$HOME/.config/dunst
if ! [ -d $DUNSTRC ];then
	mkdir -p $DUNSTRC
fi
cp _dunstrc $DUNSTRC/dunstrc

grep -e "Updater.sh" $AUTO &>/dev/null
if [ $? -eq 0 ];then
	printf "\nAlready set in $AUTO\n"
else
	echo "sleep 60 && /usr/local/bin/Updater.sh -d &" >>$AUTO
fi

printf "\nAGNOSTEP_Updater has been set.\n"
