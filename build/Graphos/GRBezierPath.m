/*
 Project: Graphos
 GRBezierPath.m

 Copyright (C) 2000-2025 GNUstep Application Project

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

#import "GRBezierPath.h"
#import "GRDocView.h"
#import "GRFunctions.h"
#import "GRBezierPathEditor.h"

static double k = 0.025;

@implementation GRBezierPath

- (GRObjectEditor *)allocEditor
{
  return [[GRBezierPathEditor alloc] initEditor:self];
}

/** initializes by using the properties array as defaults */
- (id)initInView:(GRDocView *)aView
      zoomFactor:(CGFloat)zf
      withProperties:(NSDictionary *)properties
{
  self = [super initInView:aView zoomFactor:zf withProperties:properties];
  if(self)
    {
      controlPoints = [[NSMutableArray alloc] initWithCapacity: 1];
    }

  return self;
}

- (id)initFromData:(NSDictionary *)description
        inView:(GRDocView *)aView
        zoomFactor:(CGFloat)zf
{
  self = [super initFromData:description inView:aView zoomFactor:zf];
  if(self != nil)
    {
      NSArray *psops, *linearr;
      NSString *str;
      NSPoint p, pp[3];
      GRBezierControlPoint *prevcp;
      double distx, disty;
      NSUInteger i, count;
      NSArray *points;
      BOOL symm;
      
      psops = nil;
      linearr = nil;

      controlPoints = [[NSMutableArray alloc] initWithCapacity: 1];
      points = [description objectForKey: @"points"];
      for (i = 0; i < [points count]; i++)
        {
          GRBezierHandle h;
          GRBezierControlPoint *cp;

          linearr = [[points objectAtIndex: i] componentsSeparatedByString: @" "];
          h.firstHandle.x = [[linearr objectAtIndex: 0] floatValue];
          h.firstHandle.y = [[linearr objectAtIndex: 1] floatValue];
          h.firstHandleRect = NSMakeRect(h.firstHandle.x-2, h.firstHandle.y-2, 4, 4);
          h.center.x = [[linearr objectAtIndex: 2] floatValue];
          h.center.y = [[linearr objectAtIndex: 3] floatValue];
          h.centerRect = NSMakeRect(h.center.x-3, h.center.y-3, 6, 6);
          h.secondHandle.x = [[linearr objectAtIndex: 4] floatValue];
          h.secondHandle.y = [[linearr objectAtIndex: 5] floatValue];
          h.secondHandleRect = NSMakeRect(h.secondHandle.x-2, h.secondHandle.y-2, 4, 4);
          symm = (BOOL)[[linearr objectAtIndex: 6] intValue];

          cp = [[GRBezierControlPoint alloc] initAtPoint:h.center forPath:self zoomFactor:zmFactor];
          [cp setBezierHandle:h];
          [cp setSymmetricalHandles:symm];
          [controlPoints addObject:cp];
          [cp release];
        }
      [self confirmNewCurve];
 
      psops = [description objectForKey: @"psdata"];
      for(i = 0; i < [psops count]; i++)
        {
	  linearr = [[psops objectAtIndex: i] componentsSeparatedByString: @" "];
	  count = [linearr count];
	  str = [linearr objectAtIndex: count -1];
	  
	  if([str isEqualToString: @"moveto"])
            {
	      pp[0].x = [[linearr objectAtIndex: 0] floatValue];
	      pp[0].y = [[linearr objectAtIndex: 1] floatValue];
	      [self addControlAtPoint: pp[0]];
              [self confirmNewCurve];
            }
	  
	  if([str isEqualToString: @"lineto"])
            {
	      pp[0].x = [[linearr objectAtIndex: 0] floatValue];
	      pp[0].y = [[linearr objectAtIndex: 1] floatValue];
	      [self addLineToPoint: pp[0]];
              [self confirmNewCurve];
            }
	  
	  if([str isEqualToString: @"curveto"])
            {
	      pp[0].x = [[linearr objectAtIndex: 0] floatValue];
	      pp[0].y = [[linearr objectAtIndex: 1] floatValue];
	      pp[1].x = [[linearr objectAtIndex: 2] floatValue];
	      pp[1].y = [[linearr objectAtIndex: 3] floatValue];
	      pp[2].x = [[linearr objectAtIndex: 4] floatValue];
	      pp[2].y = [[linearr objectAtIndex: 5] floatValue];
	      
	      [self addControlAtPoint: pp[2]];
	      prevcp = [controlPoints objectAtIndex: [controlPoints count] -2];
	      [prevcp calculateBezierHandles: pp[0]];
	      
	      distx = grmax(pp[1].x, pp[2].x) - grmin(pp[1].x, pp[2].x);
	      if(pp[1].x > pp[2].x)
		p.x = pp[2].x - distx;
	      else
		p.x = pp[2].x + distx;
	      
	      disty = grmax(pp[1].y, pp[2].y) - grmin(pp[1].y, pp[2].y);
	      if(pp[1].y > pp[2].y)
		p.y = pp[2].y - disty;
	      else
		p.y = pp[2].y + disty;
	      
	      [self addCurveWithBezierHandlePosition: p];
	      [self confirmNewCurve];
            }
        }
      

    }

  return self;
}


