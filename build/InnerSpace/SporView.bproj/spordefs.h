

/* Funktionsdeklarationen */

void	sysInit(void);
void	sysExit(void);
void	drawSpore(int x, int y, int col, int pow );
void	diagLine(int x1, int y1, int y2, int col );
void	tosCls(void);
void	tosText(char *s);
void	tosSetPal(int *newp, int *savp);
long	tosKeyTest(void);
void	tosCurs(int x, int y);
long	sysTimer(void);

