/*
**  SendView.h
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
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

#ifndef _GNUMail_H_SendView
#define _GNUMail_H_SendView

#import <AppKit/AppKit.h>

@interface SendView: NSView
{
  @public
    NSPopUpButton *sendTransportMethodPopUpButton;

  @private
    id parent;
}

- (id) initWithParent: (id) theParent;
- (void) layoutView;

@end


//
// Mailer
//
@interface SendMailerView: NSView
{
  @public
    NSTextField *sendMailerField;
  
  @private
    id parent;
}

- (id) initWithParent: (id) theParent;
- (void) layoutView;

@end


//
// SMTP
//
@interface SendSMTPView: NSView
{
  @public
    NSTextField *sendSMTPHostField;
    NSTextField *sendSMTPPortField;
    NSTextField *sendSMTPUsernameField;
    NSSecureTextField *sendSMTPPasswordSecureField;
    NSButton *sendRememberPassword;
    NSPopUpButton *sendUseSecureConnection;
    NSButton *sendAuthenticateUsingButton;
    NSButton *sendSupportedMechanismsButton;
    NSPopUpButton *sendSupportedMechanismsPopUp;    
  
  @private
    id parent;
}

- (id) initWithParent: (id) theParent;
- (void) layoutView;

@end
#endif // _GNUMail_H_SendView