- (NSDictionary *)objectDescription
{
  NSMutableDictionary *dict;
  NSMutableArray *points;
  NSString *str;
  NSUInteger i;
  CGFloat strokeCol[3];
  CGFloat fillCol[3];
  CGFloat strokeAlpha;
  CGFloat fillAlpha;

  strokeCol[0] = [strokeColor redComponent];
  strokeCol[1] = [strokeColor greenComponent];
  strokeCol[2] = [strokeColor blueComponent];
  strokeAlpha = [strokeColor alphaComponent];
 
  fillCol[0] = [fillColor redComponent];
  fillCol[1] = [fillColor greenComponent];
  fillCol[2] = [fillColor blueComponent];
  fillAlpha = [fillColor alphaComponent];

  dict = [NSMutableDictionary dictionaryWithCapacity: 1];
  [dict setObject: @"path" forKey: @"type"];

  str = [NSString stringWithFormat: @"%.3f", (float)flatness];
  [dict setObject: str forKey: @"flatness"];
  str = [NSString stringWithFormat: @"%u", (unsigned)linejoin];
  [dict setObject: str forKey: @"linejoin"];
  str = [NSString stringWithFormat: @"%u", (unsigned)linecap];
  [dict setObject: str forKey: @"linecap"];
  str = [NSString stringWithFormat: @"%.3f", (float)miterlimit];
  [dict setObject: str forKey: @"miterlimit"];
  str = [NSString stringWithFormat: @"%.3f", (float)linewidth];
  [dict setObject: str forKey: @"linewidth"];
  [dict setObject: [NSNumber numberWithBool:stroked] forKey: @"stroked"];
  str = [NSString stringWithFormat: @"%.3f %.3f %.3f",
		  (float)strokeCol[0], (float)strokeCol[1], (float)strokeCol[2]];
  [dict setObject: str forKey: @"strokecolor"];
  str = [NSString stringWithFormat: @"%.3f", (float)strokeAlpha];
  [dict setObject: str forKey: @"strokealpha"];
  [dict setObject:[NSNumber numberWithBool:filled] forKey: @"filled"];
  str = [NSString stringWithFormat: @"%.3f %.3f %.3f",
		  (float)fillCol[0], (float)fillCol[1], (float)fillCol[2]];
  [dict setObject: str forKey: @"fillcolor"];
  str = [NSString stringWithFormat: @"%.3f", (float)fillAlpha];
  [dict setObject: str forKey: @"fillalpha"];
  [dict setObject:[NSNumber numberWithBool:visible] forKey: @"visible"];
  [dict setObject:[NSNumber numberWithBool:locked] forKey: @"locked"];

  points = [NSMutableArray arrayWithCapacity: 1];
  for (i = 0; i < [controlPoints count]; i++)
    {
      GRBezierControlPoint *cp;
      GRBezierHandle handle;

      cp = [controlPoints objectAtIndex:i];
      handle = [cp bzHandle];
      str = [NSString stringWithFormat: @"%f %f %f %f %f %f %d",
                      handle.firstHandle.x, handle.firstHandle.y,
                      handle.center.x, handle.center.y,
                      handle.secondHandle.x, handle.secondHandle.y,
                      [cp symmetricalHandles]];
      [points addObject:str];
    }
  [dict setObject: points forKey:@ "points"];
  
  return dict;
}

- (id)copyWithZone:(NSZone *)zone
{
  GRBezierPath *objCopy;
  NSMutableArray *cpsCopy;
  NSEnumerator *e;
  GRBezierControlPoint *cp;
  
  objCopy = [super copyWithZone:zone];
  
  cpsCopy = [[NSMutableArray alloc] initWithCapacity: [controlPoints count]];
  e = [controlPoints objectEnumerator];
  while ((cp = [e nextObject]))
    {
      GRBezierControlPoint *cpCopy;

      cpCopy = [cp copy];
      [cpCopy setPath:objCopy];
      [cpsCopy addObject: cpCopy];
      [cpCopy release];
    }
  
  objCopy->controlPoints = cpsCopy;
  objCopy->calculatingHandles = calculatingHandles;
  return objCopy;
}

