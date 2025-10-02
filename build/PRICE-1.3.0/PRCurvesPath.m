//
//  PRCurvesPath.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu 11 August 2011.
//  Copyright 2011-2014 Riccardo Mottola. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCurvesPath.h"
#import <AppKit/NSColor.h>

@implementation PRCurvesPath

- (id)init
{
  self = [super init];
  if(self)
    {
      isEditing = YES;
    }
  return self;
}

-(void)stroke
{
  unsigned i;

  [super stroke];
  
  if (isEditing)
    for (i = 0; i < [self elementCount]; i++)
      {
	NSPoint cp[3];
	NSBezierPathElement pe;
	NSRect cpRect;
    
	pe = [self elementAtIndex: i associatedPoints: cp];
    
	if (pe == NSMoveToBezierPathElement)
	  {
	    [[NSColor purpleColor] set];
	    cpRect = NSMakeRect(cp[0].x - 1, cp[0].y - 1, 4, 4);
	    [NSBezierPath fillRect: cpRect];
	  }
	else if (pe == NSCurveToBezierPathElement)
	  {
	    [[NSColor orangeColor] set];
	    cpRect = NSMakeRect(cp[0].x - 1, cp[0].y - 1, 4, 4);
	    [NSBezierPath fillRect: cpRect];
	    [[NSColor orangeColor] set];
	    cpRect = NSMakeRect(cp[1].x - 1, cp[1].y - 1, 4, 4);
	    [NSBezierPath fillRect: cpRect];
	    [[NSColor purpleColor] set];
	    cpRect = NSMakeRect(cp[2].x - 1, cp[2].y - 1, 4, 4);
	    [NSBezierPath fillRect: cpRect];
	  }
    
      }
  
}

-(BOOL)isEditing;
{
  return isEditing;
}

-(void)setIsEditing: (BOOL)flag
{
  isEditing = flag;
}

-(NSPoint)blackPoint
{
  NSPoint cp[3];
  NSPoint p;
  NSBezierPathElement pe;
      
  pe = [self elementAtIndex: 0 associatedPoints: cp];
  p = cp[0];
  NSLog(@"calculated black point: %f", p.x);
  // ATTENTION: this is really true only for the simple S curve
  return p;
}

-(NSPoint)whitePoint
{
  NSPoint cp[3];
  NSPoint p;
  NSBezierPathElement pe;
      
  pe = [self elementAtIndex:[self elementCount]-1 associatedPoints: cp];
  p = NSZeroPoint;
  if (pe == NSMoveToBezierPathElement)
    p = cp[0];
  else if (pe == NSLineToBezierPathElement)
    p = cp[0];
  else if (pe == NSCurveToBezierPathElement)
    p = cp[2];

  NSLog(@"calculated white point: %f", p.x);
  return p;
}

-(NSArray *)values
{
  NSBezierPath *tp;
  NSBezierPath *fp;
  unsigned i, j;
  NSPoint *yVals;
  unsigned valsCount;
  NSMutableArray *f;
  unsigned minX, maxX;
  float lastY;

  
  tp = [NSBezierPath bezierPath];
  [tp appendBezierPath:(NSBezierPath *)self];
  [tp setFlatness: 1.0];
  fp = [tp bezierPathByFlatteningPath];
  
  valsCount = [fp elementCount];
  yVals = calloc(valsCount, sizeof(NSPoint));
  if (yVals == NULL)
    return nil;
  
  f = [[NSMutableArray alloc] initWithCapacity: UCHAR_MAX];
  for (i = 0; i < valsCount; i++)
    {
      NSBezierPathElement pe;
      NSPoint cp[3];
    
      pe = [fp elementAtIndex: i associatedPoints: cp];
 
      yVals[i] = cp[0];
    }

  minX = floor(yVals[0].x);
  maxX = floor(yVals[valsCount].x);

  for (i = 0; i < minX; i++)
    [f addObject: [NSNumber numberWithFloat: yVals[0].y]];
  
  
  for (j = 0; j < valsCount; j++)
    {
      unsigned k, l;
      float y1, y2;
    
      /* find estimation interval (k) and begin/end values y1 y2 */
      y1 = yVals[j].y;
    
      l = i;
      k = i;
      
      if (j+1 < valsCount)
	{
  	  while (k < floor(yVals[j+1].x))
	    k++;
          y2 = yVals[j+1].y;
	}
      else
	{
	  y2 = y1;
	  k++;
	}
      
//      NSLog(@"%d block %d-%d, y1-y2 %f-%f", j, l, k, y1, y2);
      for (; i < k; i++)
	{
	  float a;
      
	  a = (float)(i-l)/(k-l);
//	  NSLog(@"a: %f", a);
	  [f addObject: [NSNumber numberWithFloat: (y1 + (y2-y1)*a)]];
	}
    }

  lastY = [[f objectAtIndex: [f count]-1] floatValue];

  for (; i <= UCHAR_MAX; i++)
    [f addObject: [NSNumber numberWithFloat: lastY]];
  
  free(yVals);

  return f;
}

-(void)move: (NSPoint)p1 toPoint:(NSPoint)p2
{
  unsigned i;
  NSLog (@"move %f %f %f %f", p1.x, p1.y, p2.x, p2.y);
  for (i = 0; i < [self elementCount]; i++)
    {
      NSPoint cp[3];
      NSBezierPathElement pe;
      NSRect cpRect;
      
      pe = [self elementAtIndex: i associatedPoints: cp];
      if (pe == NSMoveToBezierPathElement)
        {
          cpRect = NSMakeRect(cp[0].x - 1, cp[0].y - 1, 4, 4);
          if (NSPointInRect(p1, cpRect))
            {
              cp[0] = p2;
            }
        }
      else if (pe == NSCurveToBezierPathElement)
        {
          cpRect = NSMakeRect(cp[0].x - 1, cp[0].y - 1, 4, 4);
          if(NSPointInRect(p1, cpRect))
            cp[0] = p2;
          cpRect = NSMakeRect(cp[1].x - 1, cp[1].y - 1, 4, 4);
          if (NSPointInRect(p1, cpRect))
            cp[1] = p2;
          cpRect = NSMakeRect(cp[2].x - 1, cp[2].y - 1, 4, 4);
          if(NSPointInRect(p1, cpRect))
            cp[2] = p2;
        }
      [self setAssociatedPoints:cp atIndex:i];
    }
}

-(BOOL)pointOnControlHandle:(NSPoint)p;
{
  unsigned i;
  BOOL hit;
  
  hit = NO;
  for (i = 0; i < [self elementCount]; i++)
    {
      NSPoint cp[3];
      NSBezierPathElement pe;
      NSRect cpRect;
      
      pe = [self elementAtIndex: i associatedPoints: cp];
      
      if (pe == NSMoveToBezierPathElement)
        {
          cpRect = NSMakeRect(cp[0].x - 1, cp[0].y - 1, 4, 4);
          hit |= NSPointInRect(p, cpRect);
        }
      else if (pe == NSCurveToBezierPathElement)
        {
          cpRect = NSMakeRect(cp[0].x - 1, cp[0].y - 1, 4, 4);
          hit |= NSPointInRect(p, cpRect);
          cpRect = NSMakeRect(cp[1].x - 1, cp[1].y - 1, 4, 4);
          hit |= NSPointInRect(p, cpRect);
          cpRect = NSMakeRect(cp[2].x - 1, cp[2].y - 1, 4, 4);
          hit |= NSPointInRect(p, cpRect);
        }
    }
  return hit;  
}


@end
