/*
**  SendingView.m
**
**  Copyright (c) 2001-2003 Ludovic Marcotte
**                2012 Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**          Riccardo Mottola
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

#include "SendingView.h"

#include "Constants.h"
#include "LabelWidget.h"


//
//
//
@implementation SendingView

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
  NSDebugLog(@"SendingView: -dealloc");

  RELEASE(headerKeyColumn);
  RELEASE(headerValueColumn);
  RELEASE(headerTableView);

  RELEASE(headerKeyField);
  RELEASE(headerValueField);
    
  [super dealloc];
}


//
//
//
- (void) layoutView
{
  LabelWidget *label, *headerKeyLabel, *headerValueLabel;
  NSButton *addHeader, *removeHeader;
  NSScrollView *scrollView;
 
  //
  // We create the view for our additional headers
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,178,430,54)
		       label: _(@"In this panel, you can specify which messages headers will be\nautomatically added when sending mails. Usually, most users will\nignore this feature.")];
  [self addSubview: label];

  headerKeyColumn = [[NSTableColumn alloc] initWithIdentifier: @"header-key"];
  [headerKeyColumn setEditable: YES];
  [[headerKeyColumn headerCell] setStringValue: _(@"Key")];
  [headerKeyColumn setMinWidth: 180];

  headerValueColumn = [[NSTableColumn alloc] initWithIdentifier: @"header-value"];
  [headerValueColumn setEditable: YES];
  [[headerValueColumn headerCell] setStringValue: _(@"Value")];
  [headerValueColumn setMinWidth: 265];

  headerTableView = [[NSTableView alloc] initWithFrame: NSMakeRect(5,70,430,95)];
  [headerTableView setDrawsGrid: NO];
  [headerTableView setAllowsColumnSelection: NO];
  [headerTableView setAllowsColumnReordering: NO];
  [headerTableView setAllowsEmptySelection: NO];
  [headerTableView setAllowsMultipleSelection: NO];
  [headerTableView addTableColumn: headerKeyColumn];
  [headerTableView addTableColumn: headerValueColumn];
  [headerTableView setDataSource: parent]; 
  [headerTableView setDelegate: parent];

  scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(5,70,430,95)];
  [scrollView setBorderType: NSBezelBorder];
  [scrollView setHasHorizontalScroller: NO];
  [scrollView setHasVerticalScroller: YES];
  [scrollView setDocumentView: headerTableView];
  [self addSubview: scrollView];
  RELEASE(scrollView);

  headerKeyLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,40,60,TextFieldHeight)
			       label: _(@"Key:")];
  [self addSubview: headerKeyLabel];

  headerKeyField = [[NSTextField alloc] initWithFrame: NSMakeRect(65,40,125,TextFieldHeight)];
  [headerKeyField setEditable: YES];
  [headerKeyField setSelectable: YES];
  [self addSubview: headerKeyField];

  headerValueLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(205,40,35,TextFieldHeight)
			    label: _(@"Value:")];
  [self addSubview: headerValueLabel];
  
  headerValueField = [[NSTextField alloc] initWithFrame: NSMakeRect(250,40,185,TextFieldHeight)];
  [headerValueField setEditable: YES];
  [headerValueField setSelectable: YES];
  [self addSubview: headerValueField];

  addHeader = [[NSButton alloc] initWithFrame: NSMakeRect(5,5,75, ButtonHeight)];
  [addHeader setTitle: _(@"Add")];
  [addHeader setTarget: parent];
  [addHeader setAction: @selector(addHeader:)];
  [self addSubview: addHeader];
  RELEASE(addHeader);

  removeHeader = [[NSButton alloc] initWithFrame: NSMakeRect(85,5,75, ButtonHeight)];
  [removeHeader setTitle: _(@"Remove")];
  [removeHeader setTarget: parent];
  [removeHeader setAction: @selector(removeHeader:)];
  [self addSubview: removeHeader];
  RELEASE(removeHeader);

  // We set the next key views
  [headerKeyField setNextKeyView: headerValueField];
  [headerValueField setNextKeyView: addHeader];
  [addHeader setNextKeyView: removeHeader];
  [removeHeader setNextKeyView: headerKeyField];
}

@end
