//
//  PRCBriCon.h
//  PRICE
//
//  Created by Riccardo Mottola on Thu Mar 3 2005.
//  Copyright (c) 2005-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>

#import "PRFilterController.h"


@interface PRCBriCon : PRFilterController
{
    IBOutlet NSWindow    *briconWindow;
    IBOutlet NSStepper   *briStep;
    IBOutlet NSSlider    *briSlider;
    IBOutlet NSTextField *briVal;
    IBOutlet NSStepper   *conStep;
    IBOutlet NSSlider    *conSlider;
    IBOutlet NSTextField *conVal;
}

- (IBAction)briconReset:(id)sender;
- (IBAction)changeBri:(id)sender;
- (IBAction)changeCon:(id)sender;

@end

