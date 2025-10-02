/*
**  MailboxInspectorPanel.m
**
**  Copyright (c) 2004 Ludovic Marcotte
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

#include "MailboxInspectorPanel.h"

#include "Constants.h"
#include "LabelWidget.h"

//
//
//
@implementation MailboxInspectorPanel

- (void) dealloc
{
  RELEASE(threadArcsView);
  RELEASE(box);
  [super dealloc];
}


//
//
//
- (void) layoutPanel
{
  NSPopUpButton *popup;

  popup = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(10,470,230,25)];
  [popup setTarget: [self windowController]];
  [popup setAction: @selector(selectionHasChanged:)];
  [popup setAutoenablesItems: NO];
  [popup addItemWithTitle: _(@"General Information")];
  [popup addItemWithTitle: _(@"Access Control List")];
  [popup addItemWithTitle: _(@"Quota")];
  [popup addItemWithTitle: _(@"Thread Arcs")];
  [popup setAutoresizingMask: NSViewMinYMargin];
  [[self contentView] addSubview: popup];
  RELEASE(popup);

  box = [[NSBox alloc] initWithFrame: NSMakeRect(0,0,250,460)];
  [box setTitlePosition: NSNoTitle];
  [box setBorderType: NSGrooveBorder];
  [box setAutoresizingMask: NSViewHeightSizable|NSViewWidthSizable];
  [[self contentView] addSubview: box];

  // We then init and layout our subviews
  threadArcsView = [[MailboxInspectorThreadArcsView alloc] init];
  [threadArcsView layoutView];
}
@end


//
//
//
@implementation MailboxInspectorThreadArcsView

- (void) layoutView
{
  NSScrollView *textScrollView;

  [self setFrame: NSMakeRect(0,0,250,460)];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];

  subject = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,440,240,TextFieldHeight)
			 label: _(@"< no selected message >")
			 alignment: NSCenterTextAlignment];
  [subject setAutoresizingMask: NSViewMinYMargin|NSViewWidthSizable];
  [self addSubview: subject];

  textScrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(5,200,240,230)];
  [textScrollView setBorderType: NSLineBorder];
  [textScrollView setHasHorizontalScroller: NO];
  [textScrollView setHasVerticalScroller: NO];
  [textScrollView setAutoresizingMask: NSViewHeightSizable|NSViewWidthSizable];
    
  textView = [[NSTextView alloc] initWithFrame: [[textScrollView contentView] frame]];
  //[textView setTextContainerInset: NSMakeSize(5,5)];
  [textView setBackgroundColor: [NSColor textBackgroundColor]];
  [textView setRichText: YES];
  [textView setUsesFontPanel: YES];
  [textView setDelegate: self];
  [textView setHorizontallyResizable: YES];
  [textView setVerticallyResizable: YES];
  [textView setMinSize: NSMakeSize(0, 0)];
  [textView setMaxSize: NSMakeSize(1E7, 1E7)];
  [textView setAutoresizingMask: NSViewHeightSizable|NSViewWidthSizable];
  [[textView textContainer] setContainerSize: NSMakeSize([[textScrollView contentView] frame].size.width, 1E7)];

  [[textView textContainer] setWidthTracksTextView: YES];
  [textView setEditable: NO];
  [textView setString: @""];

  [textScrollView setDocumentView: textView];
  [self addSubview: textScrollView];

}

@end
