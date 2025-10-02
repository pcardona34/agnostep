/*
**  ClockController.m
**
**  Copyright (c) 2001-2004 Ludovic Marcotte
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

#include "ClockController.h"

#include "Clock.h"
#include "Constants.h"

#include <Pantomime/CWMessage.h>

static ClockController *singleInstance = nil;

@implementation ClockController

//
//
//
- (id) initWithOwner: (id) theOwner
{
  NSBundle *aBundle;
  
  self = [super init];

  owner = theOwner;
 
  aBundle = [NSBundle bundleForClass: [self class]];
  
  resourcePath = [aBundle resourcePath];
  RETAIN(resourcePath);

  allClockViews = [[NSMutableArray alloc] init];

  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(resourcePath);
  RELEASE(allClockViews);
  
  [super dealloc];
}


//
//
//
+ (id) singleInstance
{
  //NSDebugLog(@"ClockController: -singleInstance");

  if (!singleInstance )
    {
      singleInstance = [[ClockController alloc] initWithOwner: nil];
    }

  return singleInstance;
}


//
// access / mutation methods
//
- (NSString *) name
{
  return @"Clock";
}

- (NSString *) description
{
  return @"This is a simple Clock bundle.";
}

- (NSString *) version
{
  return @"v0.2.0";
}

- (void) setOwner: (id) theOwner
{
  owner = theOwner;
}

//
// UI elements
//
- (BOOL) hasPreferencesPanel
{
  return NO;
}

- (BOOL) hasComposeViewAccessory
{
  return NO;
}

- (BOOL) hasViewingViewAccessory
{
  return YES;
}

- (id) viewingViewAccessory
{  
  Clock *aClock;

  aClock = [[Clock alloc] initWithPathToResources: resourcePath];
  [allClockViews addObject: aClock];

  return AUTORELEASE(aClock);
}

//
//
//
- (enum ViewingViewType) viewingViewAccessoryType
{
  return ViewingViewTypeToolbar;
}

- (void) viewingViewAccessoryWillBeRemovedFromSuperview: (id) theView
{
  if (theView == nil)
    {
      return;
    }
  else
    {
      Clock *aClock;
      int i;
      
#warning FIXME
      for (i = 0; i < [allClockViews count]; i++)
	{
	  aClock = [allClockViews objectAtIndex: i];
	  
	  if ([aClock isDescendantOf: theView])
	    {
	      [allClockViews removeObject: aClock];
	      break;
	    }
	}
    }
}

- (void) setCurrentSuperview: (NSView *) theView
{
  superview = theView;
}

- (NSArray *) submenuForMenu: (NSMenu *) theMenu
{
  return nil;
}

- (NSArray *) menuItemsForMenu: (NSMenu *) theMenu
{
  return nil;
}


//
// Pantomime related methods
//
- (void) messageWasDisplayed: (CWMessage *) theMessage
                      inView: (NSTextView *) theTextView
{
  NSArray *allItems;
  Clock *aClock;
  BOOL b;
  int i;
  
  if (superview == nil)
    {
      return;
    }

  b = NO;

  for (i = 0; i < [allClockViews count]; i++)
    {
      aClock = [allClockViews objectAtIndex: i];
      
      // Since this bundle will be shown in the toolbar, we can't
      // use [aClock isDescendantOf: superview]. What we'll do
      // is to get all the view of all visible items and see
      // if we got our clock view.
      allItems = [[[theTextView window] toolbar] visibleItems];

#warning does not work as expected when mailwindow > 1
      for (i = 0; i < [allItems count]; i++)
	{
	  if ([[allItems objectAtIndex: i] view] == aClock)
	    {
	      b = YES;
	      break;
	    }
	}
      
      if (b)
	{
	  [aClock setDate: [theMessage receivedDate]];
	  break;
	}
    }
}

@end
