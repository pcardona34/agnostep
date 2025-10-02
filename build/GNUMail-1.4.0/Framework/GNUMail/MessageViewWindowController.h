/*
**  MessageViewWindowController.h
**
**  Copyright (c) 2001-2006 Ujwal S. Sathyam, Ludovic Marcotte
**
**  Author: Ujwal S. Sathyam <ujwal@setlurgroup.com>
**          Ludovic Marcotte <ludovic@Sophos.ca>
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

#ifndef _GNUMail_H_MessageViewWindowController
#define _GNUMail_H_MessageViewWindowController

#import <AppKit/AppKit.h>

#import "Constants.h"

@class CWFolder;
@class CWMessage;
@class MailHeaderCell;
@class MailWindowController;
@class ThreadArcsCell;

@interface MessageViewWindowController : NSWindowController
{
    IBOutlet NSTextView *textView;

    CWMessage *message;                          // the message that will be displayed
    CWFolder *folder;                            // the folder this message lives in
    MailWindowController *mailWindowController;  // the owning/parent mail window controller
    BOOL showAllHeaders;                         // flag to show all email headers
    BOOL showRawSource;                          // flag to show raw source
    NSInteger indexOffset;                       // offset to our initial index
    MailHeaderCell *mailHeaderCell;              // cell in which we display the headers
    ThreadArcsCell *threadArcsCell;
    

    @public
      IBOutlet NSButton *showOrHideAllHeaders;
      IBOutlet NSButton *raw;
}


//
// action methods
//
- (IBAction) deleteMessage: (id) sender;
- (IBAction) replyToMessage: (id) sender;
- (IBAction) previousMessage: (id) sender;
- (IBAction) nextMessage: (id) sender;
- (IBAction) firstMessage: (id) sender;
- (IBAction) lastMessage: (id) sender;
- (IBAction) showOrHideAllHeaders: (id) sender;


//
// delegate methods
//
- (void) windowWillClose: (NSNotification *) theNotification;
- (void) windowDidLoad;
- (void) windowDidBecomeKey: (NSNotification *) aNotification;


//
// access/mutation methods
//
- (NSTextView *) textView;
- (CWMessage *) message;
- (CWMessage *) selectedMessage;
- (NSArray *) allMessages;
- (void) setMessage:(CWMessage *)aMessage;
- (CWFolder *) folder;
- (void) setFolder:(CWFolder *) aFolder;
- (MailWindowController *) mailWindowController;
- (void) setMailWindowController: (MailWindowController *)aMailWindowController;
- (BOOL) showAllHeaders;
- (void) setShowAllHeaders: (BOOL) aBool;
- (BOOL) showRawSource;
- (void) setShowRawSource: (BOOL) aBool;
- (MailHeaderCell *) mailHeaderCell;
- (ThreadArcsCell *) threadArcsCell;
- (NSInteger) indexOffset;
- (void) setIndexOffset: (NSInteger) theIndexOffset;


//
// other methods
//
-  (void) textView: (NSTextView *) aTextView
     clickedOnCell: (id <NSTextAttachmentCell>) attachmentCell
	    inRect: (NSRect) cellFrame
           atIndex: (unsigned) charIndex;

- (BOOL) textView: (NSTextView *) textView
    clickedOnLink: (id) link 
	  atIndex: (unsigned) charIndex;



@end


//
// Private interface
//
@interface MessageViewWindowController (Private)

- (void) _loadAccessoryViews;

@end

#endif // _GNUMail_H_MessageViewWindowController
