//
//  PRCCurves.h
//  PRICE
//
//  Created by Riccardo Mottola on 7 August 2011.
//  Copyright 2011-2014 Riccardo Mottola. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import <Foundation/Foundation.h>
#import <AppKit/NSWindow.h>

#import "PRCurvesView.h"
#import "PRFilterController.h"

@class NSBezierPath;

@interface PRCCurves : PRFilterController
{
  IBOutlet NSWindow     *curvesWindow;
  IBOutlet PRCurvesView *curvesView;
  IBOutlet NSTextField  *blackPointField;
  IBOutlet NSTextField  *whitePointField;
  IBOutlet NSStepper    *blackPointStepper;
  IBOutlet NSStepper    *whitePointStepper;
  
  NSBezierPath *currPath;
}

- (IBAction)recalculateCurves:(id)sender;

- (IBAction)curvesReset:(id)sender;
- (IBAction)setBlackPoint:(id)sender;
- (IBAction)setWhitePoint:(id)sender;

- (void)setBlackPointValue:(int)val;
- (void)setWhitePointValue:(int)val;


@end
