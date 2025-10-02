/*
**  Views.m
**
**  Copyright (c) 2003-2004 Ludovic Marcotte
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

#include "Views.h"

#include "LabelWidget.h"

const NSString *TableColumnIdentifier = @"mailboxes";

//
// ChooseTypeView
//
@implementation ChooseTypeView

- (id) initWithOwner: (id) theOwner
{
  self = [super init];
 
  owner = theOwner;

  return self;
}

- (void) dealloc
{
  [super dealloc];
}

- (void) layoutView
{
  NSButton *cancel, *next;
  NSButtonCell *cell;
  LabelWidget *label;
  NSImageView *icon;

  [self setFrame: NSMakeRect(0,0,270,300)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  
  icon = [[NSImageView alloc] initWithFrame: NSMakeRect(10,242,48,48)];
  [icon setImageAlignment: NSImageAlignCenter];
  [icon setImage: [NSImage imageNamed: @"GNUMail.tiff"]];
  [icon setImageFrameStyle: NSImageFrameNone];
  [icon setEditable: NO];
  [self addSubview: icon];
  RELEASE(icon);

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(70,240,190,20)
		       label: _(@"Import Mailboxes")];
  [label setFont: [NSFont boldSystemFontOfSize: 16]];
  [self addSubview: label];

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,180,250,35)
		       label: _(@"Please choose the type of mailbox you\nwant to import:")];
  [self addSubview: label];


  cell = [[NSButtonCell alloc] init];
  AUTORELEASE(cell);
  [cell setButtonType: NSRadioButton];
  [cell setBordered: NO];
  [cell setImagePosition: NSImageLeft];

  matrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(10,110,250,45)
			     mode: NSRadioModeMatrix
			     prototype: cell
			     numberOfRows: 2
			     numberOfColumns: 1];

  [matrix setTarget: owner];
  [matrix setIntercellSpacing: NSMakeSize (0, 10)];
  [matrix setAutosizesCells: NO];
  [matrix setAllowsEmptySelection: NO];
 
  cell = [matrix cellAtRow: 0 column: 0];
  [cell setAction: @selector(selectionInMatrixHasChanged:)];
  [cell setTitle: _(@"Microsoft Entourage X")];

  cell = [matrix cellAtRow: 1 column: 0];
  [cell setTitle: _(@"Standard UNIX mbox")];
  [cell setAction: @selector(selectionInMatrixHasChanged:)];
  [matrix sizeToFit];
  [self addSubview: matrix];

  cancel = [[NSButton alloc] initWithFrame: NSMakeRect(10,10,75,25)];
  [cancel setTitle: _(@"Cancel")];
  [cancel setTarget: owner];
  [cancel setAction: @selector(close)];
  [self addSubview: cancel];
  RELEASE(cancel);

  next = [[NSButton alloc] initWithFrame: NSMakeRect(220,10,25,25)];
  [next setTitle: @""];
  [next setImagePosition: NSImageOnly];
  [next setImage: [NSImage imageNamed: @"sort_right.tiff"]];
  [next setTarget: owner];
  [next setAction: @selector(nextClicked:)];
  [self addSubview: next];
  RELEASE(next);
}

@end


//
// ExplanationView
//
@implementation ExplanationView

- (id) initWithOwner: (id) theOwner
{
  self = [super init];
 
  owner = theOwner;

  return self;
}

- (void) dealloc
{
  RELEASE(explanationLabel);
  RELEASE(chooseButton);

  [super dealloc];
}

- (void) layoutView
{
  NSButton *cancel, *next, *previous;
  LabelWidget *label;
  NSImageView *icon;

  [self setFrame: NSMakeRect(0,0,270,300)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  
  icon = [[NSImageView alloc] initWithFrame: NSMakeRect(10,242,48,48)];
  [icon setImageAlignment: NSImageAlignCenter];
  [icon setImage: [NSImage imageNamed: @"GNUMail.tiff"]];
  [icon setImageFrameStyle: NSImageFrameNone];
  [icon setEditable: NO];
  [self addSubview: icon];
  RELEASE(icon);

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(70,240,190,20)
		       label: _(@"Import Mailboxes")];
  [label setFont: [NSFont boldSystemFontOfSize: 16]];
  [self addSubview: label];

  explanationLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,80,250,150)
				  label: @""];
  [self addSubview: explanationLabel];
  RETAIN(explanationLabel);
  
  chooseButton = [[NSButton alloc] initWithFrame: NSMakeRect(60,50,150,25)];
  [chooseButton setTitle: _(@"Choose File...")];
  [chooseButton setTarget: owner];
  [chooseButton setAction: @selector(chooseClicked:)];
  [self addSubview: chooseButton];

  cancel = [[NSButton alloc] initWithFrame: NSMakeRect(10,10,75,25)];
  [cancel setTitle: _(@"Cancel")];
  [cancel setTarget: owner];
  [cancel setAction: @selector(close)];
  [self addSubview: cancel];
  RELEASE(cancel);

  previous = [[NSButton alloc] initWithFrame: NSMakeRect(190,10,25,25)];
  [previous setTitle: @""];
  [previous setImagePosition: NSImageOnly];
  [previous setImage: [NSImage imageNamed: @"sort_left.tiff"]];
  [previous setTarget: owner];
  [previous setAction: @selector(previousClicked:)];
  [self addSubview: previous];
  RELEASE(previous);

  next = [[NSButton alloc] initWithFrame: NSMakeRect(220,10,25,25)];
  [next setTitle: @""];
  [next setImagePosition: NSImageOnly];
  [next setImage: [NSImage imageNamed: @"sort_right.tiff"]];
  [next setTarget: owner];
  [next setAction: @selector(nextClicked:)];
  [self addSubview: next];
  RELEASE(next);
}

@end


//
// ChooseMailboxView
//
@implementation ChooseMailboxView

- (id) initWithOwner: (id) theOwner
{
  self = [super init];
 
  owner = theOwner;

  return self;
}

- (void) dealloc
{
  RELEASE(tableView);
  [super dealloc];
}

- (void) layoutView
{
  NSButton *cancel, *done, *previous;
  NSTableColumn *tableColumn;
  NSScrollView *scrollView;
  LabelWidget *label;  
  NSImageView *icon;

  [self setFrame: NSMakeRect(0,0,270,300)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  
  icon = [[NSImageView alloc] initWithFrame: NSMakeRect(10,242,48,48)];
  [icon setImageAlignment: NSImageAlignCenter];
  [icon setImage: [NSImage imageNamed: @"GNUMail.tiff"]];
  [icon setImageFrameStyle: NSImageFrameNone];
  [icon setEditable: NO];
  [self addSubview: icon];
  RELEASE(icon);

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(70,240,190,20)
		       label: _(@"Import Mailboxes")];
  [label setFont: [NSFont boldSystemFontOfSize: 16]];
  [self addSubview: label];

  
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,200,250,20)
		       label: _(@"Choose the mailboxes to import:")];
  [self addSubview: label];
  
  tableColumn = [[NSTableColumn alloc] initWithIdentifier: (id)TableColumnIdentifier];
  AUTORELEASE(tableColumn);
  [tableColumn setEditable: YES];
  [[tableColumn headerCell] setStringValue: _(@"Mailboxes")];
  [tableColumn setWidth: 240];

  tableView = [[NSTableView alloc] initWithFrame: NSMakeRect(5,50,260,140)];
  [tableView setDrawsGrid:NO];
  [tableView setAllowsColumnSelection: NO];
  [tableView setAllowsColumnReordering: NO];
  [tableView setAllowsEmptySelection: NO];
  [tableView setAllowsMultipleSelection: YES];
  [tableView addTableColumn: tableColumn];
  [tableView setDataSource: owner]; 
  [tableView setDelegate: owner];

  scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(5,50,260,140)];
  [scrollView setBorderType: NSBezelBorder];
  [scrollView setHasHorizontalScroller: NO];
  [scrollView setHasVerticalScroller: YES];
  [scrollView setDocumentView: tableView];
  [self addSubview: scrollView];
  RELEASE(scrollView);
  
  cancel = [[NSButton alloc] initWithFrame: NSMakeRect(10,10,75,25)];
  [cancel setTitle: _(@"Cancel")];
  [cancel setTarget: owner];
  [cancel setAction: @selector(close)];
  [self addSubview: cancel];
  RELEASE(cancel);

  previous = [[NSButton alloc] initWithFrame: NSMakeRect(170,10,25,25)];
  [previous setTitle: @""];
  [previous setImagePosition: NSImageOnly];
  [previous setImage: [NSImage imageNamed: @"sort_left.tiff"]];
  [previous setTarget: owner];
  [previous setAction: @selector(previousClicked:)];
  [self addSubview: previous];
  RELEASE(previous);

  done = [[NSButton alloc] initWithFrame: NSMakeRect(200,10,50,25)];
  [done setTitle: _(@"Done")];
  [done setTarget: owner];
  [done setAction: @selector(doneClicked:)];
  [self addSubview: done];
  RELEASE(done);
}

@end
