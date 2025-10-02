/*
**  MIMEView.m
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

#include "MIMEView.h"

#include "Constants.h"
#include "LabelWidget.h"


@implementation MIMEView

//
//
//
- (id) initWithParent: (id) theParent
{
  self = [super init];

  parent = theParent;
  [self setFrame:NSMakeRect(0,0,450,370)];
  
  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(mimeTypesColumn);
  RELEASE(fileExtensionsColumn);
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
		       label: _(@"In this panel, you can add MIME types used by GNUMail to view\nor perform actions on attachments based on their Content-Type.")];
  [self addSubview: label];
  
  mimeTypesColumn = [[NSTableColumn alloc] initWithIdentifier: @"mime-type"];
  [mimeTypesColumn setEditable: NO];
  [[mimeTypesColumn headerCell] setStringValue: _(@"MIME type")];
  [mimeTypesColumn setMinWidth: 215];

  fileExtensionsColumn = [[NSTableColumn alloc] initWithIdentifier: @"file-extensions"];
  [fileExtensionsColumn setEditable: NO];
  [[fileExtensionsColumn headerCell] setStringValue: _(@"File extension(s)")];
  [fileExtensionsColumn setMinWidth: 215];
  
  tableView = [[NSTableView alloc] initWithFrame: NSMakeRect(5,40,430,145)];
  [tableView setDrawsGrid: NO];
  [tableView setAllowsColumnSelection: NO];
  [tableView setAllowsColumnReordering: NO];
  [tableView setAllowsEmptySelection: NO];
  [tableView setAllowsMultipleSelection: NO];
  [tableView addTableColumn: mimeTypesColumn];
  [tableView addTableColumn: fileExtensionsColumn];
  [tableView setDataSource: parent];
  [tableView setDelegate: parent];
  [tableView setTarget: parent];
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
  [add setTarget: parent];
  [add setAction: @selector(add:)];
  [self addSubview: add];
  RELEASE(add);
  
  edit = [[NSButton alloc] initWithFrame: NSMakeRect(85,5,75,ButtonHeight)];
  [edit setTitle: _(@"Edit")];
  [edit setTarget: parent];
  [edit setAction: @selector(edit:)];
  [self addSubview: edit];
  RELEASE(edit);

  delete = [[NSButton alloc] initWithFrame: NSMakeRect(165,5,75,ButtonHeight)];
  [delete setTitle: _(@"Delete")];
  [delete setTarget: parent];
  [delete setAction: @selector(delete:)];
  [self addSubview: delete];
  RELEASE(delete);
}

@end

