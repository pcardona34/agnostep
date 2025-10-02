/*
**  NewMailboxPanelController.h
**
**  Copyright (c) 2001-2005 Ludovic Marcotte
**                2020      Riccardo Mottola
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

#ifndef _GNUMail_H_NewMailboxPanelController
#define _GNUMail_H_NewMailboxPanelController

#import <AppKit/AppKit.h>

@interface NewMailboxPanelController: NSWindowController
{
  // Outlets
  IBOutlet NSTextField *mailboxNameField;
}

//
// action methods
//
- (IBAction) okClicked: (id) sender;
- (IBAction) cancelClicked: (id) sender;


//
// access/mutation methods
//
- (NSTextField *) mailboxNameField;

@end

#endif //  _GNUMail_H_NewMailboxPanelController
