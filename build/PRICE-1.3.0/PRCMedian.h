//
//  PRCMedian.h
//  PRICE
//
//  Created by Riccardo Mottola on Thu Mar 25 2004.
//  Copyright (c) 2004-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import <AppKit/AppKit.h>

#import "PRFilterController.h"

@interface PRCMedian : PRFilterController
{
    IBOutlet NSWindow *medianWindow;
    IBOutlet NSButton *separableCheck;
    IBOutlet NSPopUpButton *formSelect;
    IBOutlet NSTextField *sizeField;
    IBOutlet NSSlider *sizeSlider;
}

- (IBAction)changeSize:(id)sender;

@end
