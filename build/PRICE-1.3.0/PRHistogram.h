//
//  PRHistogram.h
//  PRICE
//
//  Created by Riccardo Mottola on Thu Dec 11 2003.
//  Copyright (c) 2003-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>
#include <limits.h>
#import <PRImage.h>


@class PRCHistogram;

@interface PRHistogram : NSView
{
    float histogram[UCHAR_MAX+1];             /* normalized histogram */
    float cumulativeHistogram[UCHAR_MAX+1];   /* cumulative histogram */
    float histogramR[UCHAR_MAX+1];            /* normalized histogram */
    float histogramG[UCHAR_MAX+1];            /* normalized histogram */
    float histogramB[UCHAR_MAX+1];            /* normalized histogram */
    float cumulativeHistogramR[UCHAR_MAX+1];  /* cumulative histogram */
    float cumulativeHistogramG[UCHAR_MAX+1];  /* cumulative histogram */
    float cumulativeHistogramB[UCHAR_MAX+1];  /* cumulative histogram */
    float maxHisto;
    float maxCumulativeHisto;
    IBOutlet PRCHistogram *theController;
    PRImage *theImage;
    @private BOOL calculationsDone;
    @protected BOOL hasColor;
}

- (void)setImage :(PRImage *)image;
- (void)calculateHistogram;
- (void)displayHistogram :(NSRect)viewRect;

@end
