/*
**  FilterHeaderEditorWindow.m
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

#include "FilterHeaderEditorWindow.h"

#include "Constants.h"
#include "LabelWidget.h"

@implementation FilterHeaderEditorWindow

- (void) dealloc
{
  NSDebugLog(@"FilterHeaderEditorWindow: -dealloc");

  RELEASE(headerField);

  RELEASE(tableView);

  [super dealloc];
}

- (void) layoutWindow
{
  NSButton *removeHeader, *addHeader, *okButton, *cancelButton;
  NSTableColumn *tableColumn;
  NSScrollView *scrollView;
  LabelWidget *headerLabel;

  // We begin with our table view
  tableColumn = [[NSTableColumn alloc] initWithIdentifier: @"header"];
  AUTORELEASE(tableColumn);
  [tableColumn setEditable: NO];
  [[tableColumn headerCell] setStringValue: _(@"Header")];
  [tableColumn setWidth: 240];

  tableView = [[NSTableView alloc] initWithFrame: NSMakeRect(10,110,220,225)];
  [tableView setDrawsGrid:NO];
  [tableView setAllowsColumnSelection: NO];
  [tableView setAllowsColumnReordering: NO];
  [tableView setAllowsEmptySelection: NO];
  [tableView setAllowsMultipleSelection: NO];
  [tableView addTableColumn: tableColumn];
  [tableView setDataSource: [self windowController]]; 
  [tableView setDelegate: [self windowController]];

  scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(10,110,220,225)];
  [scrollView setBorderType: NSBezelBorder];
  [scrollView setHasHorizontalScroller:NO];
  [scrollView setDocumentView:tableView];
  [[self contentView] addSubview: scrollView];
  RELEASE(scrollView);

  // We add our label and our text field
  headerLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,80,50,TextFieldHeight)
			     label: _(@"Header:") ];
  [[self contentView] addSubview: headerLabel];

  headerField = [[NSTextField alloc] initWithFrame: NSMakeRect(65,80,165,TextFieldHeight)];
  [[self contentView] addSubview: headerField];

  
  // We finish with our four buttons
  removeHeader = [[NSButton alloc] initWithFrame: NSMakeRect(10,45,105, ButtonHeight)];
  [removeHeader setTitle: _(@"Remove")];
  [removeHeader setTarget: [self windowController]];
  [removeHeader setAction:@selector(removeHeader:)];
  [[self contentView] addSubview: removeHeader];
  RELEASE(removeHeader);

  addHeader = [[NSButton alloc] initWithFrame: NSMakeRect(125,45,105, ButtonHeight)];
  [addHeader setTitle: _(@"Add")];
  [addHeader setTarget: [self windowController]];
  [addHeader setAction:@selector(addHeader:)];
  [[self contentView] addSubview: addHeader];
  RELEASE(addHeader);
  
  cancelButton = [[NSButton alloc] initWithFrame: NSMakeRect(10,10,105,ButtonHeight)];;
  [cancelButton setButtonType:NSMomentaryPushButton];
  [cancelButton setTitle: _(@"Cancel")];
  [cancelButton setTarget: [self windowController]];
  [cancelButton setAction: @selector(cancelClicked:) ];
  [[self contentView] addSubview: cancelButton];
  RELEASE(cancelButton);
 
  okButton = [[NSButton alloc] initWithFrame: NSMakeRect(125,10,105,ButtonHeight)];
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


//
// access/mutation methods
//


- (NSTextField *) headerField
{
  return headerField;
}

- (NSTableView *) tableView
{
  return tableView;
}


@end





