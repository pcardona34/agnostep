#!/bin/bash

####################################################
### P i S i N    Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

################################
### Install all GNUstep libs and Tools
################################


####################################
### Install GNUstep MAKE TOOLS
function install_gnustep_make
{

TTTLE="1 - GNUstep Make Tools"
echo ${TITLE} >>$LOG

cd ../build || exit 1

printf "Fetching...\n"
if [ -d tools-make ];then
	cd tools-make
	git pull &>/dev/null
else
	git clone --branch=master "https://github.com/gnustep/tools-make" &>/dev/null
	cd tools-make
fi

printf "Configuring...\n"

### Cleaning
sudo chown -fR $USER:$USER . &>/dev/null
make clean &>/dev/null

if [ "$RUNTIME_VERSION" == "" ];then
	export RUNTIME_VERSION="gnustep-2.1"
fi
./configure --enable-debug-by-default --with-layout=gnustep --enable-objc-arc --with-library-combo=ng-gnu-gnu &>>$LOG &
PID=$!
spinner

printf "\rBuilding and installing...\n"
make ${MKARGS} &>>$LOG &
PID=$!
spinner

sudo -E make install &>>$LOG &
PID=$!
spinner

sudo ldconfig

cd $_PWD

### Post-install
grep -e "GNUstep.sh" $HOME/.bashrc &>/dev/null
if [ $? -ne 0 ];then
	echo ". /usr/GNUstep/System/Library/Makefiles/GNUstep.sh" >> $HOME/.bashrc
fi

grep -e "RUNTIME_VERSION" $HOME/.bashrc &>/dev/null
if [ $? -ne 0 ];then
	echo "export RUNTIME_VERSION=${RUNTIME_VERSION}" >> $HOME/.bashrc
fi

ok "\rDone"

}

################################################
### Install GNUstep BASE

function install_gnustep_base
{

GS_SOURCE="/usr/GNUstep/System/Library/Makefiles/GNUstep.sh"
if [ -f $GS_SOURCE ];then
	. $GS_SOURCE
else
	exit 1
fi

cd ../build || exit 1

title "2 - GNUstep BASE"

printf "Fetching...\n"
if [ -d libs-base ];then
	cd libs-base
	git pull &>/dev/null
else
	git clone --branch=master "https://github.com/gnustep/libs-base" &>/dev/null
	cd libs-base
fi

printf "Configuring...\n"

### Cleaning
sudo chown -fR $USER:$USER . &>/dev/null
make clean &>/dev/null

./configure &>>$LOG &
PID=$!
spinner

printf "\rBuilding and installing...\n"
make -j8 &>>$LOG &
PID=$!
spinner

sudo -E make install &>>$LOG &
PID=$!
spinner

sudo ldconfig

printf "\r\rTesting...\n"
echo "Testing: BEGINS: gnustep-base" >>$LOG
make check &>>$LOG &
PID=$!
spinner
echo "Testing: ENDS: gnustep-base" >>$LOG

cd $_PWD

ok "\rDone"

}

########################################
### Install GNUstep COREBASE

function install_gnustep_corebase
{

GS_SOURCE="/usr/GNUstep/System/Library/Makefiles/GNUstep.sh"
if [ -f $GS_SOURCE ];then
	. $GS_SOURCE
else
	exit 1
fi

cd ../build || exit 1

title "3 - GNUstep COREBASE"

printf "Fetching...\n"
if [ -d libs-corebase ];then
	cd libs-corebase
	git pull &>/dev/null
else
	git clone --branch=master "https://github.com/gnustep/libs-corebase" &>/dev/null
	cd libs-corebase
fi

printf "Configuring...\n"
### Cleaning
sudo chown -fR $USER:$USER . &>/dev/null
make clean &>/dev/null

./configure &>>$LOG &
PID=$!
spinner

printf "\rBuilding and installing...\n"
make -j8 &>>$LOG &
PID=$!
spinner

sudo -E make install &>>$LOG &
PID=$!
spinner

sudo ldconfig

cd $_PWD

ok "\rDone"

}

###########################################
### Install GNUstep GUI

function install_gnustep_gui
{

GS_SOURCE="/usr/GNUstep/System/Library/Makefiles/GNUstep.sh"
if [ -f $GS_SOURCE ];then
	. $GS_SOURCE
else
	exit 1
fi


cd ../build || exit 1

title "4 - GNUstep GUI"

printf "Fetching...\n"
if [ -d libs-gui ];then
	cd libs-gui
	git pull origin master &>/dev/null
else
	git clone --branch=master "https://github.com/gnustep/libs-gui" &>/dev/null
	cd libs-gui
fi

printf "Configuring...\n"

### Cleaning
sudo chown -fR $USER:$USER . &>/dev/null
make clean &>/dev/null

./configure --disable-icu-config &>>$LOG &
PID=$!
spinner

printf "\rBuilding and installing...\n"
make -j8 &>>$LOG &
PID=$!
spinner

sudo -E make install &>>$LOG &
PID=$!
spinner

sudo ldconfig

cd $_PWD

ok "\rDone"

}

#######################################
### Install GNUstep BACK

function install_gnustep_back
{

GS_SOURCE="/usr/GNUstep/System/Library/Makefiles/GNUstep.sh"
if [ -f $GS_SOURCE ];then
	. $GS_SOURCE
else
	exit 1
fi

cd ../build || exit 1

title "5 - GNUstep BACK"

printf "Fetching...\n"
if [ -d libs-back ];then
	cd libs-back
	git pull origin master &>/dev/null
else
	git clone --branch=master "https://github.com/gnustep/libs-back" &>/dev/null
	cd libs-gui
fi

printf "Configuring...\n"

### Cleaning
sudo chown -fR $USER:$USER . &>/dev/null
make clean &>/dev/null

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

sudo ldconfig

cd $_PWD

ok "\rDone"

}

######################################
### is_gnustep_ok

function is_gnustep_ok
{

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

cd $PISIN

if [ ${_COUNT} -ne 0 ];then
	alert "GNUstep installation has generated ${_COUNT} errors: check the logs in your home directory."
	exit 1
else
	info "GNUstep installation was successful. You can go forward."
fi
}

### Enf of functions
########################################
