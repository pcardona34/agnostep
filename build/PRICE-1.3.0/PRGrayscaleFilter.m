//
//  PRGrayscaleFilter.m
//  PRICE
//
//  Created by Riccardo Mottola on Mon Dec 23 2002.
//  Copyright (c) 2002-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import "PRGrayscaleFilter.h"
#include <math.h>

#if defined (__SVR4) && defined (__sun)
#define rintf(x) rint(x)
#endif

@implementation PRGrayscaleFilter

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    int method;
      
    /* interpret the parameters */
    method = [[parameters objectAtIndex:0] intValue];
    
    return [self filterImage:image :method];
}

- (NSString *)actionName
{
    return @"Make Grayscale";
}

- (PRImage *)filterImage:(PRImage *)srcImage :(int)method 
{
    NSBitmapImageRep   *srcImageRep;
    PRImage            *destImage;
    NSBitmapImageRep   *destImageRep;
    NSInteger          w, h;
    NSInteger          x, y;
    NSInteger          destSamplesPerPixel;
    register NSInteger srcBytesPerPixel;
    register NSInteger destBytesPerPixel;
    register NSInteger srcBytesPerRow;
    register NSInteger destBytesPerRow;
    BOOL               hasAlpha;
    
    /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];
    
    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;

    hasAlpha = [srcImage hasAlpha];
    /* if the image is already greyscale... */
    if (![srcImage hasColor])
      return srcImage;

    destSamplesPerPixel = 1;
    if (hasAlpha)
      {
        destSamplesPerPixel = 2;
        hasAlpha = YES;
      }

    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
    destImageRep = [[NSBitmapImageRep alloc]
                    initWithBitmapDataPlanes:NULL
                    pixelsWide:w
                    pixelsHigh:h
                    bitsPerSample:[srcImageRep bitsPerSample]
                    samplesPerPixel:destSamplesPerPixel
                    hasAlpha:[srcImageRep hasAlpha]
                    isPlanar:NO
                    colorSpaceName:NSCalibratedWhiteColorSpace
                    bytesPerRow:0
                    bitsPerPixel:0];
    
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;

    if ([srcImageRep bitsPerSample] == 8)
      {
        unsigned char    *srcData;
        unsigned char    *destData;
        unsigned char    *p1;

        srcData = [srcImageRep bitmapData];
        destData = [destImageRep bitmapData];
        if (method == METHOD_AVERAGE)
          {
            /* execute the actual filtering (R+G+B)/3 */
            for (y = 0; y < h; y++)
              for (x = 0; x < w; x++)
                {
                  p1 = srcData + srcBytesPerRow * y  + srcBytesPerPixel * x;
                  destData[y*destBytesPerRow + x*destBytesPerPixel] = (unsigned char)rint((p1[0] + p1[1] + p1[2]) / 3);
                  if (hasAlpha)
                    destData[y*destBytesPerRow + x*destBytesPerPixel + 1] = p1[3];
                }
          }
        else if (method == METHOD_LUMINANCE)
          {
            /* execute the actual filtering
             * JPEG-YCbCr (601) from "digital 8-bit R'G'B'  "
             * Y' =       + 0.299    * R'd + 0.587    * G'd + 0.114    * B'd
             */
            for (y = 0; y < h; y++)
              for (x = 0; x < w; x++)
                {
                  p1 = srcData + srcBytesPerRow * y  + srcBytesPerPixel * x;
                  destData[y*destBytesPerRow + x*destBytesPerPixel] = (unsigned char)rintf(0.2990f*p1[0] + 0.5870f*p1[1] + 0.1140f*p1[2]);
                  if (hasAlpha)
                    destData[y*destBytesPerRow + x*destBytesPerPixel + 1] = p1[3];
                }
          }
      }
    else if ([srcImageRep bitsPerSample] == 16)
      {
        unsigned short    *srcData;
        unsigned short    *destData;
        unsigned short    *p1;
        unsigned short    *p2;

        srcData = (unsigned short*)[srcImageRep bitmapData];
        destData = (unsigned short*)[destImageRep bitmapData];
        if (method == METHOD_AVERAGE)
          {
            /* execute the actual filtering (R+G+B)/3 */
            for (y = 0; y < h; y++)
              for (x = 0; x < w; x++)
                {
                  p1 = (unsigned short*)((unsigned char*)srcData + srcBytesPerRow * y  + srcBytesPerPixel * x);
                  p2 = (unsigned short*)((unsigned char*)destData + destBytesPerRow  * y + destBytesPerPixel * x);
                  p2[0] = (unsigned short)rint((p1[0] + p1[1] + p1[2]) / 3);
                  if (hasAlpha)
                    p2[1] = p1[3];
                }
          }
        else if (method == METHOD_LUMINANCE)
          {
            /* execute the actual filtering
             * JPEG-YCbCr (601) from "digital 8-bit R'G'B'  "
             * Y' =       + 0.299    * R'd + 0.587    * G'd + 0.114    * B'd
             */
            for (y = 0; y < h; y++)
              for (x = 0; x < w; x++)
                {
                  p1 = (unsigned short*)((unsigned char*)srcData + srcBytesPerRow * y  + srcBytesPerPixel * x);
                  p2 = (unsigned short*)((unsigned char*)destData + destBytesPerRow  * y + destBytesPerPixel * x);
                  p2[0] = (unsigned short)rintf(0.2990f*p1[0] + 0.5870f*p1[1] + 0.1140f*p1[2]);
                  if (hasAlpha)
                    p2[1] = p1[3];
                }
          }        
      }
    else
      {
        NSLog(@"Unhandled bits per sample: %ld", (long int)[srcImageRep bitsPerSample]);
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
