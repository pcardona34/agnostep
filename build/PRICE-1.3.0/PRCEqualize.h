//
//  PRCEqualize.h
//  PRICE
//  Image Equalization Controller
//
//  Created by Riccardo Mottola on Fri Dec 05 2003.
//  Copyright (c) 2003-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>

#import "PRFilterController.h"

@interface PRCEqualize : PRFilterController
{
    IBOutlet NSWindow *equalWindow;
    IBOutlet NSPopUpButton *colorSpaceChoice;
}

@end
