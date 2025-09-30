#!/bin/sh

_PWD=`pwd`
TARGET="${HOME}/Pictures/Screenshots"
DELAY=0

# Options
if [ -n "$1" ];then
	case "$1" in
		"-h" | "--help")
			clear
			printf "\n\nUse: \
			\n${0}\t\tTakes immediately a screenshot \
			\n${0} -d\tTakes a delayed screenshot. Default: 5 sec. \
			\n${0} -h\tPrint this help.\n\n"
			exit 0;;
		"-d")
			DELAY=5;;
		*)
			${0} -h;;
	esac
fi

# Screenshots folder
if ! [ -d ${TARGET} ];then
	mkdir -p ${TARGET}
fi

SCREENSHOT=`date -u | sed s/\ /-/g | sed s/é/e/g | sed s/-UTC// | tr -d '.:'`

sleep ${DELAY}
xwd -root -display :0 | convert xwd:- ${SCREENSHOT}.jpg

if [ -f ${SCREENSHOT}.jpg ];then
	mv ${_PWD}/${SCREENSHOT}.jpg ${TARGET}/
	printf "\nThe screenshot is there: ${TARGET}/${SCREENSHOT}.jpg\n\n"
else
	printf "\nError: no screenshot could be shot.\n"
fi
