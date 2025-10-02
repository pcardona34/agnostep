/*
**  EditWindowToolbar.h
**
**  Copyright (c) 2002-2006 Ludovic Marcotte
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
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _GNUMail_H_EditWindowToolbar
#define _GNUMail_H_EditWindowToolbar

#import <AppKit/AppKit.h>

#include "EditWindowController.h"

@interface EditWindowController (EditWindowToolbar)
     
//
// NSToolbar delegate methods
//
- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar
      itemForItemIdentifier: (NSString *) itemIdentifier
  willBeInsertedIntoToolbar: (BOOL) flag;

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar;

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar*) toolbar;


//
// NSToolbarItemValidation protocol
//
- (BOOL) validateToolbarItem: (NSToolbarItem *) theItem;

@end

#endif // _GNUMail_H_EditWindowToolbar
