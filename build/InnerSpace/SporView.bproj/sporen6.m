/*

		Dateiname:	SPOREN6.C
		Dateityp:	Source
		Zweck:		Spielkram
		Projekt:	SPOREN.PRJ
		Version:	2.60
		Start:		03.07.95
		Update:		14.07.95
		Autor:		Stefan Jeworowski

*/

/* Bibliotheken */

#include	<stdlib.h>
#include	<time.h>
#include	<string.h>
#include	<stdio.h>

#include	"spordefs.h"
//#include	"drawspor.h"
#include	"sporen6.h"
#include	"draw.h"

#define		NOENTRY			0L

/*
	( SP )
*/
#define REAL_MAX_SPOREN		50000
#define REALMAPMX					500
#define REALMAPMY					500
#define DIAGSY						0

/* Variablen- / Zeigerdeklarationen */

SPORE	sporen[ REAL_MAX_SPOREN ],
			*freelist[ REAL_MAX_SPOREN ],
			*map[ REALMAPMX ][ REALMAPMY ],
			*firstSp, *lastSp;

int		ende, freect, statCount, clrCount;

SPCOORD	loctab[ 8 ] = {	{-1,-1}, { 0,-1}, { 1,-1},
						{-1, 0},          { 1, 0},
						{-1, 1}, { 0, 1}, { 1, 1}	};

int		typCount[ 4 ];
int	MAPMX,		/* ( SP ) */
		MAPMY,
		SCRMX,		/* Anzahl Pix in X */
		MAX_SPOREN,
		DIAGHT,
		start_population,
		start_spread,
		random_kind,
		start_cloud,
		eatOne,
		hh;


/* Die Haupt-Steuer-Funktionen */

#ifdef ATARI
main()
#endif
#ifdef NeXT
	int	start_simulation()
#endif
#ifdef GNUSTEP
	int	start_simulation()
#endif
{
	hsInit();
	hsMain();
	hsExit();
	return (0);
}


/*
	einen Simulationsschritt durchföhren ( SP )
*/
void cDoSimulation( void )
{
	if( do_sim_step() == 0 )
		init_sim();

	return;
}


/*
	ScreenSize setzen ( SP )
*/
void set_screen_size( int mapx, int mapy, int pixelx )
{

	MAPMX = mapx / 4;
	DIAGHT = mapy / 10;		
	MAPMY = ( mapy - DIAGHT ) / 4;
#ifdef DEBUG
	fprintf( stderr, "mapy:%d DIAGHT:%d\n", mapy, DIAGHT );
#endif
	SCRMX	= pixelx;

	return;
}


/*
	Parameter setzen ( SP )
	maxsporen 				-> grðût mðgliche Population
	start_population 	-> Population bei Simulationsstart
	random_kind      	-> 0 = gleich viele Sporen der jeweiligen Farbe setzen
									     1 = Anzahl der Sporen der jeweiligen Frabe wörfeln
	start_spread 			-> abstand der einzelnen 'Startwolken' ( 3er Gruppen )
	start_cloud 			-> Ausdehnung der Startwolken
*/
void set_simulation_parameter( int maxsporen, int start_pop, int spread, int rnd_kind,
 			int cloud, int eat  )
{
	if( maxsporen > REAL_MAX_SPOREN )
		maxsporen = REAL_MAX_SPOREN;

	MAX_SPOREN = maxsporen;

	random_kind = rnd_kind;
	start_population = start_pop / 3;
	start_spread = spread;
	start_cloud = cloud;
	eatOne = eat;

	hh = MAX_SPOREN / DIAGHT +1;

#ifdef DEBUG
	fprintf( stderr, "ms/dh:%d\n", MAX_SPOREN / DIAGHT );
#endif

	return;
}


/*
	einen 'Sim' durchlauf durchföhren ( SP )
*/
int do_sim_step()
{
	sporenLife();
	statistik();

	return( freect );
}


