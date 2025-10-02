//
//  PRCTraceEdges.h
//  PRICE
//
//  Created by Riccardo Mottola on Wed Jan 14 2004.
//  Copyright (c) 2004-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


// we encode the filter type in the tag of the NSMenuItem of the NSPopUpButton
// 1: gradient, pixel difference
// 2: gradient, separated pixel difference
// 3: gradient, Roberts
// 4: gradient, Prewitt
// 5: gradient, Sobel
// 6: gradient, Abdou, hx
// 7: Laplacian 1, 4 neighbors
// 8: Laplacian 2, 8 neighbors
// 9: Laplacian, Prewitt, method 1

#import <AppKit/AppKit.h>

#import "PRFilterController.h"

@interface PRCTraceEdges : PRFilterController
{
    IBOutlet NSWindow *edgeWindow;
    IBOutlet NSButton *thresholdCheck;
    IBOutlet NSSlider *thresholdSlider;
    IBOutlet NSButton *zeroCrossCheck;
    IBOutlet NSTextField *thresholdField;
    IBOutlet NSPopUpButton *filterType;
    BOOL thresholdOn;
    float thresholdLevel;
}

- (IBAction)thresholdToggle:(id)sender;
- (IBAction)changeThreshold:(id)sender;
- (IBAction)filterTypeToggle:(id)sender;

@end
