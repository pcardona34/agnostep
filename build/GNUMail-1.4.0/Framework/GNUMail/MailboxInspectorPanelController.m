/*
**  MailboxInspectorPanelController.m
**
**  Copyright (C) 2004-2007 Ludovic Marcotte
**  Copyright (C) 2014      Riccardo Mottola
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
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#import "MailboxInspectorPanelController.h"

#ifndef MACOSX
#import "MailboxInspectorPanel.h"
#endif

#import "ThreadArcsCell.h"

#import <Pantomime/CWMessage.h>

static MailboxInspectorPanelController *singleInstance = nil;

//
//
//
@implementation MailboxInspectorPanelController

- (id) initWithWindowNibName: (NSString *) windowNibName
{
#ifdef MACOSX
  self = [super initWithWindowNibName: windowNibName];
#else
  MailboxInspectorPanel *aPanel;
  
  aPanel = [[MailboxInspectorPanel alloc] initWithContentRect: NSMakeRect(200,200,250,500)
					  styleMask: NSTitledWindowMask|NSClosableWindowMask|
					  NSMiniaturizableWindowMask|NSResizableWindowMask
					  backing: NSBackingStoreBuffered
					  defer: YES];
  
  self = [super initWithWindow: aPanel];

  [aPanel layoutPanel];
  [aPanel setDelegate: self];
  [aPanel setMinSize: [aPanel frame].size];

  // We link our outlets
  threadArcsView = aPanel->threadArcsView;
  textView = ((MailboxInspectorThreadArcsView *)threadArcsView)->textView;
  subject = (NSTextField *)((MailboxInspectorThreadArcsView *)threadArcsView)->subject;

  box = aPanel->box;
  RELEASE(aPanel);
#endif

  _cell = [[ThreadArcsCell alloc] init];
  [_cell setUsesInspector: YES];
  [_cell setController: self];

  // We set the window's title
  [[self window] setTitle: _(@"Mailbox Inspector")];

  // We finally set our autosave window frame name and restore the one from the user's defaults.
  [[self window] setFrameAutosaveName: @"MailboxInspectorPanel"];
  [[self window] setFrameUsingName: @"MailboxInspectorPanel"];
  
  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(_message);
  RELEASE(_cell);
  [super dealloc];
}


//
// delete methods
//
- (IBAction) selectionHasChanged: (id) sender
{
  [sender synchronizeTitleAndSelectedItem];
  
  switch ([sender indexOfSelectedItem])
    {
    case 3:
      [box setContentView: threadArcsView];
      break;

    default:
      [box setContentView: AUTORELEASE([[NSView alloc] init])];
    }
}


//
// access / mutation methods
//
- (NSTextView *) textView
{
  return textView;
}


//
//
//
- (CWMessage *) selectedMessage
{
  return _message;
}

- (void) setSelectedMessage: (CWMessage *) theMessage
{
  NSTextAttachment *aTextAttachment;

  ASSIGN(_message, theMessage);

  // We refresh our "Thread Arcs" panel
  aTextAttachment = [[NSTextAttachment alloc] init];
  [aTextAttachment setAttachmentCell: _cell];  
  [[textView textStorage] setAttributedString: [NSMutableAttributedString attributedStringWithAttachment: aTextAttachment]];
  RELEASE(aTextAttachment);

  [subject setStringValue: ((theMessage && [theMessage subject]) ? (id)[theMessage subject] : (id)@"")];
}


//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[MailboxInspectorPanelController alloc] initWithWindowNibName: @"MailboxInspectorPanel"];
    }
  
  return singleInstance;
}

@end
