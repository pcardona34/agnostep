//
//  PRCConvolve55.h
//  PRICE
//  Convolve 5x5 Controller
//
//  Created by Riccardo Mottola on Tue Jan 21 2003.
//  Copyright (c) 2003-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>

#import "PRFilterController.h"


@interface PRCConvolve55 : PRFilterController
{
    IBOutlet NSWindow    *filterWindow;
    IBOutlet NSTextField *matField11;
    IBOutlet NSTextField *matField12;
    IBOutlet NSTextField *matField13;
    IBOutlet NSTextField *matField14;
    IBOutlet NSTextField *matField15;
    IBOutlet NSTextField *matField21;
    IBOutlet NSTextField *matField22;
    IBOutlet NSTextField *matField23;
    IBOutlet NSTextField *matField24;
    IBOutlet NSTextField *matField25;
    IBOutlet NSTextField *matField31;
    IBOutlet NSTextField *matField32;
    IBOutlet NSTextField *matField33;
    IBOutlet NSTextField *matField34;
    IBOutlet NSTextField *matField35;
    IBOutlet NSTextField *matField41;
    IBOutlet NSTextField *matField42;
    IBOutlet NSTextField *matField43;
    IBOutlet NSTextField *matField44;
    IBOutlet NSTextField *matField45;
    IBOutlet NSTextField *matField51;
    IBOutlet NSTextField *matField52;
    IBOutlet NSTextField *matField53;
    IBOutlet NSTextField *matField54;
    IBOutlet NSTextField *matField55;
    IBOutlet NSTextField *scaleField;
    IBOutlet NSTextField *offsetField;
    IBOutlet NSButton    *autoScaleCheck;
    int convMatrix[5][5];
    BOOL autoScale;
    int offset;
    float scale;
}

- (IBAction)convMatrix11:(id)sender;
- (IBAction)convMatrix12:(id)sender;
- (IBAction)convMatrix13:(id)sender;
- (IBAction)convMatrix14:(id)sender;
- (IBAction)convMatrix15:(id)sender;
- (IBAction)convMatrix21:(id)sender;
- (IBAction)convMatrix22:(id)sender;
- (IBAction)convMatrix23:(id)sender;
- (IBAction)convMatrix24:(id)sender;
- (IBAction)convMatrix25:(id)sender;
- (IBAction)convMatrix31:(id)sender;
- (IBAction)convMatrix32:(id)sender;
- (IBAction)convMatrix33:(id)sender;
- (IBAction)convMatrix34:(id)sender;
- (IBAction)convMatrix35:(id)sender;
- (IBAction)convMatrix41:(id)sender;
- (IBAction)convMatrix42:(id)sender;
- (IBAction)convMatrix43:(id)sender;
- (IBAction)convMatrix44:(id)sender;
- (IBAction)convMatrix45:(id)sender;
- (IBAction)convMatrix51:(id)sender;
- (IBAction)convMatrix52:(id)sender;
- (IBAction)convMatrix53:(id)sender;
- (IBAction)convMatrix54:(id)sender;
- (IBAction)convMatrix55:(id)sender;

- (IBAction)scaleFactor:(id)sender;
- (IBAction)offsetFactor:(id)sender;
- (IBAction)autoRange:(id)sender;

@end
