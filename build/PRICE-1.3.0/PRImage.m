//
//  PRImage.m
//  PRICE
//
//  Created by Riccardo Mottola on Wed Oct 12 2005.
//  Copyright (c) 2005-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRImage.h"

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_3)
NSString *NSImageEXIFData = @"NSImageEXIFData";
#endif


/* PRImage subclasses NSImage to implement some key features
   - the first loaded bitmap representation is retained and made accessible, so that it doesn't get lost when it is replaced with cached representations
   - image pixel size is retrieved from this representation
   - use setBitmapRep to set the master NSBitmapImageRep
*/

@implementation PRImage

- (id)initWithData:(NSData*)data
{
  self = [super initWithData:data];
  bitmapRep = [[self representations] objectAtIndex:0];
  if (![bitmapRep isKindOfClass:[NSBitmapImageRep class]])
    {
      NSLog(@"we got %@", [bitmapRep class]);
    }
  NSLog(@" init bitrep is: %@", bitmapRep);
  [bitmapRep retain];
  [self setSize: [self pixelSize]];
  return self;
}

- (id)initWithSize:(NSSize)aSize
{
    self = [super initWithSize:aSize];
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  PRImage *objCopy;
  
  objCopy = [super copyWithZone:zone];
  while( [[objCopy representations] count] > 0 )
    {
	  [objCopy removeRepresentation:[[objCopy representations] objectAtIndex:0]];
    }
  objCopy->bitmapRep = nil;
  [objCopy setBitmapRep:[[bitmapRep copy] autorelease]];
  
  return objCopy;
}

- (void)dealloc
{
  [bitmapRep release];
  [super dealloc];
}

- (NSInteger)height
{
  return [bitmapRep pixelsHigh];
}

- (NSInteger)width
{
  return [bitmapRep pixelsWide];
}

- (BOOL)hasColor
{
  BOOL r = NO;
  
  if ([bitmapRep hasAlpha])
	{
	  if ([bitmapRep samplesPerPixel] > 2)
		r = YES;
	}
  else
	{
	  if ([bitmapRep samplesPerPixel] > 1)
		r = YES;
	}
  NSLog(@"hasColor ? %d", r);
  return r;
}

- (BOOL)hasAlpha
{
  return [bitmapRep hasAlpha];
}

/**
  BitsPerPixel may be mmore than bitsPerSample*samplesPerPixel:
  the pixel data could be padded or aligned on byte boundaries
 */
- (NSInteger)bitsPerPixel
{
  return [bitmapRep bitsPerPixel];
}

- (NSInteger)bitsPerSample
{
  return [bitmapRep bitsPerSample];
}

- (NSInteger)samplesPerPixel
{
  return [bitmapRep samplesPerPixel];
}

- (NSSize)pixelSize
{
  return NSMakeSize((float)[bitmapRep pixelsWide],(float)[bitmapRep pixelsHigh]);
}

- (NSBitmapImageRep *)bitmapRep
{
  NSLog(@"ret bitrep is: %@ bps: %d, spp %d", bitmapRep, [bitmapRep bitsPerSample], [bitmapRep samplesPerPixel]);
  return bitmapRep;
}

- (void)setBitmapRep:(NSBitmapImageRep *)rep
{
  if (bitmapRep != rep)
    {
      [rep retain];
      [bitmapRep release];
      bitmapRep = rep;
      [self addRepresentation:bitmapRep];
    }
}

@end
