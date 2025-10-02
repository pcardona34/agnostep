/*
**  ViewingViewController.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
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

#include "ViewingViewController.h"

#include "Constants.h"
#include "HeadersWindowController.h"
#include "NSUserDefaults+Extensions.h"

#ifndef MACOSX
#include "ViewingView.h"
#endif

static ViewingViewController *singleInstance = nil;

@implementation ViewingViewController

//
//
//
- (id) initWithNibName: (NSString *) theName
{
  self = [super init];

#ifdef MACOSX
  
  if (![NSBundle loadNibNamed: theName  owner: self])
    {
      AUTORELEASE(self);
      return nil;
    }

  RETAIN(view);

#else
  // We link our view
  view = [[ViewingView alloc] initWithParent: self];
  [view layoutView];

  // We link our outlets
  doubleClickPopUpButton = ((ViewingView *)view)->doubleClickPopUpButton;
  matrix = ((ViewingView *)view)->matrix;
#endif

  // We initialize our array containing all our headers
  _shownHeaders = [[NSMutableArray alloc] init];

  // We get our defaults for this panel
  [self initializeFromDefaults];

  return self;
}


//
//
//
- (void) dealloc
{
  singleInstance = nil;
  
  RELEASE(_shownHeaders);
  RELEASE(view);

  [super dealloc];
}


//
// action methods
//
- (IBAction) headersButtonClicked: (id) sender
{
  HeadersWindowController *aHeadersWindowController;
  int result;

  aHeadersWindowController = [[HeadersWindowController alloc]
			       initWithWindowNibName: @"HeadersWindow"];

  [aHeadersWindowController setShownHeaders: _shownHeaders];
  [aHeadersWindowController setShowAllHeadersButtonState: _showAllHeadersButtonState];
  
  result = [NSApp runModalForWindow: [aHeadersWindowController window]];
  
  // We must update our preferences
  if (result == NSRunStoppedResponse)
    {
      [_shownHeaders removeAllObjects];
      [_shownHeaders addObjectsFromArray: [aHeadersWindowController shownHeaders]];
      _showAllHeadersButtonState = [aHeadersWindowController showAllHeadersButtonState];
    }

  // We release our controller
  RELEASE(aHeadersWindowController);
}


//
// access methods
//
- (NSImage *) image
{
  NSBundle *aBundle;
  
  aBundle = [NSBundle bundleForClass: [self class]];
  
  return AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
					[aBundle pathForResource: @"viewing" ofType: @"tiff"]]);
}

- (NSString *) name
{
  return _(@"Viewing");
}

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
  NSArray *values;

  aUserDefaults = [NSUserDefaults standardUserDefaults];

  if ([aUserDefaults objectForKey: @"PreferredViewStyleAfterRestart"])
    {
      [matrix selectCellAtRow: 0  column: [aUserDefaults integerForKey: @"PreferredViewStyleAfterRestart"  default: 0]];
    }
  else
    {
      [matrix selectCellAtRow: 0  column: [aUserDefaults integerForKey: @"PreferredViewStyle"  default: 0]];
    }

  _showAllHeadersButtonState = [aUserDefaults integerForKey: @"SHOWALLHEADERS"  default: NSOffState];
  [doubleClickPopUpButton selectItemAtIndex: [aUserDefaults integerForKey: @"DOUBLECLICKACTION"  default: ACTION_VIEW_MESSAGE]];

  // We load the headers we want to show
  values = [aUserDefaults objectForKey: @"SHOWNHEADERS"];
  
  if (values)
    {
      [_shownHeaders addObjectsFromArray: values];
    }
}


//
//
//
- (void) saveChanges
{
  NSUserDefaults *aUserDefaults;
  
  aUserDefaults = [NSUserDefaults standardUserDefaults];
  
  [aUserDefaults setInteger: [[matrix selectedCell] tag]  forKey: @"PreferredViewStyleAfterRestart"];
  [aUserDefaults setInteger: _showAllHeadersButtonState  forKey: @"SHOWALLHEADERS"];
  [aUserDefaults setInteger: [doubleClickPopUpButton indexOfSelectedItem]  forKey: @"DOUBLECLICKACTION"];
  [aUserDefaults setObject: _shownHeaders  forKey: @"SHOWNHEADERS"];
}


//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[ViewingViewController alloc] initWithNibName: @"ViewingView"];
    }

  return singleInstance;
}

@end
