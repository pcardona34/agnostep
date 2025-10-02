/*
**  ColorsViewController.m
**
**  Copyright (c) 2002-2007 Ludovic Marcotte
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>   
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "ColorsViewController.h"

#include "Constants.h"
#include "NSColor+Extensions.h"
#include "NSUserDefaults+Extensions.h"

#ifndef MACOSX
#include "ColorsView.h"
#endif

static ColorsViewController *singleInstance = nil;

//
//
//
@implementation ColorsViewController

- (id) initWithNibName: (NSString *) theName
{
  self = [super init];

#ifdef MACOSX
  
  if (![NSBundle loadNibNamed: theName  owner: self] )
    {
      AUTORELEASE(self);
      return nil;
    }

  RETAIN(view);

#else
  // We link our view
  view = [[ColorsView alloc] initWithParent: self];
  [view layoutView];

  // We link our outlets
  level1ColorWell = ((ColorsView *)view)->level1ColorWell;
  level2ColorWell = ((ColorsView *)view)->level2ColorWell;
  level3ColorWell = ((ColorsView *)view)->level3ColorWell;
  level4ColorWell = ((ColorsView *)view)->level4ColorWell;
  mailHeaderCellColorWell = ((ColorsView *)view)->mailHeaderCellColorWell;
  colorQuoteLevelButton = ((ColorsView *)view)->colorQuoteLevelButton;
#endif

  // We get our defaults for this panel
  [self initializeFromDefaults];

  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"ColorsViewController: -dealloc");

  singleInstance = nil;
  RELEASE(view);

  [super dealloc];
}


//
// access methods
//
- (NSImage *) image
{
  NSBundle *aBundle;
  
  aBundle = [NSBundle bundleForClass: [self class]];
  
  return AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
					[aBundle pathForResource: @"colors" ofType: @"tiff"]]);
}


//
//
//
- (NSString *) name
{
  return _(@"Colors");
}


//
//
//
- (NSView *) view
{
  return view;
}

- (BOOL) hasChangesPending
{
  return YES;
}


//
//
//
- (void) initializeFromDefaults
{
  NSUserDefaults *aUserDefaults;
  NSColor *aColor;

  aUserDefaults = [NSUserDefaults standardUserDefaults];

  //
  // COLOR_QUOTED_TEXT
  //
  [colorQuoteLevelButton setState: [aUserDefaults integerForKey: @"COLOR_QUOTED_TEXT" default: NSOnState]];
  

  //
  // QUOTE_COLOR_LEVEL_1
  //
  aColor = [aUserDefaults colorForKey: @"QUOTE_COLOR_LEVEL_1"];
  aColor = (aColor ? aColor : [NSColor blueColor]);
  [level1ColorWell setColor: aColor];

  
  //
  // QUOTE_COLOR_LEVEL_2
  //
  aColor = [aUserDefaults colorForKey: @"QUOTE_COLOR_LEVEL_2"];
  aColor = (aColor ? aColor : [NSColor redColor]);
  [level2ColorWell setColor: aColor];

    
  //
  // QUOTE_COLOR_LEVEL_3
  //
  aColor = [aUserDefaults colorForKey: @"QUOTE_COLOR_LEVEL_3"];
  aColor = (aColor ? aColor : [NSColor greenColor]);
  [level3ColorWell setColor: aColor];

    
  //
  // QUOTE_COLOR_LEVEL_4
  //
  aColor = [aUserDefaults colorForKey: @"QUOTE_COLOR_LEVEL_4"];
  aColor = (aColor ? aColor : [NSColor cyanColor]);
  [level4ColorWell setColor: aColor];


  //
  // MAILHEADERCELL_COLOR
  //
  aColor = [aUserDefaults colorForKey: @"MAILHEADERCELL_COLOR"];
  aColor = (aColor ? aColor : [NSColor colorWithCalibratedRed: 0.9  green: 0.9  blue: 1.0  alpha: 1.0]);
  [mailHeaderCellColorWell setColor: aColor];

  [self colorQuoteLevelButtonClicked: self];
}


//
//
//
- (void) saveChanges
{
  NSUserDefaults *aUserDefaults;

  aUserDefaults = [NSUserDefaults standardUserDefaults];

  [aUserDefaults setInteger: [colorQuoteLevelButton state]  forKey: @"COLOR_QUOTED_TEXT"];

  [aUserDefaults setColor: [level1ColorWell color]  forKey: @"QUOTE_COLOR_LEVEL_1"];
  [aUserDefaults setColor: [level2ColorWell color]  forKey: @"QUOTE_COLOR_LEVEL_2"];
  [aUserDefaults setColor: [level3ColorWell color]  forKey: @"QUOTE_COLOR_LEVEL_3"];
  [aUserDefaults setColor: [level4ColorWell color]  forKey: @"QUOTE_COLOR_LEVEL_4"];

  [aUserDefaults setColor: [[mailHeaderCellColorWell color] colorUsingColorSpaceName: NSCalibratedRGBColorSpace]
		 forKey: @"MAILHEADERCELL_COLOR"];

  // We flush our quote colors cache
  [NSColor updateCache];
}


//
// action methods
//
- (IBAction) colorQuoteLevelButtonClicked: (id) sender
{
  BOOL aBOOL;

  aBOOL = ([colorQuoteLevelButton state] == NSOnState ? YES : NO);

  [level1ColorWell setEnabled: aBOOL];
  [level2ColorWell setEnabled: aBOOL];
  [level3ColorWell setEnabled: aBOOL];
  [level4ColorWell setEnabled: aBOOL];
}


//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[ColorsViewController alloc] initWithNibName: @"ColorsView"];
    }

  return singleInstance;
}

@end
