/*
 Project: Graphos
 GRBezierControlPoint.m

 Copyright (C) 2000-2017 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
 Author: Ing. Riccardo Mottola

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */


#import "GRBezierControlPoint.h"
#import "GRBezierPathEditor.h"
#import "GRFunctions.h"

@implementation GRBezierControlPoint

- (id)initAtPoint:(NSPoint)aPoint
        forPath:(GRBezierPath *)aPath
       zoomFactor:(CGFloat)zf
{
  self = [super init];
  if(self)
    {
      path = aPath;
      zmFactor = zf;
      center = aPoint;
      bzHandle.center = aPoint;
      bzHandle.firstHandle = aPoint;
      bzHandle.secondHandle = aPoint;
      bzHandle.centerRect = NSMakeRect(aPoint.x-3, aPoint.y-3, 6, 6);
      [self calculateBezierHandles: aPoint];
      isSelect = NO;
      symmetricalHandles = YES;
      pointPosition = GRPointMiddle;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
  GRBezierControlPoint *objCopy;

  objCopy = [super copyWithZone: zone];
  objCopy->symmetricalHandles = symmetricalHandles;
  objCopy->pointPosition = pointPosition;
  objCopy->path = path;
  objCopy->bzHandle = bzHandle;

  return objCopy;
}

- (void)setPath:(GRBezierPath *)thePath
{
  path = thePath;
}


- (void)calculateBezierHandles:(NSPoint)draggedHandlePos
{
    double distx, disty;

    bzHandle.firstHandle = draggedHandlePos;
    bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);

    distx = grmax(bzHandle.firstHandle.x, bzHandle.center.x) - grmin(bzHandle.firstHandle.x, bzHandle.center.x);
    disty = grmax(bzHandle.firstHandle.y, bzHandle.center.y) - grmin(bzHandle.firstHandle.y, bzHandle.center.y);
    if (symmetricalHandles)
      {
        if(bzHandle.firstHandle.x > bzHandle.center.x)
          bzHandle.secondHandle.x = bzHandle.center.x - distx;
        else
          bzHandle.secondHandle.x = bzHandle.center.x + distx;
        
        if(bzHandle.firstHandle.y > bzHandle.center.y)
          bzHandle.secondHandle.y = bzHandle.center.y - disty;
        else
          bzHandle.secondHandle.y = bzHandle.center.y + disty;
      }
    bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);

    if(distx || disty)
        isActiveHandle = YES;
}

- (void)moveToPoint:(NSPoint)p
{
    double xdiff, ydiff;

    xdiff = p.x - bzHandle.center.x;
    ydiff = p.y - bzHandle.center.y;
    bzHandle.center.x += xdiff;
    bzHandle.center.y += ydiff;
    bzHandle.centerRect = NSMakeRect(bzHandle.center.x-3, bzHandle.center.y-3, 6, 6);
    bzHandle.firstHandle.x += xdiff;
    bzHandle.firstHandle.y += ydiff;
    bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);
    bzHandle.secondHandle.x += xdiff;
    bzHandle.secondHandle.y += ydiff;
    bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);
}

- (void)moveBezierHandleToPosition:(NSPoint)newp oldPosition:(NSPoint)oldp
{
  GRBezierControlPoint *mtopoint, *ponpoint = nil;
  double distx, disty;

  mtopoint = [path firstPoint];
  ponpoint = [path pointOnPoint: self];
  if(ponpoint && [(GRPathEditor *)[path editor] isDone] && (self == mtopoint))
    [ponpoint moveBezierHandleToPosition: newp oldPosition: oldp];

  if(pointInRect(bzHandle.firstHandleRect, oldp))
    {
      bzHandle.firstHandle = newp;
      if (symmetricalHandles)
	{
	  distx = grmax(bzHandle.firstHandle.x, bzHandle.center.x) - grmin(bzHandle.firstHandle.x, bzHandle.center.x);
	  disty = grmax(bzHandle.firstHandle.y, bzHandle.center.y) - grmin(bzHandle.firstHandle.y, bzHandle.center.y);
	  if(bzHandle.firstHandle.x > bzHandle.center.x)
	    bzHandle.secondHandle.x = bzHandle.center.x - distx;
	  else
	    bzHandle.secondHandle.x = bzHandle.center.x + distx;
	  if(bzHandle.firstHandle.y > bzHandle.center.y)
	    bzHandle.secondHandle.y = bzHandle.center.y - disty;
	  else
	    bzHandle.secondHandle.y = bzHandle.center.y + disty;
	}
    }
  else if(pointInRect(bzHandle.secondHandleRect, oldp))
    {
      bzHandle.secondHandle = newp;
      if (symmetricalHandles)
	{
	  distx = grmax(bzHandle.secondHandle.x, bzHandle.center.x) - grmin(bzHandle.secondHandle.x, bzHandle.center.x);
	  disty = grmax(bzHandle.secondHandle.y, bzHandle.center.y) - grmin(bzHandle.secondHandle.y, bzHandle.center.y);
	  if(bzHandle.secondHandle.x > bzHandle.center.x)
	    bzHandle.firstHandle.x = bzHandle.center.x - distx;
	  else
	    bzHandle.firstHandle.x = bzHandle.center.x + distx;
	  if(bzHandle.secondHandle.y > bzHandle.center.y)
	    bzHandle.firstHandle.y = bzHandle.center.y - disty;
	  else
	    bzHandle.firstHandle.y = bzHandle.center.y + disty;
	}
    }

  bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);
  bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);
}

