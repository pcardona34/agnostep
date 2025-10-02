//
//  PRCustTraceEdges.m
//  PRICE
//
//  Created by Riccardo Mottola on Fri Mar 19 2004.
//  Copyright (c) 2004-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCustTraceEdges.h"
#import "PRTraceEdges.h"
#import "PRMedian.h"
#import "PRGrayscaleFilter.h"
#include <math.h>
#include <limits.h>


@implementation PRCustTraceEdges

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    int filterType;
    float thresLevel;
    BOOL useZeroCross;
    BOOL enable1;
    enum medianForms form1;
    int size1;
    BOOL separable1;
    BOOL enable2;
    enum medianForms form2;
    int size2;
    BOOL separable2;
    BOOL enable3;
    enum medianForms form3;
    int size3;
    BOOL separable3;
    
    
    /* interpret the parameters */
    filterType = [[parameters objectAtIndex:0] intValue];
    thresLevel = [[parameters objectAtIndex:1] floatValue];
    useZeroCross = [[parameters objectAtIndex:2] boolValue];
    enable1 = [[parameters objectAtIndex:3] boolValue];
    form1 = [[parameters objectAtIndex:4] intValue];
    size1 = [[parameters objectAtIndex:5] intValue];
    separable1 = [[parameters objectAtIndex:6] boolValue];
    enable2 = [[parameters objectAtIndex:7] boolValue];
    form2 = [[parameters objectAtIndex:8] intValue];
    size2 = [[parameters objectAtIndex:9] intValue];
    separable2 = [[parameters objectAtIndex:10] boolValue];
    enable3 = [[parameters objectAtIndex:11] boolValue];
    form3 = [[parameters objectAtIndex:12] intValue];
    size3 = [[parameters objectAtIndex:13] intValue];
    separable3 = [[parameters objectAtIndex:14] boolValue];
    
    return [self edgeImage
        :image :filterType :thresLevel :useZeroCross
        :enable1 :form1 :size1 :separable1
        :enable2 :form2 :size2 :separable2
        :enable3 :form3 :size3 :separable3
        :progressPanel];
}

- (NSString *)actionName
{
    return @"Edge Tracer";
}


