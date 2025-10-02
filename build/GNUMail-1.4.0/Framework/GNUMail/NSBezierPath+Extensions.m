/*
**  NSBezierPath+Extensions.m
**
**  Copyright (c) 2002-2005 Francis Lachapelle
**
**  Author: Francis Lachapelle <francis@Sophos.ca>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "NSBezierPath+Extensions.h"

//
// Simple category of NSBezierPath to easily draw a rectangle with
// custom rounded corners.
//
@implementation NSBezierPath (GNUMailBezierPathExtensions)

- (void) appendBezierPathWithRoundedRectangle: (NSRect) theRect
                                   withRadius: (float) theRadius
{
  NSPoint topMid = NSMakePoint(NSMidX(theRect), NSMaxY(theRect));
  NSPoint topLeft = NSMakePoint(NSMinX(theRect), NSMaxY(theRect));
  NSPoint topRight = NSMakePoint(NSMaxX(theRect), NSMaxY(theRect));
  NSPoint bottomRight = NSMakePoint(NSMaxX(theRect), NSMinY(theRect));
  
  [self moveToPoint: topMid];
  [self appendBezierPathWithArcFromPoint: topLeft
	toPoint: theRect.origin
	radius: theRadius];
  [self appendBezierPathWithArcFromPoint: theRect.origin
	toPoint: bottomRight
	radius: theRadius];
  [self appendBezierPathWithArcFromPoint: bottomRight
	toPoint: topRight
	radius: theRadius];
  [self appendBezierPathWithArcFromPoint: topRight
	toPoint: topLeft
	radius: theRadius];
  [self closePath];
}

@end
