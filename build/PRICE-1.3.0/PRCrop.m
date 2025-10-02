//
//  PRCrop.m
//  PRICE
//
//  Created by Riccardo Mottola on Fri Jan 28 2005.
//  Copyright (c) 2005-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#include "PRCrop.h"

@implementation PRCrop

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    int pixTop;
    int pixBottom;
    int pixRight;
    int pixLeft;

    /* interpret the parameters */
    pixTop = [[parameters objectAtIndex:0] intValue];
    pixBottom = [[parameters objectAtIndex:1] intValue];
    pixLeft = [[parameters objectAtIndex:2] intValue];
    pixRight = [[parameters objectAtIndex:3] intValue];

    return [self cropImage:image :pixTop :pixBottom :pixLeft :pixRight];
}

- (NSString *)actionName
{
    return @"Crop";
}

- (PRImage *)cropImage :(PRImage *)srcImage :(int)pixTop :(int)pixBottom :(int)pixLeft :(int)pixRight
{
  NSBitmapImageRep *srcImageRep;
  PRImage *destImage;
  NSBitmapImageRep *destImageRep;
  NSInteger origW, origH;
  NSInteger newW, newH;
  NSInteger x, y;
  NSInteger i;
  unsigned char *srcData;
  unsigned char *destData;
  NSInteger srcSamplesPerPixel;
  NSInteger destSamplesPerPixel;
  register NSInteger srcBytesPerPixel;
  register NSInteger destBytesPerPixel;
  register NSInteger srcBytesPerRow;
  register NSInteger destBytesPerRow;
    
    /* some trace */
    NSLog(@"top: %d left:%d right:%d bottom:%d", pixTop, pixLeft, pixRight, pixBottom);
    

    /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];
    origW = [srcImageRep pixelsWide];
    origH = [srcImageRep pixelsHigh];
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    destSamplesPerPixel = srcSamplesPerPixel;
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
    
    newW = origW - pixLeft - pixRight;
    newH = origH - pixTop - pixBottom;

    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(newW, newH)];
    destImageRep = [[NSBitmapImageRep alloc]
                     initWithBitmapDataPlanes:NULL
                                   pixelsWide:newW
                                   pixelsHigh:newH
                                bitsPerSample:[srcImageRep bitsPerSample]
                              samplesPerPixel:destSamplesPerPixel
                                     hasAlpha:[srcImageRep hasAlpha]
                                     isPlanar:NO
                               colorSpaceName:[srcImageRep colorSpaceName]
                                  bytesPerRow:0
                                 bitsPerPixel:0];
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;


    for (y = 0; y < newH; y++)
      for (x = 0; x < newW; x++)
        for (i = 0; i < srcSamplesPerPixel; i++)
          {
            NSInteger sX, sY;

            sX = x + pixLeft;
            sY = y + pixTop;
            if ((sX >= 0 && sX < origW) && (sY >= 0 && sY < origH))
              {
                destData[destBytesPerRow * y + destBytesPerPixel * x + i] = srcData[srcBytesPerRow * sY + srcBytesPerPixel * sX + i];
              }
            else
              {
                destData[destBytesPerRow * y + destBytesPerPixel * x + i] = 0;
              }
          }
    [destImage setBitmapRep:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}

@end