- (void)dealloc
{
  [controlPoints release];
  [super dealloc];
}

- (NSMutableArray *)controlPoints
{
  return controlPoints;
}


- (void)addControlAtPoint:(NSPoint)aPoint
{
    GRBezierControlPoint *cp;

    cp = [[GRBezierControlPoint alloc] initAtPoint: aPoint
                                         forPath: self zoomFactor: zmFactor];
    [controlPoints addObject: cp];
    [cp select];
    currentPoint = cp;
    [cp release];

    if([controlPoints count] == 1)
      [displayPath moveToPoint: GRpointZoom(aPoint, zmFactor)];
}

- (void)addLineToPoint:(NSPoint)aPoint
{
  GRBezierControlPoint *mtopoint, *prevpoint;
  GRBezierHandle handle;
  
  [self addControlAtPoint: aPoint];
  mtopoint = [controlPoints objectAtIndex: 0];
  prevpoint = [controlPoints objectAtIndex: [controlPoints count] -2];

  if([prevpoint isActiveHandle])
    {
      handle = [prevpoint bzHandle];
      [displayPath curveToPoint: [(GRBezierControlPoint *)currentPoint center]
              controlPoint1: handle.firstHandle
              controlPoint2: [(GRBezierControlPoint *)currentPoint center]];
      [self confirmNewCurve];
      return;
    }
  
  if([self isPoint: (GRBezierControlPoint *)currentPoint onPoint: mtopoint])
    {
      [currentPoint moveToPoint: [mtopoint center]];
      [displayPath lineToPoint: GRpointZoom([mtopoint center], zmFactor)];
      [(GRBezierPathEditor *)editor setIsDone:YES];
    }
  else
    {
      [displayPath lineToPoint: GRpointZoom(aPoint, zmFactor)];
    }
}

- (void)addCurveWithBezierHandlePosition:(NSPoint)handlePos
{
  GRBezierControlPoint *mtopoint;
  GRBezierHandle handle1, handle2;
  NSBezierPathElement type;
  NSPoint pts[3];

  mtopoint = [controlPoints objectAtIndex: 0];
  if([self isPoint: (GRBezierControlPoint *)currentPoint onPoint: mtopoint] && [controlPoints count] != 1)
    {
      if(!calculatingHandles)
        {
          [currentPoint moveToPoint:[mtopoint center]];
        }
      else
        {
          [mtopoint calculateBezierHandles: handlePos];
          type = [displayPath elementAtIndex: 1];
          if(type == NSCurveToBezierPathElement)
            {
              [displayPath elementAtIndex: 1 associatedPoints: pts];
              pts[0] = GRpointZoom([mtopoint bzHandle].firstHandle, zmFactor);
              
              [displayPath setAssociatedPoints: pts atIndex: 1];           
            }
          else 
            {
              [self remakePath];
            }
        }
    }
  
    [(GRBezierControlPoint *)currentPoint calculateBezierHandles: handlePos];
    if([controlPoints count] == 1)
      return;
    
    handle1 = [[controlPoints objectAtIndex: [controlPoints count] -2] bzHandle];
    handle2 = [(GRBezierControlPoint *)currentPoint bzHandle];

    if(calculatingHandles)
      {
        pts[0] = GRpointZoom(handle1.firstHandle, zmFactor);
        pts[1] = GRpointZoom(handle2.secondHandle, zmFactor);
        pts[2] = GRpointZoom([(GRBezierControlPoint *)currentPoint center], zmFactor);
        [displayPath setAssociatedPoints: pts atIndex: [controlPoints count] -1];
      }
    else
      {
        [displayPath curveToPoint: GRpointZoom([(GRBezierControlPoint *)currentPoint center], zmFactor)
		controlPoint1: GRpointZoom(handle1.firstHandle, zmFactor)
		controlPoint2: GRpointZoom(handle2.secondHandle, zmFactor)];
        calculatingHandles = YES;
      }
}

