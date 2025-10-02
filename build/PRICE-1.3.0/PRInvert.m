//
//  PRInvert.m
//  PRICE
//
//  Created by Riccardo Mottola on Fri Dec 07 2007.
//  Copyright (c) 2007-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#include <limits.h>
#import "PRInvert.h"


@implementation PRInvert

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    /* interpret the parameters */

    return [self filterImage:image];
}

- (NSString *)actionName
{
    return @"Invert";
}

- (PRImage *)filterImage:(PRImage *)srcImage
{
  NSBitmapImageRep    *srcImageRep;
  PRImage             *destImage;
  NSBitmapImageRep    *destImageRep;
  NSInteger           w, h;
  NSInteger           x, y;
  BOOL                hasAlpha;
  NSInteger           srcBytesPerRow;
  NSInteger           destBytesPerRow;
  NSInteger           bitsPerPixel;
  NSInteger           srcBytesPerPixel;
  NSInteger           destBytesPerPixel;
  register NSInteger  maxPerChannel;
    

  /* get source image representation and associated information */
  srcImageRep = [srcImage bitmapRep];
  w = [srcImageRep pixelsWide];
  h = [srcImageRep pixelsHigh];
  srcBytesPerRow = [srcImageRep bytesPerRow];
  hasAlpha = [srcImageRep hasAlpha];
  bitsPerPixel = [srcImageRep bitsPerPixel];
  srcBytesPerPixel = bitsPerPixel / 8;
  maxPerChannel = pow(2, [srcImageRep bitsPerSample])-1;  
  
  /* allocate destination image and its representation */
  destImage = [[PRImage alloc] initWithSize:[srcImage size]];
  destImageRep = [[NSBitmapImageRep alloc]
                    initWithBitmapDataPlanes:NULL
                                  pixelsWide:w
                                  pixelsHigh:h
                               bitsPerSample:[srcImageRep bitsPerSample]
                             samplesPerPixel:[srcImageRep samplesPerPixel]
                                    hasAlpha:hasAlpha
                                    isPlanar:NO
                              colorSpaceName:[srcImageRep colorSpaceName]
                                 bytesPerRow:0
                                bitsPerPixel:0];
  
  destBytesPerRow = [destImageRep bytesPerRow];
  destBytesPerPixel = [destImageRep bitsPerPixel] / 8;

  /* execute the actual filtering  */
  /* take in account if image has alpha and if it is has one or 3 samples */
  /* alpha shall be preserved and not inverted */
  if ([srcImageRep bitsPerSample] == 8)
    {
      unsigned char    *srcData;
      unsigned char    *destData;
      unsigned char    *p1;
      unsigned char    *p2;
        
      srcData = [srcImageRep bitmapData];
      destData = [destImageRep bitmapData];
      if (![srcImage hasColor])
        for (y = 0; y < h; y++)
          for (x = 0; x < w; x++)
            {
              p1 = srcData + srcBytesPerRow * y + srcBytesPerPixel * x;
              p2 = destData + destBytesPerRow * y + destBytesPerPixel * x;
              p2[0] = maxPerChannel - p1[0];
              if (hasAlpha)
                p2[1] = p1[1];
            }
      else
        for (y = 0; y < h; y++)
          for (x = 0; x < w; x++)
            {
              p1 = srcData + srcBytesPerRow * y + srcBytesPerPixel * x;
              p2 = destData + destBytesPerRow * y + destBytesPerPixel * x;
              p2[0] = maxPerChannel - p1[0];
              p2[1] = maxPerChannel - p1[1];
              p2[2] = maxPerChannel - p1[2];
              if(hasAlpha)
                p2[3] = p1[3];
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
      if (![srcImage hasColor])
        for (y = 0; y < h; y++)
          for (x = 0; x < w; x++)
            {
              p1 = (unsigned short*)((unsigned char*)srcData + srcBytesPerRow * y + srcBytesPerPixel * x);
              p2 = (unsigned short*)((unsigned char*)destData + destBytesPerRow * y + destBytesPerPixel * x);
              p2[0] = maxPerChannel - p1[0];
              if (hasAlpha)
                p2[1] = p1[1];
            }
      else
        for (y = 0; y < h; y++)
          for (x = 0; x < w; x++)
            {
              p1 = (unsigned short*)((unsigned char*)srcData + srcBytesPerRow * y + srcBytesPerPixel * x);
              p2 = (unsigned short*)((unsigned char*)destData + destBytesPerRow * y + destBytesPerPixel * x);
              p2[0] = maxPerChannel - p1[0];
              p2[1] = maxPerChannel - p1[1];
              p2[2] = maxPerChannel - p1[2];
              if(hasAlpha)
                p2[3] = p1[3];
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
