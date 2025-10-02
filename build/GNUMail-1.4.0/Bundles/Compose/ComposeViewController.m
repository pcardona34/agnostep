/*
**  ComposeViewController.m
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

#include "ComposeViewController.h"

#include "Constants.h"
#include "NSUserDefaults+Extensions.h"

#ifndef MACOSX
#include "ComposeView.h"
#endif

#include <Pantomime/CWCharset.h>

static ComposeViewController *singleInstance = nil;

//
//
//
@implementation ComposeViewController

- (id) initWithNibName: (NSString *) theName
{
  self = [super init];

#ifdef MACOSX
  if (![NSBundle loadNibNamed: theName owner: self] )
    {
      AUTORELEASE(self);
      return nil;
    }
  RETAIN(view);
#else
  // We link our views
  view = [[ComposeView alloc] initWithParent: self];
  [view layoutView];

  replyPopUpButton = ((ComposeView *)view)->replyPopUpButton;
  forwardPopUpButton = ((ComposeView *)view)->forwardPopUpButton;
  lineWrapLimitField = ((ComposeView *)view)->lineWrapLimitField;
  defaultCharsetPopUpButton = ((ComposeView *)view)->defaultCharsetPopUpButton;
#endif

  // We add the items in our charset popup button
  [self _initializeCharsetPopUpButton];
  
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
					[aBundle pathForResource: @"MailIcon_create" ofType: @"tiff"]]);
}


//
//
//
- (NSString *) name
{
  return _(@"Compose");
}


//
//
//
- (NSView *) view
{
  return view;
}


//
//
//
- (BOOL) hasChangesPending
{
  return YES;
}


//
//
//
- (void) initializeFromDefaults
{
  [replyPopUpButton selectItemAtIndex: [[NSUserDefaults standardUserDefaults] 
					 integerForKey: @"SIGNATURE_REPLY_POSITION"  default: SIGNATURE_END]];
  [forwardPopUpButton selectItemAtIndex: [[NSUserDefaults standardUserDefaults]
					   integerForKey: @"SIGNATURE_FORWARD_POSITION"  default: SIGNATURE_BEGINNING]];
  [lineWrapLimitField setIntValue: [[NSUserDefaults standardUserDefaults] integerForKey: @"LINE_WRAP_LIMIT" default: 72]];

  if ([[NSUserDefaults standardUserDefaults] objectForKey: @"DEFAULT_CHARSET"])
    {
      [defaultCharsetPopUpButton selectItemWithTitle: 
				       [[CWCharset allCharsets] 
					 objectForKey: [[NSUserDefaults standardUserDefaults] objectForKey: @"DEFAULT_CHARSET"]]];
    }
  else
    {
      [defaultCharsetPopUpButton selectItemAtIndex: 0];
    }
}



//
//
//
- (void) saveChanges
{
  NSArray *allKeys;
  int aValue;

  [replyPopUpButton synchronizeTitleAndSelectedItem];
  [forwardPopUpButton synchronizeTitleAndSelectedItem];

  // We save the preferences
  [[NSUserDefaults standardUserDefaults] setInteger: [replyPopUpButton indexOfSelectedItem]
					 forKey: @"SIGNATURE_REPLY_POSITION"];
  
  [[NSUserDefaults standardUserDefaults] setInteger: [forwardPopUpButton indexOfSelectedItem]
					 forKey: @"SIGNATURE_FORWARD_POSITION"];

  aValue = [lineWrapLimitField intValue];

  if (aValue <= 0 || aValue > 998)
    {
      aValue = 998;
    }
  
  [[NSUserDefaults standardUserDefaults] setInteger: aValue
					 forKey:  @"LINE_WRAP_LIMIT"];

  [defaultCharsetPopUpButton synchronizeTitleAndSelectedItem];

  allKeys = [[CWCharset allCharsets] allKeysForObject: [defaultCharsetPopUpButton titleOfSelectedItem]];
  
  if ([allKeys count])
    {
      [[NSUserDefaults standardUserDefaults] setObject: [allKeys objectAtIndex: 0]
					     forKey: @"DEFAULT_CHARSET"];
    }
  else
    {
      [[NSUserDefaults standardUserDefaults] setObject: @"Automatic"
					     forKey: @"DEFAULT_CHARSET"];
    }
}


//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[ComposeViewController alloc] initWithNibName: @"ComposeView"];
    }

  return singleInstance;
}

@end


//
// Private implementation
//
@implementation ComposeViewController (Private)

- (void) _initializeCharsetPopUpButton
{
  NSMutableArray *aMutableArray;

  [defaultCharsetPopUpButton removeAllItems];
  
  aMutableArray = [[NSMutableArray alloc] init];
  [aMutableArray addObjectsFromArray: [[CWCharset allCharsets] allValues]];
  [aMutableArray sortUsingSelector: @selector(compare:)];
  
  // We always add our "Automatic" item
  [aMutableArray insertObject: _(@"Automatic")  atIndex: 0];
  
  [defaultCharsetPopUpButton addItemsWithTitles: aMutableArray];
  RELEASE(aMutableArray);
}

@end