- (void)subdividePathAtPoint:(NSPoint)p splitIt:(BOOL)split
{
    GRBezierControlPoint *ncp, *prevcp, *nextcp, *cp = nil;
    GRBezierHandle handle1, handle2;
    hitData hitdata;
    NSPoint pp[81], newpp[7];
    int i;
    NSUInteger pcount, index;
    double y, s, ax, ay;

    pcount = 0;
    y = (int)p.y -4;
    while(pcount < 81) {
        for(i = -4; i <= 4; i++)
        {
            pp[pcount].x = (int)p.x + i;
            pp[pcount].y = y;
            pcount++;
        }
        y++;
    }

    for(i = 0; i < 81; i++)
    {
        hitdata = [self hitDataOfPathSegmentOwningPoint: p];
        cp = hitdata.cp;
        if(cp)
            break;
    }
    if(cp == nil)
        return;

    index = [self indexOfPoint: cp];
    if (index == NSNotFound)
      return;
    if (index > 0)
      index--;
    
    ncp = [[GRBezierControlPoint alloc] initAtPoint: hitdata.p
                                          forPath: self zoomFactor: zmFactor];
    [controlPoints insertObject: ncp atIndex: index];
    [ncp select];
    currentPoint = ncp;
    [ncp release];

    if(index == 0)
        prevcp = [controlPoints objectAtIndex: [controlPoints count] -1];
    else
        prevcp = [controlPoints objectAtIndex: index -1];

    nextcp = [controlPoints objectAtIndex: index +1];

    s = 1 - hitdata.t;

    newpp[0].x = [prevcp center].x;
    newpp[0].y = [prevcp center].y;
    newpp[6].x = [nextcp center].x;
    newpp[6].y = [nextcp center].y;

    handle1 = [prevcp bzHandle];
    handle2 = [nextcp bzHandle];

    ax = s * handle1.firstHandle.x + hitdata.t * handle2.secondHandle.x;
    ay = s * handle1.firstHandle.y + hitdata.t * handle2.secondHandle.y;

    newpp[1].x = s * newpp[0].x + hitdata.t * handle1.firstHandle.x;
    newpp[1].y = s * newpp[0].y + hitdata.t * handle1.firstHandle.y;
    newpp[2].x = s * newpp[1].x + hitdata.t * ax;
    newpp[2].y = s * newpp[1].y + hitdata.t * ay;

    newpp[5].x = s *  newpp[2].x + hitdata.t * newpp[6].x;
    newpp[5].y = s *  newpp[2].y + hitdata.t * newpp[6].y;
    newpp[4].x = s * ax + hitdata.t * newpp[5].x;
    newpp[4].y = s * ay + hitdata.t * newpp[5].y;

    newpp[3].x = s * newpp[2].x + hitdata.t * newpp[4].x;
    newpp[3].y = s * newpp[2].y + hitdata.t * newpp[4].y;


    NSLog(@"%i %i - %i %i", (int)[(GRBezierControlPoint *)currentPoint center].x,
           (int)[(GRBezierControlPoint *)currentPoint center].y, (int)newpp[3].x, (int)newpp[3].y);


    [prevcp calculateBezierHandles: newpp[1]];
    [(GRBezierControlPoint *)currentPoint calculateBezierHandles: newpp[4]];
    //	[nextcp calculateBezierHandles: newpp[5]];

    [self remakePath];
}

- (void)deletePoint:(GRBezierControlPoint *)p
{
  NSUInteger i;
  GRBezierControlPoint *cpToDelete;

  if ([controlPoints count] < 2)
    return;

  i = 0;
  cpToDelete = NULL;
  while (i < [controlPoints count] && cpToDelete == NULL)
    {
      GRBezierControlPoint *cp;
      
      cp = [controlPoints objectAtIndex:i];
      if (cp == p)
        cpToDelete = cp;
      else
        i++;
    }

  [controlPoints removeObjectAtIndex:i];
  [self remakePath];
}

- (BOOL)isPoint:(GRBezierControlPoint *)cp1 onPoint:(GRBezierControlPoint *)cp2
{
  return pointInRect([cp2 centerRect], [cp1 center]);
}

- (GRBezierControlPoint *)pointOnPoint:(GRBezierControlPoint *)aPoint
{
  GRBezierControlPoint *cp, *ponpoint = nil;
  NSUInteger i;

  for(i = 0; i < [controlPoints count]; i++)
    {
      cp = [controlPoints objectAtIndex: i];
      if([self isPoint: aPoint onPoint: cp] && (aPoint != cp))
        {
          ponpoint = cp;
          break;
        }
    }
  
  return ponpoint;
}

