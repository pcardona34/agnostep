/*
**
**  AddressBookPanel.m
**
**  Copyright (c) 2003 Ludovic Marcotte
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
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "AddressBookPanel.h"

#include <Addresses/Addresses.h>
#include "Constants.h"

//
//
//
@implementation AddressBookPanel

- (void) dealloc
{
  RELEASE(singlePropertyView);
  
  [super dealloc];
}


//
//
//
- (void) layoutPanel
{
  NSButton *open, *to, *cc, *bcc;
  NSTextField *prefLabelField;
  float x, w;
  
  open = [[NSButton alloc] initWithFrame: NSMakeRect(10,280,40,40)];
  [open setStringValue: @""];
  [open setImagePosition: NSImageOnly];
  [open setImage: [NSImage imageNamed: @"AddressManager_32.tiff"]];
  [open setTarget: [self windowController]];
  [open setAction: @selector(openClicked:)];
  [[self contentView] addSubview: open];
  RELEASE(open);

  prefLabelField = [[NSTextField alloc] initWithFrame: NSMakeRect(60,285,310,30)];
  [prefLabelField setStringValue: _(@"Preferred Address Type:")];
  [prefLabelField setEditable: NO];
  [prefLabelField setSelectable: NO];
  [prefLabelField setDrawsBackground: NO];
  [prefLabelField setBezeled: NO];
  [prefLabelField setBordered: NO];
  [prefLabelField sizeToFit];
  w = [prefLabelField frame].size.width;
  [prefLabelField setFrameSize: NSMakeSize(w, 30)];
  [[self contentView] addSubview: prefLabelField];
  RELEASE(prefLabelField);

  x = [prefLabelField frame].origin.x + [prefLabelField frame].size.width + 5;
  prefLabelPopup = [[NSPopUpButton alloc]
		     initWithFrame: NSMakeRect(x,285,370-x,30)];
  [prefLabelPopup setTarget: self];
  [prefLabelPopup setAction: @selector(prefLabelChanged:)];
  [[self contentView] addSubview: prefLabelPopup];

  [prefLabelPopup addItemWithTitle: _(@"Any")];
  RELEASE(prefLabelPopup);
  
  to = [[NSButton alloc] initWithFrame: NSMakeRect(380,280,40,40)];
  [to setStringValue: @""];
  [to setImagePosition: NSImageOnly];
  [to setImage: [NSImage imageNamed: @"Address_to.tiff"]];
  [to setTarget: [self windowController]];
  [to setAction: @selector(toClicked:)];
  [[self contentView] addSubview: to];
  RELEASE(to);

  cc = [[NSButton alloc] initWithFrame: NSMakeRect(425,280,40,40)];
  [cc setStringValue: @""];
  [cc setImagePosition: NSImageOnly];
  [cc setImage: [NSImage imageNamed: @"Address_cc.tiff"]];
  [cc setTarget: [self windowController]];
  [cc setAction: @selector(ccClicked:)];
  [[self contentView] addSubview: cc];
  RELEASE(cc);

  bcc = [[NSButton alloc] initWithFrame: NSMakeRect(470,280,40,40)];
  [bcc setStringValue: @""];
  [bcc setImagePosition: NSImageOnly];
  [bcc setImage: [NSImage imageNamed: @"Address_bcc.tiff"]];
  [bcc setTarget: [self windowController]];
  [bcc setAction: @selector(bccClicked:)];
  [[self contentView] addSubview: bcc];
  RELEASE(bcc);

  //[ADPerson setScreenNameFormat: ADScreenNameFirstNameFirst];
  singlePropertyView = [[ADSinglePropertyView alloc] initWithFrame: NSMakeRect(10,5,500,265)];
  [singlePropertyView setDelegate: [self windowController]];
  [singlePropertyView setAutoselectMode: ADAutoselectFirstValue];
  [[self contentView] addSubview: singlePropertyView];
}

- (void) prefLabelChanged: (id) sender
{
  [singlePropertyView setPreferredLabel: [[sender selectedItem]
					   representedObject]];
}
@end