- (PRImage *)edgeImage :(PRImage *)srcImage :(int)filterType :(float)thresholdLevel :(BOOL)useZeroCross :(BOOL)enable1 :(enum medianForms)form1 :(int)size1 :(BOOL)separable1 :(BOOL)enable2 :(enum medianForms)form2 :(int)size2 :(BOOL)separable2 :(BOOL) enable3 :(enum medianForms)form3 :(int)size3 :(BOOL)separable3 :(PRCProgress *)prPanel
{
  PRImage           *destImage;
  NSBitmapImageRep  *destImageRep;
  unsigned char     *destData;
  NSInteger         w, h;
  NSInteger         x, y;
  NSInteger         destSamplesPerPixel;
  NSInteger         destBytesPerRow;
  NSInteger         destBytesPerPixel;
  PRMedian          *medianFilter;
  PRTraceEdges      *edgeFilter;
  int               finalLevels;
  int               finalLevelSize;
    
  progressSteps = 0;
  totalProgressSteps = 1;
  if (enable1)
    totalProgressSteps += 2;
  if (enable2)
    totalProgressSteps += 2;
  if (enable3)
    totalProgressSteps += 2;
    
  if (!enable1 && !enable2 && !enable3) /* if none of the median processors is enabled */
    totalProgressSteps++;
    
  progPanel = prPanel;
    
  /* check the number of images to process */
  finalLevels = 0;
  if (enable1)
    finalLevels++;
  if (enable2)
    finalLevels++;
  if (enable3)
    finalLevels++;
  finalLevelSize = 0;
  if (finalLevels)
    finalLevelSize = UCHAR_MAX / finalLevels;
    
  /* get source image representation and associated information */
  if (progPanel != nil)
    {
      [self setActivity:@"Get image size"];
      [self advanceProgress];
    }
    
  w = [srcImage width];
  h = [srcImage height];
    
  /* check bith depth and color/greyscale image */
  if ([srcImage hasColor])
    {
      PRGrayscaleFilter *grayFilter;

      grayFilter = [[PRGrayscaleFilter alloc] init];
      srcImage = [grayFilter filterImage:srcImage :METHOD_LUMINANCE];
      [grayFilter release];
    }
  destSamplesPerPixel = 1;
        
  /* allocate destination image and its representation */
  destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
  destImageRep = [[NSBitmapImageRep alloc]
                    initWithBitmapDataPlanes:NULL
                                  pixelsWide:w
                                  pixelsHigh:h
                               bitsPerSample:8
                             samplesPerPixel:destSamplesPerPixel
                                    hasAlpha:NO
                                    isPlanar:NO
                              colorSpaceName:NSCalibratedWhiteColorSpace
                                 bytesPerRow:0
                                bitsPerPixel:0];
    
  destData = [destImageRep bitmapData];
  destBytesPerRow = [destImageRep bytesPerRow];
  destBytesPerPixel = [destImageRep bitsPerPixel] / 8;
    
  /* let's make the paper white */
  memset(destData, UCHAR_MAX, h * destBytesPerRow);

  /* allocate filters */
  medianFilter = [[PRMedian alloc] init];
  edgeFilter   = [[PRTraceEdges alloc] init];

  if (finalLevels > 0)
    {
      if (enable1)
        {
          PRImage   *firstImage;
          NSBitmapImageRep  *firstImageRep;
          NSInteger fiBytesPerRow;
          NSInteger fiBytesPerPixel;
          unsigned char     *fiData;
            
            if (progPanel != nil)
              {
                [self setActivity:@"Processing image 1: median"];
                [self advanceProgress];
              }
          firstImage  = [medianFilter medianImage :srcImage :form1 :size1 :separable1 :NULL];
          if (progPanel != nil)
            {
              [self setActivity:@"Processing image 1: trace edges"];
              [self advanceProgress];
            }
          firstImage  = [edgeFilter edgeImage :firstImage  :filterType :YES :thresholdLevel :useZeroCross];
          firstImageRep = [firstImage bitmapRep];
          fiBytesPerRow = [firstImageRep bytesPerRow];
          fiBytesPerPixel = [firstImageRep bitsPerPixel] / 8;
          fiData = [firstImageRep bitmapData];
          for (y = 0; y < h; y++)
            {
              for (x = 0; x < w; x++)
                {
                  if (*(fiData + fiBytesPerRow*y + fiBytesPerPixel*x) == 0)
                    *(destData + destBytesPerRow*y + destBytesPerPixel*x) -= finalLevelSize;
                }
            }
        }
        
      if (enable2)
        {
          PRImage   *secondImage;
          NSBitmapImageRep  *secondImageRep;
          NSInteger siBytesPerRow;
          NSInteger siBytesPerPixel;
          unsigned char     *siData;
             
            if (progPanel != nil)
              {
                [self setActivity:@"Processing image 2: median"];
                [self advanceProgress];
              }
          secondImage = [medianFilter medianImage :srcImage :form2 :size2 :separable2 :NULL];
          if (progPanel != nil)
            {
              [self setActivity:@"Processing image 2: trace edges"];
              [self advanceProgress];
            }
          secondImage = [edgeFilter edgeImage :secondImage :filterType :YES :thresholdLevel :useZeroCross];
          secondImageRep = [secondImage bitmapRep];
          siBytesPerRow = [secondImageRep bytesPerRow];
          siBytesPerPixel = [secondImageRep bitsPerPixel] / 8;
          siData = [secondImageRep bitmapData];
          for (y = 0; y < h; y++)
              {
                for (x = 0; x < w; x++)
                  {
                    if (*(siData + siBytesPerRow*y + siBytesPerPixel*x) == 0)
                      *(destData + destBytesPerRow*y + destBytesPerPixel*x) -= finalLevelSize;
                  }
              }
        }
        
      if (enable3)
        {
          PRImage   *thirdImage;
          NSBitmapImageRep  *thirdImageRep;
          NSInteger tiBytesPerRow;
          NSInteger tiBytesPerPixel;
          unsigned char     *tiData;

          if (progPanel != nil)
            {
              [self setActivity:@"Processing image 3: median"];
              [self advanceProgress];
            }
          thirdImage  = [medianFilter medianImage :srcImage :form3 :size3 :separable3 :NULL];
          if (progPanel != nil)
            {
              [self setActivity:@"Processing image 3: trace edges"];
              [self advanceProgress];
            }
          thirdImage  = [edgeFilter edgeImage :thirdImage  :filterType :YES :thresholdLevel :useZeroCross];
          thirdImageRep = [thirdImage bitmapRep];
          tiBytesPerRow = [thirdImageRep bytesPerRow];
          tiBytesPerPixel = [thirdImageRep bitsPerPixel] / 8;
          tiData = [thirdImageRep bitmapData];
          for (y = 0; y < h; y++)
            {
              for (x = 0; x < w; x++)
                {
                  if (*(tiData + tiBytesPerRow*y + tiBytesPerPixel*x) == 0)
                    *(destData + destBytesPerRow*y + destBytesPerPixel*x) -= finalLevelSize;
                }
            }
        }
    }
  else
    {
      NSBitmapImageRep  *srcImageRep;
      unsigned char     *srcData;
      NSInteger         srcBytesPerRow;
      NSInteger         srcBytesPerPixel;
    
      /* no median processing */
      /* we conventionally process the image */
      if (progPanel != nil)
        {
          [self setActivity:@"Processing image: trace edges"];
          [self advanceProgress];
        }
      srcImage  = [edgeFilter edgeImage :srcImage  :filterType :YES :thresholdLevel :useZeroCross];
      srcImageRep = [srcImage bitmapRep];
      srcBytesPerRow = [srcImageRep bytesPerRow];
      srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
      srcData = [srcImageRep bitmapData];
      for (y = 0; y < h; y++)
        {
          for (x = 0; x < w; x++)
            {
              if (*(srcData + srcBytesPerRow*y + srcBytesPerPixel*x) == 0)
                *(destData + destBytesPerRow*y + destBytesPerPixel*x) = 0;
            }
        }
    }
    
  /* release filters */
  [medianFilter release];
  [edgeFilter release];

  if (progPanel != nil)
    {
      [self setActivity:@"Done"];
      [self showProgress];
    }

  [destImage setBitmapRep:destImageRep];
  [destImageRep release];
  [destImage autorelease];
  return destImage;
}

@end
