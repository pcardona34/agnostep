/*
**  FontsView.m
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "FontsView.h"

#include "Constants.h"
#include "LabelWidget.h"

//
//
//
@implementation FontsView

- (id) initWithParent: (id) theParent
{
  self = [super init];

  parent = theParent;
  [self setFrame:NSMakeRect(0,0,450,252)];

  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(headerNamePopUp);
  RELEASE(headerNameSizePopUp);
  RELEASE(headerValuePopUp);
  RELEASE(headerValueSizePopUp);
  RELEASE(messagePopUp);
  RELEASE(messageSizePopUp);

  RELEASE(checkbox);
  RELEASE(plainTextMessagePopUp);
  RELEASE(plainTextMessageSizePopUp);

  RELEASE(previewTextField);

  [super dealloc];
}


//
//
//
- (void) layoutView
{
  LabelWidget *headerNameLabel, *headerValueLabel, *messageLabel, *plainTextMessageLabel;
  LabelWidget *label, *headerNameSizeLabel, *headerValueSizeLabel, *messageSizeLabel, *plainTextMessageSizeLabel;
  
  label =  [LabelWidget labelWidgetWithFrame: NSMakeRect(5, 215, 300, TextFieldHeight)
			label: _(@"Font used when displaying a message for:")];
  [self addSubview: label];
  
  //
  // Header name
  //
  headerNameLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(5, 185, 130, TextFieldHeight)
			  label: _(@"Header name:")
			  alignment: NSRightTextAlignment];
  [self addSubview: headerNameLabel];

  
  headerNamePopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(150, 185, 150, ButtonHeight)];
  [headerNamePopUp setAutoenablesItems: NO];
  [headerNamePopUp setTarget: parent];
  [headerNamePopUp setAction: @selector(selectionInPopUpHasChanged:)];
  [self addSubview: headerNamePopUp];

  headerNameSizeLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(310, 185, 40, TextFieldHeight)
				     label: _(@"Size:")];
  [self addSubview: headerNameSizeLabel];

  
  headerNameSizePopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(350, 185, 50, ButtonHeight)];
  [headerNameSizePopUp setAutoenablesItems: NO];
  [headerNameSizePopUp addItemWithTitle: @"8"];
  [headerNameSizePopUp addItemWithTitle: @"9"];
  [headerNameSizePopUp addItemWithTitle: @"10"];
  [headerNameSizePopUp addItemWithTitle: @"11"];
  [headerNameSizePopUp addItemWithTitle: @"12"];
  [headerNameSizePopUp addItemWithTitle: @"13"];
  [headerNameSizePopUp addItemWithTitle: @"14"];
  [headerNameSizePopUp addItemWithTitle: @"16"];
  [headerNameSizePopUp addItemWithTitle: @"18"];
  [headerNameSizePopUp addItemWithTitle: @"20"];
  [headerNameSizePopUp addItemWithTitle: @"24"];
  [headerNameSizePopUp addItemWithTitle: @"28"];
  [headerNameSizePopUp addItemWithTitle: @"32"];
  [headerNameSizePopUp addItemWithTitle: @"48"];
  [headerNameSizePopUp setTarget: parent];
  [headerNameSizePopUp setAction: @selector(selectionInPopUpHasChanged:)];
  [self addSubview: headerNameSizePopUp];

  

  //
  // Header value
  //
  headerValueLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(5, 155, 130, TextFieldHeight)
				  label: _(@"Header value:")
				  alignment: NSRightTextAlignment];
  [self addSubview: headerValueLabel];

  headerValuePopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(150, 155, 150, ButtonHeight)];
  [headerValuePopUp setAutoenablesItems: NO];
  [headerValuePopUp setTarget: parent];
  [headerValuePopUp setAction: @selector(selectionInPopUpHasChanged:)];
  [self addSubview: headerValuePopUp];

  headerValueSizeLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(310, 155, 40, TextFieldHeight)
				      label: _(@"Size:")];
  [self addSubview: headerValueSizeLabel];

  headerValueSizePopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(350, 155, 50, ButtonHeight)];
  [headerValueSizePopUp setAutoenablesItems: NO];
  [headerValueSizePopUp addItemWithTitle: @"8"];
  [headerValueSizePopUp addItemWithTitle: @"9"];
  [headerValueSizePopUp addItemWithTitle: @"10"];
  [headerValueSizePopUp addItemWithTitle: @"11"];
  [headerValueSizePopUp addItemWithTitle: @"12"];
  [headerValueSizePopUp addItemWithTitle: @"13"];
  [headerValueSizePopUp addItemWithTitle: @"14"];
  [headerValueSizePopUp addItemWithTitle: @"16"];
  [headerValueSizePopUp addItemWithTitle: @"18"];
  [headerValueSizePopUp addItemWithTitle: @"20"];
  [headerValueSizePopUp addItemWithTitle: @"24"];
  [headerValueSizePopUp addItemWithTitle: @"28"];
  [headerValueSizePopUp addItemWithTitle: @"32"];
  [headerValueSizePopUp addItemWithTitle: @"48"];
  [headerValueSizePopUp setTarget: parent];
  [headerValueSizePopUp setAction: @selector(selectionInPopUpHasChanged:)];
  [self addSubview: headerValueSizePopUp];


  //
  // Content of message
  //
  messageLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(0, 125, 135, TextFieldHeight)
                              label: _(@"Content of message:")
			      alignment: NSRightTextAlignment];
  [self addSubview: messageLabel];


  messagePopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(150, 125, 150, ButtonHeight)];
  [messagePopUp setAutoenablesItems: NO];
  [messagePopUp setTarget: parent];
  [messagePopUp setAction: @selector(selectionInPopUpHasChanged:)];
  [self addSubview: messagePopUp];

  messageSizeLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(310, 125, 40, TextFieldHeight)
				     label: _(@"Size:")];
  [self addSubview: messageSizeLabel];
  
  messageSizePopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(350, 125, 50, ButtonHeight)];
  [messageSizePopUp setAutoenablesItems: NO];
  [messageSizePopUp addItemWithTitle: @"8"];
  [messageSizePopUp addItemWithTitle: @"9"];
  [messageSizePopUp addItemWithTitle: @"10"];
  [messageSizePopUp addItemWithTitle: @"11"];
  [messageSizePopUp addItemWithTitle: @"12"];
  [messageSizePopUp addItemWithTitle: @"13"];
  [messageSizePopUp addItemWithTitle: @"14"];
  [messageSizePopUp addItemWithTitle: @"16"];
  [messageSizePopUp addItemWithTitle: @"18"];
  [messageSizePopUp addItemWithTitle: @"20"];
  [messageSizePopUp addItemWithTitle: @"24"];
  [messageSizePopUp addItemWithTitle: @"28"];
  [messageSizePopUp addItemWithTitle: @"32"];
  [messageSizePopUp addItemWithTitle: @"48"];
  [messageSizePopUp setTarget: parent];
  [messageSizePopUp setAction: @selector(selectionInPopUpHasChanged:)];
  [self addSubview: messageSizePopUp];


  // Fixed width for plain messages
  checkbox = [[NSButton alloc] initWithFrame: NSMakeRect(5,95,300,ButtonHeight)];
  [checkbox setButtonType: NSSwitchButton];
  [checkbox setBordered: NO];
  [checkbox setTitle: _(@"Use fixed-width font for plain text messages")];
  [checkbox setTarget: parent];
  [checkbox setAction: @selector(checkboxClicked:)];
  [self addSubview: checkbox];

  plainTextMessageLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(5, 70, 130, TextFieldHeight)
				       label: _(@"Plain text font:")
				       alignment: NSRightTextAlignment];
  [self addSubview: plainTextMessageLabel];


  plainTextMessagePopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(150, 70, 150, ButtonHeight)];
  [plainTextMessagePopUp setAutoenablesItems: NO];
  [plainTextMessagePopUp setTarget: parent];
  [plainTextMessagePopUp setAction: @selector(selectionInPopUpHasChanged:)];
  [self addSubview: plainTextMessagePopUp];

  plainTextMessageSizeLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(310, 70, 40, TextFieldHeight)
				     label: _(@"Size:")];
  [self addSubview: plainTextMessageSizeLabel];
  
  plainTextMessageSizePopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(350, 70, 50, ButtonHeight)];
  [plainTextMessageSizePopUp setAutoenablesItems: NO];
  [plainTextMessageSizePopUp addItemWithTitle: @"8"];
  [plainTextMessageSizePopUp addItemWithTitle: @"9"];
  [plainTextMessageSizePopUp addItemWithTitle: @"10"];
  [plainTextMessageSizePopUp addItemWithTitle: @"11"];
  [plainTextMessageSizePopUp addItemWithTitle: @"12"];
  [plainTextMessageSizePopUp addItemWithTitle: @"13"];
  [plainTextMessageSizePopUp addItemWithTitle: @"14"];
  [plainTextMessageSizePopUp addItemWithTitle: @"16"];
  [plainTextMessageSizePopUp addItemWithTitle: @"18"];
  [plainTextMessageSizePopUp addItemWithTitle: @"20"];
  [plainTextMessageSizePopUp addItemWithTitle: @"24"];
  [plainTextMessageSizePopUp addItemWithTitle: @"28"];
  [plainTextMessageSizePopUp addItemWithTitle: @"32"];
  [plainTextMessageSizePopUp addItemWithTitle: @"48"];
  [plainTextMessageSizePopUp setTarget: parent];
  [plainTextMessageSizePopUp setAction: @selector(selectionInPopUpHasChanged:)];
  [self addSubview: plainTextMessageSizePopUp];

  previewLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(5, 45, 250, TextFieldHeight)
			      label: _(@"Font preview for the header name:")];
  [self addSubview: previewLabel];
  
  previewTextField = [[NSTextField alloc] initWithFrame: NSMakeRect(5,0,295,40)];
  [previewTextField setStringValue: _(@"This is an example...")];
  [previewTextField setEditable: NO];
  [previewTextField setSelectable: NO];
  [previewTextField setBezeled: YES];
  [previewTextField setDrawsBackground: YES];
  [previewTextField setBackgroundColor: [NSColor controlBackgroundColor]];

  [self addSubview: previewTextField];
}

@end
