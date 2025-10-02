/*
 Project: Graphos
 GRObjectControlPoint.m

 Copyright (C) 2007-2013 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2007-11-18

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

#import "GRObjectControlPoint.h"


@implementation GRObjectControlPoint

- (id)initAtPoint:(NSPoint)aPoint zoomFactor:(CGFloat)zf
{
    self = [super init];
    if(self)
    {
        center = aPoint;
        centerRect = NSMakeRect(aPoint.x-3, aPoint.y-3, 6, 6);
        isSelect = NO;
        zmFactor = zf;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    GRObjectControlPoint *objCopy;

    objCopy = [[[self class] allocWithZone:zone] init];
    objCopy->isActiveHandle = isActiveHandle;
    objCopy->isSelect = isSelect;
    objCopy->center = NSMakePoint (center.x, center.y);
    objCopy->centerRect = NSMakeRect (centerRect.origin.x, centerRect.origin.y, centerRect.size.width, centerRect.size.height);
    objCopy->zmFactor = zmFactor;

    return objCopy;
}


- (void)moveToPoint:(NSPoint)p
{
  center.x = p.x;
  center.y = p.y;
  centerRect = NSMakeRect(center.x-3, center.y-3, 6, 6);
}

- (void)drawControlAsSelected: (BOOL)sel
{
  NSPoint centerZ;
  NSRect centerRectZ;
  NSRect innerRectZ;

  centerZ.x = center.x * zmFactor;
  centerZ.y = center.y * zmFactor;
  centerRectZ = NSMakeRect(centerZ.x-3, centerZ.y-3, 6, 6);
  innerRectZ = NSMakeRect(centerZ.x-2, centerZ.y-2, 4, 4);

  [[NSColor blackColor] set];
  NSRectFill(centerRectZ);

  if (sel)
    {
      [[NSColor whiteColor] set];
      NSRectFill(innerRectZ);
    }
}

- (void)drawControl
{
  [self drawControlAsSelected:isSelect];
}

- (void)setZoomFactor:(CGFloat)f
{
  //  center.x = center.x / zmFactor * f;
  //  center.y = center.y / zmFactor * f;
  //  centerRect = NSMakeRect(center.x-3, center.y-3, 6, 6);
  zmFactor = f;
}

- (NSPoint)center
{
    return center;
}

- (NSRect)centerRect
{
  return centerRect;
}

- (void)select
{
    isSelect = YES;
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


@end
