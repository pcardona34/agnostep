//
//  PRCScale.m
//  PRICE
//
//  Created by Riccardo Mottola on Wed Jan 19 2005.
//  Copyright (c) 2005-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#include <math.h>
#import "PRCScale.h"
#import "PRScale.h"
#import "MyDocument.h"


@implementation PRCScale

- (id)init
{
    if ((self = [super init]))
    {
        filter = [[PRScale alloc] init];
    }
    return self;
}

- (IBAction)changePixelsX:(id)sender
{
  pixelsX = [pixelsXField intValue];
  [percentXField setFloatValue:((float)pixelsX / originalWidth *100)];
  if ([uniformToggle intValue])
    {
      pixelsY = (int)rint(pixelsX * ratio);
      [pixelsYField setIntValue:pixelsY];
      [percentYField setFloatValue:[percentXField floatValue]];
    }
  [self parametersChanged:self];
}

- (IBAction)changePixelsY:(id)sender
{
  pixelsY = [pixelsYField intValue];
  [percentYField setFloatValue:((float)pixelsY / originalHeight *100)];
  if ([uniformToggle intValue])
    {
      pixelsX = (int)rint(pixelsY / ratio);
      [pixelsXField setIntValue:pixelsX];
      [percentXField setFloatValue:[percentYField floatValue]];
    }
  [self parametersChanged:self];
}

- (IBAction)changePercentX:(id)sender
{
  float percentX;

  percentX = [percentXField floatValue];
  pixelsX = (int)rint(originalWidth * (percentX / 100));
  [pixelsXField setIntValue:pixelsX];
  if ([uniformToggle intValue])
    {
      pixelsY = (int)rint(pixelsX * ratio);
      [pixelsYField setIntValue:pixelsY];
      [percentYField setFloatValue:percentX];
    }
  [self parametersChanged:self];
}

- (IBAction)changePercentY:(id)sender
{
  float percentY;

  percentY = [percentYField floatValue];
  pixelsY = (int)rint(originalHeight * (percentY / 100));
  [pixelsYField setIntValue:pixelsY];
  if ([uniformToggle intValue])
    {
      pixelsX = (int)rint(pixelsY / ratio);
      [pixelsXField setIntValue:pixelsX];
      [percentXField setFloatValue:percentY];
    }
  [self parametersChanged:self];
}

- (IBAction)showFilter:(id)sender
{
    [super showFilter:sender];

    if (!scaleWindow)
        [NSBundle loadNibNamed:@"Scale" owner:self];
    [scaleWindow makeKeyAndOrderFront:nil];
    pixelsX = [[[[NSDocumentController sharedDocumentController] currentDocument] activeImage] width];
    pixelsY = [[[[NSDocumentController sharedDocumentController] currentDocument] activeImage] height];
    originalWidth = pixelsX;
    originalHeight = pixelsY;
    ratio = (float)pixelsY / (float)pixelsX;
    [pixelsXField setIntValue:pixelsX];
    [pixelsYField setIntValue:pixelsY];
    [percentXField setFloatValue:100];
    [percentYField setFloatValue:100];
    
    [self parametersChanged:self];
}

- (NSArray *)encodeParameters
{
    int      method;
    NSArray  *parameters;

    switch ([[methodSelect selectedItem] tag])
    {
        case 0:
            method = NEAREST_NEIGHBOUR;
            break;
        case 1:
            method = BILINEAR;
            break;
        default:
            method = NEAREST_NEIGHBOUR;
            NSLog(@"Unexpected value for method in scale");
    }


    
    /* read pixels value again */
    pixelsX = [pixelsXField intValue];
    pixelsY = [pixelsYField intValue];

    /* encode parameters */
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:pixelsX],
        [NSNumber numberWithInt:pixelsY],
        [NSNumber numberWithInt:method],
        nil];

    return parameters;
}

- (void)closeFilterPanel
{
    [scaleWindow performClose:nil];
}

@end
