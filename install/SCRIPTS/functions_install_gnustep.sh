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
### Installation of GNUstep: Functions
### with GNU Runtime
####################################################

#################################################
### Thanks to the Riccardo Mottola
### to recommend GNU Runtime
#################################################

function install_make
{
TITLE="Building GNUstep-make..."
echo "$TITLE" >>$LOG
title "$TITLE"

cd make || exit 1

sudo make distclean &>/dev/null

printf "Configuring...\n"
./configure \
    --with-layout=gnustep \
    --prefix=/ &>>$LOG &
PID=$!
spinner
printf "\rBuilding...\n"
make -j8 &>>$LOG &
PID=$!
spinner
printf "\rInstalling\n"
sudo -E make install &>>$LOG &
PID=$!
spinner
ok "\rDone"
sudo ldconfig
}
################################################

#################################################
# Checkout sources
function fetch_sources
{
TITLE="Checking out Sources..."
echo "$TITLE" >>$LOG
title "$TITLE"

HUB=https://github.com/
GSMAKE=make
BASE=base
GUI=gui
BACK=back

printf "\nGNUstep Tools Make\n"
git clone $HUB/gnustep/$GSMAKE &>>$LOG &
PID=$!
spinner
ok "\rDone"
printf "\nGNUstep Base\n"
git clone $HUB/gnustep/$BASE &>>$LOG &
PID=$!
spinner
ok "\rDone"
printf "\nGNUstep Gui\n"
git clone $HUB/gnustep/$GUI &>>$LOG &
PID=$!
spinner
ok "\rDone"
printf "\nGNUstep Back\n"
git clone $HUB/gnustep/$BACK &>>$LOG &
PID=$!
spinner
ok "\rDone"
}

#################################################
## Build GNUstep base
function install_base
{
TITLE="Building Fundation: GNUstep Base..."
echo "$TITLE" >>$LOG
title "$TITLE"

cd base || exit 1

printf "Configuring...\n"
./configure &>>$LOG &
PID=$!
spinner
printf "\rBuilding...\n"
make -j8 &>>$LOG &
PID=$!
spinner
printf "\rInstalling...\n"
sudo -E make install &>>$LOG &
PID=$!
spinner
ok "\rDone"

sudo ldconfig
}
#################################################

#################################################
## Build GNUstep GUI
function install_gui
{
TITLE="Building AppKit: GNUstep Gui"
echo "$TITLE" >>$LOG
title "$TITLE"

cd gui || exit 1

printf "Configuring...\n"
./configure &>>$LOG &
PID=$!
spinner
printf "\rBuilding...\n"
make -j8 &>>$LOG &
PID=$!
spinner
printf "\rInstalling...\n"
sudo -E make install &>>$LOG &
PID=$!
spinner
ok "\rDone"

sudo ldconfig
}
#################################################

#################################################
## Build GNUstep back
function install_back
{
TITLE="Building the Backend: GNUstep Back..."
echo "$TITLE" >>$LOG
title "$TITLE"

cd back || exit 1
printf "Configuring...\n"
./configure &>>$LOG &
PID=$!
spinner
printf "\rBuilding...\n"
make &>>$LOG &
PID=$!
spinner
printf "\rInstalling...\n"
sudo -E make install &>>$LOG &
PID=$!
spinner
ok "\rDone"

sudo ldconfig
}
###############################################

######################################
### is_gnustep_ok

function is_gnustep_ok
{
TITLE="Checking GNUstep installation..."
title "$TITLE"

local _COUNT=0

cd $HOME
for _LOG in *.log
do
	grep -e " Error " $_LOG &>/dev/null
	if [ $? -eq 0 ];then
		_COUNT=$(( $_COUNT + 1 ))
	fi
	grep -e " error: " $_LOG &>/dev/null
	if [ $? -eq 0 ];then
		_COUNT=$(( $_COUNT + 1 ))
	fi
done

if [ ${_COUNT} -ne 0 ];then
	alert "GNUstep installation has generated ${_COUNT} errors: check the logs in your home directory."
	exit 1
else
	info "GNUstep installation was successful. You can go forward."
	sleep 5
fi
}
########################################

### Enf of functions
########################################
