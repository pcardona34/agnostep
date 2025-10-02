/*

		Dateiname:	SPOREN6.H
		Dateityp:	Headerdatei
		Zweck:		Spielkram
		Projekt:	SPOREN.PRJ
		Version:	2.30
		Start:		03.07.95
		Update:		14.07.95
		Autor:		Stefan Jeworowski

*/

/* Typendefinitionen */


typedef struct
{
	int		x,
			y;
} SPCOORD;

typedef struct
{
	int		mapx,
			mapy;
	char	rot,
			typ,
			pow;
	void	*pPrv,
			*pNxt;
} SPORE;


/* Funktionsdeklarationen */

void	hsInit(void);
void	hsMain(void);
void	hsExit(void);
void	hsError(int e);

void	init_sim( void );
int		do_sim_step( void );
void	set_screen_size( int mapx, int mapy, int pixelx );
void set_simulation_parameter( int maxsporen, int start_pop, int spread, int rnd_kind,
 			int cloud, int eat  );
void  cDoSimulation( void );

void	Cls(void);
int		zufall(int wid);
void	keyTest(void);
void	varInit(void);

void	sporenInit(void);
void	sporenLife(void);
SPORE	*newSpore(void);
void	setSpore(int x, int y, int r, int t, int p);
void	killSpore(SPORE *spore);
void	statistik(void);
