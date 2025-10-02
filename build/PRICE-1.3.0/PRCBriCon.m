//
//  PRCBriCon.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu Mar 3 2005.
//  Copyright (c) 2005-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

// for values > 1
// the minimum is from 126 to 127: 1.008
// 125 to 127: 1.015
// the maximum is from 1 to 127: 127

#include <stdlib.h>

#import "PRCBriCon.h"
#import "PRBriCon.h"
#import "MyDocument.h"

#include <limits.h>

#define HALF_CHAR (UCHAR_MAX >> 1)

@implementation PRCBriCon

- (id)init
{
    if ((self = [super init]))
    {
        filter = [[PRBriCon alloc] init];
    }
    return self;
}

- (IBAction)showFilter:(id)sender
{
    [super showFilter:sender];

    if (!briconWindow)
        [NSBundle loadNibNamed:@"BriCon" owner:self];
    [briconWindow makeKeyAndOrderFront:nil];
    
    [self parametersChanged:self];
}


- (NSArray *)encodeParameters
{
    NSArray  *parameters;
    float    contrast;
    int      level;
    
    level = [conVal intValue];
    contrast = 1 + (float)abs(level)/HALF_CHAR;
    if (level < 0)
        contrast = 1 / contrast;
    
    /* encode parameters */
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:[briVal intValue]],
        [NSNumber numberWithFloat:contrast],
        nil];
    
    return parameters;
}

- (void)closeFilterPanel
{
    [briconWindow performClose:nil];
}

- (IBAction)briconReset:(id)sender
{
    [briSlider setIntValue:0];
    [briStep setIntValue:0];
    [briVal setIntValue:0];
    [conSlider setFloatValue:0.0];
    [conStep setFloatValue:0.0];
    [conVal setFloatValue:0.0];
    [self parametersChanged:sender];
}

- (IBAction)changeBri:(id)sender
{
    if (sender == briVal)
    {
        int tempVal;
        
        tempVal = [sender intValue];
        if (tempVal > 255)
        {
            tempVal = 255;
            [briVal setIntValue:tempVal];
        } else if (tempVal < -255)
        {
            tempVal = -255;
            [briVal setIntValue:tempVal];
        }
        [briSlider setIntValue:tempVal];
        [briStep setIntValue:tempVal];
    } else if (sender == briStep)
    {
        [briSlider setIntValue:[sender intValue]];
        [briVal setIntValue:[sender intValue]];
    } else if (sender == briSlider)
    {
        [briVal setIntValue:[sender intValue]];
        [briStep setIntValue:[sender intValue]];
    } else
        NSLog(@"undexpected sender value in changeBri");
    [self parametersChanged:sender];
}

- (IBAction)changeCon:(id)sender
{
    if (sender == conVal)
    {
        int tempVal;
        
        tempVal = [sender intValue];
        if (tempVal > 127)
        {
            tempVal = 127;
            [briVal setIntValue:tempVal];
        } else if (tempVal < -127)
        {
            tempVal = -127;
            [briVal setIntValue:tempVal];
        }
        [conSlider setIntValue:tempVal];
        [conStep setIntValue:tempVal];
    } else if (sender == conStep)
    {
        [conSlider setIntValue:[sender intValue]];
        [conVal setIntValue:[sender intValue]];
    } else if (sender == conSlider)
    {
        [conVal setIntValue:[sender intValue]];
        [conStep setIntValue:[sender intValue]];
    } else
        NSLog(@"undexpected sender value in changeCon");
    [self parametersChanged:sender];
}

@end
