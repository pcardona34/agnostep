/*
**  MailboxManagerToolbar.m
**
**  Copyright (c) 2002-2004 Francis Lachapelle
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

#import "MailboxManagerToolbar.h"

#import "Constants.h"
#import "ExtendedOutlineView.h"

@implementation MailboxManagerController (MailboxManagerToolbar)

//
// NSToolbar delegate methods
//
- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar
      itemForItemIdentifier: (NSString *) itemIdentifier
  willBeInsertedIntoToolbar: (BOOL) flag
{
  NSToolbarItem *item;

  item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
  
  if ([itemIdentifier isEqualToString: @"delete"])
    {
      [item setLabel: _(@"Delete")];
      [item setPaletteLabel: _(@"Delete Mailbox")];
      [item setImage: [NSImage imageNamed: @"delete_32.tiff"]];
      [item setTarget: self];
      [item setAction: @selector(delete:)];
    }
  else if ([itemIdentifier isEqualToString: @"create"])
    {
      [item setLabel: _(@"Create")];
      [item setPaletteLabel: _(@"Create Mailbox")];
      [item setImage: [NSImage imageNamed: @"mailbox_add_32.tiff"]];
      [item setTarget: self];
      [item setAction: @selector(create:)];
    }
  else if ([itemIdentifier isEqualToString: @"rename"])
    {
      [item setLabel: _(@"Rename")];
      [item setPaletteLabel: _(@"Rename Mailbox")];
      [item setImage: [NSImage imageNamed: @"mailbox_rename_32.tiff"]];
      [item setTarget: self];
      [item setAction: @selector(rename:)];
    }

  return AUTORELEASE(item);
}


- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) theToolbar
{
  return [NSArray arrayWithObjects: NSToolbarSeparatorItemIdentifier,
		  NSToolbarSpaceItemIdentifier,
		  NSToolbarFlexibleSpaceItemIdentifier,
		  NSToolbarCustomizeToolbarItemIdentifier, 
		  @"delete",
                  @"create",
		  @"rename",
		  nil];
}


- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) theToolbar
{
  return [NSArray arrayWithObjects: @"delete",
		  @"create",
		  @"rename",
		  nil];
}


//
// NSToolbarItemValidation protocol
//
- (BOOL) validateToolbarItem: (NSToolbarItem *) theItem
{
  int row, level, nb;
  id item;
  
  nb = [outlineView numberOfRows];
  row = [outlineView selectedRow];

  if (row < 0 || row >= nb) return NO;

  item = [outlineView itemAtRow: row];
  level = [outlineView levelForItem: item];
  
  if ([theItem action] == @selector(delete:) || [theItem action] == @selector(rename:))
    {
      return (row > 0 && level > 0);
    }
  else if ([theItem action] == @selector(create:))
    {
      return (row >= 0 && level >= 0);
    }
  
  return YES;
}

@end
