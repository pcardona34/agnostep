//
//  PRCCrop.h
//  PRICE
//
//  Created by Riccardo Mottola on Fri Jan 28 2005.
//  Copyright (c) 2005-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>

#import "PRFilterController.h"

@interface PRCCrop : PRFilterController
{
  IBOutlet NSWindow *cropWindow;
  IBOutlet NSTextField *topField;
  IBOutlet NSTextField *bottomField;
  IBOutlet NSTextField *leftField;
  IBOutlet NSTextField *rightField;
  IBOutlet NSTextField *widthField;
  IBOutlet NSTextField *heightField;
  NSInteger origWidth;
  NSInteger origHeight;
}

- (IBAction)changeTop:(id)sender;
- (IBAction)changeBottom:(id)sender;
- (IBAction)changeLeft:(id)sender;
- (IBAction)changeRight:(id)sender;
- (IBAction)resetValues:(id)sender;
- (void)updateSize;

@end


