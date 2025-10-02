/*
**  PasswordPanelController.h
**
**  Copyright (c) 2001, 2002, 2003 Ludovic Marcotte
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

#ifndef _GNUMail_H_PasswordPanelController
#define _GNUMail_H_PasswordPanelController

#import <AppKit/AppKit.h>

@interface PasswordPanelController: NSWindowController
{
  // Outlets
  IBOutlet NSSecureTextField *passwordSecureField;

  // Other ivar
  NSString *password;
}

- (id) initWithWindowNibName: (NSString *) windowNibName;
- (void) dealloc;

//
// action methods
//

- (IBAction) okClicked: (id) sender;
- (IBAction) cancelClicked: (id) sender;

//
// delegate methods
//

- (void) windowWillClose: (NSNotification *) theNotification;

//
// access/mutation methods
//

- (NSString *) password;
- (void) setPassword: (NSString *) thePassword;

@end

#endif // _GNUMail_H_PasswordPanelController