- (void)confirmNewCurve
{
  if (!controlPoints || [controlPoints count] == 0)
    return;
  calculatingHandles = NO;
  if([controlPoints count] == 1)
    return;
  if (currentPoint == nil)
    [(GRBezierPathEditor *)editor setIsDone:YES];
  else if([self isPoint: (GRBezierControlPoint *)currentPoint onPoint: [controlPoints objectAtIndex: 0]])
    [(GRBezierPathEditor *)editor setIsDone:YES];
  
  [self remakePath];
}

- (void)remakePath
{
  GRBezierControlPoint *cp, *prevcp, *mtopoint;
  NSUInteger i;

  [path removeAllPoints];
  [displayPath removeAllPoints];
  if (!controlPoints || [controlPoints count] == 0)
    return;

  mtopoint = [controlPoints objectAtIndex: 0];
  [path moveToPoint: [mtopoint center]];
  [displayPath moveToPoint: GRpointZoom([mtopoint center], zmFactor)];
  for(i = 1; i < [controlPoints count]; i++)
    {
      GRBezierHandle handle1, handle2;
      BOOL isLine;

      cp = [controlPoints objectAtIndex: i];
      prevcp = [controlPoints objectAtIndex: i -1];
      handle1 = [prevcp bzHandle];
      handle2 = [cp bzHandle];

      /* we have a line if the start and end control points have respectively
         right and left center-coincident handles */
      isLine = NO;
      if (NSEqualPoints(handle1.center, handle1.secondHandle) && NSEqualPoints(handle2.center, handle2.firstHandle))
        isLine = YES;
      
      if (isLine)
        {
          [path lineToPoint: [cp center]];
          [displayPath lineToPoint: GRpointZoom([cp center], zmFactor)];
        }
      else
        {
          [path curveToPoint: [cp center]
                 controlPoint1: handle1.firstHandle
                 controlPoint2: handle2.secondHandle];
          [displayPath curveToPoint: GRpointZoom([cp center], zmFactor)
                 controlPoint1: GRpointZoom(handle1.firstHandle, zmFactor)
                 controlPoint2: GRpointZoom(handle2.secondHandle, zmFactor)];
          [cp setPointPosition:GRPointMiddle];
        }

      if([self isPoint: cp onPoint: mtopoint])
	[(GRBezierPathEditor *)editor setIsDone:YES];
    }

  /* if the path is open, set the Start ad End points controls */
  if (!NSEqualPoints([(GRBezierControlPoint *)[controlPoints objectAtIndex:0] center], [(GRBezierControlPoint *)[controlPoints objectAtIndex:[controlPoints count]-1] center]))
    {
      [[controlPoints objectAtIndex:0] setPointPosition:GRPointStart];
      [[controlPoints objectAtIndex:[controlPoints count]-1] setPointPosition:GRPointEnd];
    }
}


- (hitData)hitDataOfPathSegmentOwningPoint:(NSPoint)pt
{
    hitData hitdata;
    GRBezierControlPoint *cp, *prevcp;
    GRBezierHandle handle1, handle2;
    NSPoint p, bp;
    NSRect r;
    double t;
    NSUInteger i;

    hitdata.cp = nil;
    hitdata.t = 0;
    hitdata.p = NSZeroPoint;

    r = NSMakeRect((int)pt.x -4, (int)pt.y -4, 8, 8);

    for(i = 0; i < [controlPoints count]; i++)
    {
        cp = [controlPoints objectAtIndex: i];

        if(pointInRect([cp centerRect], pt))
            return hitdata;

        if(i == 0)
            prevcp = [controlPoints objectAtIndex: [controlPoints count] -1];
        else
            prevcp = [controlPoints objectAtIndex: i -1];

        handle1 = [prevcp bzHandle];
        handle2 = [cp bzHandle];

        bp.x = [prevcp center].x;
        bp.y = [prevcp center].y;
        for(t = k; t <= 1+k; t += k) {
            p.x = (bp.x+t*(-bp.x*3+t*(3*bp.x-bp.x*t)))
            +t*(3*handle1.firstHandle.x+t*
                (-6*handle1.firstHandle.x+handle1.firstHandle.x*3*t))
            +t*t*(handle2.secondHandle.x*3-handle2.secondHandle.x*3*t)
            +[cp center].x*t*t*t;
            p.y = (bp.y+t*(-bp.y*3+t*(3*bp.y-bp.y*t)))
                +t*(3*handle1.firstHandle.y+t*
                    (-6*handle1.firstHandle.y+handle1.firstHandle.y*3*t))
                +t*t*(handle2.secondHandle.y*3-handle2.secondHandle.y*3*t)
                +[cp center].y*t*t*t;

            if(pointInRect(r, p))
            {
                hitdata.cp = cp;
                hitdata.p.x = p.x;
                hitdata.p.y = p.y;
                hitdata.t = t - k;
                return hitdata;
            }
        }
    }

    return hitdata;
}

