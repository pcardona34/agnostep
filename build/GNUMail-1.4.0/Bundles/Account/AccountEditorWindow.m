/*
**  AccountEditorWindow.m
**
**  Copyright (c) 2003-2006 Ludovic Marcotte
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

#include "AccountEditorWindow.h"

#include "Constants.h"
#include "LabelWidget.h"


//
//
//
@implementation AccountEditorWindow

- (void) dealloc
{
  NSDebugLog(@"AccountEditorWindow: -dealloc");

  [super dealloc];
}


//
//
//
- (void) layoutWindow
{
  NSButton *okButton, *cancelButton;
  NSTabViewItem *tabViewItem;

  tabView = [[NSTabView alloc] initWithFrame: NSMakeRect(5,35,400,360)];

  tabViewItem = [[NSTabViewItem alloc] initWithIdentifier: @"Personal"];
  [tabViewItem setLabel: _(@"Personal")];
  [tabView addTabViewItem: tabViewItem];
  RELEASE(tabViewItem);

  tabViewItem = [[NSTabViewItem alloc] initWithIdentifier: @"Receive"];
  [tabViewItem setLabel: _(@"Receive")];
  [tabView addTabViewItem: tabViewItem];
  RELEASE(tabViewItem);

  tabViewItem = [[NSTabViewItem alloc] initWithIdentifier: @"Receive options"];
  [tabViewItem setLabel: _(@"Receive options")];
  [tabView addTabViewItem: tabViewItem];
  RELEASE(tabViewItem);

  tabViewItem = [[NSTabViewItem alloc] initWithIdentifier: @"Send"];
  [tabViewItem setLabel: _(@"Send")];
  [tabView addTabViewItem: tabViewItem];
  RELEASE(tabViewItem);

  [[self contentView] addSubview: tabView];
  RELEASE(tabView);

  cancelButton = [[NSButton alloc] initWithFrame: NSMakeRect(250,5,75,ButtonHeight)];
  [cancelButton setButtonType: NSMomentaryPushButton];
  [cancelButton setKeyEquivalent: @"\e"];
  [cancelButton setTitle: _(@"Cancel")];
  [cancelButton setTarget: [self windowController]];
  [cancelButton setAction: @selector(cancelClicked:)];
  [[self contentView] addSubview: cancelButton];
  RELEASE(cancelButton);

  okButton = [[NSButton alloc] initWithFrame:  NSMakeRect(330,5,75,ButtonHeight)];
  [okButton setButtonType: NSMomentaryPushButton];
  [okButton setKeyEquivalent: @"\r"];
  [okButton setImagePosition: NSImageRight];
  [okButton setImage: [NSImage imageNamed: @"common_ret"]];
  [okButton setAlternateImage: [NSImage imageNamed: @"common_retH"]];
  [okButton setTitle: _(@"OK")];
  [okButton setTarget: [self windowController]];
  [okButton setAction: @selector(okClicked:)];
  [[self contentView] addSubview: okButton];
  RELEASE(okButton);
}

@end
