/*
**  MailboxManager.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
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

#include "MailboxManager.h"

#include "GNUMail.h"
#include "Constants.h"
#include "LabelWidget.h"
#include "ExtendedOutlineView.h"


//
//
//
@implementation MailboxManager

- (void) dealloc
{
  RELEASE(mailboxColumn);
  RELEASE(messagesColumn);
  RELEASE(outlineView);
  RELEASE(scrollView);
  [super dealloc];
}


//
//
//
- (void) layoutWindow
{
  mailboxColumn = [[NSTableColumn alloc] initWithIdentifier: @"Mailbox"];
  [mailboxColumn setEditable: YES];
  [[mailboxColumn headerCell] setStringValue: _(@"Mailbox")];
  [mailboxColumn setMinWidth: 125];

  messagesColumn = [[NSTableColumn alloc] initWithIdentifier: @"Messages"];
  [messagesColumn setEditable: NO];
  [[messagesColumn headerCell] setStringValue: _(@"Messages")];
  [messagesColumn setMinWidth: 75];

  outlineView = [[ExtendedOutlineView alloc] initWithFrame: NSMakeRect (0, 0, 220, 300)];
  [outlineView addTableColumn: mailboxColumn];
  [outlineView addTableColumn: messagesColumn];
  [outlineView setOutlineTableColumn: mailboxColumn];
  [outlineView setDrawsGrid: NO];
  [outlineView setIndentationPerLevel: 10];
  [outlineView setAutoresizesOutlineColumn: YES];
  [outlineView setIndentationMarkerFollowsCell: YES];
  [outlineView setAllowsColumnSelection: NO];
  [outlineView setAllowsColumnReordering: NO];
  [outlineView setAllowsEmptySelection: YES];
  [outlineView setAllowsMultipleSelection: YES];
  [outlineView setAutoresizesAllColumnsToFit: YES];
  [outlineView sizeLastColumnToFit];
  [outlineView setIndentationPerLevel: 5];
  [outlineView setDataSource: [self windowController]];
  [outlineView setDelegate: [self windowController]];

  scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect (0, 0, 220, 300)];
  [scrollView setDocumentView: outlineView];
  [scrollView setHasHorizontalScroller: NO];
  [scrollView setHasVerticalScroller: YES];
  [scrollView setBorderType: NSBezelBorder];
  [scrollView setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  [[self contentView] addSubview: scrollView];
  [self setInitialFirstResponder:outlineView];

  [self setMinSize: NSMakeSize(220,300)];
}

@end
