#
# Makefile for module for BackSpace.app
#

MODULE=		Qix
INSTALLDIR=	/LocalLibrary/BackSpaceViews

$(MODULE)View.o: $(MODULE)View.m $(MODULE)View.h
	cc -arch m68k -arch i386 -arch hppa -arch sparc -g -O -Wall -c $(MODULE)View.m

install: $(MODULE)View.o
	mkdirs $(INSTALLDIR)
	install -m 644 $(MODULE)View.o $(INSTALLDIR)
