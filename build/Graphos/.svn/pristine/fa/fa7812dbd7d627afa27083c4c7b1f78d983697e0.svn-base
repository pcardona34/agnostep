/*
 Project: Graphos
 GRBezierControlPoint.h

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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GRObjectControlPoint.h"

enum
{
  GRPointMiddle = 0,
  GRPointStart = 1,
  GRPointEnd = 2
}; typedef NSUInteger GRPointTangentStyle;

typedef struct
{
    NSPoint firstHandle;
    NSRect firstHandleRect;
    NSPoint center;
    NSRect centerRect;
    NSPoint secondHandle;
    NSRect secondHandleRect;
} GRBezierHandle;

@class GRBezierPath;

@interface GRBezierControlPoint : GRObjectControlPoint
{
  GRBezierPath *path;
  GRBezierHandle bzHandle;
  BOOL symmetricalHandles;
  GRPointTangentStyle pointPosition;
}

- (id)initAtPoint:(NSPoint)aPoint
          forPath:(GRBezierPath *)aPath
       zoomFactor:(CGFloat)zf;

- (void)setPath:(GRBezierPath *)thePath;
- (void)calculateBezierHandles:(NSPoint)draggedHandlePosition;
- (void)moveToPoint:(NSPoint)p;
- (void)moveBezierHandleToPosition:(NSPoint)newp oldPosition:(NSPoint)oldp;
- (void)overlapHandles;
- (void)extractHandles;

- (GRBezierHandle)bzHandle;
- (void)setBezierHandle:(GRBezierHandle)handle;
- (void)drawHandle;

- (void)select;
- (void)unselect;
- (BOOL)isSelect;
- (BOOL)isActiveHandle;
- (BOOL)symmetricalHandles;
- (void)setSymmetricalHandles:(BOOL)flag;
- (void)setPointPosition:(GRPointTangentStyle)pPos;

@end

