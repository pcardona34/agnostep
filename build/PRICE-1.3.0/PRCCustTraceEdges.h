//
//  PRCCustTraceEdges.h
//  PRICE
//
//  Created by Riccardo Mottola on Thu Mar 18 2004.
//  Copyright (c) 2004-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>

#import "PRFilterController.h"


@interface PRCCustTraceEdges : PRFilterController
{
    IBOutlet NSWindow *edgeWindow;
    IBOutlet NSSlider *thresholdSlider;
    IBOutlet NSButton *zeroCrossCheck;
    IBOutlet NSTextField *thresholdField;
    IBOutlet NSPopUpButton *filterType;
    float thresholdLevel;
    IBOutlet NSButton *enableCheck1;
    IBOutlet NSButton *separableCheck1;
    IBOutlet NSPopUpButton *formSelect1;
    IBOutlet NSTextField *sizeField1;
    IBOutlet NSSlider *sizeSlider1;
    IBOutlet NSButton *enableCheck2;
    IBOutlet NSButton *separableCheck2;
    IBOutlet NSPopUpButton *formSelect2;
    IBOutlet NSTextField *sizeField2;
    IBOutlet NSSlider *sizeSlider2;
    IBOutlet NSButton *enableCheck3;
    IBOutlet NSButton *separableCheck3;
    IBOutlet NSPopUpButton *formSelect3;
    IBOutlet NSTextField *sizeField3;
    IBOutlet NSSlider *sizeSlider3;
}

- (IBAction)changeSize1:(id)sender;
- (IBAction)changeSize2:(id)sender;
- (IBAction)changeSize3:(id)sender;
- (IBAction)enablePane1:(id)sender;
- (IBAction)enablePane2:(id)sender;
- (IBAction)enablePane3:(id)sender;
- (IBAction)toggleStatePane1:(BOOL) state;
- (IBAction)toggleStatePane2:(BOOL) state;
- (IBAction)toggleStatePane3:(BOOL) state;
- (IBAction)changeThreshold:(id)sender;

@end
