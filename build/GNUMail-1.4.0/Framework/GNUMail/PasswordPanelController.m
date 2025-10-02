/*
**  PasswordPanelController.m
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
**  Copyright (C) 2015      Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
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

#include "PasswordPanelController.h"

#include "GNUMail.h"
#include "Constants.h"



//
//
//
@implementation PasswordPanelController

- (id) initWithWindowNibName: (NSString *) windowNibName
{
  self = [super initWithWindowNibName: windowNibName];

  return self;
}


//
//
//
- (void) awakeFromNib
{
  [[self window] setInitialFirstResponder: [[passwordSecureField cell] controlView]];
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"PasswordPanelController: -dealloc");
  RELEASE(password);

  [super dealloc];
}


//
// action methods
//

- (IBAction) okClicked: (id) sender
{
  [self setPassword: [passwordSecureField stringValue]];
  [NSApp stopModal];
  [self close];
}


- (IBAction) cancelClicked: (id) sender
{
  [self setPassword: nil];
  [NSApp stopModalWithCode: NSRunAbortedResponse];
  [self close];
}


//
// delegate methods
//
- (void) windowWillClose: (NSNotification *) theNotification
{
  // Do nothing
}


//
// access/mutation methods
//
- (NSString *) password
{
  return password;
}


- (void) setPassword: (NSString *) thePassword
{
  if ( thePassword )
    {
      RETAIN(thePassword);
      RELEASE(password);
      password = thePassword;
    }
  else
    {
      DESTROY(password);
    }
}

@end
