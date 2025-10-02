/*
 Project: Graphos
 GRPathObject.h

 Copyright (C) 2008-2018 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2008-03-14

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

/**
 * PathObject is a superclass for every graphics object consisting of
 * a fillable path. It is itself a subclass of GRDrawableObject.
 * It is abstract and created to standardize behaviour, it is not instantiatable itself.
 * Instances are like BezierPaths and Boxes.
 */

#import <Foundation/Foundation.h>
#import <AppKit/NSBezierPath.h>
#import "GRDrawableObject.h"
#import "GRObjectControlPoint.h"

@interface GRPathObject : GRDrawableObject
{
  // object bezier path
  NSBezierPath *path;

  // already zoomed bezier path for faster drawing
  NSBezierPath *displayPath;
  
  CGFloat linewidth;
  CGFloat flatness;
  CGFloat miterlimit;
  NSLineJoinStyle linejoin;
  NSLineCapStyle linecap;
  GRObjectControlPoint *currentPoint;
}

- (void)setLineWidth:(CGFloat)width;
- (CGFloat)lineWidth;

- (void)setFlat:(CGFloat)flat;
- (CGFloat)flatness;

- (void)setLineJoin:(NSLineJoinStyle)join;
- (NSLineJoinStyle)lineJoin;

- (void)setLineCap:(NSLineCapStyle)cap;
- (NSLineCapStyle)lineCap;

- (void)setMiterLimit:(CGFloat)limit;
- (CGFloat)miterLimit;

/** sets the current selected control point */
- (void)setCurrentPoint:(GRObjectControlPoint *)aPoint;

/** returns the currently selected control point */
- (GRObjectControlPoint *)currentPoint;

/** recompute the path object based on its controlpoints */
- (void)remakePath;

@end
