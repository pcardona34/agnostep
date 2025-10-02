/*
 Project: Graphos
 GRObjectControlPoint.h

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

#import <Foundation/Foundation.h>

#ifndef MAC_OS_X_VERSION_10_4
#define MAC_OS_X_VERSION_10_4 1040
#endif

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4) && !defined(CGFloat)
#define NSUInteger unsigned
#define NSInteger int
#define CGFloat float
#endif

@class GRBoxEditor;


@interface GRObjectControlPoint : NSObject <NSCopying>
{
  BOOL isActiveHandle;
  BOOL isSelect;
  NSPoint center;
  NSRect centerRect;
  CGFloat zmFactor;
}

- (id)initAtPoint:(NSPoint)aPoint zoomFactor:(CGFloat)zf;

- (void)moveToPoint:(NSPoint)p;

- (void)setZoomFactor:(CGFloat)f;

- (NSPoint)center;
- (NSRect)centerRect;

- (void)drawControlAsSelected: (BOOL)sel;
- (void)drawControl;


- (void)select;
- (void)unselect;
- (BOOL)isSelect;
- (BOOL)isActiveHandle;

@end
