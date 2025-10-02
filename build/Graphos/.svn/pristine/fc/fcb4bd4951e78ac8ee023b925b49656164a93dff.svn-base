/*
 Project: Graphos
 GRCircle.m

 Copyright (C) 2009-2018 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2009-12-27

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

#import <AppKit/NSColor.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSGraphicsContext.h>
#import "GRCircle.h"
#import "GRCircleEditor.h"
#import "GRFunctions.h"

@implementation GRCircle

- (GRObjectEditor *)allocEditor
{
  return [[GRCircleEditor alloc] initEditor:self];
}

/** initializes by using the properties array as defaults */
- (id)initInView:(GRDocView *)aView
      zoomFactor:(CGFloat)zf
  withProperties:(NSDictionary *)properties
{
  self = [super initInView:aView zoomFactor:zf withProperties:properties];
  if(self)
    {
      id obj;

      pos = NSMakePoint([[properties objectForKey: @"posx"]  floatValue],
			[[properties objectForKey: @"posy"]  floatValue]);
      size = NSMakeSize([[properties objectForKey: @"width"]  floatValue],
			[[properties objectForKey: @"height"]  floatValue]);
      bounds = GRMakeBounds(pos.x, pos.y, size.width, size.height);

      isCircle = NO;
      obj = [properties objectForKey: @"circle"];
      if (obj)      
	isCircle = [obj boolValue];

      rotation = 0;
      obj = [properties objectForKey: @"rotation"];
      if (obj)      
	rotation = [obj floatValue];

      startControlPoint = [[GRObjectControlPoint alloc] initAtPoint: pos zoomFactor:zf];
      endControlPoint = [[GRObjectControlPoint alloc] initAtPoint: NSMakePoint(pos.x + size.width, pos.y + size.height) zoomFactor:zf];
      [self setZoomFactor: zf];
    }

  return self;
}

