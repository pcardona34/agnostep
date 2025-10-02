//
//  PREqualize.m
//  PRICE
//  Image level equalization
//
//  Created by Riccardo Mottola on Fri Dec 05 2003.
//  Copyright (c) 2003-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#include <math.h>
#include <limits.h>

#import "PREqualize.h"

#if defined (__SVR4) && defined (__sun)
#define rintf(x) rint(x)
#endif


@implementation PREqualize

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    int space;

    /* interpret the parameters */
    space = [[parameters objectAtIndex:0] intValue];

    return [self equalizeImage:image :space];
}

- (NSString *)actionName
{
    return @"Equalize";
}

- (PRImage *)equalizeImage:(PRImage *)srcImage :(int)space
{
  NSBitmapImageRep *srcImageRep;
  PRImage          *destImage;
  NSBitmapImageRep *destImageRep;
  NSInteger        w, h;
  NSInteger        x, y;
  NSInteger        i;
  unsigned char    *srcData;
  unsigned char    *destData;
  NSInteger srcSamplesPerPixel;
  NSInteger destSamplesPerPixel;
  register NSInteger srcBytesPerPixel;
  register NSInteger destBytesPerPixel;
  register NSInteger srcBytesPerRow;
  register NSInteger destBytesPerRow;
  int              pixNum;
  BOOL             hasAlpha;
    
  /* some trace */
  NSLog(@"levels: %d", UCHAR_MAX);
  NSLog(@"space: %d", space);
    
    /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];
    
    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    pixNum = h * w;
    NSLog(@"pixels: %d", pixNum);
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
    destSamplesPerPixel = srcSamplesPerPixel;
    
    hasAlpha = [srcImageRep hasAlpha];

    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
    destImageRep = [[NSBitmapImageRep alloc]
                initWithBitmapDataPlanes:NULL
                              pixelsWide:w
                              pixelsHigh:h
                           bitsPerSample:[srcImageRep bitsPerSample]
                         samplesPerPixel:destSamplesPerPixel
                                hasAlpha:[srcImage hasAlpha]
                                isPlanar:NO
                          colorSpaceName:[srcImageRep colorSpaceName]
                             bytesPerRow:w*destSamplesPerPixel
                            bitsPerPixel:0];
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;

    if ([srcImage hasColor])
    {
        if (space == COLOR_SPACE_RGB)
        {
            unsigned long int histogramDenormR[UCHAR_MAX+1]; /* not normalized pixel count for each level */
            unsigned long int histogramDenormG[UCHAR_MAX+1]; /* not normalized pixel count for each level */
            unsigned long int histogramDenormB[UCHAR_MAX+1]; /* not normalized pixel count for each level */
            float histogramR[UCHAR_MAX+1];                   /* normalized histogram */
            float histogramG[UCHAR_MAX+1];                   /* normalized histogram */
            float histogramB[UCHAR_MAX+1];                   /* normalized histogram */
            float cumulativeHistogramR[UCHAR_MAX+1];         /* cumulative histogram */
            float cumulativeHistogramG[UCHAR_MAX+1];         /* cumulative histogram */
            float cumulativeHistogramB[UCHAR_MAX+1];         /* cumulative histogram */
            
            /* calculate the histogram */
            for (i = 0; i <= UCHAR_MAX; i++)
                histogramDenormR[i] = histogramDenormG[i] = histogramDenormB[i] =  0;
            for (y = 0; y < h; y++)
                for (x = 0; x < w*3; x += 3)
                {
                    histogramDenormR[srcData[y*srcBytesPerRow + srcBytesPerPixel*x]]++;
                    histogramDenormG[srcData[y*srcBytesPerRow + srcBytesPerPixel*x + 1]]++;
                    histogramDenormB[srcData[y*srcBytesPerRow + srcBytesPerPixel*x + 2]]++;
                }
        
            /* normalize histogram */
            for (i = 0; i <= UCHAR_MAX; i++)
            {
                histogramR[i] = (float)histogramDenormR[i] / (float)pixNum;
                histogramG[i] = (float)histogramDenormG[i] / (float)pixNum;
                histogramB[i] = (float)histogramDenormB[i] / (float)pixNum;
            }
            
            /* cumulative histogram */
            cumulativeHistogramR[0] = histogramR[0];
            cumulativeHistogramG[0] = histogramG[0];
            cumulativeHistogramB[0] = histogramB[0];
            for (i = 1; i <= UCHAR_MAX; i++)
            {
                cumulativeHistogramR[i] = cumulativeHistogramR[i-1] + histogramR[i];
                cumulativeHistogramG[i] = cumulativeHistogramG[i-1] + histogramG[i];
                cumulativeHistogramB[i] = cumulativeHistogramB[i-1] + histogramB[i];
            }
            
            /* equalize */
            for (y = 0; y < h; y++)
                for (x = 0; x < w; x++)
                {
                    destData[y*destBytesPerRow + destBytesPerPixel*x]     = floor((UCHAR_MAX+0.9)*cumulativeHistogramR[srcData[y*srcBytesPerRow + srcBytesPerPixel*x]]);
                    destData[y*destBytesPerRow + destBytesPerPixel*x + 1] = floor((UCHAR_MAX+0.9)*cumulativeHistogramG[srcData[y*srcBytesPerRow + srcBytesPerPixel*x + 1]]);
                    destData[y*destBytesPerRow + destBytesPerPixel*x + 2] = floor((UCHAR_MAX+0.9)*cumulativeHistogramB[srcData[y*srcBytesPerRow + srcBytesPerPixel*x + 2]]);
                    if (hasAlpha)
                      destData[y*destBytesPerRow + destBytesPerPixel*x + 3] = srcData[y*srcBytesPerRow + srcBytesPerPixel*x + 3];
                }
        } else if (space == COLOR_SPACE_YUV)
        {
            unsigned long int histogramDenormY[UCHAR_MAX+1]; /* not normalized pixel count for each level */
            float histogramY[UCHAR_MAX+1];                   /* normalized histogram */
            float cumulativeHistogramY[UCHAR_MAX+1];         /* cumulative histogram */
            register int r, g, b;
            unsigned char yy, cb, cr;
            
/*
 *            JPEG-YCbCr (601) from "digital 8-bit R'G'B'  "
 *            ========================================================================
 *            Y' =       + 0.299    * R'd + 0.587    * G'd + 0.114    * B'd
 *            Cb = 128   - 0.168736 * R'd - 0.331264 * G'd + 0.5      * B'd
 *            Cr = 128   + 0.5      * R'd - 0.418688 * G'd - 0.081312 * B'd
 *            ........................................................................
 *            R'd, G'd, B'd   in {0, 1, 2, ..., 255}
 *            Y', Cb, Cr      in {0, 1, 2, ..., 255}
 * R = Y                    + 1.402   (Cr-128)
 * G = Y - 0.34414 (Cb-128) - 0.71414 (Cr-128)
 * B = Y + 1.772   (Cb-128)
 */
            /* first we convert the whole image to YCC-d */
            for (y = 0; y < h; y++)
                for (x = 0; x < w; x++)
                {
                    r = srcData[y*srcBytesPerRow + srcBytesPerPixel*x];
                    g = srcData[y*srcBytesPerRow + srcBytesPerPixel*x + 1];
                    b = srcData[y*srcBytesPerRow + srcBytesPerPixel*x + 2];
                    yy = rintf(       + 0.2990f*r + 0.5870f*g + 0.1140f*b);
                    cb = rintf(128.0f - 0.1687f*r - 0.3313f*g + 0.5000f*b);
                    cr = rintf(128.0f + 0.5000f*r - 0.4187f*g - 0.0813f*b);

                    destData[y*destBytesPerRow + destBytesPerPixel*x]     = yy;
                    destData[y*destBytesPerRow + destBytesPerPixel*x + 1] = cb;
                    destData[y*destBytesPerRow + destBytesPerPixel*x + 2] = cr;
                    
                    if (hasAlpha)
                      destData[y*destBytesPerRow + destBytesPerPixel*x + 3] = srcData[y*srcBytesPerRow + srcBytesPerPixel*x + 3];
                }

            /* calculate the histogram */
            for (i = 0; i <= UCHAR_MAX; i++)
                histogramDenormY[i] =  0;
            for (y = 0; y < h; y++)
                for (x = 0; x < w; x++)
                    histogramDenormY[destData[y*destBytesPerRow + destBytesPerPixel*x]]++;

            /* normalize histogram */
            for (i = 0; i <= UCHAR_MAX; i++)
                histogramY[i] = (float)histogramDenormY[i] / (float)pixNum;

            /* cumulative histogram */
            cumulativeHistogramY[0] = histogramY[0];
            for (i = 1; i <= UCHAR_MAX; i++)
                cumulativeHistogramY[i] = cumulativeHistogramY[i-1] + histogramY[i];


            /* equalize */
            for (y = 0; y < h; y++)
                for (x = 0; x < w; x++)
                {
                    destData[y*destBytesPerRow + destBytesPerPixel*x] = floor((UCHAR_MAX+0.9)*cumulativeHistogramY[destData[y*destBytesPerRow + destBytesPerPixel*x]]);
                }
                    
            /* now we convert back to RGB */
            for (y = 0; y < h; y++)
                for (x = 0; x < w; x++)
                {
                    yy = destData[y*destBytesPerRow + destBytesPerPixel*x];
                    cb = destData[y*destBytesPerRow + destBytesPerPixel*x + 1];
                    cr = destData[y*destBytesPerRow + destBytesPerPixel*x + 2];
                    r = yy                     + (int)rintf(1.40200f*(cr-128));
                    g = yy - (int)rintf(0.34414f*(cb-128) + 0.71414f*(cr-128));
                    b = yy + (int)rintf(1.77200f*(cb-128));
                    r = r > UCHAR_MAX ? UCHAR_MAX : r;
                    g = g > UCHAR_MAX ? UCHAR_MAX : g;
                    b = b > UCHAR_MAX ? UCHAR_MAX : b;
                    r = r < 0 ? 0 : r;
                    g = g < 0 ? 0 : g;
                    b = b < 0 ? 0 : b;
                    destData[y*destBytesPerRow + destBytesPerPixel*x]     = r;
                    destData[y*destBytesPerRow + destBytesPerPixel*x + 1] = g;
                    destData[y*destBytesPerRow + destBytesPerPixel*x + 2] = b;
                    
                    /* no need to convert back alpha channel */
                } 
        }
    } else
    {
        unsigned long int histogramDenorm[UCHAR_MAX+1]; /* not normalized pixel count for each level */
        float histogram[UCHAR_MAX+1];                   /* normalized histogram */
        float cumulativeHistogram[UCHAR_MAX+1];         /* cumulative histogram */
        /* calculate the histogram */
        for (i = 0; i <= UCHAR_MAX; i++)
            histogramDenorm[i] = 0;
        for (y = 0; y < h; y++)
            for (x = 0; x < w; x++)
                histogramDenorm[srcData[y*srcBytesPerRow + x]]++;
    
        /* normalize histogram */
        for (i = 0; i <= UCHAR_MAX; i++)
            histogram[i] = (float)histogramDenorm[i] / (float)pixNum;
        
        /* cumulative histogram */
        cumulativeHistogram[0] = histogram[0];
        for (i = 1; i <= UCHAR_MAX; i++)
            cumulativeHistogram[i] = cumulativeHistogram[i-1] + histogram[i];
        
        /* equalize */
        for (y = 0; y < h; y++)
            for (x = 0; x < w; x++)
              {
                destData[y*destBytesPerRow + destBytesPerPixel*x] = floor((UCHAR_MAX+0.9)*cumulativeHistogram[srcData[y*srcBytesPerRow + srcBytesPerPixel*x]]);
                if (hasAlpha)
                  destData[y*destBytesPerRow + destBytesPerPixel*x + 1] = srcData[y*srcBytesPerRow + srcBytesPerPixel*x + 1];
              }
    }
    
    [destImage setBitmapRep:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}


@end