- (void)moveAddingCoordsOfPoint:(NSPoint)p
{
  NSUInteger i;

    for(i = 0; i < [controlPoints count]; i++)
    {
        GRBezierControlPoint *cp = [controlPoints objectAtIndex: i];
        [cp moveToPoint: NSMakePoint([cp center].x + p.x, [cp center].y + p.y)];
    }
    [self remakePath];
}

- (void)setZoomFactor:(CGFloat)f
{
  NSUInteger i;

    zmFactor = f;
    for(i = 0; i < [controlPoints count]; i++)
        [[controlPoints objectAtIndex: i] setZoomFactor: zmFactor];

    [self remakePath];
}

- (BOOL)objectHitForSelection:(NSPoint)p
{
  return [self onPathBorder:p];
}

/** Returns yes if the Point lies on a control point */
- (BOOL)onControlPoint:(NSPoint)p
{
  NSInteger i;
  GRBezierControlPoint *cp;
  GRBezierHandle handle;

  for(i = 0; i < [controlPoints count]; i++)
    {
      cp = [controlPoints objectAtIndex: i];
      handle = [cp bzHandle];
      if(pointInRect(handle.centerRect, p))
	return YES;
    }

  return NO;
}

/** checks if a given point is a control point or a point on the path border

  ATTENTION: for closed path it retuns also YES if the point is inside the area
*/
- (BOOL)onPathBorder:(NSPoint)p
{
  if ([self onControlPoint:p])
    return YES;

  /* mypath represents the Path in the current zoom, so it needs to be converted */
  if([displayPath containsPoint: GRpointZoom(p, zmFactor)])
    return YES;
  
  return NO;
}

- (GRBezierControlPoint *)firstPoint
{
    return (GRBezierControlPoint *)[controlPoints objectAtIndex: 0];
}



- (GRBezierControlPoint *)lastPoint
{
    return (GRBezierControlPoint *)[controlPoints objectAtIndex: [controlPoints count] -1];
}

- (NSUInteger)indexOfPoint:(GRBezierControlPoint *)aPoint
{
  NSUInteger i;
  NSUInteger r;
  BOOL found;

  r = NSNotFound;
  found = NO;

  i = 0;
  while (i < [controlPoints count] && !found)
    {
      if([controlPoints objectAtIndex: i] == aPoint)
        found = YES;
      i++;
    }

  if(found)
    r = i;
  
  return r;
}




/* override for editor handling */
- (void)setLocked:(BOOL)value
{
    [super setLocked:value];
    
    if(!locked)
        [editor unselect];
    else
        [(GRBezierPathEditor *)editor selectAsGroup];
}


- (void)draw
{
  GRBezierControlPoint *cp;
  NSUInteger i;
  NSBezierPath *bzp;
  CGFloat linew;
  NSBezierPath *pathToDraw;
  
  if(![controlPoints count] || !visible)
    return;

  linew =  linewidth;
  pathToDraw = path;
  if ([[NSGraphicsContext currentContext] isDrawingToScreen])
    {
      linew = linewidth * zmFactor;
      pathToDraw = displayPath;
    }
    
  bzp = [NSBezierPath bezierPath];
  if(filled)
    {
      [NSGraphicsContext saveGraphicsState];
      [fillColor set];
      [pathToDraw fill];
      [NSGraphicsContext restoreGraphicsState];
    }
  if(stroked)
    {
      [NSGraphicsContext saveGraphicsState];
      [pathToDraw setLineJoinStyle:linejoin];
      [pathToDraw setLineCapStyle:linecap];
      [pathToDraw setLineWidth:linew];
      [strokeColor set];
      [pathToDraw stroke];
      [NSGraphicsContext restoreGraphicsState];
    }
    
    
  [bzp setLineWidth:1];
  if([(GRBezierPathEditor *)editor isGroupSelected])
    {
      for(i = 0; i < [controlPoints count]; i++)
        {
	  cp = [controlPoints objectAtIndex: i];
          [cp drawControlAsSelected:YES];
        }
    }
  
  if ([[NSGraphicsContext currentContext] isDrawingToScreen])
    [editor draw];
}

@end
