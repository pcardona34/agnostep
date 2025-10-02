/*
**  HeadersWindow.m
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "HeadersWindow.h"

#include "Constants.h"
#include "LabelWidget.h"

//const NSString *TableColumnIdentifier = @"header";

//
//
//
@implementation HeadersWindow

- (void) dealloc
{
  NSDebugLog(@"HeadersWindow: -dealloc");

  RELEASE(showAllHeaders);
  RELEASE(tableView);
  RELEASE(keyField);

  [super dealloc];
}


//
//
//
- (void) layoutWindow
{
  NSButton *okButton, *cancelButton, *removeShown, *addShown, *addDefaults, *moveUp, *moveDown;
  NSTableColumn *tableColumn;
  NSScrollView *scrollView;
  LabelWidget *keyLabel;
  NSBox *box;

  //
  // Our visible header box
  // 
  box = [[NSBox alloc] initWithFrame: NSMakeRect(5,45,430,245)];
  [box setContentViewMargins: NSMakeSize(5,0)];
  [box setTitlePosition: NSAtTop];
  [box setTitle: _(@"Shown headers while viewing a mail")];
  [box setBorderType: NSGrooveBorder];
  
  showAllHeaders = [[NSButton alloc] initWithFrame: NSMakeRect(5,200,200,ButtonHeight)];
  [showAllHeaders setButtonType: NSSwitchButton];
  [showAllHeaders setBordered: NO];
  [showAllHeaders setTitle: _(@"Show all headers")];
  [box addSubview: showAllHeaders];

  addShown = [[NSButton alloc] initWithFrame: NSMakeRect(5,5,80,ButtonHeight)];
  [addShown setStringValue: _(@"Add")];
  [addShown setTarget: [self windowController]];
  [addShown setAction:@selector(addShown:)];
  [[box contentView] addSubview: addShown];
  RELEASE(addShown);

  removeShown = [[NSButton alloc] initWithFrame: NSMakeRect(95,5,80,ButtonHeight)];
  [removeShown setStringValue: _(@"Remove")];
  [removeShown setTarget: [self windowController]];
  [removeShown setAction:@selector(removeShown:)];
  [[box contentView] addSubview: removeShown];
  RELEASE(removeShown);

  addDefaults = [[NSButton alloc] initWithFrame: NSMakeRect(185,5,80,ButtonHeight)];
  [addDefaults setStringValue: _(@"Defaults")];
  [addDefaults setTarget: [self windowController]];
  [addDefaults setAction:@selector(addDefaults:)];
  [[box contentView] addSubview: addDefaults];
  RELEASE(addDefaults);

  moveUp = [[NSButton alloc] initWithFrame:NSMakeRect(275,5,64,ButtonHeight)];
  [moveUp setTitle: @""];
  [moveUp setImagePosition: NSImageOnly];
  [moveUp setImage: [NSImage imageNamed: @"sort_up.tiff"]];
  [moveUp setTarget: [self windowController]];
  [moveUp setAction: @selector(moveUp:)];
  [moveUp setAutoresizingMask: NSViewMinYMargin];
  [[box contentView] addSubview: moveUp];
  RELEASE(moveUp);
  
  moveDown = [[NSButton alloc] initWithFrame:NSMakeRect(349,5,64,ButtonHeight)];
  [moveDown setTitle: @""];
  [moveDown setImagePosition: NSImageOnly];
  [moveDown setImage: [NSImage imageNamed: @"sort_down.tiff"]];
  [moveDown setTarget: [self windowController]];
  [moveDown setAction: @selector(moveDown:)];
  [moveDown setAutoresizingMask: NSViewMinYMargin];
  [[box contentView] addSubview: moveDown];
  RELEASE(moveDown);

  keyLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,40,60,TextFieldHeight)
			  label: _(@"Key:") ];
  [[box contentView] addSubview: keyLabel];

  keyField = [[NSTextField alloc] initWithFrame: NSMakeRect(70,40,340,TextFieldHeight)];
  [[box contentView] addSubview: keyField];

  tableColumn = [[NSTableColumn alloc] initWithIdentifier: (id) @"header"];
  AUTORELEASE(tableColumn);
  [tableColumn setEditable: YES];
  [[tableColumn headerCell] setStringValue: _(@"Shown Headers")];
  [tableColumn setWidth: 240];

  tableView = [[NSTableView alloc] initWithFrame: NSMakeRect(5,75,405,120)];
  [tableView setDrawsGrid:NO];
  [tableView setAllowsColumnSelection: NO];
  [tableView setAllowsColumnReordering: NO];
  [tableView setAllowsEmptySelection: NO];
  [tableView setAllowsMultipleSelection: NO];
  [tableView addTableColumn: tableColumn];
  [tableView setDataSource: [self windowController]]; 
  [tableView setDelegate: [self windowController]];

  scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(5,75,405,120)];
  [scrollView setBorderType: NSBezelBorder];
  [scrollView setHasHorizontalScroller: NO];
  [scrollView setHasVerticalScroller: YES];
  [scrollView setDocumentView: tableView];
  [[box contentView] addSubview: scrollView];
  RELEASE(scrollView);

  [[self contentView] addSubview: box];
  RELEASE(box);

  cancelButton = [[NSButton alloc] initWithFrame: NSMakeRect(280,10,75,ButtonHeight)];
  [cancelButton setButtonType: NSMomentaryPushButton];
  [cancelButton setKeyEquivalent: @"\e"];
  [cancelButton setTitle: _(@"Cancel")];
  [cancelButton setTarget: [self windowController]];
  [cancelButton setAction: @selector(cancelClicked:)];
  [[self contentView] addSubview: cancelButton];
  RELEASE(cancelButton);

  okButton = [[NSButton alloc] initWithFrame:  NSMakeRect(360,10,75,ButtonHeight)];
  [okButton setButtonType: NSMomentaryPushButton];
  [okButton setKeyEquivalent: @"\r"];
  [okButton setImagePosition: NSImageRight];
  [okButton setImage: [NSImage imageNamed: @"common_ret"]];
  [okButton setAlternateImage: [NSImage imageNamed: @"common_retH"]];
  [okButton setTitle: _(@"OK")];
  [okButton setTarget: [self windowController]];
  [okButton setAction: @selector(okClicked:)];
  [[self contentView] addSubview:okButton];
  RELEASE(okButton);
}

@end
