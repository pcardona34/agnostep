//
// RegularPolyhedraView  -  a flexible, bouncing polyhedron.
//
// Module for BackSpace.app
// 22 Nov 91 - 8 Dec 91.
// Simon Marchant, and Paul Brown (simon@math.berkeley.edu,
//		pbrown@math.berkeley.edu).
//

/* Ported to Backspace and to GNUstep by Gregory Casamento */

#include "PolyhedraView.h"
#include "PolyhedraViewWraps.h"

#include <Foundation/NSBundle.h>
#include <AppKit/NSNibLoading.h>
#include <AppKit/NSGraphics.h>
#include <AppKit/NSMatrix.h>
#include <AppKit/PSOperators.h>
// #include <libc.h>
// #include <dpsclient/wraps.h>
#include <math.h>
// #include <AppKit/publicWraps.h>

#include <stdlib.h>

#ifdef WIN32
#define MAXPATHLEN MAX_PATH
#define random(x) rand(x)
#endif


#ifdef WIN32
#define RAND ((float)rand()/(float)RAND_MAX)

float randBetween(float lower, float upper)
{
  float result = 0.0;
  
  if (lower > upper) 
    {
      float temp = 0.0;
      temp = lower; lower = upper; upper = temp;
    }
  result = ((upper - lower) * RAND + lower);
  printf("upper = %f, lower = %f, result = %f\n",upper,lower,result);
  return result;
}
#endif

// Number of vertices of the polyhedron
static int theNumVertices[NUM_POLYHEDRA] =
	{4, 8, 6, 20, 12};

// Number of vertices adjacent to a vertex.
static int theNumAdjacents[NUM_POLYHEDRA] =
	{3, 3, 4, 3, 5};

// Number of faces of the polyhedron.
static int theNumFaces[NUM_POLYHEDRA] =
	{4, 6, 8, 12, 20};

// Number of vertices on each face.
static int theVerticesPerFace[NUM_POLYHEDRA] =
	{3, 4, 3, 5, 3};

// Number of non NO_DRAW faces - i.e. faces that we actually bother drawing.
static int realFaces[NUM_POLYHEDRA] =
	{3, 4, 4, 9, 14};

// Numbers describing the 3D co-ordinates of the polyhedra - the initial positions.
static D3_PT offsets[NUM_POLYHEDRA][MAX_NUM_VERTICES] = {
  {{ 0,         0,         1.73205},	// Tetrahedron
   { 0,         1.63299,  -0.57735},
   {-1.41421,  -0.816497, -0.57735},
   { 1.41421,  -0.816497, -0.57735},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0}},
  {{ 0.707107,  0.707107,  0.707107},	// Cube.
   {-0.707107,  0.707107,  0.707107},
   {-0.707107, -0.707107,  0.707107},
   { 0.707107, -0.707107,  0.707107},
   {-0.707107, -0.707107, -0.707107},
   { 0.707107, -0.707107, -0.707107},
   { 0.707107,  0.707107, -0.707107},
   {-0.707107,  0.707107, -0.707107},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0}},
  {{ 0,         0,         1.41421},	// Octahedron
   { 1.41421,   0,         0},
   { 0,         1.41421,   0},
   { 0,         0,        -1.41421},
   {-1.41421,   0,         0},
   { 0,        -1.41421,   0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0}},
  {{ 0.525731,  0.381966,  0.850651},	//Dodecahedron.
   {-0.200811,  0.618034,  0.850651},
   {-0.649839,  0,         0.850651},
   {-0.200811, -0.618034,  0.850651},
   { 0.525731, -0.381966,  0.850651},
   { 0.850651,  0.618034,  0.200811},
   {-0.32492,   1.0,       0.200811},
   {-1.05146,   0,         0.200811},
   {-0.32492,  -1.0,       0.200811},
   { 0.850651, -0.618034,  0.200811},
   { 0.32492,   1.0,      -0.200811},
   {-0.850651,  0.618034, -0.200811},
   {-0.850651, -0.618034, -0.200811},
   { 0.32492,  -1.0,      -0.200811},
   { 1.05146,   0,        -0.200811},
   { 0.200811,  0.618034, -0.850651},
   {-0.525731,  0.381966, -0.850651},
   {-0.525731, -0.381966, -0.850651},
   { 0.200811, -0.618034, -0.850651},
   { 0.649839,  0,        -0.850651}},
  {{ 0,         0,         1.0},		// Icosahedron.
   { 0.894427,  0,         0.447214},
   { 0.276393,  0.850651,  0.447214},
   {-0.723607,  0.525731,  0.447214},
   {-0.723607, -0.525731,  0.447214},
   { 0.276393, -0.850651,  0.447214},
   { 0.723607,  0.525731, -0.447214},
   {-0.276393,  0.850651, -0.447214},
   {-0.894427,  0,        -0.447214},
   {-0.276393, -0.850651, -0.447214},
   { 0.723607, -0.525731, -0.447214},
   { 0,         0,        -1.0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0},
   { 0,         0,         0}}};

