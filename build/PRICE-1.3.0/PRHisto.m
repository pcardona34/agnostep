//
//  PRHisto.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu Dec 18 2003.
//  Copyright (c) 2003-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRHisto.h"


@implementation PRHisto

- (void)displayHistogram :(NSRect)viewRect
{
    NSRect bar;
    NSBezierPath *bez;
    NSBezierPath *redBez, *greenBez, *blueBez;
    NSColor *fillRed, *fillGreen, *fillBlue;
    int i;
    float barWidth;
    float barHeightScale;
    
    NSLog(@"Standard Histogram drawing");
    NSLog(@"maxHisto: %f", maxHisto);
    
    barWidth = viewRect.size.width / UCHAR_MAX;
    barHeightScale =  viewRect.size.height / maxHisto;
    NSLog(@"frame height: %f", viewRect.size.height);
    NSLog(@"scale: %f", barHeightScale);
    bez = [NSBezierPath bezierPath];
    redBez = [NSBezierPath bezierPath];
    greenBez = [NSBezierPath bezierPath];
    blueBez = [NSBezierPath bezierPath];
    
    if (hasColor)
    {
        fillRed = [NSColor redColor];
        fillGreen = [NSColor greenColor];
        fillBlue = [NSColor blueColor];
        if (1)
        {
            for(i = 0; i < UCHAR_MAX; i++)
            {
                float redHeight;
                float greenHeight;
                float blueHeight;
                redHeight   = histogramR[i]*barHeightScale;
                greenHeight = histogramG[i]*barHeightScale;
                blueHeight  = histogramB[i]*barHeightScale;
                bar = NSMakeRect(i*barWidth, 0, barWidth, greenHeight);
                [greenBez appendBezierPathWithRect:bar];
                bar = NSMakeRect(i*barWidth, greenHeight, barWidth, redHeight);
                [redBez appendBezierPathWithRect:bar];
                bar = NSMakeRect(i*barWidth, greenHeight + redHeight, barWidth, blueHeight);
                [blueBez appendBezierPathWithRect:bar];
            }
            [fillRed set];
            [redBez fill];
            [fillGreen set];
            [greenBez fill];
            [fillBlue set];
            [blueBez fill];
        } else
        {
            for(i = 0; i < UCHAR_MAX; i++)
            {
                if (histogramR[i] > histogramG[i])
                {
                    if (histogramG[i] > histogramB[i])
                    {
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramG[i]*barHeightScale);
                        [greenBez appendBezierPathWithRect:bar];
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramB[i]*barHeightScale);
                        [blueBez appendBezierPathWithRect:bar];
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramR[i]*barHeightScale);
                        [redBez appendBezierPathWithRect:bar];
                    } else
                    {
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramB[i]*barHeightScale);
                        [blueBez appendBezierPathWithRect:bar];
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramG[i]*barHeightScale);
                        [greenBez appendBezierPathWithRect:bar];
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramR[i]*barHeightScale);
                        [redBez appendBezierPathWithRect:bar];
                    }
                }
                else
                {
                    if (histogramG[i] > histogramB[i])
                    {
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramG[i]*barHeightScale);
                        [greenBez appendBezierPathWithRect:bar];
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramB[i]*barHeightScale);
                        [blueBez appendBezierPathWithRect:bar];
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramR[i]*barHeightScale);
                        [redBez appendBezierPathWithRect:bar];
                    } else
                    {
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramB[i]*barHeightScale);
                        [blueBez appendBezierPathWithRect:bar];
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramG[i]*barHeightScale);
                        [greenBez appendBezierPathWithRect:bar];
                        bar = NSMakeRect(i*barWidth, 0, barWidth, histogramR[i]*barHeightScale);
                        [redBez appendBezierPathWithRect:bar];
                    }
                }
            }
            [fillRed set];
            [redBez fill];
            [fillGreen set];
            [greenBez fill];
            [fillBlue set];
            [blueBez fill];
        }
    } else /* greyscale */
    {
        for(i = 0; i < UCHAR_MAX; i++)
        {
            bar = NSMakeRect(i*barWidth, 0, barWidth, histogram[i]*barHeightScale);
            [bez appendBezierPathWithRect:bar];
        }
        [bez fill];
    }
}

@end