/*
	Anfangssporen setzen ( SP )
*/
void init_sim()
{
	int	x,
			y,
			i;

	hsInit();

	Cls();
	sporenInit();
	varInit();

	for(i = 0 ; i < start_population; i++)
	{
		x = MAPMX / 2 + zufall( start_spread ) - start_spread / 2;
		y = MAPMY / 2 + zufall( start_spread ) - start_spread / 2;

		if( random_kind == 1 )
		{
			setSpore( x-zufall( start_cloud ), y-zufall( start_cloud ), zufall( 8 ), 
					zufall( 3 ) + 1, 100 );
			setSpore( x+zufall( start_cloud ), y+zufall( start_cloud ), zufall( 8 ), 
					zufall( 3 ) + 1, 100 );
			setSpore( x+zufall( start_cloud ), y-zufall( start_cloud ), zufall( 8 ), 
					zufall( 3 ) + 1, 100 );
		}
		else
		{
			setSpore( x-zufall( start_cloud ), y-zufall( start_cloud ), zufall(8), 1, 100 );
			setSpore( x+zufall( start_cloud ), y+zufall( start_cloud ), zufall(8), 2, 100 );
			setSpore( x+zufall( start_cloud ), y-zufall( start_cloud ), zufall(8), 3, 100 );
		}
	}

	return;
}


void hsInit(void)
{
	srand((unsigned) time(0L) % 37);
	sysInit();
}

void hsMain(void)
{
	int x, y;

	do
	{
		Cls();
		sporenInit();
		varInit();
		x = MAPMX / 2;
		y = MAPMY / 2;
		setSpore( x-zufall(5), y-zufall(5), zufall(8), 1, 100 );
		setSpore( x+zufall(5), y+zufall(5), zufall(8), 2, 100 );
		setSpore( x+zufall(5), y-zufall(5), zufall(8), 3, 100 );
		do
		{
			sporenLife();
			statistik();
			keyTest();
		}
		while ( ende == 0 && freect != 0 );
	}
	while ( !ende );
}

void hsExit(void)
{
	sysExit();
}

void hsError(int e)
{
	hsExit();
	exit(e);
}


/* Die Hilfsfunktionen */

void Cls(void)
{
	int x, y;

	tosCls();
	NextCls( MAPMX * 4, DIAGHT );

	for ( x = 0; x < MAPMX; x++ )
	{
		for ( y = 0; y < MAPMY; y++ )
		{
			map[ x ][ y ] = (SPORE *) NOENTRY;
		}
	}
}

int zufall(int wid)
{
	return rand() % wid;
}

void keyTest(void)
{
/*
	long k;

	k = tosKeyTest();						/* Abfragen, ohne warten */
/*
	if ( (int) k == 27 )	ende = 1;		/* ESC = Abbruch */
}


/*	Die Programmfunktionen */

void varInit(void)
{
	ende = 0;
	freect = 0;
	firstSp = NOENTRY;
	lastSp = NOENTRY;
	typCount[ 1 ] = 0;
	typCount[ 2 ] = 0;
	typCount[ 3 ] = 0;
	statCount = 0;
	clrCount = SCRMX / 16;
}

void sporenInit(void)
{
	int a;

	for (a = 0; a < MAX_SPOREN; a++)
	{
		sporen[ a ].mapx = 0;
		sporen[ a ].mapy = 0;
		sporen[ a ].rot = 0;
		sporen[ a ].typ = 0;
		sporen[ a ].pow = 0;
		sporen[ a ].pPrv = (SPORE *) NOENTRY;
		sporen[ a ].pNxt = (SPORE *) NOENTRY;
		freelist[ a ] = &( sporen[ a ] );
	}
	freect = 0;
}

