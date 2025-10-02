//
//  PRCDFTHighPass.h
//  PRICE
//  DFT based HighPass filter controller
//
//  Created by Riccardo Mottola on Mon Oct 13 2003.
//  Copyright (c) 2003-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import <AppKit/AppKit.h>

#import "PRFilterController.h"


@interface PRCDFTHighPass : PRFilterController
{
    IBOutlet NSWindow    *filterWindow;
    IBOutlet NSButton    *autoRangeCheck;
    IBOutlet NSSlider    *passBandSlider;
    IBOutlet NSSlider    *stopBandSlider;
    IBOutlet NSTextField *passBandVal;
    IBOutlet NSTextField *passBandValPi;
    IBOutlet NSTextField *stopBandVal;
    IBOutlet NSTextField *stopBandValPi;
    float passBandFreq;
    float stopBandFreq;
    BOOL autoRange;
}

- (IBAction)dftHPAutoRange:(id)sender;
- (IBAction)changeStopBand:(id)sender;
- (IBAction)changePassBand:(id)sender;

@end
