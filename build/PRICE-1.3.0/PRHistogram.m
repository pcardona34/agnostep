//
//  PRHistogram.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu Dec 11 2003.
//  Copyright (c) 2003-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRHistogram.h"
#import "PRCHistogram.h"


@implementation PRHistogram

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        calculationsDone = NO;
    }
    return self;
}

- (void)setImage :(PRImage *)image
{
    theImage = image;
}

- (void)drawRect :(NSRect)rect
{
    if (calculationsDone) /* only redraw if the data is valid */
        [self displayHistogram :rect];
}

- (void)calculateHistogram
{
  NSBitmapImageRep *theImageRep;
  unsigned char *theData;
  NSInteger w, h;
  NSInteger x, y;
  NSInteger i;
  register NSInteger srcBytesPerPixel;
  register NSInteger srcBytesPerRow;
  NSInteger pixNum;
  unsigned long int histogramDenorm[UCHAR_MAX+1];  /* not normalized pixel count for each level */
  unsigned long int histogramDenormR[UCHAR_MAX+1]; /* not normalized pixel count for each level */
  unsigned long int histogramDenormG[UCHAR_MAX+1]; /* not normalized pixel count for each level */
  unsigned long int histogramDenormB[UCHAR_MAX+1]; /* not normalized pixel count for each level */


    /* get source image representation and associated information */
    theImageRep = [theImage bitmapRep];
    
    w = [theImageRep pixelsWide];
    h = [theImageRep pixelsHigh];
    pixNum = h * w;
    srcBytesPerRow = [theImageRep bytesPerRow];
    srcBytesPerPixel = [theImageRep bitsPerPixel] / 8;

    /* check bith depth and color/greyscale image */
    hasColor = [theImage hasColor];
    NSLog(@"Colorimage? %d", hasColor);
    
    theData = [theImageRep bitmapData];
    
    if (hasColor)
    {
        /* calculate the histogram */
        for (i = 0; i <= UCHAR_MAX; i++)
            histogramDenormR[i] = histogramDenormG[i] = histogramDenormB[i] = 0;
        for (y = 0; y < h; y++)
            for (x = 0; x < w; x++)
            {
                histogramDenormR[theData[y*srcBytesPerRow + x*srcBytesPerPixel]]++;
                histogramDenormG[theData[y*srcBytesPerRow + x*srcBytesPerPixel + 1]]++;
                histogramDenormB[theData[y*srcBytesPerRow + x*srcBytesPerPixel + 2]]++;
            }

        /* normalize histogram */
        /* calculate the maximum luminance as maxHisto */
        maxHisto = 0;
        for (i = 0; i <= UCHAR_MAX; i++)
        {
            histogramR[i] = (float)histogramDenormR[i] / (float)pixNum;
            histogramG[i] = (float)histogramDenormG[i] / (float)pixNum;
            histogramB[i] = (float)histogramDenormB[i] / (float)pixNum;
            if (histogramR[i] + histogramG[i] + histogramB[i] > maxHisto)
                maxHisto = histogramR[i] + histogramG[i] + histogramB[i];
        }

        /* cumulative histogram */
        maxCumulativeHisto = 0;
        cumulativeHistogramR[0] = histogramR[0];
        cumulativeHistogramG[0] = histogramG[0];
        cumulativeHistogramB[0] = histogramB[0];
        for (i = 1; i <= UCHAR_MAX; i++)
        {
            cumulativeHistogramR[i] = cumulativeHistogramR[i-1] + histogramR[i];
            cumulativeHistogramG[i] = cumulativeHistogramG[i-1] + histogramG[i];
            cumulativeHistogramB[i] = cumulativeHistogramB[i-1] + histogramB[i];
            if (cumulativeHistogramR[i] + cumulativeHistogramG[i] + cumulativeHistogramB[i] > maxCumulativeHisto)
                maxCumulativeHisto = cumulativeHistogramR[i] + cumulativeHistogramG[i] + cumulativeHistogramB[i];
        }
    } else
    {
        /* calculate the histogram */
        for (i = 0; i <= UCHAR_MAX; i++)
            histogramDenorm[i] = 0;
        for (y = 0; y < h; y++)
            for (x = 0; x < w; x++)
                histogramDenorm[theData[y*srcBytesPerRow + x*srcBytesPerPixel]]++;
    
        /* normalize histogram */
        maxHisto = 0;
        for (i = 0; i <= UCHAR_MAX; i++)
        {
            histogram[i] = (float)histogramDenorm[i] / (float)pixNum;
            if (histogram[i] > maxHisto)
                maxHisto = histogram[i];
        }
        
        /* cumulative histogram */
        maxCumulativeHisto = 0;
        cumulativeHistogram[0] = histogram[0];
        for (i = 1; i <= UCHAR_MAX; i++)
        {
            cumulativeHistogram[i] = cumulativeHistogram[i-1] + histogram[i];
            if (cumulativeHistogram[i] > maxCumulativeHisto)
                maxCumulativeHisto = cumulativeHistogram[i];
        }
    }
    
    calculationsDone = YES;
}


- (void)displayHistogram :(NSRect)viewRect
{
    NSLog(@"Parent Histogram drawing. Ovverride me!");
}


@end
