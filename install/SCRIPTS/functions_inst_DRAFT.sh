#!/bin/bash

####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

####################################################
### Functions for DRAFT - GNUstep apps
####################################################

###############################################
### gs-webbrowser
function install_gs-webbrowser()
{
APPNAME=WebBrowser
REL="0.1"

cd ../build || exit 1

title "$APPNAME" | tee -a $LOG

printf "Fetching...\n"
if [ -d gs-webbrowser ];then
	cd gs-webbrowser
	git pull origin main &>/dev/null
else
	git clone https://github.com/onflapp/gs-webbrowser.git &>/dev/null
	cd gs-webbrowser
fi

printf "Building...\n"
make

printf "Installing...\n"
sudo make install

### Cleaning
make clean &>/dev/null

ok "Done"

cd $_PWD

check ${APPNAME}
}
### End of gs-webbrowser
################################################


#################################################
############ GAMES ##############################
#################################################

########################################
## NeXTGo
### Repo/Release: github/gnustep/gap: ?
########################################

function install_nextgo()
{

APPNAME="NeXTGo"
REL="3.0"

echo "$APPNAME $REL" >>$LOG
title "$APPNAME $REL"

cd ../build || exit 1

printf "Fetching...\n"
svn co svn://svn.savannah.nongnu.org/gap/trunk/ported-apps/Games/NeXTGo
cd NeXTGo || exit 1
#make 

### Error with:
### findnext.c:71:8: error: type specifier missing, defaults to 'int'; ISO C99 and later 
### do not support implicit int [-Wimplicit-int]

#sudo -E make install

#_build
}

#############################################
#############################################

function install_Weather()
{
cd $HOME/SOURCES/Draft || exit 1
### Fetching
if ! [ -d Weather.app ]; then
	git clone https://github.com/paulodelgado/Weather.app.git
	cd Weather.app
else
	cd Weather.app
   make clean
	git pull origin master
fi

### Build
printf "Building...\n"
make
sudo -E make install
}