// List of faces in the polyhedron.
static int faces[NUM_POLYHEDRA][MAX_NUM_FACES][MAX_VERTICES_PER_FACE] = {
  {{0, 1, 2, -1, -1},			// Tetrahedron.
   {0, 2, 3, -1, -1},
   {0, 3, 1, -1, -1},
   {1, 3, 2, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1}},
  {{0, 1, 2, 3, -1},			// Cube.
   {0, 3, 5, 6, -1},
   {0, 6, 7, 1, -1},
   {1, 7, 4, 2, -1}, 
   {4, 7, 6, 5, -1},
   {2, 4, 5, 3, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1}},
  {{0, 1, 2, -1, -1},			// Octahedron.
   {0, 2, 4, -1, -1},
   {0, 4, 5, -1, -1},
   {0, 5, 1, -1, -1},
   {1, 5, 3, -1, -1},
   {1, 3, 2, -1, -1},
   {3, 5, 4, -1, -1},
   {2, 3, 4, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1}},
  {{0, 1, 2, 3, 4},			// Dodecahedron.
   {0, 4, 9, 14, 5},
   {0, 5, 10, 6, 1},
   {1, 6, 11, 7, 2},
   {2, 7, 12, 8, 3},
   {3, 4, 9, 13, 8},
   {5, 14, 19, 15, 10},
   {6, 10, 15, 16, 11},
   {7, 11, 16, 17, 12},
   {8, 12, 17, 18, 13},
   {9, 13, 18, 19, 14},
   {15, 19, 18, 17, 16},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1},
   {-1, -1, -1, -1, -1}},
  {{0, 2, 1, -1, -1},			// Icosahedron.
   {0, 3, 2, -1, -1},
   {0, 4, 3, -1, -1},
   {0, 5, 4, -1, -1},
   {0, 1, 5, -1, -1},
   {1, 2, 6, -1, -1},
   {2, 3, 7, -1, -1},
   {3, 4, 8, -1, -1},
   {4, 5, 9, -1, -1},
   {5, 1, 10, -1, -1},
   {6, 2, 7, -1, -1},
   {7, 3, 8, -1, -1},
   {8, 4, 9, -1, -1},
   {9, 5, 10, -1, -1},
   {10, 1, 6, -1, -1},
   {6, 7, 11, -1, -1},
   {7, 8, 11, -1, -1},
   {8, 9, 11, -1, -1},
   {9, 10, 11, -1, -1},
   {10, 6, 11, -1, -1}}};

// Array following contains the vertex adjacency information, so we can 
// determine which n vertices are adjacent to any given one.


typedef struct { float r,g,b; } rgbcolor;

static rgbcolor clut[5] = {
  {1,0,0},
  {0,1,.2},
  {0,0,1},
  {1,.8,0},
  {1,.3,0}
};

// Two "pseudo-colours".
#define TRANSPARENT		-1
#define NO_DRAW			-2

// Colour that you draw the face with.
// TRANSPARENT means just draw the edges.
// NO_DRAW means that the face is transparent, and other faces
// draw all the edges of the face - so no need to draw it.
static int faceColour[NUM_POLYHEDRA][MAX_NUM_FACES] =
  {{0, TRANSPARENT, TRANSPARENT, NO_DRAW,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT},
   {1, NO_DRAW, TRANSPARENT, NO_DRAW,
    2, TRANSPARENT, TRANSPARENT, TRANSPARENT,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT},
   {3, NO_DRAW, 4, NO_DRAW,
    0, NO_DRAW, NO_DRAW, 1,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT},
   {2, NO_DRAW, TRANSPARENT, NO_DRAW,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, 3,
    TRANSPARENT, NO_DRAW, 4, TRANSPARENT,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT,
    TRANSPARENT, TRANSPARENT, TRANSPARENT, TRANSPARENT},
   {0, TRANSPARENT, 1, NO_DRAW, TRANSPARENT,
    NO_DRAW, NO_DRAW, NO_DRAW, 2, 3,
    4, 0, TRANSPARENT, TRANSPARENT, TRANSPARENT,
    TRANSPARENT, NO_DRAW, 1, NO_DRAW, 2}};

