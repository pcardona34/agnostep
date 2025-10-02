//
//  PRCTraceEdges.m
//  PRICE
//
//  Created by Riccardo Mottola on Wed Jan 14 2004.
//  Copyright (c) 2004-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import "PRCTraceEdges.h"
#import "MyDocument.h"
#import "PRTraceEdges.h"


@implementation PRCTraceEdges

- (id)init
{
    if ((self = [super init]))
    {
        filter = [[PRTraceEdges alloc] init];
    }
    return self;
}

- (IBAction)showFilter:(id)sender
{
    [super showFilter:sender];
    
    if (!edgeWindow)
        [NSBundle loadNibNamed:@"TraceEdges" owner:self];
    [edgeWindow makeKeyAndOrderFront:nil];

    if ([thresholdCheck state] == NSOnState)
    {
        [thresholdSlider setEnabled:YES];
        [thresholdField setEnabled:YES];
        thresholdOn = YES;
        if ([[filterType selectedItem] tag] >= 7)
            [zeroCrossCheck setEnabled:YES];
    } else
    {
        [thresholdSlider setEnabled:NO];
        [thresholdField setEnabled:NO];
        thresholdOn = NO;
        [zeroCrossCheck setEnabled:NO];
    }
    thresholdLevel = [thresholdField floatValue];

    [self parametersChanged:self];
}

- (NSArray *)encodeParameters
{
    BOOL           zeroCrossOn;
    NSArray        *parameters;
    
    if ([zeroCrossCheck state] == NSOnState)
        zeroCrossOn = YES;
    else
        zeroCrossOn = NO;
        
    if ([[filterType selectedItem] tag] < 7)
    {
        [zeroCrossCheck setState:NO];
        zeroCrossOn = NO;
    }
    
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt: [[filterType selectedItem] tag]],
        [NSNumber numberWithBool: thresholdOn],
        [NSNumber numberWithFloat: thresholdLevel],
        [NSNumber numberWithBool: zeroCrossOn],
        nil];

    return parameters;
}

- (void)closeFilterPanel
{
    [edgeWindow performClose:nil];
}

- (IBAction)thresholdToggle:(id)sender
{
    thresholdOn = !thresholdOn;
    if (thresholdOn)
    {
        [thresholdSlider setEnabled:YES];
        [thresholdField setEnabled:YES];
        if ([[filterType selectedItem] tag] >= 7)
            [zeroCrossCheck setEnabled:YES];
    } else
    {
        [thresholdSlider setEnabled:NO];
        [thresholdField setEnabled:NO];
        [zeroCrossCheck setEnabled:NO];
    }
    [self parametersChanged:sender];
}

- (IBAction)changeThreshold:(id)sender
{
    thresholdLevel = [sender floatValue];
    [thresholdField setFloatValue:thresholdLevel];
    [self parametersChanged:sender];
}


- (IBAction)filterTypeToggle:(id)sender
{
    if ([[filterType selectedItem] tag] >= 7)
        [zeroCrossCheck setEnabled:YES];
    else
        [zeroCrossCheck setEnabled:NO];
    [self parametersChanged:sender];
}

@end
