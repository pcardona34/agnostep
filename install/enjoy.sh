#!/bin/bash

####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

### Banniere
clear
cat RESOURCES/logo.txt
printf "\n\t\t\tW e l c o m e   t o   a n    A G N o S t e p    W o r l d!\n\n\t\t\tE N J O Y   installer   script   will   start   soon..."
sleep 4


####################################################
### VARS
LOGENJ="$HOME/ENJOY.log"
IS_OK=0
### LITE=0 means full install - LITE=1 means lite install: only basic apps
LITE=0
#LITE=1
_PWD=`pwd`
THERE=${_PWD}
####################################################
### Functions

. SCRIPTS/colors.sh
. SCRIPTS/functions_prep.sh

####################################################

### Abort script if EXIT is not 0
set -e

####################################################
### Builds and launches A G N o S t e p
####################################################

clear

if [ -f $HOME/.xinitrc ];then
	warning "A script to start the X session (.xinitrc) was found in your home directory."
	info "To launch the desktop, better use:"
	cli "cd && startx"
	printf "\nDo you want to force AGNoStep (re-)install?\n"
	read -p "(y/n): " -s REPONSE
	case $REPONSE in
		"y"|"Y") printf "\nStarting AGNoStep All-in-One install script...\n" && sleep 2;;
		"n"|"N"|*) printf "\nAborting...\n" && exit 1
	esac
fi

####################################################
### Timer (1)
BEG=`date`
echo "AGNOSTEP: Begining of script $0 at: $BEG" > $LOGENJ

####################################################
### Install steps
####################################################

./1_prep.sh || exit 1

cd ${THERE}
./2_install_wmaker.sh || exit 1

cd ${THERE}
./3_install_gnustep.sh || exit 1

cd ${THERE}
./4_install_frameworks.sh || exit 1

cd ${THERE}
./5_install_AGNOSTEP.sh apps || exit 1

if [ ${LITE} -eq 0 ];then
	cd ${THERE}
	./5_install_AGNOSTEP.sh extra
	cd ${THERE}
	./5_install_AGNOSTEP.sh devel
	cd ${THERE}
	./5_install_AGNOSTEP.sh games
fi
cd ${THERE}
./6_user_settings.sh

##################################################
### Timer (2)
END=`date`
echo "AGNOSTEP: End of script $0 at: $END" >> $LOGENJ

cd

### Cleaner
if [ -d $HOME/Documents ];then
	mv --force *.log $HOME/Documents/
fi

startx || exit 1

exit