@implementation PolyhedraView

// Distance between two points.  Inlined for efficiency.
float distance(float xcrd, float ycrd, float zcrd);

float distance(float xcrd, float ycrd, float zcrd)
{
  return sqrt(xcrd * xcrd + ycrd * ycrd + zcrd * zcrd);
}

// Draw a line in the proper perspectice projection from pt1 to pt2
- perspectiveLineFrom:(D3_PT)pt1 to:(D3_PT)pt2
{
  if (perspectivePt.z == 0)
    return self;
  PSmoveto(pt1.x - pt1.z * (pt1.x - perspectivePt.x) / perspectivePt.z,
	   pt1.y - pt1.z * (pt1.y - perspectivePt.y) / perspectivePt.z);
  PSlineto(pt2.x - pt2.z * (pt2.x - perspectivePt.x) / perspectivePt.z,
	   pt2.y - pt2.z * (pt2.y - perspectivePt.y) / perspectivePt.z);
  return self;
}

// Draw the background room - in the appropriate gray.
- drawBoxInColour:(float)theGray
{
  return self;	//by sam, I don't like the room!
  
#ifdef VANNA
  D3_PT	pt1, pt2;
  PSsetgray (theGray);
  pt1.x = 0;
  pt1.y = 0;
  pt1.z = 0;
  pt2.x = 0;
  pt2.y = 0;
  pt2.z = backTopRight.z;
  [self perspectiveLineFrom:pt1 to:pt2];
  pt1.z = backTopRight.z;
  pt1.y = backTopRight.y;
  [self perspectiveLineFrom:pt2 to:pt1];
  pt2.z = 0;
  pt2.y = backTopRight.y;
  [self perspectiveLineFrom:pt1 to:pt2];
  pt2 = backTopRight;
  [self perspectiveLineFrom:pt1 to:pt2];
  pt1.x = backTopRight.x;
  pt1.z = 0;
  [self perspectiveLineFrom:pt2 to:pt1];
  pt1.y = 0;
  pt1.z = backTopRight.z;
  [self perspectiveLineFrom:pt2 to:pt1];
  pt2.y = 0;
  pt2.z = 0;
  [self perspectiveLineFrom:pt1 to:pt2];
  pt2.z = backTopRight.z;
  pt2.x = 0;
  [self perspectiveLineFrom:pt1 to:pt2];
  PSstroke();
  return self;
#endif
}

