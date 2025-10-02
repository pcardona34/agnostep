/*
**  UNIXView.m
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
 
#include "UNIXView.h"

#include "Constants.h"
#include "LabelWidget.h"


//
//
//
@implementation UNIXView

- (void) dealloc
{
  NSDebugLog(@"UNIXView: -dealloc");

  RELEASE(unixDefaultInboxPopUpButton);
  RELEASE(unixMailspoolFileField);

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
  NSButton *unixMailspoolFileButton;
  LabelWidget *label;

  self = [super init];

  [self setFrame: NSMakeRect(0,0,400,360)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,290,150,TextFieldHeight)
		       label: _(@"Mail spool file:")];
  [label setAutoresizingMask: NSViewMinYMargin];
  [self addSubview: label];

  unixMailspoolFileField = [[NSTextField alloc] initWithFrame: NSMakeRect(20,260,250,TextFieldHeight)];
  [unixMailspoolFileField setEditable: YES];
  [unixMailspoolFileField setSelectable: YES];
  [unixMailspoolFileField setAutoresizingMask: NSViewMinYMargin];
  [self addSubview: unixMailspoolFileField];
  
  unixMailspoolFileButton = [[NSButton alloc] initWithFrame: NSMakeRect(280,258,75,ButtonHeight)];
  [unixMailspoolFileButton setTitle: _(@"Choose file")];
  [unixMailspoolFileButton setTarget: parent];
  [unixMailspoolFileButton setAction: @selector(unixMailspoolFileButtonClicked:)];
  [unixMailspoolFileButton setAutoresizingMask: NSViewMinYMargin];
  [self addSubview: unixMailspoolFileButton];
  RELEASE(unixMailspoolFileButton);

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,200,380,TextFieldHeight)
		       label: _(@"Save messages received from this account in this mailbox:")];
  [self addSubview: label];

  unixDefaultInboxPopUpButton = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(65, 170, 250, ButtonHeight)];
  [self addSubview: unixDefaultInboxPopUpButton];

  label =  [LabelWidget labelWidgetWithFrame: NSMakeRect(10, 140, 425, 30)
			label: _(@"If you don't see all your IMAP mailboxes, first open a connection to this server.")];
  [label setFont: [NSFont systemFontOfSize: 10]];
  [self addSubview: label];
}

@end
