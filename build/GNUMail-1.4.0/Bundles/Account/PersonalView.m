/*
**  PersonalView.m
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

#include "PersonalView.h"

#include "Constants.h"
#include "LabelWidget.h"

@implementation PersonalView

- (id) initWithParent: (id) theParent
{
  self = [super init];

  parent = theParent;

  return self;
}

//
//
//
- (void) dealloc
{
  NSDebugLog(@"PersonalView: -dealloc");
  
  RELEASE(personalAccountNameField);

  RELEASE(personalNameField);
  RELEASE(personalEMailField);
  RELEASE(personalReplyToField);
  RELEASE(personalOrganizationField);

  RELEASE(personalSignaturePopUp);
  RELEASE(personalSignatureField);
  RELEASE(personalLocationButton);
  
  [super dealloc];
}


//
//
//
- (void) layoutView
{
  LabelWidget *label, *nameLabel, *emailLabel, *personalReplyToLabel, *personalOrganizationLabel, *personalSignatureLabel;

  [self setFrame: NSMakeRect(0,0,400,360)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  
  
  //
  // Name of the account
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,310,125,15)
		       label: _(@"Account name:")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  personalAccountNameField = [[NSTextField alloc] initWithFrame: NSMakeRect(145,308,235,TextFieldHeight)];
  [personalAccountNameField setEditable: YES];
  [self addSubview: personalAccountNameField];

  //
  //
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,255,380,50)
		       label: _(@"Please specify your personal information. You need to\nspecify at least your name and your E-Mail address. You can\nleave the other fields blank.")];
  [self addSubview: label];


  //
  // Name of the user
  //
  nameLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,225,125,TextFieldHeight)
			   label: _(@"Your name:")
			   alignment: NSRightTextAlignment];
  [self addSubview: nameLabel];
  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,210,125,TextFieldHeight)
		       label: _(@"(Ex: Bob Smith)")
		       alignment: NSRightTextAlignment];
  [label setFont: [NSFont systemFontOfSize: 10]];
  [self addSubview: label];

  personalNameField = [[NSTextField alloc] initWithFrame: NSMakeRect(145,225,235,TextFieldHeight)];
  [personalNameField setEditable: YES];
  [self addSubview: personalNameField];
  

  //
  // E-Mail
  //
  emailLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,190,130,TextFieldHeight)
			    label: _(@"Your E-Mail address:")
			    alignment: NSRightTextAlignment];
  [self addSubview: emailLabel];

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,175,125,TextFieldHeight)
		       label: _(@"(Ex: bob@smith.com)")
		       alignment: NSRightTextAlignment];
  [label setFont: [NSFont systemFontOfSize: 10]];
  [self addSubview: label];
  
  personalEMailField = [[NSTextField alloc] initWithFrame: NSMakeRect(145,190,235,TextFieldHeight)];
  [personalEMailField setEditable: YES];
  [self addSubview: personalEMailField];
 
    
  //
  // Reply-To
  // 
  personalReplyToLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,155,125,TextFieldHeight)
				      label: _(@"Reply-To address:")
				      alignment: NSRightTextAlignment];
  [self addSubview: personalReplyToLabel];
  
  personalReplyToField = [[NSTextField alloc] initWithFrame: NSMakeRect(145,155,235,TextFieldHeight)];
  [personalReplyToField setEditable: YES];
  [self addSubview: personalReplyToField];


  //
  // PersonalOrganization
  //
  personalOrganizationLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,120,125,TextFieldHeight)
					   label: _(@"Organization:")
					   alignment: NSRightTextAlignment];
  [self addSubview: personalOrganizationLabel];
  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,105,125,TextFieldHeight)
		       label: _(@"(Ex: ACME inc.)")
		       alignment: NSRightTextAlignment];
  [label setFont: [NSFont systemFontOfSize: 10]];
  [self addSubview: label];
  
  personalOrganizationField = [[NSTextField alloc] initWithFrame: NSMakeRect(145,120,235,TextFieldHeight)];
  [personalOrganizationField setEditable: YES];
  [self addSubview: personalOrganizationField];
  

  //
  // We add the rest of our UI elements for setting the signature
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,70,390,30)
		       label: _(@"The signature will be appended at the end of your message.")];
  [self addSubview: label];
  
  personalSignatureLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,45,150,TextFieldHeight)
					label: _(@"Obtain signature from:")
					alignment: NSRightTextAlignment];
  [self addSubview: personalSignatureLabel];

  personalSignaturePopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(160,45,145,ButtonHeight)];
  [personalSignaturePopUp setAutoenablesItems: NO];
  [personalSignaturePopUp addItemWithTitle: _(@"content of file")];
  [personalSignaturePopUp addItemWithTitle: _(@"program's output")];
  [personalSignaturePopUp setTarget: parent];
  [personalSignaturePopUp setAction: @selector(selectionInPersonalSignaturePopUpHasChanged:)];
  [self addSubview: personalSignaturePopUp];

  personalLocationButton = [[NSButton alloc] initWithFrame: NSMakeRect(315,45,65,ButtonHeight)];
  [personalLocationButton setTitle: _(@"Choose")];
  [personalLocationButton setTarget: parent];
  [personalLocationButton setAction: @selector(personalLocationButtonClicked:)];
  [self addSubview: personalLocationButton];
  
  personalLocationLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,15,150,TextFieldHeight)
				       label: _(@"File location:")
				       alignment: NSRightTextAlignment];
  [self addSubview: personalLocationLabel];

  personalSignatureField = [[NSTextField alloc] initWithFrame: NSMakeRect(160,15,220,TextFieldHeight)];
  [personalSignatureField setEditable: YES];
  [personalSignatureField setSelectable: YES];
  [self addSubview: personalSignatureField];
  
  //
  // We set the next key views
  //
  [personalAccountNameField setNextKeyView: personalNameField];
  [personalNameField setNextKeyView: personalEMailField];
  [personalEMailField setNextKeyView: personalReplyToField];
  [personalReplyToField setNextKeyView: personalOrganizationField];
  [personalOrganizationField setNextKeyView: personalSignaturePopUp];
  [personalSignaturePopUp setNextKeyView: personalLocationButton];
  [personalLocationButton setNextKeyView: personalSignatureField];
  [personalSignatureField setNextKeyView: personalAccountNameField];
}

@end
