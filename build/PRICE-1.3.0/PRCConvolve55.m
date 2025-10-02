//
//  PRCConvolve55.m
//  PRICE
//  Convolve 5x5 Controller
//
//  Created by Riccardo Mottola on Tue Jan 21 2003.
//  Copyright (c) 2003-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCConvolve55.h"
#import "MyDocument.h"
#import "PRConvolve55.h"

@implementation PRCConvolve55

- (id)init
{
    if ((self = [super init]))
    {
        filter = [[PRConvolve55 alloc] init];
    }
    return self;
}

- (IBAction)showFilter:(id)sender
{
    [super showFilter:sender];

    if (!filterWindow)
        [NSBundle loadNibNamed:@"Convolve55" owner:self];
    [filterWindow makeKeyAndOrderFront:nil];
    convMatrix[0][0] = [matField11 intValue];
    convMatrix[0][1] = [matField12 intValue];
    convMatrix[0][2] = [matField13 intValue];
    convMatrix[0][3] = [matField14 intValue];
    convMatrix[0][4] = [matField15 intValue];
    convMatrix[1][0] = [matField21 intValue];
    convMatrix[1][1] = [matField22 intValue];
    convMatrix[1][2] = [matField23 intValue];
    convMatrix[1][3] = [matField24 intValue];
    convMatrix[1][4] = [matField25 intValue];
    convMatrix[2][0] = [matField31 intValue];
    convMatrix[2][1] = [matField32 intValue];
    convMatrix[2][2] = [matField33 intValue];
    convMatrix[2][3] = [matField34 intValue];
    convMatrix[2][4] = [matField35 intValue];
    convMatrix[3][0] = [matField41 intValue];
    convMatrix[3][1] = [matField42 intValue];
    convMatrix[3][2] = [matField43 intValue];
    convMatrix[3][3] = [matField44 intValue];
    convMatrix[3][4] = [matField45 intValue];
    convMatrix[4][0] = [matField51 intValue];
    convMatrix[4][1] = [matField52 intValue];
    convMatrix[4][2] = [matField53 intValue];
    convMatrix[4][3] = [matField54 intValue];
    convMatrix[4][4] = [matField55 intValue];
    if ([autoScaleCheck state] == NSOnState)
    {
        [scaleField setEnabled:NO];
        [offsetField setEnabled:NO];
        autoScale = YES;
    } else
    {
        [scaleField setEnabled:YES];
        [offsetField setEnabled:YES];
        autoScale = NO;
    }
    offset = [offsetField intValue];
    scale = [scaleField floatValue];

    [self parametersChanged:self];
}

- (IBAction)convMatrix11:(id)sender
{
    convMatrix[0][0] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix12:(id)sender
{
    convMatrix[0][1] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix13:(id)sender
{
    convMatrix[0][2] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix14:(id)sender
{
    convMatrix[0][3] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix15:(id)sender
{
    convMatrix[0][4] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix21:(id)sender
{
    convMatrix[1][0] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix22:(id)sender
{
    convMatrix[1][1] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix23:(id)sender
{
    convMatrix[1][2] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix24:(id)sender
{
    convMatrix[1][3] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix25:(id)sender
{
    convMatrix[1][4] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix31:(id)sender
{
    convMatrix[2][0] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix32:(id)sender
{
    convMatrix[2][1] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix33:(id)sender
{
    convMatrix[2][2] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix34:(id)sender
{
    convMatrix[2][3] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix35:(id)sender
{
    convMatrix[2][4] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix41:(id)sender
{
    convMatrix[3][0] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix42:(id)sender
{
    convMatrix[3][1] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix43:(id)sender
{
    convMatrix[3][2] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix44:(id)sender
{
    convMatrix[3][3] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix45:(id)sender
{
    convMatrix[3][4] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix51:(id)sender
{
    convMatrix[4][0] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix52:(id)sender
{
    convMatrix[4][1] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix53:(id)sender
{
    convMatrix[4][2] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix54:(id)sender
{
    convMatrix[4][3] = [sender intValue];
  [self parametersChanged:self];
}
- (IBAction)convMatrix55:(id)sender
{
    convMatrix[4][4] = [sender intValue];
  [self parametersChanged:self];
}

- (IBAction)autoRange:(id)sender
{
    autoScale = !autoScale;
    if (autoScale)
    {
        [scaleField setEnabled:NO];
        [offsetField setEnabled:NO];
    } else
    {
        [scaleField setEnabled:YES];
        [offsetField setEnabled:YES];
    }
  [self parametersChanged:self];
}

- (IBAction)scaleFactor:(id)sender
{
    scale = [sender floatValue];
  [self parametersChanged:self];
}

- (IBAction)offsetFactor:(id)sender
{
    offset = [sender intValue];
  [self parametersChanged:self];
}

- (void)closeFilterPanel
{
    [filterWindow performClose:nil];
}

- (NSArray *)encodeParameters
{
    NSArray        *parameters;
    NSMutableArray *convArray;
    int            i, j;
    
    /* encode the parameters */
    convArray = [NSMutableArray arrayWithCapacity:25];
    for (i = 0; i < 5; i++)
        for (j = 0; j < 5; j++)
            [convArray addObject: [NSNumber numberWithInt: convMatrix[i][j]]];

    
    parameters = [NSArray arrayWithObjects:
        convArray,
        [NSNumber numberWithInt: offset],
        [NSNumber numberWithFloat: scale],
        [NSNumber numberWithBool: autoScale],
        nil];

    return parameters;
}

@end
