/*
**  FilteringView.m
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

#include "FilteringView.h"

#include "FilteringViewController.h"
#include "Constants.h"
#include "LabelWidget.h"

@implementation FilteringView

//
//
//
- (id) initWithParent: (id) theParent
{
  self = [super init];

  _parent = theParent;
  [self setFrame:NSMakeRect(0,0,450,253)];
  
  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(rulesColumn);
  RELEASE(activeColumn);
  RELEASE(tableView);
  [super dealloc];
}


//
//
//
- (void) layoutView
{
  LabelWidget *label;
  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,195,430,35)
		       label: _(@"In this panel, you can add Filters used by GNUMail to perform\nactions when sending or receiving mails.")];
  [self addSubview: label];

  rulesColumn = [[NSTableColumn alloc] initWithIdentifier: @"rules"];
  [rulesColumn setEditable: NO];
  [[rulesColumn headerCell] setStringValue: _(@"Rules")];
  [rulesColumn setMinWidth: 275];

  activeColumn = [[NSTableColumn alloc] initWithIdentifier: @"active"];
  [activeColumn setEditable: YES];
  [[activeColumn headerCell] setStringValue: _(@"Active")];
  [activeColumn setMinWidth: 50];
  
  tableView = [[NSTableView alloc] initWithFrame: NSMakeRect(5,40,430,145)];
  [tableView setDrawsGrid:NO];
  [tableView setAllowsColumnSelection: NO];
  [tableView setAllowsColumnReordering: NO];
  [tableView setAllowsEmptySelection: NO];
  [tableView setAllowsMultipleSelection: NO];
  [tableView addTableColumn: rulesColumn];
  [tableView addTableColumn: activeColumn];
  [tableView setDataSource: _parent];
  [tableView setDelegate: _parent];
  [tableView setTarget: _parent];
  [tableView setDoubleAction: @selector(edit:)];

  scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(5,40,430,145)];
  [scrollView setBorderType: NSBezelBorder];
  [scrollView setHasHorizontalScroller: NO];
  [scrollView setHasVerticalScroller: YES];
  [scrollView setDocumentView: tableView];
  [self addSubview: scrollView];
  RELEASE(scrollView);
  
  add = [[NSButton alloc] initWithFrame: NSMakeRect(5,5,75,ButtonHeight)];
  [add setTitle: _(@"Add")];
  [add setTarget: _parent];
  [add setAction: @selector(add:)];
  [self addSubview: add];
  RELEASE(add);
  
  edit = [[NSButton alloc] initWithFrame: NSMakeRect(85,5,75,ButtonHeight)];
  [edit setTitle: _(@"Edit")];
  [edit setTarget: _parent];
  [edit setAction: @selector(edit:)];
  [self addSubview: edit];
  RELEASE(edit);

  delete = [[NSButton alloc] initWithFrame: NSMakeRect(165,5,75,ButtonHeight)];
  [delete setTitle: _(@"Delete")];
  [delete setTarget: _parent];
  [delete setAction: @selector(delete:)];
  [self addSubview: delete];
  RELEASE(delete);

  duplicate = [[NSButton alloc] initWithFrame: NSMakeRect(245,5,75,ButtonHeight)];
  [duplicate setTitle: _(@"Duplicate")];
  [duplicate setTarget: _parent];
  [duplicate setAction: @selector(duplicate:)];
  [self addSubview: duplicate];
  RELEASE(duplicate);

  moveUp = [[NSButton alloc] initWithFrame: NSMakeRect(330,5,50,ButtonHeight)];
  [moveUp setTitle: @""];
  [moveUp setImagePosition: NSImageOnly];
  [moveUp setImage: [NSImage imageNamed: @"sort_up.tiff"]];
  [moveUp setTarget: _parent];
  [moveUp setAction: @selector(moveUp:)];
  [self addSubview: moveUp];
  RELEASE(moveUp);
  
  moveDown = [[NSButton alloc] initWithFrame: NSMakeRect(385,5,50,ButtonHeight)];
  [moveDown setTitle: @""];
  [moveDown setImagePosition: NSImageOnly];
  [moveDown setImage: [NSImage imageNamed: @"sort_down.tiff"]];
  [moveDown setTarget: _parent];
  [moveDown setAction: @selector(moveDown:)];
  [self addSubview: moveDown];
  RELEASE(moveDown);
}

@end

