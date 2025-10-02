//
//  PRFilterController.m
//  PRICE
//  Filter Controller
//
//  Created by Riccardo Mottola on 2/19/10.
//  Copyright 2010-2011 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import "PRFilterController.h"
#import "PRImage.h"
#import "PRFilter.h"
#import "MyDocument.h"

@implementation PRFilterController

- (void)dealloc
{
  [oldParameters release];
  [filter release];
  [super dealloc];
}

/** generic action to be called when the filter parameters change
    and update of the preview is desired */
- (IBAction)parametersChanged:(id)sender
{
  NSArray *newParameters;
  
  newParameters = [self encodeParameters];
  
  if (oldParameters && [newParameters isEqualToArray:oldParameters])
    return;
  
  [newParameters retain];
  [oldParameters release];
  oldParameters = newParameters;
  if ([previewController continuous])
    [previewController updatePreview:sender];
}


/** method to encode the interface settings and pass them as an array to the filter
    it needs to be sublcassed by each filter controller */
- (NSArray *)encodeParameters
{
    return nil;
}

/** shows the filter panel */
- (IBAction)showFilter:(id)sender
{
    previewController = [[NSApp delegate] previewController];
    [previewController setFilterController: self];
    [previewController cleanPreview:self];
    [previewController showPreview];
}

/** method to hide the filter panel. This needs to be overridden.
    This method gets invoked if necessary at the end of filterOk.
    This method gets invoked on filterCancel */
- (void)closeFilterPanel
{
    NSLog(@"closeFilterPanel: This method should be overridden.");
}

/** action invoked to run the filter */
- (IBAction)filterOK:(id)sender
{
    [[[NSDocumentController sharedDocumentController] currentDocument] runFilter:filter with:[self encodeParameters]];
    
    if ([[NSApp delegate] prefClosePanels])
    {
        [self closeFilterPanel];
        [previewController hidePreview]; 
    }
}

/** action invoked by cancelling the filter action */
- (IBAction)filterCancel:(id)sender
{
  [self closeFilterPanel];
  [previewController hidePreview]; 
}

- (PRImage *)filteredImage
{
  PRImage           *img;
    
  img = [filter filterImage:[[[NSDocumentController sharedDocumentController] currentDocument] activeImage] with:[self encodeParameters] progressPanel:previewController];
    
  return img;
}

@end