// Draw the polyhedron at the current position.
- drawPolyhedron
{
  int		i, j, k, m, n=0;
  float	faceVerticesZ[MAX_NUM_FACES][MAX_VERTICES_PER_FACE];
  float	sortedVerticesZ[MAX_NUM_FACES][MAX_VERTICES_PER_FACE];
  NSPoint	faceVerticesScreen[MAX_NUM_FACES][MAX_VERTICES_PER_FACE];
  BOOL	drawn[MAX_NUM_FACES];
  BOOL	intersect;
  NSPoint	*thisFace, *tempFace, *firstVertex, *secondVertex, *thirdVertex, *fourthVertex;
  int	colours[MAX_NUM_FACES];
  float	r[MAX_NUM_FACES];
  float	g[MAX_NUM_FACES];
  float	b[MAX_NUM_FACES];
  VERTEX	*thisVertex;
  float	firstVertexZ, secondVertexZ, thirdVertexZ, fourthVertexZ;
  float	det, s=0, t=0;
  
  // Pre-compute the positions of each of the vertices as they're drawn on the screen.  We'll need
  // them a little later, and we'll keep them around until we erase this polyhedron from the screen.
  for (i = 0; i < numVertices; i++)
    {
      thisVertex = &(vertices[i]);
      thisVertex->screenPos.x = perspectivePt.x + (thisVertex->pos.x - perspectivePt.x) * 
	perspectivePt.z / (perspectivePt.z + thisVertex->pos.z);
      thisVertex->screenPos.y = perspectivePt.y + (thisVertex->pos.y - perspectivePt.y) * 
	perspectivePt.z / (perspectivePt.z + thisVertex->pos.z);
      // NSLog(@"%f, %f ... %f, %f",thisVertex->pos.x, thisVertex->pos.y, vertices[i].pos.x, vertices[i].pos.y);
    }
  // Pick out the faces we have to draw, and grab an ordered list of the z-coordinates of each
  // vertex in each face, for later on.
  k = 0;
  for (i = 0; i < numFaces; i++)
    if (faceColour[polyhedron][i] != NO_DRAW)
      {
	for (j = 0; j < verticesPerFace; j++)
	  {
	    thisVertex = &(vertices[faces[polyhedron][i][j]]);
	    // NSLog(@"thisVertex->screenPos.x = %f", thisVertex->screenPos.x);
	    faceVerticesScreen[k][j] = thisVertex->screenPos;
	    faceVerticesZ[k][j] = thisVertex->pos.z;
	    for (m = 0; (m < j) && (sortedVerticesZ[k][m] > thisVertex->pos.z); m++)
	      ;
	    for (n = j; n > m; n--)
	      sortedVerticesZ[k][n] = sortedVerticesZ[k][n - 1];
	    sortedVerticesZ[k][m] = thisVertex->pos.z;
	  }
	colours[k] = faceColour[polyhedron][i];
	if (colours[k] != TRANSPARENT)
	  {	
	    r[k] = clut[colours[k]].r;
	    g[k] = clut[colours[k]].g;
	    b[k] = clut[colours[k]].b;
	  }
	drawn[k] = NO;
	k++;
      }
  // Now, run through the list of faces we have to draw, and select the next one to
  // draw - by making sure that it's not in front of any faces we haven't drawn
  // yet.
  for (i = 0; i < numDrawFaces; i++)
    {
      for (k = 0; drawn[k]; k++)
	;
      thisFace = (NSPoint *)&(faceVerticesScreen[k]);
      for (j = k + 1; j < numDrawFaces; j++)
	if (!drawn[j])
	  {
	    tempFace = (NSPoint *)&(faceVerticesScreen[j]);
	    intersect = NO;
	    // check for edges intersecting.
	    for (m = 0; (!intersect) && (m < verticesPerFace); m++)
	      for (n = 0; (!intersect) && (n < verticesPerFace); n++)
		{
		  firstVertex = thisFace + m;
		  secondVertex = (m + 1 == verticesPerFace) ? thisFace : thisFace + m + 1;
		  thirdVertex = tempFace + n;
		  fourthVertex = (n + 1 == verticesPerFace) ? tempFace : tempFace + n + 1;
		  if (((firstVertex->x != thirdVertex->x) || (firstVertex->y != thirdVertex->y)) &&
		      ((firstVertex->x != fourthVertex->x) || (firstVertex->y != fourthVertex->y)) &&
		      ((secondVertex->x != thirdVertex->x) || (secondVertex->y != thirdVertex->y)) &&
		      ((secondVertex->x != fourthVertex->x) || (secondVertex->y != fourthVertex->y)))
		    if ((det = ((firstVertex->x - secondVertex->x) * (fourthVertex->y - thirdVertex->y) -
				(firstVertex->y - secondVertex->y) * (fourthVertex->x - thirdVertex->x))) != 0)
		      {
			t = ((fourthVertex->y - thirdVertex->y) * (fourthVertex->x - secondVertex->x) +
			     (thirdVertex->x - fourthVertex->x) * (fourthVertex->y - secondVertex->y)) / det;
			s = ((secondVertex->y - firstVertex->y) * (fourthVertex->x - secondVertex->x) +
			     (firstVertex->x - secondVertex->x) * (fourthVertex->y - secondVertex->y)) / det;
			if ((t > 0.0) && (t < 1.0) && (s > 0.0) & (s < 1.0))
			  intersect = YES;
		      }
		}
	    m --;
	    n --;
	    // if no edges intersect, order by z-coordinates.
	    if (!intersect)
	      {
		for (m = 0; (m < verticesPerFace) && (sortedVerticesZ[k][m] == sortedVerticesZ[j][m]); m++)
		  ;
		if ((m != verticesPerFace) && (sortedVerticesZ[j][m] > sortedVerticesZ[k][m]))
		  {
		    k = j;
		    thisFace = tempFace;
		  }
		//					else
		//						;
	      }
	    else
	      // if there's a pair of edges intersecting, look at the z-coord at the
	      // intersection pt - the largest z-coord is the one we drawn.
	      {
		firstVertexZ = faceVerticesZ[k][m];
		secondVertexZ = (m + 1 == verticesPerFace) ? faceVerticesZ[k][0] :
		  faceVerticesZ[k][m + 1];
		thirdVertexZ = faceVerticesZ[j][n];
		fourthVertexZ = (n + 1 == verticesPerFace) ? faceVerticesZ[j][0] :
		  faceVerticesZ[j][n + 1];
		if (firstVertexZ * t + secondVertexZ * (1 - t) < thirdVertexZ * s + fourthVertexZ * (1 - s))
		  {
		    k = j;
		    thisFace = tempFace;
		  }
	      }
	  }
      
      
      
      // Let the wraps do the drawing, depending on the number of vertices in
      // the face, and whether or not we should fill the face.
      if (verticesPerFace == 3)
	if (colours[k] != TRANSPARENT)
	  {
	    //	    NSLog(@"%f %f %f %f %f %f %f %f %f", thisFace[0].x, thisFace[0].y, thisFace[1].x, thisFace[1].y,
	    // thisFace[2].x, thisFace[2].y, r[k],g[k],b[k]);
	    colourTriangle(thisFace[0].x, thisFace[0].y, thisFace[1].x, thisFace[1].y,
			   thisFace[2].x, thisFace[2].y, r[k],g[k],b[k]);
	  }
	else
	  outlineTriangle(thisFace[0].x, thisFace[0].y, thisFace[1].x, thisFace[1].y,
			  thisFace[2].x, thisFace[2].y);
      else
	if (verticesPerFace == 4)
	  if (colours[k] != TRANSPARENT)
	    colourSquare(thisFace[0].x, thisFace[0].y, thisFace[1].x, thisFace[1].y,
			 thisFace[2].x, thisFace[2].y, thisFace[3].x, thisFace[3].y,
			 r[k],g[k],b[k]);
	  else
	    outlineSquare(thisFace[0].x, thisFace[0].y, thisFace[1].x, thisFace[1].y,
			  thisFace[2].x, thisFace[2].y, thisFace[3].x, thisFace[3].y);
	else
	  if (verticesPerFace == 5)
	    if (colours[k] != TRANSPARENT)
	      colourPentagon(thisFace[0].x, thisFace[0].y, thisFace[1].x, thisFace[1].y,
			     thisFace[2].x, thisFace[2].y, thisFace[3].x, thisFace[3].y,
			     thisFace[4].x, thisFace[4].y, r[k],g[k],b[k]);
	    else
	      outlinePentagon(thisFace[0].x, thisFace[0].y, thisFace[1].x, thisFace[1].y,
			      thisFace[2].x, thisFace[2].y, thisFace[3].x, thisFace[3].y,
			      thisFace[4].x, thisFace[4].y);
      
      drawn[k] = YES;
    }
  
  return self;	
}


