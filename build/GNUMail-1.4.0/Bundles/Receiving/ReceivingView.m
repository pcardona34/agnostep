/*
**  ReceivingView.m
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

#include "ReceivingView.h"

#include "Constants.h"
#include "LabelWidget.h"

const id IncomingServersColumnIdentifier = @"incoming servers";

//
//
//
@implementation ReceivingView

- (id) initWithParent: (id) theParent
{
  self = [super init];

  _parent = theParent;
  [self setFrame:NSMakeRect(0,0,450,215)];

  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"ReceivingView: -dealloc");
  
  RELEASE(showFilterPanelButton);
  RELEASE(showNoNewMessagesPanelButton);
  RELEASE(openMailboxAfterTransfer);

  RELEASE(playSoundButton);
  RELEASE(pathToSoundField);
  RELEASE(chooseFileButton);

  [super dealloc];
}


//
//
//
- (void) layoutView
{
  LabelWidget *label;
  
  //
  // Our Options box
  //
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(5,180,430,50)
		       label: _(@"In this panel, you can configure parameters activated (or not) when\nreceiving new mails. For example, you can play a sound of your\nchoice when a new mail is received.")];
  [self addSubview: label];

  showFilterPanelButton = [[NSButton alloc] initWithFrame: NSMakeRect(5,140,410,ButtonHeight)];
  [showFilterPanelButton setButtonType: NSSwitchButton];
  [showFilterPanelButton setBordered: NO];
  [showFilterPanelButton setTitle: _(@"Show alert panel for received and transferred messages")];
  [self addSubview: showFilterPanelButton];

  showNoNewMessagesPanelButton = [[NSButton alloc] initWithFrame: NSMakeRect(5,110,410,ButtonHeight)];
  [showNoNewMessagesPanelButton setButtonType: NSSwitchButton];
  [showNoNewMessagesPanelButton setBordered: NO];
  [showNoNewMessagesPanelButton setTitle: _(@"Show No new messages alert panel")];
  [self addSubview: showNoNewMessagesPanelButton]; 

  openMailboxAfterTransfer = [[NSButton alloc] initWithFrame: NSMakeRect(5,80,410,ButtonHeight)];
  [openMailboxAfterTransfer setButtonType: NSSwitchButton];
  [openMailboxAfterTransfer setBordered: NO];
  [openMailboxAfterTransfer setTitle: _(@"Automatically open mailboxes for received and transferred messages")];
  [self addSubview: openMailboxAfterTransfer]; 


  //
  // Play sound
  //
  playSoundButton = [[NSButton alloc] initWithFrame: NSMakeRect(5,50,100,ButtonHeight)];
  [playSoundButton setButtonType: NSSwitchButton];
  [playSoundButton setBordered: NO];
  [playSoundButton setTitle: _(@"Play sound")];
  [playSoundButton setTarget: _parent];
  [playSoundButton setAction: @selector(playSoundButtonClicked:)];
  [self addSubview: playSoundButton];

  pathToSoundField = [[NSTextField alloc] initWithFrame: NSMakeRect(110,50,200,TextFieldHeight)];
  [pathToSoundField setEditable: NO];
  [pathToSoundField setSelectable: YES];
  [self addSubview: pathToSoundField];
  
  chooseFileButton = [[NSButton alloc] initWithFrame: NSMakeRect(315,48,100,ButtonHeight)];
  [chooseFileButton setTitle: _(@"Choose file")];
  [chooseFileButton setTarget: _parent];
  [chooseFileButton setAction: @selector(chooseFileButtonClicked:)];
  [self addSubview: chooseFileButton];
}

@end
