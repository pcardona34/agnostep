/*
**  MessageViewWindowToolbar.m
**
**  Copyright (c) 2002-2006 Francis Lachapelle
**
**  Author: Francis Lachapelle <francis@Sophos.ca>
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
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "MessageViewWindowToolbar.h"

#include "Constants.h"
#include "NavigationToolbarItem.h"

#include <Pantomime/CWConstants.h>

@implementation MessageViewWindowController (MessageViewWindowToolbar)

//
// NSToolbar delegate methods
//
- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar
      itemForItemIdentifier: (NSString *) itemIdentifier
  willBeInsertedIntoToolbar: (BOOL) flag
{
  id item;
    
  item = nil;
  
  if ([itemIdentifier isEqualToString: @"delete"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: _(@"Delete")];
      [item setPaletteLabel: _(@"Delete Message")];
      [item setImage: [NSImage imageNamed: @"delete_32.tiff"]];
      [item setTarget: self];
      [item setAction: @selector(deleteMessage:)];
    }
  else if ([itemIdentifier isEqualToString: @"reply"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: _(@"Reply")];
      [item setPaletteLabel: _(@"Reply To Message")];
      [item setImage: [NSImage imageNamed: @"reply_32.tiff"]];
      [item setTarget: self];
      [item setTag: PantomimeNormalReplyMode];
      [item setAction: @selector(replyToMessage:)];
    }
  else if ([itemIdentifier isEqualToString: @"forward"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: _(@"Forward")];
      [item setPaletteLabel: _(@"Forward Message")];
      [item setImage: [NSImage imageNamed: @"forward_32.tiff"]];
      [item setTarget: [NSApp delegate]];
      [item setTag: PantomimeInlineForwardMode];
      [item setAction: @selector(forwardMessage:)];
    }
  else if ([itemIdentifier isEqualToString: @"show_all_headers"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: _(@"Show All Headers")];
      [item setPaletteLabel: _(@"Show All Message Headers")];
      [item setImage: [NSImage imageNamed: @"show_all_headers_32.tiff"]];
      [item setTag: SHOW_ALL_HEADERS];
      [item setTarget: self];
      [item setAction: @selector(showOrHideAllHeaders:)];
    }
  else if ([itemIdentifier isEqualToString: @"raw"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: _(@"Raw Source")];
      [item setPaletteLabel: _(@"Show Raw Source")];
      [item setImage: [NSImage imageNamed: @"raw_32.tiff"]];
      [item setTarget: [NSApp delegate]];
      [item setAction: @selector(showRawSource:)];
    }
  else if ([itemIdentifier isEqualToString: @"navigation"])
    {
      NSRect aRect;

      item = [[NavigationToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: @""];
      [item setPaletteLabel: _(@"Navigation")];

      aRect = [[item view] frame];
      [item setMinSize: aRect.size];
      [item setMaxSize: aRect.size];
      [item setDelegate: self];
    }

  return [item autorelease];
}


- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar
{
  return [NSArray arrayWithObjects: NSToolbarSeparatorItemIdentifier,
		  NSToolbarSpaceItemIdentifier,
		  NSToolbarFlexibleSpaceItemIdentifier,
		  NSToolbarCustomizeToolbarItemIdentifier,
		  NSToolbarPrintItemIdentifier,
		  @"delete",
                  @"reply",
		  @"forward",
                  @"show_all_headers",
		  @"raw",
		  @"navigation",
		  nil];
}


- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar*) toolbar
{
  return [NSArray arrayWithObjects: @"delete",
		  @"reply",
		  @"forward",
                  @"show_all_headers",
		  @"raw",
		  NSToolbarPrintItemIdentifier,
		  NSToolbarFlexibleSpaceItemIdentifier,
		  @"navigation",
		  nil];
}


//
// NSToolbarItemValidation protocol
//
- (BOOL) validateToolbarItem: (NSToolbarItem *) theItem
{
  return YES;
}

@end
