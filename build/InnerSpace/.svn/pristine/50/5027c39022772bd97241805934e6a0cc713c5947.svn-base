//  SpaceView.m
//
//  This class implements the flying starfield screen saver view.
//
//  Another variation on the space theme, slightly faster and different.


#import "Space2View.h"
#import <Foundation/Foundation.h>
#import <AppKit/PSOperators.h>
#import <AppKit/AppKit.h>
#import <math.h>

#define PI (3.141592653589)

NSSize sizeArray[] = {{1,1},{2,1},{2,2},{3,2},{3,3},{4,3},{4,4}};

@implementation Space2View

extern float randBetween(float a, float b);

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


//takes theta and distance and stuffs it into x &y for *p
- convertToXY:(STAR *)p
{
  NSRect bounds = [self bounds];
  p->draw.origin.x = floor(bounds.size.width / 2 + (p->distance * cos(p-> theta)));
  p->draw.origin.y = floor(bounds.size.height / 2 + (p->distance * sin(p-> theta)));
  return self;
}


- oneStep
{
  int i, count, starsInArray = 0;
  STAR *p;
  NSRect bounds = [self bounds];

  if (nstars < NSTARS) [self addStar];
  
  for (i=0; i<nstars; i++)
    {
      p = &stars[i];
      p->distance += p->delta;
      p->delta *= p->ddelta;
      p->theta += 0.012;
      if (p->theta > (2*PI)) p->theta -= (2*PI);
      
      [self convertToXY:p];
      
      // only draw the star if it moved > 1 pixel
      if (p->draw.origin.x != p->erase.origin.x || 
	  p->draw.origin.y != p->erase.origin.y)
	{
	  // add star to the erasure array
	  b[starsInArray] = p->erase;
	  
	  if (p->distance > p->changepoint[p->changemode])
	    {
	      (p->changemode)++;
	      p->draw.size = sizeArray[p->changemode];
	    }
	  
	  // clipping is off, so we must not draw outside view.
	  // replace stars that go too far...
	  if (p->draw.origin.x < 0 ||
	      p->draw.origin.y < 0 ||
	      p->draw.origin.x + 4 > bounds.size.width ||
	      p->draw.origin.y + 4 > bounds.size.height)
	    {
	      [self replaceStarAt:i];
	    }
	  
	  w[starsInArray++] = p->draw;
	  
	  p->erase = p->draw;
	}
    }
  
  if (starsInArray)
    {
      count = 0;
      while (count < starsInArray)
	{
	  // You get the best performance if you put out all the stars
	  // at once.  This causes noticable flicker, so I put out 
	  // 100 of the stars per iteration.  This gives reasonable speed
	  // and flicker is hardly noticable.  Besides, stars
	  // _should_ flicker a little...
	  
	  int t = (starsInArray - count);
	  i = (t < STARSPERIT)?t:STARSPERIT;
	  
	  PSsetgray(0.0);
	  NSRectFillList(&b[count],i);
	  
	  PSsetgray(1.0);
	  NSRectFillList(&w[count],i);
	  
	  count += STARSPERIT;
	}
    }
  
  return self;
}

- initWithFrame:(NSRect)frameRect
{
  [super initWithFrame:frameRect];
  // [self allocateGState];		// For faster lock/unlockFocus
  // [self setClipping:NO];		// even faster...
  [self setRadius];
  
  return self;
}

- drawRect:(NSRect)rects 
{
  // this drawself doesn't really draw the view at all.
  // in fact it just promotes the window to screen depth...
  
  NSRect t = NSMakeRect(0,0,1,1);
  
  PSsetrgbcolor(1,0,0);
  NSRectFill(t);	//yucky trick for window depth promotion!
  PSsetgray(0.0); 
  NSRectFill(t);
  return self;
}

- setFrame:(NSRect)rect
{
  NSRect bounds = [self bounds];

  // if (bounds.size.width == width && bounds.size.height == height) return self;
  
  [super setFrame: rect];
  [self setRadius];
  nstars = 0;
  return self;
}

// only call addStar if there is room in the stars array!
- addStar
{
  [self replaceStarAt:nstars++];
  return self;
}

- replaceStarAt:(int)index
{
  float dist, t;
  int tries = 0;
  STAR *p = &stars[index];
  BOOL inBounds;
  NSRect bounds = [self bounds];
  
  do {
    p->theta = randBetween(0,(2*PI));
    
    if (tries++ < 3) p->distance = randBetween(1, radius);
    else p->distance = randBetween(1, p->distance);
    
    inBounds = YES;
    [self convertToXY:p];
    
    if (p->draw.origin.x < 0 || p->draw.origin.y < 0 ||
	p->draw.origin.x + 4 > bounds.size.width ||
	p->draw.origin.y + 4 > bounds.size.height)
      {
	inBounds = NO;
      }
  } while (!inBounds);
  
  p->draw.size = sizeArray[0];
  
  p->delta = (0.3);
  
  //	p->ddelta = randBetween(1.0, 1.1);
  p->ddelta = randBetween(1.0, 1.15);
  
  t = randBetween(0, (0.42*radius));
  dist = MAX(20,t);
  p->changepoint[0] = p->distance + 5;			// 2nd
  p->changepoint[1] = p->changepoint[0] - 5 + dist + dist;	// 3rd
  
  p->changepoint[2] = p->changepoint[1] + dist;		// 4th
  p->changepoint[3] = p->changepoint[2] + dist;		// 5th
  p->changepoint[4] = p->changepoint[3] + dist;		// 6th
  p->changepoint[5] = 100000;				// never change to 7th
  
  p->changemode = 0;
  
  p->erase = p->draw;
  
  return self;
}

- setRadius
{
  NSRect bounds = [self bounds];

  float x = bounds.size.width;
  float y = bounds.size.height;
  radius = (sqrt(x*x + y*y))/2;
  return self;
}

@end
