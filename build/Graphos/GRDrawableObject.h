/*
 Project: Graphos
 GRDrawableObject.h

 Copyright (C) 2008-2015 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2008-02-25

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
 * DrawableObject  is a superclass for every graphics object of Graphos.
 * It is abstract and created to standardize behaviour, it is not instantiatable itself.
 */

#import <Foundation/Foundation.h>
#import <AppKit/NSColor.h>

#ifndef MAC_OS_X_VERSION_10_4
#define MAC_OS_X_VERSION_10_4 1040
#endif

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4) && !defined(CGFloat)
#define NSUInteger unsigned
#define NSInteger int
#define CGFloat float
#endif

@class GRDocView;
@class GRObjectEditor;

@interface GRDrawableObject : NSObject <NSCopying>
{
  GRDocView *docView;
  GRObjectEditor *editor;
  BOOL visible, locked;
  CGFloat zmFactor;
  BOOL stroked, filled;
  NSColor *fillColor;
  NSColor *strokeColor;
}

/** return a fresh allocated editor corresponding to the current object */
- (GRObjectEditor *)allocEditor;

- (id)initInView:(GRDocView *)aView zoomFactor:(CGFloat)zf withProperties:(NSDictionary *)properties;
- (id)initFromData:(NSDictionary *)description inView:(GRDocView *)aView zoomFactor:(CGFloat)zf;

/**
 * Returns a description of the object, used for saving to file.
 * This method must be overridden by each drawable object.
 */
- (NSDictionary *)objectDescription;

/** Returns if the point should select the object.
    For example, for a Box it checks if the point is within the Rect,
    for a Bezier path if the point is on its path */
- (BOOL)objectHitForSelection:(NSPoint)p;

- (GRDocView *)view;
- (GRObjectEditor *)editor;

/** returns if the object is currently visible */
- (BOOL)visible;

/** sets if the object is visible */
- (void)setVisible:(BOOL)value;

/** returns if the object is locked */
- (BOOL)locked;

/** locks an object */
- (void)setLocked:(BOOL)value;

/** current zoom factor */
- (CGFloat)zoomFactor;

/** the zoom factor is used to draw an object in the proper size
 * when zooming in our out the view
 */
- (void)setZoomFactor:(CGFloat)f;

- (void)setStrokeColor:(NSColor *)c;
- (NSColor *)strokeColor;
- (void)setFillColor:(NSColor *)c;
- (NSColor *)fillColor;
- (void)setFilled:(BOOL)value;
- (BOOL)isFilled;
- (void)setStroked:(BOOL)value;
- (BOOL)isStroked;

/**
 * Draws the object in the view. Called from GRDocView.
 * This method must be subclassed.
 */ 
- (void)draw;

@end
