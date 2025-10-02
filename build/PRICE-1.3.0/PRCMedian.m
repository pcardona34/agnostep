//
//  PRCMedian.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu Mar 25 2004.
//  Copyright (c) 2004-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import "PRCMedian.h"
#import "PRMedian.h"
#import "MyDocument.h"


@implementation PRCMedian

- (id)init
{
    if ((self = [super init]))
    {
        filter = [[PRMedian alloc] init];
    }
    return self;
}


- (IBAction)showFilter:(id)sender
{
    [super showFilter:sender];
    
    if (!medianWindow)
        [NSBundle loadNibNamed:@"Median" owner:self];
    [medianWindow makeKeyAndOrderFront:nil];

    [self parametersChanged:self];
}

- (NSArray *)encodeParameters
{
    enum medianForms theForm;
    BOOL             isSeparable;
    int              theSize;
    NSArray          *parameters;
    
    if ([separableCheck state] == NSOnState)
        isSeparable = YES;
    else
        isSeparable = NO;
    
    switch ([[formSelect selectedItem] tag])
    {
        case 1: theForm = HORIZONTAL_F;
            break;
        case 2: theForm = VERTICAL_F;
            break;
        case 3: theForm = CROSS_F;
            break;
        case 4: theForm = BOX_F;
            break;
        default: NSLog(@"Unrecognized form selected");
            theForm = BOX_F;
    }
    
    theSize = [sizeSlider intValue];
    
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt: theForm],
        [NSNumber numberWithInt: theSize],
        [NSNumber numberWithBool: isSeparable],
        nil];

    return parameters;
}


- (IBAction)changeSize:(id)sender
{
    [sizeField setIntValue :[sizeSlider intValue] * 2 + 1];
    [self parametersChanged:sender];
}

- (void)closeFilterPanel
{
    [medianWindow performClose:nil];
}


@end
