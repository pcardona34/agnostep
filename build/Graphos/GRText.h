/*
 Project: Graphos
 GRText.h

 Copyright (C) 2000-2013 GNUstep Application Project

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
#import "GRDrawableObject.h"

@class GRDocView;

@interface GRText : GRDrawableObject
{
    NSString *str;
    NSDictionary *parAttributes;
    NSPoint pos;
    NSSize size;
    NSRect bounds;
    float scalex, scaley;
    float rotation;
    NSRect selRect;
}

- (id)initInView:(GRDocView *)aView
         atPoint:(NSPoint)p
      zoomFactor:(CGFloat)zf
  withProperties:(NSDictionary *)properties
      openEditor:(BOOL)openedit;

- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(CGFloat)zf;


- (void)setString:(NSString *)aString attributes:(NSDictionary *)attrs;

- (void)edit;

- (void)moveAddingCoordsOfPoint:(NSPoint)p;

- (void)setZoomFactor:(CGFloat)f;

- (void)setScalex:(float)x scaley:(float)y;

- (void)setRotation:(float)r;

- (void)draw;


- (NSBezierPath *) makePathFromString: (NSString *) aString
                              forFont: (NSFont *) aFont
                              atPoint: (NSPoint) aPoint;
@end

