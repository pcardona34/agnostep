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
### Functions for Misc Folders
################################

###############################################
function icon_folder()
{
FOLDER="$1"
if ! [ -d $HOME/${FOLDER} ];then
	mkdir -p $HOME/${FOLDER}
fi
cd RESOURCES/ICONS && cp -u dir_${FOLDER}.tiff $HOME/${FOLDER}/.dir.tiff
cd $_PWD
}
