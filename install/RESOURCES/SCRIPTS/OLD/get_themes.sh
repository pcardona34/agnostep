#!/bin/bash

####################################################
### P i S i Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

WD=$(pwd)
THEME="PISI"

#########################################
### Get Themes: PISI for WM and GNUstep
#########################################

##########################################
### Get WindowMaker Theme

function getWM()
{
cd $HOME/GNUstep/Library/WindowMaker
tar -cvf WM${THEME}.tar Themes/${THEME}.themed 
gzip --force WM${THEME}.tar
mv --force WM${THEME}.tar.gz ${WD}/RESOURCES/THEMES/
cd $WD
}

##########################################
### Get GNUstep Theme

function getGS()
{
cd $HOME/GNUstep/Library/Themes
tar -cvf GS${THEME}.tar ${THEME}.theme 
gzip --force GS${THEME}.tar
mv --force GS${THEME}.tar.gz ${WD}/RESOURCES/THEMES/
cd $WD
}

##########################################
#getWM
getGS
