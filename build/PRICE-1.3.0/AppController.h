//
//  AppController.h
//  PRICE
//
//  Created by Riccardo Mottola on Thu Dec 12 2002.
//  Copyright (c) 2002-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>

#import "PRPreviewController.h"

#define prefEnlargeWindowsKey @"auto enlarge windows"
#define prefClosePanelsKey @"close panels"

#define prefEnlargeWindowsDefault YES
#define prefClosePanelsDefault NO

@interface AppController : NSObject
{
    IBOutlet NSPanel  *prefPanel;
    IBOutlet NSButton *closePanelsCheck;
    IBOutlet NSButton *enlargeWindowsCheck;
    
    PRPreviewController *previewController;
    
    @private BOOL     prefClosePanels;
    @private BOOL     prefEnlargeWindows;
}

- (IBAction) showPreferences:(id)sender;
- (IBAction) savePreferences:(id)sender;
- (IBAction) cancelPreferences:(id)sender;

- (PRPreviewController *) previewController;

- (BOOL) prefClosePanels;
- (BOOL) prefEnlargeWindows;

@end
