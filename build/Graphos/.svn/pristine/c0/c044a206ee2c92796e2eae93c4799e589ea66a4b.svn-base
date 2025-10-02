/*
 Project: Graphos
 GRBox.h

 Copyright (C) 2007-2013 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2007-09-21

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


#import <Foundation/Foundation.h>
#import <AppKit/NSBezierPath.h>
#import "GRPathObject.h"
#import "GRObjectControlPoint.h"

@interface GRBox : GRPathObject
{
  NSPoint    pos;
  NSSize     size;
  NSRect     bounds;

  NSRect     boundsZ;

  GRObjectControlPoint *startControlPoint;
  GRObjectControlPoint *endControlPoint;

  CGFloat rotation;
}

- (NSPoint) position;
- (BOOL)onControlPoint:(NSPoint)p;
- (void)setStartAtPoint:(NSPoint)aPoint;
- (void)setEndAtPoint:(NSPoint)aPoint;
- (GRObjectControlPoint *) startControlPoint;
- (GRObjectControlPoint *) endControlPoint;


@end
