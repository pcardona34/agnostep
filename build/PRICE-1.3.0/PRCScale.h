//
//  PRCScale.h
//  PRICE
//
//  Created by Riccardo Mottola on Wed Jan 19 2005.
//  Copyright (c) 2005-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>

#import "PRFilterController.h"


@interface PRCScale : PRFilterController
{
  IBOutlet NSWindow      *scaleWindow;
  IBOutlet NSTextField   *pixelsXField;
  IBOutlet NSTextField   *pixelsYField;
  IBOutlet NSTextField   *percentXField;
  IBOutlet NSTextField   *percentYField;
  IBOutlet NSButton      *uniformToggle;
  IBOutlet NSPopUpButton *methodSelect;
  NSInteger              pixelsX;
  NSInteger              pixelsY;
  NSInteger              originalWidth;
  NSInteger              originalHeight;
  float                  ratio;
}

- (IBAction)changePixelsX:(id)sender;
- (IBAction)changePixelsY:(id)sender;
- (IBAction)changePercentX:(id)sender;
- (IBAction)changePercentY:(id)sender;

@end
