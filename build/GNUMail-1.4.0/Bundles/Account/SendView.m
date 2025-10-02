/*
**  SendView.m
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

#include "SendView.h"

#include "Constants.h"
#include "LabelWidget.h"

//
//
//
@implementation SendView

- (void) dealloc
{
  NSDebugLog(@"SendView: -dealloc");
  
  [super dealloc];
}


//
//
//
- (id) initWithParent: (id) theParent
{
  self = [super init];

  parent = theParent;

  return self;
}


//
//
//
- (void) layoutView
{
  LabelWidget *label;

  [self setFrame: NSMakeRect(0,0,400,360)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,280,380,50)
		       label: _(@"Usually in this panel, you would want to add the information\nrelated to your outgoing mail server (most of the time,\nSMTP).")];
  [self addSubview: label];

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,255,120,TextFieldHeight)
		       label: _(@"Transport method:")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];
  
  sendTransportMethodPopUpButton = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(140,253,125,ButtonHeight)];
  [sendTransportMethodPopUpButton setAutoenablesItems: NO];
  [sendTransportMethodPopUpButton addItemWithTitle: _(@"Mailer")];
  [sendTransportMethodPopUpButton addItemWithTitle: _(@"SMTP")];
  [sendTransportMethodPopUpButton setTarget: parent];
  [sendTransportMethodPopUpButton setAction: @selector(sendTransportMethodHasChanged:)];
  [self addSubview: sendTransportMethodPopUpButton];
  RELEASE(sendTransportMethodPopUpButton);
}

@end


//
// Mailer
//
@implementation SendMailerView

- (void) dealloc
{
  RELEASE(sendMailerField);

  [super dealloc];
}


//
//
//
- (id) initWithParent: (id) theParent
{
  self = [super init];

  parent = theParent;

  return self;
}


//
//
//
- (void) layoutView
{
  LabelWidget *label;

  [self setFrame: NSMakeRect(0,0,400,260)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,220,120,TextFieldHeight)
		       label: _(@"Path:")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];
  
  sendMailerField = [[NSTextField alloc] initWithFrame: NSMakeRect(140,220,235,TextFieldHeight)];
  [self addSubview: sendMailerField];

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(140,195,235,TextFieldHeight)
		       label: _(@"(Ex: /usr/sbin/sendmail -t)")
		       alignment: NSLeftTextAlignment];
  //[label setFont: [NSFont systemFontOfSize: 10]];
  [self addSubview: label];
}

@end


//
// SMTP
//
@implementation SendSMTPView

- (void) dealloc
{
  [super dealloc];
}


//
//
//
- (id) initWithParent: (id) theParent
{
  self = [super init];

  parent = theParent;

  return self;
}


//
//
//
- (void) layoutView
{
  LabelWidget *label;
  
  [self setFrame: NSMakeRect(0,0,400,260)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,220,120,TextFieldHeight)
		       label: _(@"Server name:")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  sendSMTPHostField = [[NSTextField alloc] initWithFrame: NSMakeRect(140,220,235,TextFieldHeight)];
  [self addSubview: sendSMTPHostField];
  RELEASE(sendSMTPHostField);

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,190,120,TextFieldHeight)
		       label: _(@"Server port:")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  sendSMTPPortField = [[NSTextField alloc] initWithFrame: NSMakeRect(140,190,235,TextFieldHeight)];
  [self addSubview: sendSMTPPortField];
  RELEASE(sendSMTPPortField);

  //
  // Use secure connection (SSL)
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,160,120,TextFieldHeight)
		       label: _(@"Use secure connection:")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];	       

  sendUseSecureConnection = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(140,160,235,ButtonHeight)];
  [sendUseSecureConnection setTarget: parent];
  [sendUseSecureConnection setAction: @selector(sendUseSecureConnectionHasChanged:)];
  [self addSubview: sendUseSecureConnection];
  RELEASE(sendUseSecureConnection);

  
  //
  // SMTP authentication
  //
  sendAuthenticateUsingButton = [[NSButton alloc] initWithFrame: NSMakeRect(140,130,235,ButtonHeight)];
  [sendAuthenticateUsingButton setButtonType: NSSwitchButton];
  [sendAuthenticateUsingButton setBordered: NO];
  [sendAuthenticateUsingButton setTitle: _(@"Use SMTP authentication")];
  [sendAuthenticateUsingButton setTarget: parent];
  [sendAuthenticateUsingButton setAction: @selector(sendAuthenticateUsingButtonClicked:)];
  [self addSubview: sendAuthenticateUsingButton];
  RELEASE(sendAuthenticateUsingButton);

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,100,120,TextFieldHeight)
		       label: _(@"Mechanism:")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  sendSupportedMechanismsPopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(140,100,90,ButtonHeight)];
  [self addSubview: sendSupportedMechanismsPopUp];
  RELEASE(sendSupportedMechanismsPopUp);

  sendSupportedMechanismsButton = [[NSButton alloc] initWithFrame: NSMakeRect(240,100,135,ButtonHeight)];
  [sendSupportedMechanismsButton setTitle: _(@"Check supported")];
  [sendSupportedMechanismsButton setTarget: parent];
  [sendSupportedMechanismsButton setAction: @selector(sendSupportedMechanismsButtonClicked:)];
  [self addSubview: sendSupportedMechanismsButton];
  RELEASE(sendSupportedMechanismsButton);

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,70,120,TextFieldHeight)
		       label: _(@"Username:")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  sendSMTPUsernameField = [[NSTextField alloc] initWithFrame: NSMakeRect(140,70,235,TextFieldHeight)];
  [self addSubview: sendSMTPUsernameField];
  RELEASE(sendSMTPUsernameField);
 
  // Remember password option
  sendRememberPassword = [[NSButton alloc] initWithFrame: NSMakeRect(140,40,200,ButtonHeight)];
  [sendRememberPassword setButtonType: NSSwitchButton];
  [sendRememberPassword setBordered: NO];
  [sendRememberPassword setTitle: _(@"Remember password")];
  [sendRememberPassword setTarget: parent];
  [sendRememberPassword setAction: @selector(sendRememberPasswordClicked:)];
  [self addSubview: sendRememberPassword];
  RELEASE(sendRememberPassword);

  // Password
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,10,120,TextFieldHeight)
		       label: _(@"Password:")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];
  
  sendSMTPPasswordSecureField = [[NSSecureTextField alloc] initWithFrame: NSMakeRect(140,10,235,TextFieldHeight)];
  [self addSubview: sendSMTPPasswordSecureField];
  RELEASE(sendSMTPPasswordSecureField);

 
  //
  // We set the next key views
  //
  [sendSMTPHostField setNextKeyView: sendSMTPPortField];
  [sendSMTPPortField setNextKeyView: sendUseSecureConnection];
  [sendUseSecureConnection setNextKeyView: sendAuthenticateUsingButton];
}

@end