// Erase the polyhedron.  Quick, and dirty - just erase a large rectangle that
// covers the entire polyhedron on the screen - if it erase some of the background, so
// what?  We'll redraw that in a little while, anyway.  This method has the prime virtue of
// being fast, fast, fast.
- erasePolyhedron
{
  int		i;
  NSRect	eraseRect;
  float	maxX, maxY, minX, minY;
  NSPoint	thisPt;
  float         border = 50;

  maxY = maxX = 0;
  minX = [self bounds].size.width;
  minY = [self bounds].size.height;
  for (i = 0; i < numVertices; i++)
    {
      thisPt = vertices[i].screenPos;
      if (thisPt.x > maxX)
	maxX = thisPt.x;
      if (thisPt.y > maxY)
	maxY = thisPt.y;
      if (thisPt.x < minX)
	minX = thisPt.x;
      if (thisPt.y < minY)
	minY = thisPt.y;
    }
  
  eraseRect.origin.x = (minX > border)?minX - 10:minX - border - 10;
  eraseRect.origin.y = (minY > border)?minY - 10:minY - border - 10;
  eraseRect.size.width  = (maxX - minX) + border + 20;
  eraseRect.size.height = (maxY - minY) + border + 20;

  PSsetgray(NSBlack);
  // NSRectFill([self bounds]);
  NSRectFill(eraseRect);

  return self;	
}

