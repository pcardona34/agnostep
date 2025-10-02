/*
**  MailboxImportController.h
**
**  Copyright (c) 2003-2004 Ludovic Marcotte
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

#ifndef _GNUMail_H_MailboxImportController
#define _GNUMail_H_MailboxImportController

#import <AppKit/AppKit.h>

@interface MailboxImportController : NSWindowController
{
  // Outlets
  IBOutlet NSMatrix *matrix;

  IBOutlet NSTextField *explanationLabel;
  IBOutlet NSButton *chooseButton;

  IBOutlet NSTableView *tableView;

  IBOutlet id chooseTypeView;
  IBOutlet id explanationView;
  IBOutlet id chooseMailboxView;

  // Other ivars
  NSMutableArray *allMailboxes;
  NSArray *allMessages;
}


//
// Actions methods
//
- (IBAction) chooseClicked: (id) sender;
- (IBAction) doneClicked: (id) sender;
- (IBAction) nextClicked: (id) sender;
- (IBAction) previousClicked: (id) sender;
- (IBAction) selectionInMatrixHasChanged: (id) sender;

//
// Class methods
//
+ (id) singleInstance;

@end

#endif // _GNUMail_H_MailboxImportController
