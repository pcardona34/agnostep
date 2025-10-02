/*
**  HeadersWindowController.h
**
**  Copyright (c) 2003 Ludovic Marcotte
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

#ifndef _GNUMail_H_HeadersWindowController
#define _GNUMail_H_HeadersWindowController

#import <AppKit/AppKit.h>

@interface HeadersWindowController: NSWindowController
{
  // Outlets
  IBOutlet NSButton *showAllHeaders;
  IBOutlet NSTableView *tableView;
  IBOutlet NSTextField *keyField;

  // Other ivars
  NSMutableArray *shownHeaders;
}

- (id) initWithWindowNibName: (NSString *) windowNibName;
- (void) dealloc;

//
// action methods
//
- (IBAction) addDefaults: (id) sender;
- (IBAction) addShown: (id) sender;
- (IBAction) removeShown: (id) sender; 

- (IBAction) moveUp: (id) sender;
- (IBAction) moveDown: (id) sender;

- (IBAction) okClicked: (id) sender;
- (IBAction) cancelClicked: (id) sender;


//
// access/mutation methods
//
- (void) setShownHeaders: (NSMutableArray *) theMutableArray;
- (NSMutableArray *) shownHeaders;

- (void) setShowAllHeadersButtonState: (int) theState;
- (int) showAllHeadersButtonState;

@end

#endif // _GNUMail_H_HeadersWindowController
