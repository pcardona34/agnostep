//
// RegularPolyhedraView  -  a flexible, bouncing polyhedron.
//
// Module for BackSpace.app
// 22 Nov 91 - 8 Dec 91.
// Simon Marchant, and Paul Brown (simon@math.berkeley.edu,
//		pbrown@math.berkeley.edu).
//


#include <AppKit/NSView.h>
// #include "Thinker.h"
#include "BackView.h"

//#define SPRING_K		0.2
#define SPRING_K		0.15
#define SPRING_REST_LEN		150

// #define DAMPING		0.1
#define DAMPING			0.05

#define DEPTH			2
//#define MASS			10
#define MASS			15

#define TETRAHEDRON		0
#define CUBE			1
#define OCTAHEDRON		2
#define DODECAHEDRON		3
#define ICOSAHEDRON		4

#define NUM_POLYHEDRA		(ICOSAHEDRON + 1)

#define MAX_NUM_VERTICES	20
#define	MAX_NUM_ADJACENTS	5
#define MAX_NUM_FACES		20
#define MAX_VERTICES_PER_FACE	5

#define INIT_VELOCITY		10
#define MAX_VEL			100

typedef struct
{
  float	x,y,z;
} D3_PT;

typedef struct
{
  float	mass;
  D3_PT	vel;
  D3_PT	pos;
  NSPoint screenPos;
} VERTEX;

extern float randBetween(float lower, float upper);

@interface PolyhedraView:NSView
{
  int		polyhedron;
  int		selectedIndex;
  int		numVertices;
  int		numAdjacents;
  int		numFaces;
  int		numDrawFaces;
  int		verticesPerFace;
  int		realAdjacents;
  
  VERTEX	vertices[MAX_NUM_VERTICES];
  float		restLengths[MAX_NUM_VERTICES][MAX_NUM_VERTICES];
  BOOL		isAdjacent[MAX_NUM_VERTICES][MAX_NUM_VERTICES];
  
  D3_PT		perspectivePt;
  D3_PT		backTopRight;
  
  float		damping;
  
  BOOL		noAnimation;
  int		backStep;
  id            inspectorPanel;
}

- (void) oneStep;
- drawRect:(NSRect)rects;
- initWithFrame:(NSRect)frameRect;
- useNewFrame:(NSRect)frameRect;

- perspectiveLineFrom:(D3_PT)pt1 to:(D3_PT)pt2;
- drawBoxInColour:(float)theGray;
- drawPolyhedron;
- erasePolyhedron;
- frameChanged:(NSRect)frameRect;

- setSelectedIndex:sender;
- kickIt:sender;
- inspector:sender;

@end
