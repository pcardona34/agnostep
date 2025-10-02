//
//  PRPreviewController.h
//  PRICE
//
//  Created by Riccardo Mottola on 2/19/10.
//  Copyright 2010-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import <AppKit/AppKit.h>

#import "PRImageView.h"
#import "PRFilterController.h"
#import "PRCProgress.h"

@interface PRPreviewController : NSObject <FilterProgress>
{
  IBOutlet NSPanel       *previewWindow;
  IBOutlet NSButton      *buttContinuous;
  IBOutlet PRImageView   *view;
  IBOutlet NSPopUpButton *scalePopUp;
  
  PRFilterController *filterController;
  
  IBOutlet NSProgressIndicator *progressBar;
  IBOutlet NSTextField         *activityDescription;
}

- (void)setFilterController: (PRFilterController *)filterController;

- (void)showPreview;
- (void)hidePreview;

- (BOOL)continuous;
- (void)setContinuous :(BOOL)flag;

- (IBAction)cleanPreview:(id)sender;
- (IBAction)updatePreview:(id)sender;

- (IBAction)scaleFromMenu:(id)sender;


@end
