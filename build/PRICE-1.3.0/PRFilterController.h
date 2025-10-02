//
//  PRFilterController.h
//  PRICE
//  Filter Controller
//
//  Created by Riccardo Mottola on 2/19/10.
//  Copyright 2010-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import <AppKit/AppKit.h>

#import "PRImage.h"

@class PRPreviewController;
@class PRFilter;

@interface PRFilterController : NSObject
{
  PRPreviewController *previewController;
  PRFilter *filter;
  NSArray *oldParameters;
}

- (IBAction)showFilter:(id)sender;
- (IBAction)filterOK:(id)sender;
- (IBAction)filterCancel:(id)sender;
- (IBAction)parametersChanged:(id)sender;

- (void)closeFilterPanel;

- (NSArray *)encodeParameters;
- (PRImage *)filteredImage;

@end
