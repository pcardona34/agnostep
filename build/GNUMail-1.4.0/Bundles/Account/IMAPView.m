/*
**  IMAPView.m
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

#include "IMAPView.h"

#include "Constants.h"
#include "LabelWidget.h"
#include "Utilities.h"

const NSString *IMAPViewMailboxTableColumnIdentifier = @"all folders";
const NSString *IMAPViewSubscriptionTableColumnIdentifier = @"subscribed folders";

//
//
//
@implementation IMAPView

- (void) dealloc
{
  NSDebugLog(@"IMAPView: -dealloc");
  
  RELEASE(imapViewMailboxColumn);
  RELEASE(imapSubscriptionColumn);
  RELEASE(imapOutlineView);
  RELEASE(imapMatrix);

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
  NSButton *list, *imapSupportedMechanismsButton;
  NSScrollView *scrollView;
  LabelWidget *label;
  NSButtonCell *cell;

  [self setFrame: NSMakeRect(0,0,400,360)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,285,365,50)
		       label: _(@"In this panel, you can subscribe or unsubscribe to\nmailboxes on your IMAP server. To connect and list the\navailable mailboxes, click on the List button.")];
  [self addSubview: label];


  //
  //
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,235,115,45)
		       label: _(@"Authentication:")
		       alignment: NSRightTextAlignment];
  [self addSubview: label];

  imapSupportedMechanismsPopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(130,245,100,ButtonHeight)];
  [self addSubview: imapSupportedMechanismsPopUp];

  imapSupportedMechanismsButton = [[NSButton alloc] initWithFrame: NSMakeRect(240,245,135,ButtonHeight)];
  [imapSupportedMechanismsButton setTitle: _(@"Check supported")];
  [imapSupportedMechanismsButton setTarget: parent];
  [imapSupportedMechanismsButton setAction: @selector(imapSupportedMechanismsButtonClicked:)];
  [self addSubview: imapSupportedMechanismsButton];

  //
  //
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,200,145,45)
		       label: _(@"Show which mailboxes?")];
  [self addSubview: label];

  cell = [[NSButtonCell alloc] init];
  AUTORELEASE(cell);
  [cell setButtonType: NSSwitchButton];
  [cell setBordered: NO];
  [cell setImagePosition: NSImageLeft];

  imapMatrix = [[NSMatrix alloc] initWithFrame: NSMakeRect(160,215,225,20) 
			     mode: NSRadioModeMatrix
			     prototype: cell
			     numberOfRows: 1
			     numberOfColumns: 2];
  [imapMatrix setIntercellSpacing: NSMakeSize(0,0) ];
  [imapMatrix setAutosizesCells: NO];

  cell = [imapMatrix cellAtRow: 0 column: 0];
  [cell setTitle: _(@"all")];
  [cell setTag: 0];

  cell = [imapMatrix cellAtRow: 0 column: 1];
  [cell setTitle: _(@"subscribed only")];
  [cell setTag: 1];
  [self addSubview: imapMatrix];

  imapViewMailboxColumn = [[NSTableColumn alloc] initWithIdentifier: (id)IMAPViewMailboxTableColumnIdentifier];
  [imapViewMailboxColumn setEditable: NO];
  [[imapViewMailboxColumn headerCell] setStringValue: _(@"Mailboxes")];
  [imapViewMailboxColumn setMinWidth: 270];

  imapSubscriptionColumn = [[NSTableColumn alloc] initWithIdentifier: (id)IMAPViewSubscriptionTableColumnIdentifier];
  [imapSubscriptionColumn setEditable: YES];
  [[imapSubscriptionColumn headerCell] setStringValue: _(@"Subscribed")];

  imapOutlineView = [[NSOutlineView alloc] initWithFrame: NSMakeRect(5,40,390,185)];
  [imapOutlineView addTableColumn: imapViewMailboxColumn];
  [imapOutlineView addTableColumn: imapSubscriptionColumn];
  [imapOutlineView setOutlineTableColumn: imapViewMailboxColumn];
  [imapOutlineView setDrawsGrid: NO];
  [imapOutlineView setIndentationPerLevel: 10];
  [imapOutlineView setAllowsColumnSelection: NO];
  [imapOutlineView setAllowsColumnReordering: NO];
  [imapOutlineView setAllowsEmptySelection: NO];
  [imapOutlineView setAllowsMultipleSelection: NO];
  [imapOutlineView setIndentationMarkerFollowsCell: YES];
  [imapOutlineView setAutoresizesOutlineColumn: YES];
  [imapOutlineView sizeLastColumnToFit];
  [imapOutlineView setDataSource: parent]; 
  [imapOutlineView setDelegate: parent];
  [imapOutlineView setTarget: parent];
  [imapOutlineView setDoubleAction: @selector(doubleClickedOnNode:)];

  scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(5,40,390,185)];
  [scrollView setBorderType: NSBezelBorder];
  [scrollView setHasHorizontalScroller: YES];
  [scrollView setHasVerticalScroller: YES];
  [scrollView setDocumentView: imapOutlineView];
  [scrollView setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  [self addSubview: scrollView];
  RELEASE(scrollView);
  
  list = [[NSButton alloc] initWithFrame: NSMakeRect(5,5,100,ButtonHeight)];
  [list setTitle: _(@"List")];
  [list setTarget: parent];
  [list setAction: @selector(imapList:)];
  [list setAutoresizingMask: NSViewMaxXMargin|NSViewMaxYMargin];
  [self addSubview: list];
  RELEASE(list);
}


@end
