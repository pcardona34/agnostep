//
//  PRProgressAction.h
//  PRICE
//
//  Created by Riccardo Mottola on Tue Jun 22 2004.
//  Copyright (c) 2004-2008 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>
#import "PRCProgress.h"
#import "PRFilter.h"

@interface PRProgressAction : PRFilter
{
    @protected PRCProgress* progPanel;
    @protected int          progressSteps;       /* completed steps up to that point */
    @protected int          totalProgressSteps;  /* total number of steps to complete the filter */
}

- (void) setActivity :(NSString *)description;
- (void) advanceProgress;
- (void) showProgress;

@end
