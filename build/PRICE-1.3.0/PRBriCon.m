//
//  PRBriCon.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu Mar 3 2005.
//  Copyright (c) 2005-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#include <math.h>
#import <AppKit/AppKit.h>

#include <limits.h>
#define HALF_CHAR (UCHAR_MAX >> 1)

#import "PRBriCon.h"


@implementation PRBriCon

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    int   brightness;
    float contrast;

    /* interpret the parameters */
    brightness = [[parameters objectAtIndex:0] intValue];
    contrast = [[parameters objectAtIndex:1] floatValue];

    return [self adjustImage:image :brightness :contrast];
}

- (NSString *)actionName
{
    return @"Brightness & Contrast";
}

- (PRImage *)adjustImage :(PRImage *)srcImage :(int)bri :(float)con
{
  NSBitmapImageRep *srcImageRep;
  PRImage *destImage;
  NSBitmapImageRep *destImageRep;
  NSInteger w, h;
  NSInteger x, y;
  unsigned char *srcData;
  unsigned char *destData;
  int tempValue;
  NSInteger srcSamplesPerPixel;
  NSInteger destSamplesPerPixel;
  register NSInteger srcBytesPerPixel;
  register NSInteger destBytesPerPixel;
  register NSInteger srcBytesPerRow;
  register NSInteger destBytesPerRow;
  BOOL hasAlpha;
    

    /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];
    
    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;

    hasAlpha = [srcImageRep hasAlpha];

    destSamplesPerPixel = srcSamplesPerPixel;
    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
    destImageRep = [[NSBitmapImageRep alloc]
                initWithBitmapDataPlanes:NULL
                pixelsWide:w
                pixelsHigh:h
                bitsPerSample:[srcImageRep bitsPerSample]
                samplesPerPixel:destSamplesPerPixel
                hasAlpha:hasAlpha
                isPlanar:NO
                colorSpaceName:[srcImageRep colorSpaceName]
                bytesPerRow:0
                bitsPerPixel:0];
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;
    
    if ([srcImage hasColor])
    {
        for (y = 0; y < h; y++)
            for (x = 0; x < w; x++)
            {
                tempValue = (int)rint((float)(srcData[srcBytesPerRow*y + srcBytesPerPixel*x] - HALF_CHAR + bri) * con + HALF_CHAR);
                if (tempValue > UCHAR_MAX)
                    tempValue = UCHAR_MAX;
                else if (tempValue < 0)
                    tempValue = 0;
                destData[destBytesPerRow * y + destBytesPerPixel * x] = tempValue;

                tempValue = (int)rint((float)(srcData[srcBytesPerRow*y + srcBytesPerPixel*x + 1] - HALF_CHAR + bri) * con + HALF_CHAR);
                if (tempValue > UCHAR_MAX)
                    tempValue = UCHAR_MAX;
                else if (tempValue < 0)
                    tempValue = 0;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 1] = tempValue;

                tempValue = (int)rint((float)(srcData[srcBytesPerRow*y + srcBytesPerPixel*x + 2] - HALF_CHAR + bri) * con + HALF_CHAR);
                if (tempValue > UCHAR_MAX)
                    tempValue = UCHAR_MAX;
                else if (tempValue < 0)
                    tempValue = 0;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 2] = tempValue;
                
                if (hasAlpha)
                  destData[destBytesPerRow * y + destBytesPerPixel * x + 3] = srcData[srcBytesPerRow*y + srcBytesPerPixel*x + 3];
            }
    } else
    {
        for (y = 0; y < h; y++)
            for (x = 0; x < w; x++)
            {
                tempValue = (int)rint((float)(srcData[srcBytesPerRow*y + srcBytesPerPixel*x] - HALF_CHAR + bri) * con + HALF_CHAR);
                if (tempValue > UCHAR_MAX)
                    tempValue = UCHAR_MAX;
                else if (tempValue < 0)
                    tempValue = 0;
                destData[destBytesPerRow * y + destBytesPerPixel * x] = tempValue;
                
                if (hasAlpha)
                  destData[destSamplesPerPixel*(y*w + x) + 1] = srcData[srcBytesPerRow*y + srcSamplesPerPixel*x + 1];
            }
    }
    
    [destImage setBitmapRep:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}

- (BOOL)displayProgress
{
    return NO;
}


@end
