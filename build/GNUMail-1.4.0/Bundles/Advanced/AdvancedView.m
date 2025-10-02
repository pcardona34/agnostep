/*
**  AdvancedView.m
**
**  Copyright (c) 2002-2006 Ludovic Marcotte
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

#include "AdvancedView.h"

#include "Constants.h"
#include "LabelWidget.h"


//
//
//
@implementation AdvancedView

- (id) initWithParent: (id) theParent
{
  self = [super init];

  _parent = theParent;
  [self setFrame:NSMakeRect(0,0,455,250)];

  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(optionsColumn);
  RELEASE(enabledColumn);
  RELEASE(tableView);
  [super dealloc];
}


//
//
//
- (void) layoutView
{
  LabelWidget *label;

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,180,430,50)
		       label: _(@"In this panel, you can set advanced options for GNUMail.\nGenerally, most users will simply ignore those advanced options.\nSee the User Manual for documentation on them.")];
  [self addSubview: label];

  optionsColumn = [[NSTableColumn alloc] initWithIdentifier: @"options"];
  [optionsColumn setEditable: NO];
  [[optionsColumn headerCell] setStringValue: _(@"Options")];
  [optionsColumn setMinWidth: 330];

  enabledColumn = [[NSTableColumn alloc] initWithIdentifier: @"enabled"];
  [enabledColumn setEditable: YES];
  [[enabledColumn headerCell] setStringValue: _(@"Enabled")];
  [enabledColumn setMinWidth: 50];
  
  tableView = [[NSTableView alloc] initWithFrame: NSMakeRect(5,5,435,165)];
  [tableView setDrawsGrid:NO];
  [tableView setAllowsColumnSelection: NO];
  [tableView setAllowsColumnReordering: NO];
  [tableView setAllowsEmptySelection: NO];
  [tableView setAllowsMultipleSelection: NO];
  [tableView addTableColumn: optionsColumn];
  [tableView addTableColumn: enabledColumn];
  [tableView setDataSource: _parent];
  [tableView setDelegate: _parent];
  [tableView setTarget: _parent];
  [tableView setDoubleAction: @selector(edit:)];

  scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(5,5,435,165)];
  [scrollView setBorderType: NSBezelBorder];
  [scrollView setHasHorizontalScroller: NO];
  [scrollView setHasVerticalScroller: YES];
  [scrollView setDocumentView: tableView];
  [self addSubview: scrollView];
  RELEASE(scrollView);
}

@end
