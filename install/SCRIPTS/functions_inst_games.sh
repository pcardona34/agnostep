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
### Functions for inst_games...
####################################################


######################################
## Chess
### Repo/release: github/gnustep/gap
######################################

function install_chess()
{

APPNAME="Chess"
REL="2.7"

echo "$APPNAME $REL" >>$LOG
title "$APPNAME $REL"

printf "Fetching...\n"

cd ../build || exit 1

if [ -d $APPNAME ];then
	cd $APPNAME
	svn update &>/dev/null
else
	svn co svn://svn.savannah.nongnu.org/gap/trunk/ported-apps/Games/Chess &>/dev/null
	cd $APPNAME
fi

_build
}


##################################################
## Gomoku
### Repo/Release: github/pcardona34/Gomoku: 1.2.9
##################################################

function install_gomoku(){

APPNAME="Gomoku"
REL="1.2.9"

echo "$APPNAME $REL" >>$LOG
title "$APPNAME $REL"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d Gomoku ];then
	cd Gomoku
	git pull origin master &>/dev/null
else
	git clone https://github.com/pcardona34/Gomoku.git &>/dev/null
	cd Gomoku
fi

_build
}


##################################
## LapisPuzzle
### Repo/Release:

function install_lapis()
{
APPNAME="LapisPuzzle"
REL="1.2"

echo "$APPNAME $REL" >>$LOG
title "$APPNAME $REL"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d LapisPuzzle-1.2 ];then
	cd LapisPuzzle-1.2
else
	wget --quiet http://mirror.easyname.at/nongnu/gap/LapisPuzzle-1.2.tar.gz
	gunzip --force LapisPuzzle-1.2.tar.gz
	tar -xf LapisPuzzle-1.2.tar
	cd LapisPuzzle-1.2
fi

_build
}

##################################################
## Freecell
### Repo/Release: github/alexmyczko/Freecell.app: 0.1
##################################################

function install_freecell()
{

APPNAME="Freecell"
REL="0.1"

echo "$APPNAME $REL" >>$LOG
title "$APPNAME $REL"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d Freecell.app ];then
	cd Freecell.app
	git pull origin master &>/dev/null
else
	git clone https://github.com/alexmyczko/Freecell.app.git &>/dev/null
	cd Freecell.app
fi

_build
}

######################################
## GShisen
### Repo/Release: savannah/gap: 1.3.0
######################################

function install_gshisen(){

APPNAME="GShisen"
REL="1.3.0"

echo "$APPNAME $REL" >>$LOG
title "$APPNAME $REL"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d GShisen ];then
	cd GShisen
	svn update
else
	svn co svn://svn.savannah.nongnu.org/gap/trunk/user-apps/Games/GShisen &>/dev/null
#	wget --quiet http://mirror.netcologne.de/savannah/gap/GShisen-1.3.0.tar.gz
#	gunzip --force GShisen-1.3.0.tar.gz
#	tar -xf GShisen-1.3.0.tar
	cd GShisen
fi

_build
}
