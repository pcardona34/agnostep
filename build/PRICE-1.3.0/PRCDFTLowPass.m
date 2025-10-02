//
//  PRCDFTLowPass.m
//  PRICE
//  DFT based LowPass filter controller
//
//  Created by Riccardo Mottola on Sat Sep 13 2003.
//  Copyright (c) 2003-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCDFTLowPass.h"
#import "MyDocument.h"
#include "math.h"
#import "PRDFTLowPass.h"


@implementation PRCDFTLowPass

- (id)init
{
    if ((self = [super init]))
    {
        filter = [[PRDFTLowPass alloc] init];
    }
    return self;
}

- (IBAction)showFilter:(id)sender
{
    [super showFilter:sender];

    if (!filterWindow)
        [NSBundle loadNibNamed:@"DFTLowPass" owner:self];
    [filterWindow makeKeyAndOrderFront:nil];
    
    /* now we read the default values and initialize all fields */
    if ([autoRangeCheck state] == NSOnState)
        autoRange = YES;
    else
        autoRange = NO;
    passBandFreq = [passBandSlider floatValue];
    [passBandVal setFloatValue:passBandFreq];
    [passBandValPi setFloatValue:(passBandFreq*M_PI)];    
    stopBandFreq = [stopBandSlider floatValue];
    [stopBandVal setFloatValue:stopBandFreq];
    [stopBandValPi setFloatValue:(stopBandFreq*M_PI)];
    
    [self parametersChanged:self];
}

- (NSArray *)encodeParameters
{
    NSArray      *parameters;
    
    /* encode parameters */
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithBool:autoRange],
        [NSNumber numberWithFloat:passBandFreq],
        [NSNumber numberWithFloat:stopBandFreq],
        nil];
    
    return parameters;
}

- (void)closeFilterPanel
{
    [filterWindow performClose:nil];
}

- (IBAction)dftLPAutoRange:(id)sender
{
    if ([autoRangeCheck state] == NSOnState)
        autoRange = YES;
    else
        autoRange = NO;
    [self parametersChanged:sender];
}

- (IBAction)changeStopBand:(id)sender
{
    if (sender == stopBandValPi)
    {
        stopBandFreq = [sender floatValue] / M_PI;
        if (stopBandFreq > 1)
        {
            stopBandFreq = 1;
            [stopBandValPi setFloatValue:(stopBandFreq*M_PI)];
        } else if (stopBandFreq < 0)
        {
            stopBandFreq = 0;
            [stopBandValPi setFloatValue:(stopBandFreq*M_PI)];
        }
        [stopBandVal setFloatValue:stopBandFreq];
        [stopBandSlider setFloatValue:stopBandFreq];
    } else if (sender == stopBandVal)
    {
        stopBandFreq = [sender floatValue];
        if (stopBandFreq > 1)
        {
            stopBandFreq = 1;
            [stopBandVal setFloatValue:stopBandFreq];
        } else if (passBandFreq < 0)
        {
            stopBandFreq = 0;
            [stopBandVal setFloatValue:stopBandFreq];
        }
        [stopBandValPi setFloatValue:(stopBandFreq*M_PI)];
        [stopBandSlider setFloatValue:stopBandFreq];
    } else
    {
        stopBandFreq = [sender floatValue];
        [stopBandVal setFloatValue:stopBandFreq];
        [stopBandValPi setFloatValue:(stopBandFreq*M_PI)];
    }
    if (passBandFreq > stopBandFreq)
    {
         passBandFreq = stopBandFreq;
        [passBandVal setFloatValue:passBandFreq];
        [passBandValPi setFloatValue:(passBandFreq*M_PI)];
        [passBandSlider setFloatValue:passBandFreq];
    }
    [self parametersChanged:sender];
}

- (IBAction)changePassBand:(id)sender
{
    if (sender == passBandValPi)
    {
        passBandFreq = [sender floatValue] / M_PI;
        if (passBandFreq > 1)
        {
            passBandFreq = 1;
            [passBandValPi setFloatValue:(passBandFreq*M_PI)];
        } else if (passBandFreq < 0)
        {
            passBandFreq = 0;
            [passBandValPi setFloatValue:(passBandFreq*M_PI)];
        }
        [passBandVal setFloatValue:passBandFreq];
        [passBandSlider setFloatValue:passBandFreq];
    } else if (sender == passBandVal)
    {
        passBandFreq = [sender floatValue];
        if (passBandFreq > 1)
        {
            passBandFreq = 1;
            [passBandVal setFloatValue:passBandFreq];
        } else if (passBandFreq < 0)
        {
            passBandFreq = 0;
            [passBandVal setFloatValue:passBandFreq];
        }
        [passBandValPi setFloatValue:(passBandFreq*M_PI)];
        [passBandSlider setFloatValue:passBandFreq];
    } else
    {
        passBandFreq = [sender floatValue];
        [passBandVal setFloatValue:passBandFreq];
        [passBandValPi setFloatValue:(passBandFreq*M_PI)];
    }
    if (stopBandFreq < passBandFreq)
    {
        stopBandFreq = passBandFreq;
        [stopBandVal setFloatValue:stopBandFreq];
        [stopBandValPi setFloatValue:(stopBandFreq*M_PI)];
        [stopBandSlider setFloatValue:stopBandFreq];
    }
    [self parametersChanged:sender];
}

@end