// Do one animation step.
- (void) oneStep
{
  int		i, j;
  float	length;
  float	dotProduct;
  D3_PT	velForce[MAX_NUM_VERTICES], force[MAX_NUM_VERTICES];
  float	theForce;
  D3_PT	sumVel;
  
  // NSLog(@"Called");
  // Cycle the background box colours.
  if (((backStep ++) % 20) == 0)
    {
      // NSLog(@"Called1");
      switch (backStep / 20)
	{
#ifdef VANNA
	case 0:
	  [self drawBoxInColour:NSWhite];
	  break;
	case 1:
	  [self drawBoxInColour:NSLightGray];
	  break;
	case 2:
	  [self drawBoxInColour:NSDarkGray];
	  break;
	case 3:
	  [self drawBoxInColour:NSBlack];
	  break;
#endif
	default:
	  // Compute average velocity of icosahedron
	  // If it's too small, give it a random kick
	  sumVel.x = sumVel.y = sumVel.z = 0;
	  for (i = 0; i < numVertices; i++)
	    {
	      // NSLog(@"Called2");
	      
	      sumVel.x += vertices[i].vel.x;
	      sumVel.y += vertices[i].vel.y;
	      sumVel.z += vertices[i].vel.z;
	    }
	  if (distance(sumVel.x, sumVel.y, sumVel.z) / numVertices < 0.5) //.33
	    {
	      sumVel.x = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
	      // NSLog(@"sumVel.x = %f",sumVel.x);
	      sumVel.y = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
	      sumVel.z = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
	      for (i = 0; i < numVertices; i++)
		{
		  vertices[i].vel.x += sumVel.x;
		  vertices[i].vel.y += sumVel.y;
		  vertices[i].vel.z += sumVel.z;
		}
	    }
	  backStep = 0;
	  break;
	}
    }
  // If we're not doing anything about the polyhedron, leave now.
  if (noAnimation)
    return;
  // Erase it.
  [self erasePolyhedron];
  // Move it, bouncing off walls as necessary
  for (i = 0; i < numVertices; i++)
    {
      vertices[i].pos.x += vertices[i].vel.x;
      if ((vertices[i].pos.x < 0) || (vertices[i].pos.x > backTopRight.x))
	vertices[i].vel.x = -vertices[i].vel.x;
      vertices[i].pos.y += vertices[i].vel.y;
      if ((vertices[i].pos.y < 0) || (vertices[i].pos.y > backTopRight.y))
	vertices[i].vel.y = -vertices[i].vel.y;
      vertices[i].pos.z += vertices[i].vel.z;
      if ((vertices[i].pos.z < 0) || (vertices[i].pos.z > backTopRight.z))
	vertices[i].vel.z = -vertices[i].vel.z;
    }
  // draw it
  [self drawPolyhedron];
  for (i = 0; i < numVertices; i++)
    {
      velForce[i].x = force[i].x = 0;
      velForce[i].y = force[i].y = 0;
      velForce[i].z = force[i].z = 0;
    }
  // calculate the force on each vertex.
  // Notice the use of symmetry here to cut down the amount of computation
  // i.e. the force on vertex j exerted by the spring from vertex i is minus
  //      that on vertex i exerted by vertex j .....
  for (i = 0; i < numVertices; i++)
    {
      for (j = i + 1; j < numVertices; j++)
	{
	  // spring forces (Hookes' Law - remember that?)
	  length = distance(vertices[i].pos.x - vertices[j].pos.x,
			    vertices[i].pos.y - vertices[j].pos.y,
			    vertices[i].pos.z - vertices[j].pos.z);
	  theForce = (vertices[i].pos.x - vertices[j].pos.x) / length * (restLengths[i][j] - length) * SPRING_K;
	  force[i].x += theForce;
	  force[j].x -= theForce;
	  theForce = (vertices[i].pos.y - vertices[j].pos.y) / length * (restLengths[i][j] - length) * SPRING_K;
	  force[i].y += theForce;
	  force[j].y -= theForce;
	  theForce = (vertices[i].pos.z - vertices[j].pos.z) / length * (restLengths[i][j] - length) * SPRING_K;
	  force[i].z += theForce;
	  force[j].z -= theForce;
	  
	  // Velocity damping - only for adjacent vertices
	  
	  if (isAdjacent[i][j])
	    {
	      dotProduct = ((vertices[i].pos.x - vertices[j].pos.x) * 
			    (vertices[i].vel.x - vertices[j].vel.x) +
			    (vertices[i].pos.y - vertices[j].pos.y) * 
			    (vertices[i].vel.y - vertices[j].vel.y) +
			    (vertices[i].pos.z - vertices[j].pos.z) * 
			    (vertices[i].vel.z - vertices[j].vel.z)) / 
		length/length * damping;
	      
	      theForce = dotProduct * (vertices[i].pos.x - vertices[j].pos.x);
	      velForce[i].x -= theForce;
	      velForce[j].x += theForce;
	      theForce = dotProduct * (vertices[i].pos.y - vertices[j].pos.y);
	      velForce[i].y -= theForce;
	      velForce[j].y += theForce;
	      theForce = dotProduct * (vertices[i].pos.z - vertices[j].pos.z); //xxx
	      velForce[i].z -= theForce;
	      velForce[j].z += theForce;
	    }
	}
    }
  // Change the velocities (F = ma !!).  Make sure the velocities don't get too big.
  // (Stability check).
  for (i = 0; i < numVertices; i++)
    {
      vertices[i].vel.x += (velForce[i].x + force[i].x) / vertices[i].mass;
      if (fabs(vertices[i].vel.x) > MAX_VEL)
	vertices[i].vel.x = vertices[i].vel.x / fabs(vertices[i].vel.x) * MAX_VEL;
      vertices[i].vel.y += (velForce[i].y + force[i].y) / vertices[i].mass;
      if (fabs(vertices[i].vel.y) > MAX_VEL)
	vertices[i].vel.y = vertices[i].vel.y / fabs(vertices[i].vel.y) * MAX_VEL;
      vertices[i].vel.z += (velForce[i].z + force[i].z) / vertices[i].mass;
      if (fabs(vertices[i].vel.z) > MAX_VEL)
	vertices[i].vel.z = vertices[i].vel.z / fabs(vertices[i].vel.z) * MAX_VEL;
    }
  // return self;
}

