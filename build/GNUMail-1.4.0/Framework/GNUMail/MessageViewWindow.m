/*
**  MessageViewWindow.m
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
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "MessageViewWindow.h"

#include "ExtendedTextView.h"
#include "Constants.h"

//
//
//
@implementation MessageViewWindow

- (void) dealloc
{
  RELEASE(textScrollView);
  RELEASE(textView);
  [super dealloc];
}


//
//
//
- (void) layoutWindow
{  
  NSRect aRect;

  textScrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(5,5,710,580)];
  [textScrollView setBorderType: NSBezelBorder];
  [textScrollView setHasHorizontalScroller: NO];
  [textScrollView setHasVerticalScroller: YES];
  [textScrollView setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
 
  aRect = [[textScrollView contentView] frame];
  textView = [[ExtendedTextView alloc] init];
  [textView setFrame: aRect];
  [textView setTextContainerInset: NSMakeSize(5,5)];
  [textView setBackgroundColor: [NSColor textBackgroundColor]];
  [textView setRichText: YES];
  [textView setUsesFontPanel: YES];
  [textView setDelegate: [self windowController]];
  [textView setHorizontallyResizable: NO];
  [textView setVerticallyResizable: YES];
  [textView setMinSize: NSMakeSize (0, 0)];
  [textView setMaxSize: NSMakeSize (1E7, 1E7)];
  [textView setAutoresizingMask: NSViewHeightSizable|NSViewWidthSizable];
  [[textView textContainer] setContainerSize: NSMakeSize(aRect.size.width, 1E7)];

  [[textView textContainer] setWidthTracksTextView: YES];
  [textView setEditable: NO];
  [textView setString: @""];
  
  [textScrollView setDocumentView: textView];
  
  [[self contentView] addSubview: textScrollView];
  [self setMinSize: NSMakeSize(400,450)];
}

@end
