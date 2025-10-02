/*
**  POP3View.m
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

#include "POP3View.h"

#include "Constants.h"
#include "LabelWidget.h"


//
//
//
@implementation POP3View

- (void) dealloc
{
  NSDebugLog(@"POP3View: -dealloc");

  RELEASE(pop3DefaultInboxPopUpButton);
  RELEASE(pop3LeaveOnServer);
  RELEASE(pop3DaysField);
  RELEASE(pop3UseAPOP);

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

  self = [super init];
  
  [self setFrame: NSMakeRect(0,0,400,360)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];

  pop3LeaveOnServer = [[NSButton alloc] initWithFrame: NSMakeRect(10,290,210,ButtonHeight)];
  [pop3LeaveOnServer setButtonType: NSSwitchButton];
  [pop3LeaveOnServer setBordered: NO];
  [pop3LeaveOnServer setTitle: _(@"Leave messages on server for")];
  [pop3LeaveOnServer setAutoresizingMask: NSViewMinYMargin];
  [self addSubview: pop3LeaveOnServer];

  pop3DaysField = [[NSTextField alloc] initWithFrame: NSMakeRect(225,293,40,TextFieldHeight)];
  [pop3DaysField setAutoresizingMask: NSViewMinYMargin];
  [self addSubview: pop3DaysField];
  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(275,293,50,TextFieldHeight)
		       label: _(@"days")];
  [label setAutoresizingMask: NSViewMinYMargin];
  [self addSubview: label];
  

  pop3UseAPOP = [[NSButton alloc] initWithFrame: NSMakeRect(10,260,380,ButtonHeight)];
  [pop3UseAPOP setButtonType: NSSwitchButton];
  [pop3UseAPOP setBordered: NO];
  [pop3UseAPOP setTitle: _(@"Use Authenticated Post Office Protocol (APOP)")];
  [pop3UseAPOP setAutoresizingMask: NSViewMinYMargin];
  [self addSubview: pop3UseAPOP];


  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,200,380,TextFieldHeight)
		       label: _(@"Save messages received from this account in this mailbox:")];
  [self addSubview: label];

  pop3DefaultInboxPopUpButton = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(65, 170, 250, ButtonHeight)];
  [self addSubview: pop3DefaultInboxPopUpButton];

  label =  [LabelWidget labelWidgetWithFrame: NSMakeRect(10, 140, 425, 30)
			label: _(@"If you don't see all your IMAP mailboxes, first open a connection to this server.")];
  [label setFont: [NSFont systemFontOfSize: 10]];
  [self addSubview: label];

  //
  // We set the next key views
  //
  [pop3LeaveOnServer setNextKeyView: pop3DaysField];
  [pop3DaysField setNextKeyView: pop3UseAPOP];
  [pop3UseAPOP setNextKeyView: pop3LeaveOnServer];
}

@end