void killSpore(SPORE *spore)
{
	SPORE *prev, *next;

	prev = spore->pPrv;
	next = spore->pNxt;
	if ( prev != NOENTRY ) prev->pNxt = next;
	if ( next != NOENTRY ) next->pPrv = prev;
	freelist[ --freect ] = spore;
	if ( spore == lastSp ) lastSp = next;
	if ( spore == firstSp ) firstSp = prev;

	map[ spore->mapx ][ spore->mapy ] = NOENTRY;
	drawSpore( spore->mapx, spore->mapy + ( DIAGHT / 4 ), 0, 0 );
	typCount[ ( int )spore->typ ]--;
}

SPORE *newSpore(void)
{
	SPORE *spore;

	if ( freect < MAX_SPOREN )
	{
		spore = freelist[ freect++ ];
	}
	else
	{
		return ( NOENTRY );
	}
	spore->pPrv = firstSp;
	spore->pNxt = NOENTRY;
	if ( firstSp != NOENTRY )
	{
		firstSp->pNxt = spore;
	}
	else
	{
		lastSp = spore;
	}
	firstSp = spore;

	return ( spore );
}

void setSpore(int x, int y, int r, int t, int p)
{
	SPORE *spore;

	spore = newSpore();
	if (spore != NOENTRY)
	{
		spore->mapx = x;
		spore->mapy = y;
		spore->rot = r;
		spore->typ = t;
		spore->pow = p;
		typCount[ t ]++;
		map[ x ][ y ] = spore;
		drawSpore( x, y + ( DIAGHT / 4 ), spore->typ, spore->pow );
	}
}

void sporenLife(void)
{
	register int x, y, r, t, p;
	SPORE *aspore, *bspore;
	int		flag = 0;

	aspore = firstSp;
	if ( aspore != NOENTRY )
	{
		do
		{
			if ( aspore->pow == 0 )
			{
				killSpore( aspore );
			}
			else
			{
				r = aspore->rot;
				r++;
				if ( r == 8 ) r = 0;
				aspore->rot = r;
				x = aspore->mapx + loctab[ r ].x;
				y = aspore->mapy + loctab[ r ].y;
				if ( x < 0 ) x = MAPMX - 1;
				else
				{
					if ( x >= MAPMX ) x = 0;
				}
				if ( y < 0 ) y = MAPMY - 1;
				else
				{
					if ( y >= MAPMY ) y = 0;
				}
				bspore = map[ x ][ y ];
				t = aspore->typ;
				if ( bspore != NOENTRY )
				{
					if( !eatOne )
					{
						if ( bspore->typ != t )
						{
							flag = 1;
						}
						else
						{
							flag = 0;
							aspore->pow--;
						}
					}
					else
					{
						t = aspore -> typ - 1;
						if ( t == 0 )
							t = 3;
						if ( bspore -> typ == t )
							flag = 1;
						else
						{
							aspore->pow--;							
							flag = 0;
						}
					}
					if( flag )
					{
						p = aspore->pow + 30;
						bspore->pow = 0;
						if ( p > 100 ) p = 100;
						aspore->pow = p;
					}
				}
				else
				{
					p = (int) aspore->pow - 10;
					if ( p > 0 )
					{
						setSpore( x, y, r, t, p );
						aspore->pow = p;
					}
					aspore->pow--;
				}
			}
			aspore = aspore->pPrv;
		}
		while ( aspore != NOENTRY );
	}
}

void statistik(void)
{
	int x, y1, y2, y3, y12;

	x = statCount;
	y1 = typCount[ 1 ] / hh;
	y2 = typCount[ 2 ] / hh;
	y3 = typCount[ 3 ] / hh;

	y12 = y1 + y2;
	diagLine( x, DIAGSY, y1, 1 );
	diagLine( x, DIAGSY + y1, y12, 2 );
	diagLine( x, DIAGSY + y12, y12 + y3, 3 );

	statCount++;
	if ( statCount == SCRMX )
 		statCount = 0;
	diagLine( clrCount, DIAGSY, DIAGHT/* + 9*/, 0 );
	clrCount++;
	if ( clrCount == SCRMX ) 
		clrCount = 0;
}