// Just erase ourself.
- drawRect:(NSRect)rects // :(int)rectCount
{
  PSsetlinewidth(0);
  PSsetgray(0);
  NSRectFill(rects);	
  return self;
}

// Somebody just changed the size of the box we're sitting in - recompute
// stuff, and start the animation again.
- (id) frameChanged:(NSRect)frameRect
{
  D3_PT	initPos, initVel;
  int	i, j;
  float	length;
  
  [self useNewFrame: frameRect];
  
  // Compute the room size.
  backTopRight.x = frameRect.size.width;
  backTopRight.y = frameRect.size.height;
  backTopRight.z = frameRect.size.height;
  
  // Where the perspective's coming from.
  perspectivePt.x = backTopRight.x / 2;
  perspectivePt.y = backTopRight.y / 2;
  perspectivePt.z = backTopRight.y * DEPTH;
  
  // Compute initial velocity.
  initVel.x = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
  initVel.y = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
  initVel.z = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
  
  // NSLog(@"initVel.x = %f y = %f z = %f",initVel.x, initVel.y, initVel.z);
  
  // If the room's too small, we're going to have problems, so don't
  // stick the polyhedron in.
  if ((frameRect.size.width < 240) || (frameRect.size.height < 240))
    noAnimation = YES;
  else
    {
      noAnimation = NO;
      
      // Compute initial position.
      initPos.x = randBetween((float)120, (float)(frameRect.size.width - 120));
      initPos.y = randBetween((float)120, (float)(frameRect.size.height - 120));
      initPos.z = randBetween((float)120, (float)(frameRect.size.height - 120));
      
      //  NSLog(@"initPos.x = %f y = %f z = %f",initPos.x, initPos.y, initPos.z);

      // Compute the rest lengths of the springs.
      length = distance(offsets[polyhedron][0].x - offsets[polyhedron][1].x, 
			offsets[polyhedron][0].y - offsets[polyhedron][1].y, 
			offsets[polyhedron][0].z - offsets[polyhedron][1].z);
      for (i = 0; i < numVertices; i++)
	{
	  vertices[i].pos.x = initPos.x + offsets[polyhedron][i].x * SPRING_REST_LEN / length;
	  vertices[i].pos.y = initPos.y + offsets[polyhedron][i].y * SPRING_REST_LEN / length;
	  vertices[i].pos.z = initPos.z + offsets[polyhedron][i].z * SPRING_REST_LEN / length;
	  vertices[i].vel  = initVel;
	}
      for (i = 0; i < numVertices; i++)
	for (j = 0; j < numVertices; j++)
	  {
	    length = distance(vertices[i].pos.x - vertices[j].pos.x, vertices[i].pos.y - vertices[j].pos.y,
			      vertices[i].pos.z - vertices[j].pos.z);
	    restLengths[i][j] = length;
	  }
    }
  
  // Compute the damping factor
  
  damping = DAMPING * realAdjacents / numVertices;
  
  // sanity check:  if this number is too big, then velocity
  // damping contributes to instability, rather than curing it...
  
  if (damping > 0.3)
    damping = 0.3;
  
  return self;
}


