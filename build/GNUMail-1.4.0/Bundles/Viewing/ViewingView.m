/*
**  ViewingView.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**                2012 Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**          Riccardo Mottola <rm@gnu.org>
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

#include "ViewingView.h"

#include "Constants.h"
#include "LabelWidget.h"

//
//
//
@implementation ViewingView

- (id) initWithParent: (id) theParent
{
  self = [super init];

  parent = theParent;
  [self setFrame:NSMakeRect(0,0,475,240)];

  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(doubleClickPopUpButton);
  RELEASE(matrix);
  [super dealloc];
}


//
//
//
- (void) layoutView
{
  NSButton *headersButton;
  LabelWidget *label;
  NSButtonCell *cell;
  NSBundle *aBundle;
  
  aBundle = [NSBundle bundleForClass: [parent class]];

  cell = [[NSButtonCell alloc] init];
  AUTORELEASE(cell);
  [cell setButtonType: NSPushOnPushOffButton];
  [cell setBordered: YES];
  [cell setImagePosition: NSImageAbove];

  matrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(10,100,400,106)
			     mode: NSRadioModeMatrix
			     prototype: cell
			     numberOfRows: 1
			     numberOfColumns: 4];
  [matrix setTarget: parent];
  [matrix setIntercellSpacing: NSMakeSize (4,0)];
  [matrix setAutosizesCells: NO];
  [matrix setAllowsEmptySelection: NO];
 
  cell = [matrix cellAtRow: 0 column: 0];
  [cell setTitle: _(@"Drawer")];
  [cell setTag: GNUMailDrawerView];
  [cell setImage: AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
						 [aBundle pathForResource: @"drawer_96x96" ofType: @"tiff"]])];

  cell = [matrix cellAtRow: 0 column: 1];
  [cell setTitle: _(@"Floating")];
  [cell setTag: GNUMailFloatingView];
  [cell setImage: AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
						 [aBundle pathForResource: @"floating_96x96" ofType: @"tiff"]])];

  cell = [matrix cellAtRow: 0 column: 2];
  [cell setTitle: _(@"3-Pane")];
  [cell setTag: GNUMail3PaneView];
  [cell setImage: AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
						 [aBundle pathForResource: @"3-pane_96x96" ofType: @"tiff"]])];

  cell = [matrix cellAtRow: 0 column: 3];
  [cell setTitle: _(@"Widescreen")];
  [cell setTag: GNUMailWidescreenView];
  [cell setImage:  AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
						  [aBundle pathForResource: @"widescreen_96x96" ofType: @"tiff"]])];

  [matrix sizeToFit];
  [self addSubview: matrix];

  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(10,80,400,20)
		       label: _(@"(You need to restart GNUMail for this change to take effect)")
		       alignment: NSCenterTextAlignment];
  [self addSubview: label];



  //
  //
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,35,190,TextFieldHeight)
		       label: _(@"Double-clicking on a message") ];
  [self addSubview: label];

  doubleClickPopUpButton = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(205,33,230,ButtonHeight)];
  [doubleClickPopUpButton setAutoenablesItems: NO];
  [doubleClickPopUpButton addItemWithTitle: _(@"opens reply editor")];
  [doubleClickPopUpButton addItemWithTitle: _(@"opens message in new window")];
  [doubleClickPopUpButton addItemWithTitle: _(@"does nothing")];
  [self addSubview: doubleClickPopUpButton];

  //
  // Our label/button to set the visible headers
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,5,385,TextFieldHeight)
		       label: _(@"To specify the list of visible headers of messages, click here")];
  [self addSubview: label];
    
  headersButton = [[NSButton alloc] initWithFrame: NSMakeRect(395,3,40,ButtonHeight)];
  [headersButton setTitle: _(@"Set")];
  [headersButton setTarget: parent];
  [headersButton setAction:@selector(headersButtonClicked:)];
  [self addSubview: headersButton];
  RELEASE(headersButton);

}

@end
