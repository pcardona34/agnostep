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
### Functions for Install Themes
################################

###############################################
function install_wm_theme
{
title "AGNOSTEP Theme for WindowMaker"
printf "Installing the theme...\n"
cd RESOURCES/THEMES || exit 1
if [ ! -d $HOME/GNUstep/Library/WindowMaker/Themes ];then
	mkdir -p $HOME/GNUstep/Library/WindowMaker/Themes
fi
cp WMAGNOSTEP.tar.gz $HOME/GNUstep/Library/WindowMaker/Themes/
cd $HOME/GNUstep/Library/WindowMaker/Themes || exit 1
gunzip --force WMAGNOSTEP.tar.gz && tar -xf WMAGNOSTEP.tar
rm WMAGNOSTEP.tar
cd $_PWD
ok "Done"
}

###############################################
function install_gs_theme
{
title "AGNOSTEP Theme for GNUstep"
printf "Installing the theme...\n"
if ! [ -d $HOME/GNUstep/Library/Themes ];then
	mkdir -p $HOME/GNUstep/Library/Themes
fi
cd RESOURCES/THEMES
cp GSAGNOSTEP.tar.gz $HOME/GNUstep/Library/Themes/
cd $HOME/GNUstep/Library/Themes || exit 1
gunzip --force GSAGNOSTEP.tar.gz
tar -xf GSAGNOSTEP.tar
rm GSAGNOSTEP.tar
cd $_PWD
ok "Done"
}
