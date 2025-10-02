/*
**  ComposeView.m
**
**  Copyright (c) 2001-2004 Ludovic Marcotte
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

#include "ComposeView.h"

#include "Constants.h"
#include "LabelWidget.h"


//
//
//
@implementation ComposeView

- (id) initWithParent: (id) theParent
{
  self = [super init];

  parent = theParent;
  [self setFrame:NSMakeRect(0,0,450,245)];

  return self;
}

//
//
//
- (void) dealloc
{
  NSDebugLog(@"ComposeView: -dealloc");
  
  RELEASE(replyPopUpButton);
  RELEASE(forwardPopUpButton);
  RELEASE(lineWrapLimitField);
  RELEASE(defaultCharsetPopUpButton);
  RELEASE(defaultEncodingPopUpButton);

  [super dealloc];
}


//
//
//
- (void) layoutView
{
  LabelWidget *replyLabel1, *replyLabel2, *forwardLabel1, *forwardLabel2;
  LabelWidget *label;

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,178,430,54)
		       label: _(@"In this panel, you can specify where you want GNUMail to\nautomatically add your signature when replying to a mail or when\nforwarding a mail.")];
  [self addSubview: label];

  // Our reply information
  replyLabel1 = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,155,400,TextFieldHeight)
			     label: _(@"When replying to an E-Mail, add the signature to the") ];
  [self addSubview: replyLabel1];
  
  replyPopUpButton = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(20,130,120,ButtonHeight)];
  [replyPopUpButton setAutoenablesItems: NO];
  [replyPopUpButton addItemWithTitle: _(@"beginning")];
  [replyPopUpButton addItemWithTitle: _(@"end")];
  [self addSubview: replyPopUpButton];

  replyLabel2 = [LabelWidget labelWidgetWithFrame: NSMakeRect(145,130,150,TextFieldHeight)
			     label: _(@"of the message.") ];
  [self addSubview: replyLabel2];
  
  
  // Our forward information
  forwardLabel1 = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,105,400,TextFieldHeight)
			       label: _(@"When forwarding an E-Mail, add the signature to the") ];
  [self addSubview: forwardLabel1];
  
  forwardPopUpButton = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(20,80,120,ButtonHeight)];
  [forwardPopUpButton setAutoenablesItems: NO];
  [forwardPopUpButton addItemWithTitle: _(@"beginning")];
  [forwardPopUpButton addItemWithTitle: _(@"end")];
  [self addSubview: forwardPopUpButton];

  forwardLabel2 = [LabelWidget labelWidgetWithFrame: NSMakeRect(145,80,150,TextFieldHeight)
			       label: _(@"of the message.") ];
  [self addSubview: forwardLabel2];

  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,50,80,TextFieldHeight)
		       label: _(@"Wrap lines at")];
  [self addSubview: label];
  
  lineWrapLimitField = [[NSTextField alloc] initWithFrame: NSMakeRect(90,50,40,TextFieldHeight)];
  [self addSubview: lineWrapLimitField];
  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(135,50,295,TextFieldHeight)
		       label: _(@"characters when sending plain/text messages.")];
  [self addSubview: label];

  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,25,350,TextFieldHeight)
		       label: _(@"Default charset used when sending a message:")];
  [self addSubview: label];

  defaultCharsetPopUpButton = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(20,0,250,ButtonHeight)];
  [defaultCharsetPopUpButton setAutoenablesItems: NO];
  [defaultCharsetPopUpButton addItemWithTitle: _(@"Automatic")];
  [self addSubview: defaultCharsetPopUpButton];

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(270,0,70,TextFieldHeight)
		       label: _(@"encoding:")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  defaultEncodingPopUpButton = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(350,0,80,ButtonHeight)];
  [defaultEncodingPopUpButton setAutoenablesItems: NO];
  // FIXME - move to controller
  [defaultEncodingPopUpButton addItemWithTitle: _(@"8bit")];
  [defaultEncodingPopUpButton addItemWithTitle: _(@"base64")];
  [defaultEncodingPopUpButton addItemWithTitle: _(@"quoted-printable")];
  [self addSubview: defaultEncodingPopUpButton];
}

@end
