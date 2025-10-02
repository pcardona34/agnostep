/*

		Dateiname:	SPORDEFS.C
		Dateityp:	Include-Datei fÅr SPOREN6.C
		Zweck:		ATARI ST Funktionslibrary
		Projekt:	SPOREN.PRJ
		Version:	1.10
		Start:		06.07.95
		Update:		06.07.95
		Autor:		Stefan Jeworowski

*/

/* Bibliotheken */

#include "spordefs.h"					/* prototypen ( SP ) */

#ifdef ATARI
	#include	<tos.h>
	#include	<linea.h>
#endif

#ifdef NeXT
	#include	"draw.h"
#endif
#ifdef GNUSTEP
	#include "draw.h"
#endif

/* Defines */

extern int DIAGHT;

#define		ZeroY		0		/* Nullpunkt der Y Achse */
#define		OrigX		20		/* linker Rand bei 20 */


/* Konstanten */

const	int	linepatt	= -1;	/* linienmuster fÅr horizontal_line() */


/* Variablen */

long	oldSSP, *HZ_200;


/* Funktionsdefinitionen */

void sysInit(void)
{
#ifdef ATARI
	oldSSP = Super(0L);				/* Supervisormodus fÅr sysTimer() */
	HZ_200 = (long *) 0x4BA;		/* Systemtimer fÅr sysTimer() */
	linea_init();
	hide_mouse();
	set_wrt_mode(REPLACE);
	set_pattern(&linepatt, 0, 1);	/* Linienmuster fÅr vdiDSpore() */
#endif

	return;
}


void sysExit(void)
{
#ifdef ATARI
	Super((void *) oldSSP);			/* ZurÅck in Usermodus */
#endif

	return;
}


void drawSpore(int x, int y, int color, int pow )
{
#ifdef ATARI
	horizontal_line( x, abs( ZeroY - y ), x+2 );
#endif
#ifdef NeXT
	cSetColor( color, pow );
	cSetSpor( x, abs(ZeroY - y ) );
#endif	
#ifdef GNUSTEP
        cSetColor( color, pow );
        cSetSpor( x, abs(ZeroY - y ) );
#endif
	return;
}


void diagLine(int x1, int y1, int y2, int col )
{
#ifdef ATARI
	draw_line( x1, abs(ZeroY-y1), x2, abs(ZeroY-y1) );
#endif
#ifdef NeXT
	cSetColor( col, 100 ); 
	cSetLine( x1, y1, x1, y2 );
#endif
#ifdef GNUSTEP
        cSetColor( col, 100 );
        cSetLine( x1, y1, x1, y2 );
#endif
	return;
}


void tosCls(void)
{
#ifdef ATARI
	Cconout(27);
	Cconout(69);
#endif

	return;
}


void tosText(char *s)
{
#ifdef ATARI
	Cconws( s );
#endif

	return;
}


void tosSetPal(int *newp, int *savp)
{
#ifdef ATARI
	int a;

	for (a = 0; a < 16; a++)
	{
		savp[ a ] = Setcolor( a, newp[ a ] );
	}
#endif
	
	return;
}


long tosKeyTest(void)
{
#ifdef ATARI
	return Crawio( 0xFF );
#endif
#ifdef NeXT
	return( 0 );
#endif
#ifdef GNUSTEP
	return ( 0 );
#endif
}



void tosCurs(int x, int y)
{
	char esc[5] = { 27, 'Y', 0, 0, 0 };

	esc[2] = (char) y + 31;
	esc[3] = (char) x + 31;
#ifdef ATARI
	Cconws( esc );
#endif

	return;
}


long sysTimer(void)
{
#ifdef ATARI
	return *HZ_200;
#endif
#ifdef NeXT
	return( 0 );
#endif
#ifdef GNUSTEP
	return 0;
#endif
}
