//
//  PRCGrayscale.m
//  PRICE
//  Grayscale Conversion Controller
//
//  Created by Riccardo Mottola on Tue Jan 16 2007.
//  Copyright (c) 2007-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCGrayscale.h"
#import "PRGrayscaleFilter.h"

@implementation PRCGrayscale

- (id)init
{
    if ((self = [super init]))
    {
        filter = [[PRGrayscaleFilter alloc] init];
    }
    return self;
}

- (IBAction)showFilter:(id)sender
{
    [super showFilter:sender];

    if (!grayWindow)
        [NSBundle loadNibNamed:@"Grayscale" owner:self];
    [grayWindow makeKeyAndOrderFront:nil];

    [self parametersChanged:self];
}

- (NSArray *)encodeParameters
{
    NSArray           *parameters;
    int               index;
    int               method;
    
    index = [methodChoice indexOfSelectedItem];
    if (index == 0)
      method = METHOD_AVERAGE;
    else if (index == 1)
      method = METHOD_LUMINANCE;
    else
      method = -1;

    /* encode parameters */
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:method],
        nil];

    return parameters;
}

- (void)closeFilterPanel
{
    [grayWindow performClose:nil];
}



@end
