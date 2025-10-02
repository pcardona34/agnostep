//
//  PRImage.h
//  PRICE
//
//  Created by Riccardo Mottola on Wed Oct 12 2005.
//  Copyright (c) 2005-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

// this class implements a tailored variation of NSImage for PRICE
// the assumption that each time only one representation (of bitmap type) is available is done
// thus it can be made directly accessible as well as some of its properties can be cached

#import <AppKit/AppKit.h>

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
typedef int NSInteger;
#endif

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_3)
extern NSString *NSImageEXIFData;
#endif

@interface PRImage : NSImage
{
  @private
  NSBitmapImageRep *bitmapRep;
}

- (NSInteger)height;
- (NSInteger)width;
- (BOOL)hasColor;
- (BOOL)hasAlpha;
- (NSInteger)bitsPerPixel;
- (NSInteger)bitsPerSample;
- (NSInteger)samplesPerPixel;
- (NSSize)pixelSize;
- (NSBitmapImageRep *)bitmapRep;
- (void)setBitmapRep:(NSBitmapImageRep *)rep;

@end
