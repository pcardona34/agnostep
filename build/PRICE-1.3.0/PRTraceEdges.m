//
//  PRTraceEdges.m
//  PRICE
//
//  Created by Riccardo Mottola on Wed Jan 14 2004.
//  Copyright (c) 2004-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import "PRTraceEdges.h"
#import "PRGrayscaleFilter.h"

#include <math.h>
#include <limits.h>


@implementation PRTraceEdges

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    int filterType;
    BOOL useThreshold;
    float thresLevel;
    BOOL useZeroCross;
    
    /* interpret the parameters */
    filterType = [[parameters objectAtIndex:0] intValue];
    useThreshold = [[parameters objectAtIndex:1] boolValue];
    thresLevel = [[parameters objectAtIndex:2] floatValue];
    useZeroCross = [[parameters objectAtIndex:3] boolValue];
    
    return [self edgeImage:image :filterType :useThreshold :thresLevel :useZeroCross];
}

- (NSString *)actionName
{
    return @"Trace Edges";
}


- (PRImage *)edgeImage :(PRImage *)srcImage :(int)filterType :(BOOL)useThreshold :(float)thresholdLevel :(BOOL)useZeroCross
{
  NSBitmapImageRep   *srcImageRep;
  PRImage            *destImage;
  NSBitmapImageRep   *destImageRep;
  NSInteger          w, h;
  NSInteger          x, y;
  NSInteger          i, j;
  unsigned char      *srcData;
  unsigned char      *destData;
  NSInteger          destSamplesPerPixel;
  register NSInteger srcBytesPerPixel;
  register NSInteger destBytesPerPixel;
  register NSInteger srcBytesPerRow;
  register NSInteger destBytesPerRow;
  float              *M, *N;
  unsigned char      *p1;
  int                convMatrix[5][5];
  float              convSum;
    
  /* get source image representation and associated information */
  srcImageRep = [srcImage bitmapRep];
  
  w = [srcImageRep pixelsWide];
  h = [srcImageRep pixelsHigh];
    
  /* check bith depth and color/greyscale image */
  if ([srcImage hasColor])
    {
      PRGrayscaleFilter *grayFilter;
      
      grayFilter = [[PRGrayscaleFilter alloc] init];
      /* Luminance conversion leaves us more signal than average */
      srcImage = [grayFilter filterImage:srcImage :METHOD_LUMINANCE];
      [grayFilter release];
      srcImageRep = [srcImage bitmapRep];
      NSLog (@"done greyscale converting");   
    }

  srcBytesPerRow = [srcImageRep bytesPerRow];
  srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
  destSamplesPerPixel = 1;
  
    srcData = [srcImageRep bitmapData];
    
    
    /* allocate float data */
    M = (float *)calloc(h*w, sizeof(float));
    N = (float *)calloc(h*w, sizeof(float));
    
    /* copy the image to the float matrix */
    for (y = 0; y < h; y++)
    {
        p1 = srcData +  y * srcBytesPerRow; 
        for (x = 0; x < w; x++)
        {
            
            M[y*w + x] = (double)p1[x*srcBytesPerPixel] / UCHAR_MAX;
        }
    }
    
    
    /* set the filter matrix */
    for (i = 0; i < 5; i++)
        for (j = 0; j < 5; j++)
            convMatrix[i][j] = 0;
    
    /* see PRCTraceEdge.h for the filter correspondences */
    switch (filterType)
    {
    case 1: NSLog(@"Pixel difference");
        convMatrix[1][1] = 0;
        convMatrix[1][2] = -1;
        convMatrix[1][3] = 0;
        convMatrix[2][1] = 0;
        convMatrix[2][2] = 2;
        convMatrix[2][3] = -1;
        break;
    case 2: NSLog(@"Separated pixel difference");
        convMatrix[1][1] = 0;
        convMatrix[1][2] = -1;
        convMatrix[1][3] = 0;
        convMatrix[2][1] = 1;
        convMatrix[2][2] = 0;
        convMatrix[2][3] = -1;
        convMatrix[3][1] = 0;
        convMatrix[3][2] = 1;
        convMatrix[3][3] = 0;
        break;
    case 3: NSLog(@"Roberts");
        convMatrix[1][1] = -1;
        convMatrix[1][2] = 0;
        convMatrix[1][3] = -1;
        convMatrix[2][1] = 0;
        convMatrix[2][2] = 2;
        convMatrix[2][3] = 0;
        break;
    case 4: NSLog(@"Prewitt");
        convMatrix[1][1] = 0;
        convMatrix[1][2] = -1;
        convMatrix[1][3] = -2;
        convMatrix[2][1] = 1;
        convMatrix[2][2] = 0;
        convMatrix[2][3] = -1;
        convMatrix[3][1] = 2;
        convMatrix[3][2] = 1;
        convMatrix[3][3] = 0;
        break;
    case 5: NSLog(@"Sobel");
        convMatrix[1][1] = 0;
        convMatrix[1][2] = -2;
        convMatrix[1][3] = -2;
        convMatrix[2][1] = 2;
        convMatrix[2][2] = 0;
        convMatrix[2][3] = -2;
        convMatrix[3][1] = 2;
        convMatrix[3][2] = 2;
        convMatrix[3][3] = 0;
        break;
    case 6: NSLog(@"Abdou x");
        convMatrix[0][0] = 1;
        convMatrix[0][1] = 1;
        convMatrix[0][2] = 0;
        convMatrix[0][3] = -1;
        convMatrix[0][4] = -1;
        convMatrix[1][0] = 1;
        convMatrix[1][1] = 2;
        convMatrix[1][2] = 0;
        convMatrix[1][3] = -2;
        convMatrix[1][4] = -1;
        convMatrix[2][0] = 1;
        convMatrix[2][1] = 2;
        convMatrix[2][2] = 0;
        convMatrix[2][3] = -2;
        convMatrix[2][4] = -1;
        convMatrix[3][0] = 1;
        convMatrix[3][1] = 2;
        convMatrix[3][2] = 0;
        convMatrix[3][3] = -2;
        convMatrix[3][4] = -1;
        convMatrix[4][0] = 1;
        convMatrix[4][1] = 1;
        convMatrix[4][2] = 0;
        convMatrix[4][3] = -1;
        convMatrix[4][4] = -1;
        break;
    case 7: NSLog(@"Laplacian 1");
        convMatrix[1][1] = 0;
        convMatrix[1][2] = -1;
        convMatrix[1][3] = 0;
        convMatrix[2][1] = -1;
        convMatrix[2][2] = 4;
        convMatrix[2][3] = -1;
        convMatrix[3][1] = 0;
        convMatrix[3][2] = -1;
        convMatrix[3][3] = 0;
        break;
    case 8: NSLog(@"Laplacian 2");
        convMatrix[1][1] = -1;
        convMatrix[1][2] = 2;
        convMatrix[1][3] = -1;
        convMatrix[2][1] = 2;
        convMatrix[2][2] = -4;
        convMatrix[2][3] = 2;
        convMatrix[3][1] = -1;
        convMatrix[3][2] = 2;
        convMatrix[3][3] = -1;
        break;
    case 9: NSLog(@"Laplacian Prewitt");
        convMatrix[1][1] = -1;
        convMatrix[1][2] = -1;
        convMatrix[1][3] = -1;
        convMatrix[2][1] = -1;
        convMatrix[2][2] = 8;
        convMatrix[2][3] = -1;
        convMatrix[3][1] = -1;
        convMatrix[3][2] = -1;
        convMatrix[3][3] = -1;
        break;
    default:
        NSLog(@"Unknown filter type for Trace Edges.");
    }
    
           
    /* the core */
    for (y = 0 + 2; y < h - 3; y++)
        for (x = 0 + 2; x < w - 3; x++)
        {
            convSum = 0;
            for (i = -2; i <= 2; i++)
                for (j = -2; j <= 2; j++)
                    convSum += convMatrix[i+2][j+2] * M[(y+i) * w + (x+j)];
            N[y*w + x] = convSum;
        } 
    
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
    
    /* copy the image back from the float matrix */
    if (useThreshold)
    {
        if (useZeroCross)
        {   /* zero crossing */
            for (y = 0; y < h; y++)
            {
                p1 = destData +  (y * destBytesPerRow);
                for (x = 0; x < w; x++)
                {
                    float temp;
                    temp = fabs(N[y*w + x]);
                    if (temp < thresholdLevel)
                        p1[x*destBytesPerPixel] = UCHAR_MAX;
                    else
                        p1[x*destBytesPerPixel] = 0;
                }
            }
        } else
        {   /* no zero crossing */
            for (y = 0; y < h; y++)
            {
                p1 = destData +  (y * destBytesPerRow);
                for (x = 0; x < w; x++)
                {
                    if (N[y*w + x] > thresholdLevel)
                        p1[x*destBytesPerPixel] = 0;
                    else
                        p1[x*destBytesPerPixel] = UCHAR_MAX;
                }
            }
        }
    } else
    { /* thresholding to prevent clipping */
        for (y = 0; y < h; y++)
        {
            p1 = destData +  (y * destBytesPerRow);
            for (x = 0; x < w; x++)
            {
                float temp;
                temp = fabs(N[y*w + x]);
                if (temp < 0)
                    p1[x*destBytesPerPixel] = 0;
                else if (temp < 1)
                    p1[x*destBytesPerPixel] = (unsigned char) rint(temp * UCHAR_MAX);
                else
                    p1[x*destBytesPerPixel] = UCHAR_MAX;
            }
        }
    }
    
    /* let's free the float data */
    free(M);
    free(N);
    
    [destImage setBitmapRep:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}

@end
