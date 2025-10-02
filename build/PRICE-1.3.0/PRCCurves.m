//
//  PRCCurves.m
//  PRICE
//
//  Created by Riccardo Mottola on 7 August 2011.
//  Copyright 2011-2014 Riccardo Mottola. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "MyDocument.h"
#import "PRCCurves.h"
#import "PRCurves.h"


@implementation PRCCurves

- (id)init
{
  if ((self = [super init]))
    {
      filter = [[PRCurves alloc] init];
      
    }
  return self;
}


- (IBAction)showFilter:(id)sender
{
  [super showFilter:sender];
  
  if (!curvesWindow)
    [NSBundle loadNibNamed:@"Curves" owner:self];
  [curvesView setFilterController: self];
  
  
  currPath = [curvesView luminancePath];
//  [self curvesReset: self];
  PRImage *image = [[[NSDocumentController sharedDocumentController] currentDocument] activeImage];
  [curvesView calculateHistogram: image];

  [curvesWindow makeKeyAndOrderFront:nil];
  [self parametersChanged:self];
}

- (NSArray *)encodeParameters
{
  NSArray           *parameters;
  NSMutableArray    *arrayL;
  NSMutableArray    *arrayR;
  NSMutableArray    *arrayG;
  NSMutableArray    *arrayB;
  unsigned i;

  if ([curvesView hasColor])
    {
      arrayR = [[NSMutableArray alloc] initWithCapacity: UCHAR_MAX];
      arrayG = [[NSMutableArray alloc] initWithCapacity: UCHAR_MAX];
      arrayB = [[NSMutableArray alloc] initWithCapacity: UCHAR_MAX];
  
      for (i = 0; i <= UCHAR_MAX; i++)
	{
	  [arrayR addObject: [NSNumber numberWithUnsignedInt: curvesView->funL[i]]];
	  [arrayG addObject: [NSNumber numberWithUnsignedInt: curvesView->funL[i]]];
	  [arrayB addObject: [NSNumber numberWithUnsignedInt: curvesView->funL[i]]];
	}  
      /* encode parameters */
      parameters = [NSArray arrayWithObjects:
			      arrayR,
			    arrayG,
			    arrayB,
			    nil];
    }
  else
    {
      arrayL = [[NSMutableArray alloc] initWithCapacity: UCHAR_MAX];
  
      for (i = 0; i <= UCHAR_MAX; i++)
	[arrayL addObject: [NSNumber numberWithUnsignedInt: curvesView->funL[i]]];
  
      /* encode parameters */
      parameters = [NSArray arrayWithObjects:
			      arrayL,
			    nil];
    }

  return parameters;
}

- (void)closeFilterPanel
{
  [curvesWindow performClose:nil];
}

- (IBAction)recalculateCurves:(id)sender
{
  [curvesView calculateTransformedHistograms];
}

- (IBAction)parametersChanged:(id)sender
{
  [self recalculateCurves:sender];

  [super parametersChanged: sender];
  [curvesView setNeedsDisplay: YES];
}

- (IBAction)curvesReset:(id)sender
{
  /* first reconstruct the curves from scratch */
  [curvesView initPathLumi];
  [curvesView initPathR];
  [curvesView initPathG];
  [curvesView initPathB];

  /* make white and black points coherent */
  [self setWhitePointValue: 255];
  [curvesView setWhitePoint: 255];

  [self setBlackPointValue: 0];
  [curvesView setBlackPoint: 0];

  [self parametersChanged:sender];
}

- (void)setBlackPointValue:(int)val
{
  [blackPointField setIntValue: val];
  [blackPointStepper setIntValue: val];
  NSLog(@"black point: %d", val);  
}

- (void)setWhitePointValue:(int)val
{
  [whitePointField setIntValue: val];
  [whitePointStepper setIntValue: val];
  NSLog(@"white point: %d", val);
}

- (IBAction)setBlackPoint:(id)sender
{
  int point;
  
  point = [sender intValue];
  if (point > 254)
    point = 254;
  else if (point < 0)
    point = 0;
  else if (point >= [whitePointField intValue])
    point = [whitePointField intValue];
  [self setBlackPointValue:point];

  [curvesView setBlackPoint: point];
  [self parametersChanged:sender];
}

- (IBAction)setWhitePoint:(id)sender
{
  int point;
  
  point = [sender intValue];
  if (point > 255)
    point = 255;
  else if (point < 1)
    point = 1;
  else if (point <= [blackPointField intValue])
    point = [blackPointField intValue];
  [self setWhitePointValue: point];

  [curvesView setWhitePoint: point];
  [self parametersChanged:sender];
}


@end
