//
//  PRCCrop.m
//  PRICE
//
//  Created by Riccardo Mottola on Fri Jan 28 2005.
//  Copyright (c) 2005-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCCrop.h"
#import "MyDocument.h"
#import "PRCrop.h"

@implementation PRCCrop

- (id)init
{
  if ((self = [super init]))
    {
      filter = [[PRCrop alloc] init];
    }
  return self;
}

- (IBAction)showFilter:(id)sender
{
    [super showFilter:sender];
  
    if (!cropWindow)
        [NSBundle loadNibNamed:@"Crop" owner:self];
    [cropWindow makeKeyAndOrderFront:nil];
    origWidth = [[[[NSDocumentController sharedDocumentController] currentDocument] activeImage] width];
    origHeight = [[[[NSDocumentController sharedDocumentController] currentDocument] activeImage] height];
    [self updateSize];
    
    [self parametersChanged:self];
}

- (NSArray *)encodeParameters
{
    NSArray    *parameters;

    /* encode parameters */
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:[topField intValue]],
        [NSNumber numberWithInt:[bottomField intValue]],
        [NSNumber numberWithInt:[leftField intValue]],
        [NSNumber numberWithInt:[rightField intValue]],
        nil];

    return parameters;
}


- (IBAction)changeTop:(id)sender
{
  [self updateSize];
  [self parametersChanged:self];
}

- (IBAction)changeBottom:(id)sender
{
  [self updateSize];
  [self parametersChanged:self];
}

- (IBAction)changeLeft:(id)sender
{
  [self updateSize];
  [self parametersChanged:self];
}

- (IBAction)changeRight:(id)sender
{
  [self updateSize];
  [self parametersChanged:self];
}

- (IBAction)resetValues:(id)sender
{
  [topField setIntValue:0];
  [bottomField setIntValue:0];
  [leftField setIntValue:0];
  [rightField setIntValue:0];

  [self parametersChanged:self];
}

- (void)updateSize
{
    [widthField setIntValue:(origWidth - [rightField intValue] - [leftField intValue])];
    [heightField setIntValue:(origHeight - [topField intValue] - [bottomField intValue])];
}

- (void)closeFilterPanel
{
  [cropWindow performClose:nil];
}

@end