- (void)overlapHandles
{
  bzHandle.firstHandle = bzHandle.center;
  bzHandle.secondHandle = bzHandle.center;
  bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);
  bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);
}

- (void)extractHandles
{
  CGFloat dx, dy;

  dx = 10;
  dy = 0;
  bzHandle.firstHandle = NSMakePoint(bzHandle.center.x + dx, bzHandle.center.y + dy);
  bzHandle.secondHandle = NSMakePoint(bzHandle.center.x - dx, bzHandle.center.y - dy);
  bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);
  bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);  
}

- (void)drawControlAsSelected: (BOOL)sel
{
  NSPoint centerZ;
  NSRect centerRectZ;

  centerZ.x = bzHandle.center.x * zmFactor;
  centerZ.y = bzHandle.center.y * zmFactor;
  centerRectZ = NSMakeRect(centerZ.x-3, centerZ.y-3, 6, 6);
 
  if (sel)
    {
      [[NSColor blackColor] set];
      NSRectFill(centerRectZ);
    }
  else
    {
      [[NSColor whiteColor] set];
      NSRectFill(centerRectZ);
      [[NSColor blackColor] set];
      NSFrameRect(centerRectZ);
    }
}

- (void)drawHandle;
{
  NSPoint firstHandleP;
  NSRect firstHandleR;
  NSPoint secondHandleP;
  NSRect secondHandleR;
  NSPoint centerP;
  NSBezierPath *bzp;

  /* we calculate the zoomed coordinates */
  firstHandleP = NSMakePoint(bzHandle.firstHandle.x * zmFactor, bzHandle.firstHandle.y * zmFactor);
  secondHandleP = NSMakePoint(bzHandle.secondHandle.x * zmFactor, bzHandle.secondHandle.y * zmFactor);
  centerP = NSMakePoint(bzHandle.center.x * zmFactor, bzHandle.center.y * zmFactor);

  firstHandleR = NSMakeRect(firstHandleP.x-2, firstHandleP.y-2, 4, 4);
  secondHandleR = NSMakeRect(secondHandleP.x-2, secondHandleP.y-2, 4, 4);
  
  bzp = [NSBezierPath bezierPath];
  [bzp setLineWidth:1];
  [[NSColor blackColor] set];
  
  if (pointPosition == GRPointMiddle || pointPosition == GRPointStart)
    {
      NSRectFill(firstHandleR);
      [bzp moveToPoint:firstHandleP];
      [bzp lineToPoint:centerP];
    }
  else
    {
      [bzp moveToPoint:centerP];
    }
  
  if (pointPosition == GRPointMiddle || pointPosition == GRPointEnd)
    {
      [bzp lineToPoint:secondHandleP];
      NSRectFill(secondHandleR);
    }
  [bzp stroke];

}

- (void)drawControl
{
  [self drawControlAsSelected:isSelect];
  if (isSelect && isActiveHandle)
    [self drawHandle];
}

- (void)setZoomFactor:(CGFloat)f
{

  zmFactor = f;
}

- (GRBezierHandle)bzHandle
{
  return bzHandle;
}

- (void)setBezierHandle:(GRBezierHandle)handle
{
  bzHandle = handle;
  center = bzHandle.center;
  bzHandle.centerRect = NSMakeRect(bzHandle.center.x-3, bzHandle.center.y-3, 6, 6);
  bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);
  bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);  
}

- (NSPoint)center
{
    return bzHandle.center;
}

- (NSRect)centerRect;
{
    return bzHandle.centerRect;
}

- (void)select
{
    double distx, disty;

    isSelect = YES;
    [(GRBezierPathEditor *)[path editor] unselectOtherControls: self];
    distx = grmax(bzHandle.firstHandle.x, bzHandle.center.x) - grmin(bzHandle.firstHandle.x, bzHandle.center.x);
    disty = grmax(bzHandle.firstHandle.y, bzHandle.center.y) - grmin(bzHandle.firstHandle.y, bzHandle.center.y);
    if(distx || disty)
        isActiveHandle = YES;
}

- (void)unselect
{
  isSelect = NO;
}

- (BOOL)isSelect
{
  return isSelect;
}

- (BOOL)isActiveHandle
{
  return isActiveHandle;
}

- (BOOL)symmetricalHandles
{
  return symmetricalHandles;
}

- (void)setSymmetricalHandles:(BOOL)flag
{
  symmetricalHandles = flag;
}

- (void)setPointPosition:(GRPointTangentStyle)pPos
{
  pointPosition = pPos;
}

@end