/** initializes all parameters from a description dictionary */
- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(CGFloat)zf
{
  self = [super initFromData:description inView:aView zoomFactor:zf];
  if(self)
    {
      id obj;

      pos = NSMakePoint([[description objectForKey: @"posx"]  floatValue],
			[[description objectForKey: @"posy"]  floatValue]);
      size = NSMakeSize([[description objectForKey: @"width"]  floatValue],
			[[description objectForKey: @"height"]  floatValue]);
      bounds = GRMakeBounds(pos.x, pos.y, size.width, size.height);

      isCircle = NO;
      obj = [description objectForKey: @"circle"];
      if (obj)      
	isCircle = [obj boolValue];

      rotation = 0;
      obj = [description objectForKey: @"rotation"];
      if (obj)      
	rotation = [obj floatValue];

      startControlPoint = [[GRObjectControlPoint alloc] initAtPoint: pos zoomFactor:zf];
      endControlPoint = [[GRObjectControlPoint alloc] initAtPoint: NSMakePoint(pos.x + size.width, pos.y + size.height) zoomFactor:zf];
      [self setZoomFactor: zf];
    }
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    GRCircle *objCopy;

    objCopy = [super copyWithZone:zone];

    objCopy->startControlPoint = [[GRObjectControlPoint alloc] initAtPoint: pos zoomFactor:zmFactor];
    objCopy->endControlPoint = [[GRObjectControlPoint alloc] initAtPoint: NSMakePoint(pos.x + size.width, pos.y + size.height) zoomFactor:zmFactor];


    objCopy->pos = NSMakePoint(pos.x, pos.y);
    objCopy->size = NSMakeSize(size.width, size.height);
    objCopy->bounds = NSMakeRect(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    objCopy->boundsZ = NSMakeRect(boundsZ.origin.x, boundsZ.origin.y, boundsZ.size.width, boundsZ.size.height);
    objCopy->rotation = rotation;
    objCopy->isCircle = isCircle;

    return objCopy;
}

- (void)dealloc
{
    [startControlPoint release];
    [endControlPoint release];
    [super dealloc];
}

- (NSDictionary *)objectDescription
{
    NSMutableDictionary *dict;
    NSString *str;
    float strokeCol[3];
    float fillCol[3];
    float strokeAlpha;
    float fillAlpha;

    strokeCol[0] = [strokeColor redComponent];
    strokeCol[1] = [strokeColor greenComponent];
    strokeCol[2] = [strokeColor blueComponent];
    strokeAlpha = [strokeColor alphaComponent];

    fillCol[0] = [fillColor redComponent];
    fillCol[1] = [fillColor greenComponent];
    fillCol[2] = [fillColor blueComponent];
    fillAlpha = [fillColor alphaComponent];

    dict = [NSMutableDictionary dictionaryWithCapacity: 1];
    [dict setObject: @"circle" forKey: @"type"];

    str = [NSString stringWithFormat: @"%i", isCircle];
    [dict setObject: str forKey: @"circle"];

    str = [NSString stringWithFormat: @"%.3f", pos.x];
    [dict setObject: str forKey: @"posx"];
    str = [NSString stringWithFormat: @"%.3f", pos.y];
    [dict setObject: str forKey: @"posy"];
    
    str = [NSString stringWithFormat: @"%.3f", size.width];
    [dict setObject: str forKey: @"width"];
    str = [NSString stringWithFormat: @"%.3f", size.height];
    [dict setObject: str forKey: @"height"];

    str = [NSString stringWithFormat: @"%.3f", flatness];
    [dict setObject: str forKey: @"flatness"];
    str = [NSString stringWithFormat: @"%i", linejoin];
    [dict setObject: str forKey: @"linejoin"];
    str = [NSString stringWithFormat: @"%i", linecap];
    [dict setObject: str forKey: @"linecap"];
    str = [NSString stringWithFormat: @"%.3f", miterlimit];
    [dict setObject: str forKey: @"miterlimit"];
    str = [NSString stringWithFormat: @"%.3f", linewidth];
    [dict setObject: str forKey: @"linewidth"];
    str = [NSString stringWithFormat: @"%i", stroked];
    [dict setObject: str forKey: @"stroked"];
    str = [NSString stringWithFormat: @"%.3f %.3f %.3f",
        strokeCol[0], strokeCol[1], strokeCol[2]];
    [dict setObject: str forKey: @"strokecolor"];
    str = [NSString stringWithFormat: @"%.3f", strokeAlpha];
    [dict setObject: str forKey: @"strokealpha"];
    str = [NSString stringWithFormat: @"%i", filled];
    [dict setObject: str forKey: @"filled"];
    str = [NSString stringWithFormat: @"%.3f %.3f %.3f",
        fillCol[0], fillCol[1], fillCol[2]];
    [dict setObject: str forKey: @"fillcolor"];
    str = [NSString stringWithFormat: @"%.3f", fillAlpha];
    [dict setObject: str forKey: @"fillalpha"];
    str = [NSString stringWithFormat: @"%i", visible];
    [dict setObject: str forKey: @"visible"];
    str = [NSString stringWithFormat: @"%i", locked];
    [dict setObject: str forKey: @"locked"];

    return dict;
}

- (BOOL)circle
{
  return isCircle;
}

- (void)setCircle:(BOOL)flag
{
  isCircle = flag;
}

- (void)setStartAtPoint:(NSPoint)aPoint
{
    pos = aPoint;
    [startControlPoint moveToPoint: aPoint];
    [startControlPoint select];
}

- (void)setEndAtPoint:(NSPoint)aPoint
{
  size.width = aPoint.x - pos.x;
  size.height = aPoint.y- pos.y;
  bounds = GRMakeBounds(pos.x, pos.y, size.width, size.height);
  [endControlPoint moveToPoint: aPoint];
  [endControlPoint select];
  
  boundsZ = GRMakeBounds(pos.x * zmFactor, pos.y * zmFactor, size.width * zmFactor, size.height * zmFactor);
}

- (void)remakePath
{
    [self setStartAtPoint:[startControlPoint center]];
    [self setEndAtPoint:[endControlPoint center]];
    [(GRCircleEditor *)editor setIsDone:YES];
}


- (void)setLocked:(BOOL)value
{
    [super setLocked:value];
    if(!locked)
        [(GRCircleEditor *)editor unselect];
    else
        [(GRCircleEditor *)editor selectAsGroup];
}

- (BOOL)objectHitForSelection:(NSPoint)p
{
  return (pointInRect(bounds, p));
}

- (BOOL)onControlPoint:(NSPoint)p
{
    if (pointInRect([startControlPoint centerRect], p))
        return YES;
    if (pointInRect([endControlPoint centerRect], p))
        return YES;
    return NO;
}

- (GRObjectControlPoint *) startControlPoint
{
    return startControlPoint;
}

- (GRObjectControlPoint *) endControlPoint
{
    return endControlPoint;
}


- (void)moveAddingCoordsOfPoint:(NSPoint)p
{
  pos.x += p.x;
  pos.y += p.y;
  bounds = GRMakeBounds(pos.x, pos.y, size.width, size.height);
  [startControlPoint moveToPoint: pos];
  [endControlPoint moveToPoint: NSMakePoint(pos.x + size.width, pos.y + size.height)];
  
  boundsZ = GRMakeBounds(pos.x * zmFactor, pos.y * zmFactor, size.width * zmFactor, size.height * zmFactor);
}

- (void)setZoomFactor:(CGFloat)f
{
    [super setZoomFactor:f];

    [startControlPoint setZoomFactor:f];
    [endControlPoint setZoomFactor:f];
    [self remakePath];
}

/** bounds accessor */
- (NSRect)bounds
{
    return bounds;
}

/** position accessor */
- (NSPoint) position
{
  return pos;
}

/** draws the object and calls the editor to draw itself afterwards */
- (void)draw
{
  NSBezierPath *bzp;
  NSPoint center;
  CGFloat radius;
  CGFloat w,h;
  CGFloat minLength;
  CGFloat linew;
  NSRect drawBounds;

  drawBounds = bounds;
  linew = linewidth;
  if ([[NSGraphicsContext currentContext] isDrawingToScreen])
    {
      drawBounds = boundsZ;
      linew = linewidth * zmFactor;
    }

  center = NSMakePoint(NSMidX(drawBounds), NSMidY(drawBounds));
  w = NSWidth(drawBounds);
  h = NSHeight(drawBounds);
  if (w > h)
    minLength = h;
  else
    minLength = w;
  radius = minLength / 2;

  bzp = [NSBezierPath bezierPath];
  if (isCircle)
    [bzp appendBezierPathWithArcWithCenter:center radius:radius startAngle:0 endAngle:360];
  else
    [bzp appendBezierPathWithOvalInRect: drawBounds];
    
  if(filled)
    {
      [NSGraphicsContext saveGraphicsState];
      [fillColor set];
      [bzp fill];
      [NSGraphicsContext restoreGraphicsState];
    }
  if(stroked)
    {
      [NSGraphicsContext saveGraphicsState];
      [bzp setLineJoinStyle:linejoin];
      [bzp setLineCapStyle:linecap];
      [bzp setLineWidth:linew];
      [strokeColor set];
      [bzp stroke]; 
      [NSGraphicsContext restoreGraphicsState];
    }
  
  if ([[NSGraphicsContext currentContext] isDrawingToScreen])
    [editor draw];
}


@end
