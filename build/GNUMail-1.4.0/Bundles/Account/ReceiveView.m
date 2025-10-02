/*
**  ReceiveView.m
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

#include "ReceiveView.h"

#include "LabelWidget.h"
#include "Constants.h"


//
//
//
@implementation ReceiveView

- (void) dealloc
{
  NSDebugLog(@"ReceiveView: -dealloc");
  
  RELEASE(receiveServerNameField);
  RELEASE(receiveServerPortField);
  RELEASE(receiveUsernameField);
  RELEASE(receivePasswordSecureField);
  RELEASE(receiveRememberPassword);
  RELEASE(receiveCheckOnStartup);
  RELEASE(receiveUseSecureConnection);

  RELEASE(receivePopUp);

  RELEASE(receiveMatrix);
  RELEASE(receiveMinutesField);

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
  LabelWidget *label, *serverNameLabel, *serverPortLabel, *serverTypeLabel, *usernameLabel, *passwordLabel, *minutesLabel, *secureLabel;
  NSButtonCell *cell;

  [self setFrame: NSMakeRect(0,0,400,360)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,295,380,35)
		       label: _(@"Usually in this panel, you would want to add the information\nrelated to your incoming mail server (often POP3).")];
  [self addSubview: label];

  // Server type
  serverTypeLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,265,90,TextFieldHeight)
				 label: _(@"Server type:")
				 alignment: NSRightTextAlignment];
  //[serverTypeLabel setAutoresizingMask: NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: serverTypeLabel];
  
  receivePopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(110,263,125,ButtonHeight)];
  [receivePopUp setAutoenablesItems: NO];
  [receivePopUp addItemWithTitle: _(@"POP3")];
  [receivePopUp addItemWithTitle: _(@"IMAP")];
  [receivePopUp addItemWithTitle: _(@"UNIX")];
  [receivePopUp setTarget: parent];
  [receivePopUp setAction: @selector(setType:)];
  //[popup setAutoresizingMask: NSViewWidthSizable|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: receivePopUp];

  // Server name
  serverNameLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,235,90,TextFieldHeight)
				 label: _(@"Server name:")
				 alignment: NSRightTextAlignment];
  //[serverNameLabel setAutoresizingMask: NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: serverNameLabel];
  
  receiveServerNameField = [[NSTextField alloc] initWithFrame: NSMakeRect(110,235,150,TextFieldHeight)];
  [receiveServerNameField setSelectable: YES];
  //[serverNameField setAutoresizingMask: NSViewWidthSizable|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: receiveServerNameField];


  // Server port
  serverPortLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,205,90,TextFieldHeight)
				 label: _(@"Server port:")
				 alignment: NSRightTextAlignment];
  //[serverPortLabel setAutoresizingMask: NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: serverPortLabel];
  
  receiveServerPortField = [[NSTextField alloc] initWithFrame: NSMakeRect(110,205,150,TextFieldHeight)];
  [receiveServerPortField setSelectable: YES];
  //[serverPortField setAutoresizingMask: NSViewMinXMargin|NSViewWidthSizable|NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: receiveServerPortField];
    

  // Username
  usernameLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,175,90,TextFieldHeight) 
			       label: _(@"Username:")
			       alignment: NSRightTextAlignment];
  //[usernameLabel setAutoresizingMask: NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: usernameLabel];
    
  receiveUsernameField = [[NSTextField alloc] initWithFrame: NSMakeRect(110,175,150,TextFieldHeight)];
  [receiveUsernameField setSelectable: YES];
  //[usernameField setAutoresizingMask: NSViewWidthSizable|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: receiveUsernameField];
  
  
  // Remember password
  receiveRememberPassword = [[NSButton alloc] initWithFrame: NSMakeRect(10,145,200,ButtonHeight)];
  [receiveRememberPassword setButtonType: NSSwitchButton];
  [receiveRememberPassword setBordered: NO];
  [receiveRememberPassword setTitle: _(@"Remember password")];
  [receiveRememberPassword setTarget: parent];
  [receiveRememberPassword setAction: @selector(receiveRememberPasswordClicked:)];
  //[receiveRememberPassword setAutoresizingMask: NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: receiveRememberPassword];

  // Password
  passwordLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,120,90,TextFieldHeight) 
			       label: _(@"Password:")
			       alignment: NSRightTextAlignment];
  //[passwordLabel setAutoresizingMask: NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: passwordLabel];  
  
  receivePasswordSecureField = [[NSSecureTextField alloc] initWithFrame: NSMakeRect(110,120,150,TextFieldHeight)];
  [receivePasswordSecureField setSelectable: YES];
  //[passwordSecureField setAutoresizingMask: NSViewWidthSizable|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: receivePasswordSecureField];
  
  
  // Check on startup
  receiveCheckOnStartup = [[NSButton alloc] initWithFrame: NSMakeRect(10,90,250,ButtonHeight)];
  [receiveCheckOnStartup setButtonType: NSSwitchButton];
  [receiveCheckOnStartup setBordered: NO];
  [receiveCheckOnStartup setTitle: _(@"Check for new mail on startup")];
  //[receiveCheckOnStartup setAutoresizingMask: NSViewMinYMargin|NSViewMaxYMargin];
  [self addSubview: receiveCheckOnStartup];


  // Use SSL
  secureLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,68,190,TextFieldHeight) 
			     label: _(@"Use secure connection:")
			     alignment: NSLeftTextAlignment];
  [self addSubview: secureLabel];

  receiveUseSecureConnection = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(200,68,150,ButtonHeight)];
  [receiveUseSecureConnection setTarget: parent];
  [receiveUseSecureConnection setAction: @selector(receiveUseSecureConnectionHasChanged:)];
  [self addSubview: receiveUseSecureConnection];

  
  //
  // Matrix
  //
  cell = [[NSButtonCell alloc] init];
  AUTORELEASE(cell);
  [cell setButtonType: NSRadioButton];
  [cell setBordered: NO];
  [cell setImagePosition: NSImageLeft];

  receiveMatrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(10,5,200,45)
				    mode: NSRadioModeMatrix
				    prototype: cell
				    numberOfRows: 3
				    numberOfColumns: 1];
  [receiveMatrix setTarget: parent];
  [receiveMatrix setIntercellSpacing: NSMakeSize (0,3)];
  [receiveMatrix setAutosizesCells: NO];
  [receiveMatrix setAllowsEmptySelection: NO];
 
  cell = [receiveMatrix cellAtRow: 0 column: 0];
  [cell setTitle: _(@"Check for new mail manually")];
  [cell setAction: @selector(receiveSetManually:)];

  cell = [receiveMatrix cellAtRow: 1 column: 0];
  [cell setTitle: _(@"Check for new mail automatically every")];
  [cell setAction: @selector(receiveSetAutomatically:)];

  cell = [receiveMatrix cellAtRow: 2 column: 0];
  [cell setTitle: _(@"Never check for new mail")];
  [cell setAction: @selector(receiveSetAutomatically:)];
  [receiveMatrix sizeToFit];
 
  [self addSubview: receiveMatrix];

  receiveMinutesField = [[NSTextField alloc] initWithFrame: NSMakeRect(280,25,40,TextFieldHeight)];
  [receiveMinutesField setEditable: NO];
  [receiveMinutesField setSelectable: YES];
  [self addSubview: receiveMinutesField];
  
  minutesLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(325,23,50,TextFieldHeight)
                              label: _(@"minutes")];
  [self addSubview: minutesLabel];

  
  //
  // We set the next key views
  //
  [receivePopUp setNextKeyView: receiveServerNameField];
  [receiveServerNameField setNextKeyView: receiveServerPortField];
  [receiveServerPortField setNextKeyView: receiveUsernameField];
  [receiveUsernameField setNextKeyView: receiveRememberPassword];
  [receiveRememberPassword setNextKeyView: receivePasswordSecureField];
  [receivePasswordSecureField setNextKeyView: receiveCheckOnStartup];
  [receiveCheckOnStartup setNextKeyView: receiveUseSecureConnection];
  [receiveUseSecureConnection setNextKeyView: receiveMatrix];
  [receiveMatrix setNextKeyView: receiveMinutesField];
  [receiveMinutesField setNextKeyView: receiveServerNameField];
}

@end





