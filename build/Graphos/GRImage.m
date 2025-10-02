/*
 Project: Graphos
 GRImage.m
 
 Copyright (C) 2015-2018 GNUstep Application Project
 
 Author: Ing. Riccardo Mottola
 
 Created: 2015-01-16
 
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

#import "GRImage.h"
#import "GRImageEditor.h"


#import <AppKit/AppKit.h>
#import "GRObjectEditor.h"
#import "GRFunctions.h"

@implementation GRImage

- (GRObjectEditor *)allocEditor
{
  return [[GRImageEditor alloc] initEditor:self];
}

/** initializes by using the properties array as defaults */
- (id)initInView:(GRDocView *)aView
      zoomFactor:(CGFloat)zf
      withProperties:(NSDictionary *)properties
{
  self = [super initInView:aView zoomFactor:zf withProperties:properties];
  if(self)
    {
      NSData *imgRepData;

      imgRepData = [properties objectForKey:@"imgrepdata"];
      if (imgRepData)
        {
          NSImage *img;
          NSLog(@"GRImage: we have an image representation");

          img = [[NSImage alloc] initWithData:imgRepData];
          [self setImage: img];
          [img release];
        }
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
      NSData *imgRepData;
      id obj;      

      pos = NSMakePoint([[description objectForKey: @"posx"]  floatValue],
			[[description objectForKey: @"posy"]  floatValue]);
      size = NSMakeSize([[description objectForKey: @"width"]  floatValue],
			[[description objectForKey: @"height"]  floatValue]);
      bounds = GRMakeBounds(pos.x, pos.y, size.width, size.height);

      rotation = 0;
      obj = [description objectForKey: @"rotation"];
      if (obj)      
	rotation = [obj floatValue];
      
      startControlPoint = [[GRObjectControlPoint alloc] initAtPoint: pos zoomFactor:zf];
      endControlPoint = [[GRObjectControlPoint alloc] initAtPoint: NSMakePoint(pos.x + size.width, pos.y + size.height) zoomFactor:zf];
      [self setZoomFactor: zf];

      imgRepData = [description objectForKey:@"imgrepdata"];
      if (imgRepData)
        {
          NSImage *img;
          NSLog(@"GRImage: we have an image representation");

          img = [[NSImage alloc] initWithData:imgRepData];
          [self setImage: img];
          [img release];
        }
    }
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  GRImage *objCopy;
  
  objCopy = [super copyWithZone:zone];
  
  objCopy->image = [image copy];
  objCopy->name = [name copy];
  
  return objCopy;
}

- (void)dealloc
{
  [image release];
  [name release];
  [super dealloc];
}

- (NSDictionary *)objectDescription
{
  NSMutableDictionary *dict;
  NSData *imgData;

  dict = (NSMutableDictionary *)[super objectDescription]; /* we know the superclass actually returns a mutable dict */
  [dict retain];
  
  [dict setObject: @"image" forKey: @"type"];

  imgData = [image TIFFRepresentation];
  
  [dict setObject:imgData forKey:@"imgrepdata"];
  [dict autorelease];
  return dict;
}

/** draws the object and calls the editor to draw itself afterwards */
- (void)draw
{
  NSBezierPath *bzp;
  CGFloat linew;
  NSRect drawBounds;

  drawBounds = bounds;
  linew = linewidth;
  if ([[NSGraphicsContext currentContext] isDrawingToScreen])
    {
      drawBounds = boundsZ;
      linew = linewidth * zmFactor;
    }
  
  bzp = [NSBezierPath bezierPath];
  [bzp appendBezierPathWithRect:drawBounds];
  if(filled)
    {
      [NSGraphicsContext saveGraphicsState];
      [fillColor set];
      [bzp fill];
      [NSGraphicsContext restoreGraphicsState];
    }
  
  [image drawInRect:drawBounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  
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

- (NSImage *)image
{
  return image;
}

- (void)setImage:(NSImage *)img
{
  if (img != image)
    {
      [image release];
      image = img;
      [image retain];
      originalSize = [image size];
      originalRatio = originalSize.width / originalSize.height;
    }
}

- (float)originalRatio
{
  return originalRatio;
}

@end
