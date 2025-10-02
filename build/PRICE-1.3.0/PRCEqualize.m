//
//  PRCEqualize.m
//  PRICE
//  Image Equalization Controller
//
//  Created by Riccardo Mottola on Fri Dec 05 2003.
//  Copyright (c) 2003-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCEqualize.h"
#import "PREqualize.h"
#import "MyDocument.h"

@implementation PRCEqualize

- (id)init
{
  if ((self = [super init]))
  {
    filter = [[PREqualize alloc] init];
  }
  return self;
}

- (IBAction)showFilter:(id)sender
{
  [super showFilter:sender];
  
    if (!equalWindow)
        [NSBundle loadNibNamed:@"Equalize" owner:self];
    [equalWindow makeKeyAndOrderFront:nil];

    [self parametersChanged:self];
}

- (NSArray *)encodeParameters
{
  NSArray    *parameters;
  int        index;
  int        space;
  
  index = [colorSpaceChoice indexOfSelectedItem];
  space = COLOR_SPACE_RGB;
  if (index == 0)
    space = COLOR_SPACE_RGB;
  else if (index == 1)
    space = COLOR_SPACE_YUV;
  
  /* encode parameters */
  parameters = [NSArray arrayWithObjects:
    [NSNumber numberWithInt:space],
    nil];
  
  return parameters;
}


- (void)closeFilterPanel
{
    [equalWindow performClose:nil];
}

@end
