/*
**  AccountView.m
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

#include "AccountView.h"

#include "Constants.h"
#include "LabelWidget.h"

@implementation AccountView

- (id) initWithParent: (id) theParent
{
  self = [super init];
  
  _parent = theParent;
  [self setFrame:NSMakeRect(0,0,455,240)];

  return self;
}

//
//
//
- (void) dealloc
{
  RELEASE(tableView);
  [super dealloc];
}


//
//
//
- (void) layoutView
{
  NSButton *addButton, *deleteButton, *editButton, *defaultButton;
  NSTableColumn *accountNameColumn, *enabledColumn;
  NSScrollView *scrollView;
  LabelWidget *label;
  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,195,430,35)
		       label: _(@"Please specify your account information. You need to add at least\none account in order to use GNUMail properly.")];
  [self addSubview: label];

  enabledColumn = [[NSTableColumn alloc] initWithIdentifier: @"Enabled"];
  [enabledColumn setEditable: YES];
  [[enabledColumn headerCell] setStringValue: _(@"Enabled")];
  [enabledColumn setMinWidth: 75];

  accountNameColumn = [[NSTableColumn alloc] initWithIdentifier: @"Account Name"];
  [accountNameColumn setEditable: NO];
  [[accountNameColumn headerCell] setStringValue: _(@"Account Name")];
  [accountNameColumn setMinWidth: 315];

  tableView = [[NSTableView alloc] initWithFrame: NSMakeRect(5,40,435,145)];
  [tableView setDrawsGrid: NO];
  [tableView setAllowsColumnSelection: NO];
  [tableView setAllowsColumnReordering: NO];
  [tableView setAllowsEmptySelection: NO];
  [tableView setAllowsMultipleSelection: NO];
  [tableView addTableColumn: enabledColumn];
  [tableView addTableColumn: accountNameColumn];
  [tableView setDataSource: _parent];
  [tableView setDelegate: _parent];
  [tableView setTarget: _parent];
  [tableView setDoubleAction: @selector(editClicked:)];
  RELEASE(enabledColumn);
  RELEASE(accountNameColumn);

  scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(5,40,435,145)];
  [scrollView setBorderType: NSBezelBorder];
  [scrollView setHasHorizontalScroller: NO];
  [scrollView setHasVerticalScroller: YES];
  [scrollView setDocumentView: tableView];
  [self addSubview: scrollView];
  RELEASE(scrollView);


  addButton = [[NSButton alloc] initWithFrame: NSMakeRect(5,5,75,ButtonHeight)];
  [addButton setTitle: _(@"Add")];
  [addButton setTarget: _parent];
  [addButton setAction: @selector(addClicked:)];
  [self addSubview: addButton];
  RELEASE(addButton);
  
  editButton = [[NSButton alloc] initWithFrame: NSMakeRect(85,5,75,ButtonHeight)];
  [editButton setTitle: _(@"Edit")];
  [editButton setTarget: _parent];
  [editButton setAction: @selector(editClicked:)];
  [self addSubview: editButton];
  RELEASE(editButton);

  deleteButton = [[NSButton alloc] initWithFrame: NSMakeRect(165,5,75,ButtonHeight)];
  [deleteButton setTitle: _(@"Delete")];
  [deleteButton setTarget: _parent];
  [deleteButton setAction: @selector(deleteClicked:)];
  [self addSubview: deleteButton];
  RELEASE(deleteButton);

  defaultButton = [[NSButton alloc] initWithFrame: NSMakeRect(365,5,75,ButtonHeight)];
  [defaultButton setTitle: _(@"Default")];
  [defaultButton setTarget: _parent];
  [defaultButton setAction: @selector(defaultClicked:)];
  [self addSubview: defaultButton];
  RELEASE(defaultButton);
}

@end
