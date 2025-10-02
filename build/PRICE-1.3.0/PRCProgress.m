//
//  PRCProgress.m
//  PRICE
//
//  Created by Riccardo Mottola on Mon Jun 21 2004.
//  Copyright (c) 2004-2012 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCProgress.h"


@implementation PRCProgress

- (IBAction)showProgress:(id)sender
{
    if (!progressPanel)
        [NSBundle loadNibNamed:@"ProgressPanel" owner:self];
    [progressPanel makeKeyAndOrderFront:nil];
}

- (void)setTitle:(NSString *)title
{
    [progressPanel setTitle:title];
    [progressPanel displayIfNeeded];
}

- (void)setProgress:(double)progress
{
    [progressBar setDoubleValue:progress];
    [progressPanel displayIfNeeded];
    [progressPanel flushWindowIfNeeded];
}

- (void)setActivity:(NSString *)title
{
    [activityDescription setStringValue:title];
    [progressPanel displayIfNeeded];
}

- (void) dealloc
{
    [progressPanel close];
    [super dealloc];
}

@end
