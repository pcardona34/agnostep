#!/bin/bash

# PiSi Desktop
### Try to install new Applications
### or whose which previously failed to build...
### or seemed buggy...

_PWD=`pwd`
. ./environ.sh
. /usr/local/share/GNUstep/Makefiles/GNUstep.sh

APPLICATIONS=/usr/local/lib/GNUstep/Applications
TESTING=${APPLICATIONS}/Testing

for DIR in ${TESTING}
do
	if ! [ -d $DIR ];then
		sudo mkdir -p $DIR
	fi
done

if ! [ -d "../build" ];then
	mkdir ../build
fi

##################################
## TEMPLATES			##
##################################

##########################
## Template: for git...
##########################

function install_foo()
{

cd ../build || exit 1

APP=foo
REPO=gap
OWNER=gnustep
HUB=https://github.com
BRANCH=master
BUILD_DIR=user-apps # system-apps | ported-apps

if [ -d $REPO ];then
        cd $REPO
        git pull origin $BRANCH
else
	git clone ${HUB}/${OWNER}/${REPO}.git
	cd $REPO
fi

cd $BUILD_DIR/$APP
if [ -f configure ];then
	./configure
fi

make
sudo cp --recursive ${APP}.app ${TESTING}/

cd $_PWD
}

################################
## Template for: get method
################################

function install_bar()
{
cd ../build || exit 1

APP=bar
VERSION="1.0.0"
EXT=".tar.gz"
HUB=http://savannah.nongnu.org/download/gap

if [ -d ${APP}-${VERSION} ];then
	cd ${APP}-${VERSION}
else
	wget ${HUB}/${APP}-${VERSION}${EXT}
	gunzip ${HUB}/${APP}-${VERSION}${EXT}
	tar -xvf ${APP}-${VERSION}.tar
	cd ${APP}-${VERSION}
fi

if [ -f configure];then
	./configure
fi

make
sudo cp --recursive ${APP}.app ${TESTING}/

cd $_PWD
}

##################################
## END OF TEMPLATES		##
##################################

####################################
## BELOW BEGINS THE TESTING SPACE ##
####################################

function install_grr_gap() {

cd ../build || exit 1

if [ -d gap ];then
	cd gap
	git pull origin master
else
	git clone https://github.com/gnustep/gap.git
	cd gap
fi

cd user-apps/Grr
make
sudo make install

cd $_PWD
}

#################################
## GNUMail (latest)
### Repo/Release: subversion
#################################

function install_gnumail_latest()
{

cd ../build || exit 1

if [ -d gnustep-nonfsf ];then
        cd gnustep-nonfsf
        svn update
else
        svn co svn://svn.savannah.gnu.org/gnustep-nonfsf
        cd gnustep-nonfsf
fi

cd apps/gnumail
make
sudo make install

cd $_PWD
}

######################################################
## GS-WebBrowser
### Repo/Release: github/onflapp/gs-webbrowser: 0.1
######################################################

function install_gs-webbrowser()
{

cd ../build || exit 1

if [ -d gs-webbrowser ];then
        cd gs-webbrowser
        git pull origin main
else
        git clone https://github.com/onflapp/gs-webbrowser.git
        cd gs-webbrowser
fi

make clean
make
sudo make install

cd $_PWD
}

##########################
## Weather.app
##########################

function install_weather()
{

cd ../build || exit 1

APP=Weather
REPO=Weather.app
OWNER=paulodelgado
HUB=https://github.com
BRANCH=master
BUILD_DIR="" # system-apps | ported-apps

if [ -d $REPO ];then
        cd $REPO
        git pull origin $BRANCH
else
        git clone ${HUB}/${OWNER}/${REPO}.git
        cd $REPO
fi

# cd $BUILD_DIR/$APP
if [ -f configure ];then
        ./configure
fi

make
sudo make install
#sudo cp --recursive ${APP}.app ${TESTING}/

cd $_PWD
}


################################
## Uncomment below to install
################################

#install_grr_gap
#install_grr_sav
#install_gnumail_latest ### Uninstall GNUMail stable before
install_gs-webbrowser
### GS-Browser: builds, but Chrome do not load...
#install_weather

make_services
sudo ldconfig