// If we get either setFrame, or sizeTo messages, we'd better recompute the
// box and stuff.
- (void) setFrame:(NSRect)frameRect
{
  // NSLog(@"setFramed...");
  [super setFrame:frameRect];
  [self frameChanged: frameRect];
}

/*
  - sizeTo:(float)width :(float)height
  {
  NSRect frameRect;
  [super sizeTo:width:height];
  frameRect.origin.x = 0;
  frameRect.origin.y = 0;
  frameRect.size.width = width;
  frameRect.size.height = height;
  [self frameChanged: &frameRect];
  return self;
  }
*/

- initWithFrame:(NSRect)frameRect
{
  [super initWithFrame: frameRect];	
  [self useNewFrame:frameRect];
  srand(time(0));
  return self;
}

- useNewFrame:(NSRect)frameRect
{
  int		i, j, k;
  D3_PT	initVel;
  BOOL	foundVertex;
  
  // Decide which Polyhedron.
  if (selectedIndex == 0)	polyhedron   = random() % 5;
  else	polyhedron = selectedIndex-1;
  
  numVertices  = theNumVertices[polyhedron];
  numAdjacents = theNumAdjacents[polyhedron];
  numFaces     = theNumFaces[polyhedron];
  numDrawFaces = realFaces[polyhedron];
  verticesPerFace = theVerticesPerFace[polyhedron];
  
  // Compute adjacency info.
  // Notice that for the purposes of velocity damping, adjacent 
  // is the same as "are vertices on the same face." Not "are
  // vertices on the same edge."
  for (i = 0; i < numVertices; i++)
    {
      for (j = 0; j < numVertices; j++)
	isAdjacent[i][j] = NO;
      for (j = 0; j < numFaces; j++)
	{
	  foundVertex = NO;
	  for (k = 0; k < verticesPerFace; k++)
	    if (faces[polyhedron][j][k] == i)
	      foundVertex = YES;
	  if (foundVertex)
	    for (k = 0; k < verticesPerFace; k++)
	      if (faces[polyhedron][j][k] != i)
		isAdjacent[i][faces[polyhedron][j][k]] = YES;
	}
    }
  
  realAdjacents = 0;
  for (i = 0; i < numVertices; i++)
    if (isAdjacent[0][i])
      realAdjacents ++;
  
  backTopRight.x = 0;
  backTopRight.y = 0;
  backTopRight.z = 0;
  
  perspectivePt.x = 0;
  perspectivePt.y = 0;
  perspectivePt.z = 0;
  
  noAnimation = YES;
  initVel.x = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
  initVel.y = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
  initVel.z = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
  
  // set up the initial position of the icosahedron.
  
  for (i = 0; i < numVertices; i++)
    {
      vertices[i].mass = MASS;
      vertices[i].vel  = initVel;
    }
  
  backStep = 0;
  
  damping = DAMPING;
  
  return self;
}

- setSelectedIndex:sender
{
  int val;
  val = [sender selectedRow];
  // NSLog(@"val = %d",val);
  if (selectedIndex == val) return self;
  
  selectedIndex = val;
  [self frameChanged: [self bounds]];
  [self display];
  return self;
}

- (id)kickIt: (id)sender
{
  int i;
  float	x,y,z;
  
  x = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
  y = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
  z = randBetween(-(float)INIT_VELOCITY, (float)INIT_VELOCITY);
  
  for (i = 0; i < numVertices; i++)
    {
      vertices[i].vel.x += x;
      vertices[i].vel.y += y;
      vertices[i].vel.z += z;
    }
  return self;
}

- (id)inspector: (id)sender
{
  char buf[MAXPATHLEN];
  
  // NSLog(@"called");
  if (!inspectorPanel)
    {
      // NSLog(@"getting inspector");
      // sprintf(buf,"%s/Polyhedra.nib",[sender moduleDirectory:"Polyhedra"]);
      // [NXApp loadNibFile:buf owner:self withNames:NO];
      if(![NSBundle loadNibNamed: @"Polyhedra" owner:self])
	{
	  NSLog(@"Failed to load");
	}
    }
  // NSLog(@"inspector: %@",inspectorPanel);
  return inspectorPanel;
}

- (BOOL) useBufferedWindow
{	
  return YES;
}
@end
