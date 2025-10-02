INSTALLDIR=	$(HOME)/Library/BackSpaceViews

DYNAMODULES=	Space2View.BackO

THINGSTOREMOVE= Space2View.o

.SUFFIXES: .m .o .c .psw
.c.o:
	cc -arch m68k -arch i386 -arch hppa -arch sparc -O -g -Wall -c $*.c -o $*.o
.m.o:
	cc -arch m68k -arch i386 -arch hppa -arch sparc -O -g -Wall -c $*.m -o $*.o
.psw.h:
	pswrap -a -h $*.h -o $*.c $*.psw
.psw.o:
	pswrap -a -h $*.h -o $*.c $*.psw
	cc -arch m68k -arch i386 -arch hppa -arch sparc -O -g -Wall -c $*.c -o $*.o

all::
	$(MAKE) $(DYNAMODULES)
	
Space2View.BackO: Space2View.o Space2View.h
	ld -arch i386 -x -r -o Space2View.BackO Space2View.o

clean::
	rm -rf $(DYNAMODULES) $(THINGSTOREMOVE)
	

install::	all install-views

install-views::
	mkdirs $(INSTALLDIR)/Space2View.BackModule
	cp Space2View.BackO $(INSTALLDIR)/Space2View.BackModule
	