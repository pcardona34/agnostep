/*
**  MailboxInspectorPanelController.h
**
**  Copyright (c) 2004 Ludovic Marcotte
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

#ifndef _GNUMail_H_MailboxInspectorPanelController
#define _GNUMail_H_MailboxInspectorPanelController

#import <AppKit/AppKit.h>

@class CWMessage;
@class ThreadArcsCell;

@interface MailboxInspectorPanelController: NSWindowController
{
  // Views outlets
  IBOutlet id threadArcsView;

  // Subviews outlets
  IBOutlet NSTextView *textView;
  IBOutlet NSTextField *subject;

  IBOutlet NSBox *box;

  // Other ivars
  CWMessage *_message;
  ThreadArcsCell *_cell;
}

//
// delegate methods
//
- (IBAction) selectionHasChanged: (id) sender;

//
// access / mutation methods
//
- (NSTextView *) textView;
- (CWMessage *) selectedMessage;
- (void) setSelectedMessage: (CWMessage *) theMessage;

//
// class methods
//
+ (id) singleInstance;

@end
#endif // _GNUMail_H_MailboxInspectorPanelController
