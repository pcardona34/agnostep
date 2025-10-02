//
//  PRConvolve55.m
//  PRICE
//
//  Created by Riccardo Mottola on Sat Jan 18 2003.
//  Copyright (c) 2003-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#include <math.h>
#include <limits.h>

#import "PRConvolve55.h"
#import "PRGrayscaleFilter.h"

@implementation PRConvolve55

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    NSArray     *convArray;
    int         convMat[5][5];
    int         offset;
    float       scale;
    BOOL        autoScale;
    int         i, j, k;
    
    /* interpret the parameters */
    convArray = [parameters objectAtIndex:0];

    k = 0;
    for (i = 0; i < 5; i++)
        for (j = 0; j < 5; j++)
            convMat[i][j] = [[convArray objectAtIndex:k++] intValue];
    
    offset = [[parameters objectAtIndex:1] intValue];
    scale = [[parameters objectAtIndex:2] floatValue];
    autoScale = [[parameters objectAtIndex:3] boolValue];
    
    return [self convolveImage:image :convMat :offset :scale :autoScale :progressPanel];
}

- (NSString *)actionName
{
    return @"Convolve 5x5";
}

- (PRImage *)convolveImage:(PRImage *)srcImage :(int[5][5])convMat :(int)offset :(float)scale :(BOOL)autoScale :(PRCProgress *)prPan
{
  NSBitmapImageRep   *srcImageRep;
  PRImage            *destImage;
  NSBitmapImageRep   *destImageRep;
  NSInteger          w, h;
  NSInteger          x, y; /* image scanning variables */
  NSInteger          i, j; /* convolve matrix scanning */
  unsigned char      *srcData;
  unsigned char      *destData;
  NSInteger          srcSamplesPerPixel;
  NSInteger          destSamplesPerPixel;
  register NSInteger srcBytesPerRow;
  register NSInteger destBytesPerRow;
  register NSInteger srcBytesPerPixel;
  register NSInteger destBytesPerPixel;
  float              normalizeFactor;
  int                minVal, maxVal;
  BOOL               hasAlpha;

    progressSteps = 0;
    totalProgressSteps = 2;
    if (autoScale)
        totalProgressSteps++;
    progPanel = prPan;
        
    /* get source image representation and associated information */
    if (progPanel != nil)
    {
        [self setActivity:@"get image representation"];
        [self advanceProgress];
    }
    srcImageRep = [srcImage bitmapRep];
    
    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
    destSamplesPerPixel = srcSamplesPerPixel;

    /* check bith depth and color/greyscale image */
    hasAlpha = [srcImage hasAlpha];
    
    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
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
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;

    if ([srcImage hasColor])
    {
        int convSumR, convSumG, convSumB;

        if (autoScale)
        {
            if (progPanel != nil)
            {
                [self setActivity:@"Evaluating range"];
                [self advanceProgress];
            }
            minVal = INT_MAX;
            maxVal = INT_MIN;

            /* calibrate output range */
            for (y = 0 + 2; y < h - 3; y++)
                for (x = 0 + 2; x < w - 3; x++)
                {
                    convSumR = 0;
                    convSumG = 0;
                    convSumB = 0;
                    for (i = -2; i <= 2; i++)
                        for (j = -2; j <= 2; j++)
                        {
                            convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                            convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                            convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                        }
                    if (convSumR + convSumG + convSumB > maxVal)
                        maxVal = convSumR + convSumG + convSumB;
                    if (convSumR + convSumG + convSumB < minVal)
                        minVal = convSumR + convSumG + convSumB;
                }

            maxVal = maxVal / 3;
            minVal = minVal / 3;
            printf("Max %d, min %d\n", maxVal, minVal);
            normalizeFactor = (float)fabs(maxVal -minVal)/(float)UCHAR_MAX;
            printf("normalize factor: %f\n", normalizeFactor);
            offset = -minVal;
            scale = normalizeFactor;
        }

        printf("offset: %d, scale:%f\n", offset, scale);

        if (progPanel != nil)
        {
            [self setActivity:@"convolving"];
            [self advanceProgress];
        }
        /* execute the actual filtering */
        /* the borders */
        for (y = 0; y < 0 + 2; y++)
        {
            /* top left corner */
            for (x = 0; x < (0 + 2); x++)
            {
                convSumR = 0;
                convSumG = 0;
                convSumB = 0;
                for (i = -2; i <= -1 - y; i++)
                {
                    for (j = -2; j <= -1 - x; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel + 2];
                    }
                    for (j = 0 - x; j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                }
                for (i = 0 - y; i <= 2; i++)
                {
                    for (j = -2; j <= -1 - x; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel + 2];
                    }
                    for (j = 0 - x; j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                }
                convSumR += offset;
                convSumG += offset;
                convSumB += offset;
                convSumR = (int)rint((float)convSumR / scale);
                convSumG = (int)rint((float)convSumG / scale);
                convSumB = (int)rint((float)convSumB / scale);
                if (convSumR < 0)
                    convSumR = 0;
                if (convSumG < 0)
                    convSumG = 0;
                if (convSumB < 0)
                    convSumB = 0;
                if (convSumR > UCHAR_MAX)
                    convSumR = UCHAR_MAX;
                if (convSumG > UCHAR_MAX)
                    convSumG = UCHAR_MAX;
                if (convSumB > UCHAR_MAX)
                    convSumB = UCHAR_MAX;
                destData[destBytesPerRow * y + destBytesPerPixel * x]     = (unsigned char)convSumR;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 1] = (unsigned char)convSumG;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 2] = (unsigned char)convSumB;
            }
            /* top band */
            for (x = (0 + 2); x < (w - 3); x++)
            {
                convSumR = 0;
                convSumG = 0;
                convSumB = 0;
                for (i = -2; i <= -1 - y; i++)
                    for (j = -2; j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                for (i = 0 - y; i <= 2; i++)
                    for (j = -2; j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                convSumR += offset;
                convSumG += offset;
                convSumB += offset;
                convSumR = (int)rint((float)convSumR / scale);
                convSumG = (int)rint((float)convSumG / scale);
                convSumB = (int)rint((float)convSumB / scale);
                if (convSumR < 0)
                    convSumR = 0;
                if (convSumG < 0)
                    convSumG = 0;
                if (convSumB < 0)
                    convSumB = 0;
                if (convSumR > UCHAR_MAX)
                    convSumR = UCHAR_MAX;
                if (convSumG > UCHAR_MAX)
                    convSumG = UCHAR_MAX;
                if (convSumB > UCHAR_MAX)
                    convSumB = UCHAR_MAX;
                destData[destBytesPerRow * y + destBytesPerPixel * x]     = (unsigned char)convSumR;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 1] = (unsigned char)convSumG;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 2] = (unsigned char)convSumB;
            }
            /* top right corner */
            for (x = (w - 3); x < w; x++)
            {
                convSumR = 0;
                convSumG = 0;
                convSumB = 0;
                for (i = -2; i <= -1 - y; i++)
                {
                    for (j = -2; j <= -1 - (x - w); j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                    for (j = 0 - (x - w); j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel + 2];
                    }
                }
                for (i = 0 - y; i <= 2; i++)
                {
                    for (j = -2; j <= -1 - (x - w); j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                    for (j = 0 - (x - w); j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel + 2];
                    }
                }
                convSumR += offset;
                convSumG += offset;
                convSumB += offset;
                convSumR = (int)rint((float)convSumR / scale);
                convSumG = (int)rint((float)convSumG / scale);
                convSumB = (int)rint((float)convSumB / scale);
                if (convSumR < 0)
                    convSumR = 0;
                if (convSumG < 0)
                    convSumG = 0;
                if (convSumB < 0)
                    convSumB = 0;
                if (convSumR > UCHAR_MAX)
                    convSumR = UCHAR_MAX;
                if (convSumG > UCHAR_MAX)
                    convSumG = UCHAR_MAX;
                if (convSumB > UCHAR_MAX)
                    convSumB = UCHAR_MAX;
                destData[destBytesPerRow * y + destBytesPerPixel * x]     = (unsigned char)convSumR;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 1] = (unsigned char)convSumG;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 2] = (unsigned char)convSumB;
            }
        }
        for (y = 0 + 2; y < h - 3; y++)
        {
            /* left band */
            for (x = 0; x < (0 + 2); x++)
            {
                convSumR = 0;
                convSumG = 0;
                convSumB = 0;
                for (i = -2; i <= 2; i++)
                {
                    for (j = -2; j <= -1 - x; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel + 2];
                    }
                    for (j = 0 - x; j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                }
                convSumR += offset;
                convSumG += offset;
                convSumB += offset;
                convSumR = (int)rint((float)convSumR / scale);
                convSumG = (int)rint((float)convSumG / scale);
                convSumB = (int)rint((float)convSumB / scale);
                if (convSumR < 0)
                    convSumR = 0;
                if (convSumG < 0)
                    convSumG = 0;
                if (convSumB < 0)
                    convSumB = 0;
                if (convSumR > UCHAR_MAX)
                    convSumR = UCHAR_MAX;
                if (convSumG > UCHAR_MAX)
                    convSumG = UCHAR_MAX;
                if (convSumB > UCHAR_MAX)
                    convSumB = UCHAR_MAX;
                destData[destBytesPerRow * y + destBytesPerPixel * x]     = (unsigned char)convSumR;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 1] = (unsigned char)convSumG;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 2] = (unsigned char)convSumB;
            }
            /* right band */
            for (x = (w - 3); x < w; x++)
            {
                convSumR = 0;
                convSumG = 0;
                convSumB = 0;
                for (i = -2; i <= 2; i++)
                {
                    for (j = -2; j <= -1 - (x - w); j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                    for (j = 0 - (x - w); j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel + 2];
                    }
                }
                convSumR += offset;
                convSumG += offset;
                convSumB += offset;
                convSumR = (int)rint((float)convSumR / scale);
                convSumG = (int)rint((float)convSumG / scale);
                convSumB = (int)rint((float)convSumB / scale);
                if (convSumR < 0)
                    convSumR = 0;
                if (convSumG < 0)
                    convSumG = 0;
                if (convSumB < 0)
                    convSumB = 0;
                if (convSumR > UCHAR_MAX)
                    convSumR = UCHAR_MAX;
                if (convSumG > UCHAR_MAX)
                    convSumG = UCHAR_MAX;
                if (convSumB > UCHAR_MAX)
                    convSumB = UCHAR_MAX;
                destData[destBytesPerRow * y + destBytesPerPixel * x]     = (unsigned char)convSumR;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 1] = (unsigned char)convSumG;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 2] = (unsigned char)convSumB;
            }
        }
        for (y = h - 3; y < h; y++)
        {
            /* bottom left corner */
            for (x = 0; x < (0 + 2); x++)
            {
                convSumR = 0;
                convSumG = 0;
                convSumB = 0;
                for (i = -2; i <= -1 - (y - h); i++)
                {
                    for (j = -2; j <= -1 - x; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel + 2];
                    }
                    for (j = 0 - x; j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                }
                for (i = 0 - (y - h); i <= 2; i++)
                {
                    for (j = -2; j <= -1 - x; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel + 2];
                    }
                    for (j = 0 - x; j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                }
                convSumR += offset;
                convSumG += offset;
                convSumB += offset;
                convSumR = (int)rint((float)convSumR / scale);
                convSumG = (int)rint((float)convSumG / scale);
                convSumB = (int)rint((float)convSumB / scale);
                if (convSumR < 0)
                    convSumR = 0;
                if (convSumG < 0)
                    convSumG = 0;
                if (convSumB < 0)
                    convSumB = 0;
                if (convSumR > UCHAR_MAX)
                    convSumR = UCHAR_MAX;
                if (convSumG > UCHAR_MAX)
                    convSumG = UCHAR_MAX;
                if (convSumB > UCHAR_MAX)
                    convSumB = UCHAR_MAX;
                destData[destBytesPerRow * y + destBytesPerPixel * x]     = (unsigned char)convSumR;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 1] = (unsigned char)convSumG;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 2] = (unsigned char)convSumB;
            }
            /* bottom band */
            for (x = (0 + 2); x < (w - 3); x++)
            {
                convSumR = 0;
                convSumG = 0;
                convSumB = 0;
                for (i = -2; i <= -1 - (y - h); i++)
                    for (j = -2; j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                for (i = 0 - (y - h); i <= 2; i++)
                    for (j = -2; j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                        convSumR += offset;
                convSumG += offset;
                convSumB += offset;
                convSumR = (int)rint((float)convSumR / scale);
                convSumG = (int)rint((float)convSumG / scale);
                convSumB = (int)rint((float)convSumB / scale);
                if (convSumR < 0)
                    convSumR = 0;
                if (convSumG < 0)
                    convSumG = 0;
                if (convSumB < 0)
                    convSumB = 0;
                if (convSumR > UCHAR_MAX)
                    convSumR = UCHAR_MAX;
                if (convSumG > UCHAR_MAX)
                    convSumG = UCHAR_MAX;
                if (convSumB > UCHAR_MAX)
                    convSumB = UCHAR_MAX;
                destData[destBytesPerRow * y + destBytesPerPixel * x]     = (unsigned char)convSumR;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 1] = (unsigned char)convSumG;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 2] = (unsigned char)convSumB;
            } 
            /* bottom right corner */
            for (x = (w - 3); x < w; x++)
            {
                convSumR = 0;
                convSumG = 0;
                convSumB = 0;
                for (i = -2; i <= -1 - (y - h); i++)
                {
                    for (j = -2; j <= -1 - (x - w); j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                    for (j = 0 - (x - w); j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel + 2];
                    }
                }
                for (i = 0 - (y - h); i <= 2; i++)
                {
                    for (j = -2; j <= -1 - (x - w); j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                    for (j = 0 - (x - w); j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel + 2];
                    }
                }
                convSumR += offset;
                convSumG += offset;
                convSumB += offset;
                convSumR = (int)rint((float)convSumR / scale);
                convSumG = (int)rint((float)convSumG / scale);
                convSumB = (int)rint((float)convSumB / scale);
                if (convSumR < 0)
                    convSumR = 0;
                if (convSumG < 0)
                    convSumG = 0;
                if (convSumB < 0)
                    convSumB = 0;
                if (convSumR > UCHAR_MAX)
                    convSumR = UCHAR_MAX;
                if (convSumG > UCHAR_MAX)
                    convSumG = UCHAR_MAX;
                if (convSumB > UCHAR_MAX)
                    convSumB = UCHAR_MAX;
                destData[destBytesPerRow * y + destBytesPerPixel * x]     = (unsigned char)convSumR;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 1] = (unsigned char)convSumG;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 2] = (unsigned char)convSumB;
            }
        } 
        

        /* the core */
        for (y = 0 + 2; y < h - 3; y++)
            for (x = (0 + 2); x < (w - 3); x++)
            {
                convSumR = 0;
                convSumG = 0;
                convSumB = 0;
                for (i = -2; i <= 2; i++)
                    for (j = -2; j <= 2; j++)
                    {
                        convSumR += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                        convSumG += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 1];
                        convSumB += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel + 2];
                    }
                convSumR += offset;
                convSumG += offset;
                convSumB += offset;
                convSumR = (int)rint((float)convSumR / scale);
                convSumG = (int)rint((float)convSumG / scale);
                convSumB = (int)rint((float)convSumB / scale);
                if (convSumR < 0)
                    convSumR = 0;
                if (convSumG < 0)
                    convSumG = 0;
                if (convSumB < 0)
                    convSumB = 0;
                if (convSumR > UCHAR_MAX)
                    convSumR = UCHAR_MAX;
                if (convSumG > UCHAR_MAX)
                    convSumG = UCHAR_MAX;
                if (convSumB > UCHAR_MAX)
                    convSumB = UCHAR_MAX;
                destData[destBytesPerRow * y + destBytesPerPixel * x]     = (unsigned char)convSumR;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 1] = (unsigned char)convSumG;
                destData[destBytesPerRow * y + destBytesPerPixel * x + 2] = (unsigned char)convSumB;
            }
    } else
    {
        int convSum;
        
        if (autoScale)
        {
            if (progPanel != nil)
            {
                [self setActivity:@"Evaluating range"];
                [self advanceProgress];
            }
            minVal = INT_MAX;
            maxVal = INT_MIN;
            
            /* calibrate output range */
            for (y = 0 + 2; y < h - 3; y++)
                for (x = 0 + 2; x < w - 3; x++)
                {
                    convSum = 0;
                    for (i = -2; i <= 2; i++)
                        for (j = -2; j <= 2; j++)
                            convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];

                    if (convSum > maxVal)
                        maxVal = convSum;
                    if (convSum < minVal)
                        minVal = convSum;
                }
            printf("Max %d, min %d\n", maxVal, minVal);
            normalizeFactor = (float)fabs(maxVal -minVal)/(float)UCHAR_MAX;
            printf("normalize factor: %f\n", normalizeFactor);
            offset = -minVal;
            scale = normalizeFactor;
        }
        
        printf("offset: %d, scale:%f\n", offset, scale);
        
        if (progPanel != nil)
        {
            [self setActivity:@"convolving"];
            [self advanceProgress];
        }
        
        /* execute the actual filtering */
        /* the borders */
        for (y = 0; y < 0 + 2; y++)
        {
            /* top left corner */     
            for (x = 0; x < 0 + 2; x++)
            {
                convSum = 0;
                for (i = -2; i <= -1 - y; i++)
                {
                    for (j = -2; j <= -1 - x; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel];
                    for (j = 0 - x; j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                }
                for (i = 0 - y; i <= 2; i++)
                {
                    for (j = -2; j <= -1 - x; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel];
                    for (j = 0 - x; j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                }
                convSum += offset;
                convSum = (int)rint((float)convSum / scale);         
                if (convSum < 0)
                    convSum = 0;
                if (convSum > UCHAR_MAX)
                    convSum = UCHAR_MAX;  
                destData[destBytesPerRow * y + destBytesPerPixel * x] = (unsigned char)convSum;
            }
            /* top band */
            for (x = 0 + 2; x < w - 3; x++)
            {
                convSum = 0;
                for (i = -2; i <= -1 - y; i++)
                    for (j = -2; j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                for (i = 0 - y; i <= 2; i++)
                    for (j = -2; j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                convSum += offset;
                convSum = (int)rint((float)convSum / scale);         
                if (convSum < 0)
                    convSum = 0;
                if (convSum > UCHAR_MAX)
                    convSum = UCHAR_MAX;  
                destData[destBytesPerRow * y + destBytesPerPixel * x] = (unsigned char)convSum;
            }
            /* top right corner */     
            for (x = w - 3; x < w; x++)
            {
                convSum = 0;
                for (i = -2; i <= -1 - y; i++)
                {
                    for (j = -2; j <= -1 - (x - w); j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                    for (j = 0 - (x - w); j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+(-i-1)) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel];
                }
                for (i = 0 - y; i <= 2; i++)
                {
                    for (j = -2; j <= -1 - (x - w); j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                    for (j = 0 - (x - w); j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel];
                }
                convSum += offset;
                convSum = (int)rint((float)convSum / scale);         
                if (convSum < 0)
                    convSum = 0;
                if (convSum > UCHAR_MAX)
                    convSum = UCHAR_MAX;  
                destData[destBytesPerRow * y + destBytesPerPixel * x] = (unsigned char)convSum;
            }
        }
        for (y = 0 + 2; y < h - 3; y++)
        {
            /* left band */
            for (x = 0; x < 0 + 2; x++)
            {
                convSum = 0;
                for (i = -2; i <= 2; i++)
                {
                    for (j = -2; j <= -1 - x; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel];
                    for (j = 0 - x; j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                }
                convSum += offset;
                convSum = (int)rint((float)convSum / scale);         
                if (convSum < 0)
                    convSum = 0;
                if (convSum > UCHAR_MAX)
                    convSum = UCHAR_MAX;  
                destData[destBytesPerRow * y + destBytesPerPixel * x] = (unsigned char)convSum;
            }
            /* right band */
            for (x = w - 3; x < w; x++)
            {
                convSum = 0;
                for (i = -2; i <= 2; i++)
                {
                    for (j = -2; j <= -1 - (x - w); j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                    for (j = 0 - (x - w); j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel];
                }
                convSum += offset;
                convSum = (int)rint((float)convSum / scale);         
                if (convSum < 0)
                    convSum = 0;
                if (convSum > UCHAR_MAX)
                    convSum = UCHAR_MAX;  
                destData[destBytesPerRow * y + destBytesPerPixel * x] = (unsigned char)convSum;
            }
        }
        for (y = h - 3; y < h; y++)
        {
            /* bottom left corner */     
            for (x = 0; x < 0 + 2; x++)
            {
                convSum = 0;
                for (i = -2; i <= -1 - (y - h); i++)
                {
                    for (j = -2; j <= -1 - x; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel];
                    for (j = 0 - x; j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                }
                for (i = 0 - (y - h); i <= 2; i++)
                {
                    for (j = -2; j <= -1 - x; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+(-j-1))*srcBytesPerPixel];
                    for (j = 0 - x; j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                }
                convSum += offset;
                convSum = (int)rint((float)convSum / scale);         
                if (convSum < 0)
                    convSum = 0;
                if (convSum > UCHAR_MAX)
                    convSum = UCHAR_MAX;  
                destData[destBytesPerRow * y + destBytesPerPixel * x] = (unsigned char)convSum;
            }
            /* bottom band */
            for (x = 0 + 2; x < w - 3; x++)
            {
                convSum = 0;
                for (i = -2; i <= -1 - (y - h); i++)
                    for (j = -2; j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                for (i = 0 - (y - h); i <= 2; i++)
                    for (j = -2; j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                convSum += offset;
                convSum = (int)rint((float)convSum / scale);         
                if (convSum < 0)
                    convSum = 0;
                if (convSum > UCHAR_MAX)
                    convSum = UCHAR_MAX;  
                destData[destBytesPerRow * y + destBytesPerPixel * x] = (unsigned char)convSum;
            }
            /* bottom right corner */     
            for (x = w - 3; x < w; x++)
            {
                convSum = 0;
                for (i = -2; i <= -1 - (y - h); i++)
                {
                    for (j = -2; j <= -1 - (x - w); j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                    for (j = 0 - (x - w); j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel];
                }
                for (i = 0 - (y - h); i <= 2; i++)
                {
                    for (j = -2; j <= -1 - (x - w); j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                    for (j = 0 - (x - w); j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+(-i+1)) * srcBytesPerRow + (x+(-j+1))*srcBytesPerPixel];
                }
                convSum += offset;
                convSum = (int)rint((float)convSum / scale);         
                if (convSum < 0)
                    convSum = 0;
                if (convSum > UCHAR_MAX)
                    convSum = UCHAR_MAX;  
                destData[destBytesPerRow * y + destBytesPerPixel * x] = (unsigned char)convSum;
            }
        }
        /* the core */
        for (y = 0 + 2; y < h - 3; y++)
            for (x = 0 + 2; x < w - 3; x++)
            {
                convSum = 0;
                for (i = -2; i <= 2; i++)
                    for (j = -2; j <= 2; j++)
                        convSum += convMat[i+2][j+2] * (int)srcData[(y+i) * srcBytesPerRow + (x+j)*srcBytesPerPixel];
                convSum += offset;
                convSum = (int)rint((float)convSum / scale);         
                if (convSum < 0)
                    convSum = 0;
                if (convSum > UCHAR_MAX)
                    convSum = UCHAR_MAX;  
                destData[destBytesPerRow * y + destBytesPerPixel * x] = (unsigned char)convSum;
            }
    }
        
    /* preserve Alpha Channel if present */
    if (hasAlpha)
      {
        for (y = 0; y < h; y++)
          for (x = 0; x < w; x++)
            destData[destBytesPerRow * y + destBytesPerPixel * x + (destSamplesPerPixel-1)] = srcData[srcBytesPerRow * y + srcBytesPerPixel * x + (srcSamplesPerPixel-1)];
      }
    
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
