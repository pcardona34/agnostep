/*
 Project: Graphos
 GRBezierPath.h

 Copyright (C) 2000-2013 GNUstep Application Project

 Author: Enrico Sersale (original implementation)
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GRPathObject.h"
#import "GRBezierControlPoint.h"


typedef struct
{
    GRBezierControlPoint *cp;
    NSPoint p;
    double t;
} hitData;

@interface GRBezierPath : GRPathObject
{
    BOOL calculatingHandles;
    NSMutableArray *controlPoints;
}

- (void)addControlAtPoint:(NSPoint)aPoint;
- (void)addLineToPoint:(NSPoint)aPoint;
- (void)addCurveWithBezierHandlePosition:(NSPoint)handlePos;

- (void)subdividePathAtPoint:(NSPoint)p splitIt:(BOOL)split;
- (void)deletePoint:(GRBezierControlPoint *)p;

- (NSMutableArray *)controlPoints;
- (BOOL)isPoint:(GRBezierControlPoint *)cp1 onPoint:(GRBezierControlPoint *)cp2;
- (GRBezierControlPoint *)pointOnPoint:(GRBezierControlPoint *)aPoint;
- (void)confirmNewCurve;

- (hitData)hitDataOfPathSegmentOwningPoint:(NSPoint)pt;

- (void)moveAddingCoordsOfPoint:(NSPoint)p;

- (void)setZoomFactor:(CGFloat)f;

- (BOOL)onControlPoint:(NSPoint)p;
- (BOOL)onPathBorder:(NSPoint)p;

- (GRBezierControlPoint *)firstPoint;
- (GRBezierControlPoint *)lastPoint;

- (NSUInteger)indexOfPoint:(GRBezierControlPoint *)aPoint;


@end

