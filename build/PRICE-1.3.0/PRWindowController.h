//
//  PRWindowController.h
//  PRICE
//
//  Created by Riccardo Mottola on Thu Dec 12 2002.
//  Copyright (c) 2002-2012 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <AppKit/AppKit.h>
#import "PRImageView.h"
#import "PRImage.h"


@interface PRWindowController : NSWindowController
{
    IBOutlet PRImageView   *view;
    IBOutlet NSTextField   *imageInfoLine;
    IBOutlet NSPanel       *scalePanel;
    IBOutlet NSTextField   *scalePanelScaleField;
    IBOutlet NSPopUpButton *scalePopUp;

    IBOutlet NSView        *saveOptionsView;
    IBOutlet NSPopUpButton *fileTypePopUp;
    IBOutlet NSTextField   *jpegCompressionField;
    IBOutlet NSSlider      *jpegCompressionSlider;
    
    float scale; /* image scaling factor */

    float compressionLevel;
}

- (void)scaleFromMenu:(id)sender;
- (void)scalePanelOk:(id)sender;
- (void)scalePanelCancel:(id)sender;
- (void)scaleImageTo:(float)internal_scale;
- (void)scaleImage;
- (void)setImageToDraw:(PRImage *)image;
- (void)setImageInfo:(PRImage *)image;
- (PRImageView *)view;

- (void)setWritableFileTypes:(NSArray *)types;
- (BOOL)prepareSavePanel:(NSSavePanel *)panel;
- (void)changeSaveType:(id)sender;
- (void)setCompressionType:(NSString *)type;
- (IBAction)setCompressionLevel:(id)sender;
- (float)compressionLevel;


@end
