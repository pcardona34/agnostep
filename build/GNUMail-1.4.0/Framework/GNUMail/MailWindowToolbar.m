/*
**  MailWindowToolbar.m
**
**  Copyright (c) 2002-2007 Francis Lachapelle, Ludovic Marcotte
**  Copyright (C) 2020      Riccardo Mottola
**
**  Author: Francis Lachapelle <francis@Sophos.ca>
**          Ludovic Marcotte <ludovic@Sophos.ca>
**          Riccardo Mottola <rm@gnu.org>
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

#include "MailWindowToolbar.h"

#include "Constants.h"
#include "NavigationToolbarItem.h"
#include "NSUserDefaults+Extensions.h"

#include <Pantomime/CWConstants.h>
#include <Pantomime/CWFolder.h>

@implementation MailWindowController (MailWindowToolbar)

//
// NSToolbar delegate methods
//
- (void) toolbarDidRemoveItem: (NSNotification *) theNotification
{
  if ([[theNotification userInfo] objectForKey: @"item"] == delete)
    {
      DESTROY(delete);
    }
  else if ([[theNotification userInfo] objectForKey: @"item"] == get)
    {
      DESTROY(get);
    }
}


//
//
//
- (void) toolbarWillAddItem: (NSNotification *) theNotification
{
  id item;
  
  item = [[theNotification userInfo] objectForKey: @"item"];
  
  if ([[item itemIdentifier] isEqualToString: @"delete"])
    {
      delete = (id)item;
      RETAIN(delete);
    }
  else if ([[item itemIdentifier] isEqualToString: @"retrieve"])
    {
      get = (id)item;
      RETAIN(get);
    }
}


//
//
//
- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar
      itemForItemIdentifier: (NSString *) itemIdentifier
  willBeInsertedIntoToolbar: (BOOL) flag
{
  id item;
  
  if ([itemIdentifier isEqualToString: @"delete"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: _(@"Delete")];
      [item setPaletteLabel: _(@"Delete Message")];
      [item setImage: [NSImage imageNamed: @"delete_32.tiff"]];
      [item setTarget: self];
      [item setAction: @selector(deleteMessage:)];
      delete = (id)item;
    }
  else if ([itemIdentifier isEqualToString: @"retrieve"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: _(@"Get")];
      [item setPaletteLabel: _(@"Get New Messages")];
      [item setImage: [NSImage imageNamed: @"retrieve_32.tiff"]];
      [item setTarget: self];
      [item setAction: @selector(getNewMessages:)];
      get = (id)item;
    }
  else if ([itemIdentifier isEqualToString: @"mailbox"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: _(@"Mailboxes")];
      [item setPaletteLabel: _(@"Show Mailboxes")];
      [item setImage: [NSImage imageNamed: @"mailboxes_32.tiff"]];
      
      if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView] == GNUMailDrawerView)
	{
	  [item setTarget: self];
	  [item setAction: @selector(openOrCloseDrawer:)];
	}
      else
	{
	  [item setTarget: [NSApp delegate]];
	  [item setAction: @selector(showMailboxManager:)];
	}
    }
  else if ([itemIdentifier isEqualToString: @"compose"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: _(@"Compose")];
      [item setPaletteLabel: _(@"Compose New Message")];
      [item setImage: [NSImage imageNamed: @"create_32.tiff"]];
      [item setTarget: [NSApp delegate]];
      [item setAction: @selector(composeMessage:)];
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
  else if ([itemIdentifier isEqualToString: @"addresses"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: _(@"Addresses")];
      [item setPaletteLabel: _(@"Addresses")];
      [item setImage: [NSImage imageNamed: @"addresses_32.tiff"]];
      [item setTarget: [NSApp delegate]];
      [item setAction: @selector(showAddressBook:)];
    }
  else if ([itemIdentifier isEqualToString: @"find"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      [item setLabel: _(@"Find")];
      [item setPaletteLabel: _(@"Find Messages")];
      [item setImage: [NSImage imageNamed: @"find_32.tiff"]];
      [item setTarget: [NSApp delegate]];
      [item setAction: @selector(showFindWindow:)];
    }
  else if([itemIdentifier isEqualToString: @"fastfind"])
    {
      item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
      searchField = [[NSSearchField alloc] initWithFrame: NSMakeRect(0, 0, 140, TextFieldHeight)];
      [searchField setTarget: self];
      [searchField setAction: @selector(doFind:)];
      
      [item setLabel: _(@"Find in header")];
      [item setPaletteLabel: _(@"Find in header")];
      [item setView: searchField];
      [item setMinSize:NSMakeSize(50, NSHeight([searchField frame]))];
      [item setMaxSize:NSMakeSize(200, NSHeight([searchField frame]))];
      [item setAction: @selector(doFind:)];
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
  else
    {
      // We return the toolbar item from a bundle..
      return [additionalToolbarItems objectForKey: itemIdentifier];
    }

  return AUTORELEASE(item);
}


- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar
{
  return allowedToolbarItemIdentifiers;
}


- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar*) toolbar
{
  return [NSArray arrayWithObjects: @"delete",
		  @"retrieve",
		  @"mailbox",
		  @"compose",
		  @"reply",
		  @"forward",
		  @"addresses",
		  @"find",
          NSToolbarFlexibleSpaceItemIdentifier,
          @"fastfind",
		  nil];
}


//
// NSToolbarItemValidation protocol
//
- (BOOL) validateToolbarItem: (NSToolbarItem *) theItem
{
  if ([[self folder] mode] == PantomimeReadOnlyMode &&
      [[theItem itemIdentifier] isEqualToString: @"delete"])
    {
      return NO;
    }

  return YES;
}

@end
