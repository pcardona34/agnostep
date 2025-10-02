/*
**  FilterMessageWindow.m
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

#include "FilterMessageWindow.h"

#include "Constants.h"
#include "LabelWidget.h"

@implementation FilterMessageWindow

- (void) dealloc
{
  NSDebugLog(@"FilterMessageWindow: -dealloc");
 
  RELEASE(label);
  RELEASE(textView);
  RELEASE(scrollView);
  
  [super dealloc];
}

- (void) layoutWindow
{
  NSButton *cancelButton, *okButton;

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,225,490,TextFieldHeight)
		       label: _(@"Text to include before original message:")];
  [label setAutoresizingMask: NSViewMinYMargin];
  [[self contentView] addSubview: label];
  RETAIN(label);

  scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(5,40,490,180)];
  textView = [[NSTextView alloc] initWithFrame: [[scrollView contentView] frame]];
  [textView setTextContainerInset: NSMakeSize(5,5)];
  [textView setBackgroundColor: [NSColor whiteColor]];
  [textView setRichText: NO];
  [textView setUsesFontPanel: NO];
  [textView setHorizontallyResizable: NO];
  [textView setVerticallyResizable: YES];
  [textView setMinSize: NSMakeSize (0, 0)];
  [textView setMaxSize: NSMakeSize (1E7, 1E7)];
  [textView setAutoresizingMask: NSViewHeightSizable|NSViewWidthSizable];
  [[textView textContainer] setContainerSize: NSMakeSize([[scrollView contentView] frame].size.width, 
  							 1E7)];
  [[textView textContainer] setWidthTracksTextView: YES];
  [textView setEditable: YES];

  [scrollView setDocumentView: textView];
  [scrollView setHasHorizontalScroller: YES];
  [scrollView setHasVerticalScroller: NO];
  [scrollView setBorderType: NSBezelBorder];
  [scrollView setAutoresizingMask: (NSViewWidthSizable|NSViewHeightSizable)];
  [[self contentView] addSubview: scrollView];

  cancelButton = [[NSButton alloc] initWithFrame: NSMakeRect(315,5,75,ButtonHeight)];
  [cancelButton setTitle: _(@"Cancel")];
  [cancelButton setTarget: [self windowController]];
  [cancelButton setAction: @selector(cancelClicked:)];
  [cancelButton setAutoresizingMask: NSViewMinXMargin];
  [[self contentView] addSubview: cancelButton];
  RELEASE(cancelButton);

  okButton = [[NSButton alloc] initWithFrame: NSMakeRect(400,5,75,ButtonHeight)];
  [okButton setTitle: _(@"OK")];
  [okButton setKeyEquivalent: @"\r"];
  [okButton setImagePosition: NSImageRight];
  [okButton setImage: [NSImage imageNamed: @"common_ret"]];
  [okButton setAlternateImage: [NSImage imageNamed: @"common_retH"]];
  [okButton setTarget: [self windowController]];
  [okButton setAction: @selector(okClicked:)];
  [okButton setAutoresizingMask: NSViewMinXMargin];
  [[self contentView] addSubview: okButton];
  RELEASE(okButton);
  
}


//
// access/mutation methods
//
- (NSTextField *) label
{
  return label;
}

- (NSTextView *) textView
{
  return textView;
}

@end
