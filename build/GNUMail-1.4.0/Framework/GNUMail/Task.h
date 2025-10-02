/*
**  Task.h
**
**  Copyright (c) 2002-2007 Ludovic Marcotte
**  Copyright (C) 2022      Riccardo Mottola
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

#ifndef _GNUMail_H_Task
#define _GNUMail_H_Task

#import <Foundation/NSCalendarDate.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSObject.h>

#define SEND_SENDMAIL  1
#define SEND_SMTP      2
#define RECEIVE_IMAP   3
#define RECEIVE_POP3   4
#define RECEIVE_UNIX   5

#define LOAD_ASYNC     6
#define SAVE_ASYNC     7
#define CONNECT_ASYNC  8
#define SEARCH_ASYNC   9
#define OPEN_ASYNC     10
#define EXPUNGE_ASYNC  11

#define ORIGIN_USER    1
#define ORIGIN_TIMER   2
#define ORIGIN_STARTUP 3

//
// When sending a message using SENDMAIL or SMTP
// subOp can old GNUMailComposeMessage, GNUMailRedirectMessage...
// Over IMAP, it can hold IMAP commands such as IMAP_STATUS.
//

@class NSMutableArray;
@class NSString;

@interface Task : NSObject <NSCoding,NSCopying>
{
  @private
    NSMutableArray *_controllers;
    NSString *_subtitle;

  @protected
    id message;      // The Message, if it exists (used when sending a mail).
                     // Could be as raw source (for bounce, for example) or an instance of Message

  
    id unmodifiedMessage; // The original message - useful when we reply to a message.

    id key;          // Account name.
    id sendingKey;   // The account name used to send the mail - we only use the SMTP or the 
                     // mailer informations from this account.
    
    NSDate *date;    // The date at which we will retry to do the op for this task.

    id owner;        // The object that owns this task. It could be a MailWindowController
                     // instance, for example.

    NSMutableArray *filteredMessagesFolders; // The names of the folders when messages where
                                             // transferred since matching filters were found 
                                             // during the reception of those messages.

  @public
    id service;

    int op;          // One of the SEND_{SENDMAIL,SMTP} or RECEIVE_{IMAP,POP3} value.
    int sub_op;      // A sub-operation, generally an IMAP command.
    
    BOOL immediate;  // If YES, we run this task immediately when it has been
                     // added to our task's pool.


    int origin;      // "Where" the task has been created. This could be by the user,
                     // the timer or when the application was started.

    BOOL is_running;    // YES if the task is running, NO otherwise.

    int filtered_count;                      // The number of messages that have been filtered.

    int received_count;                      // The number of messages we have received while
                                             // this task was running. It could also be the
                                             // number of "mailboxes" when performing an 
                                             // IMAP STATUS command.
    float total_size;
    float current_size;
    int total_count;                         // The number of messages or mailboxes to receive
}

//
//
//
- (id) message;
- (void) setMessage: (id) theMessage;

- (id) unmodifiedMessage;
- (void) setUnmodifiedMessage: (id) theMessage;

- (id) key;
- (void) setKey: (id) theKey;

- (id) sendingKey;
- (void) setSendingKey: (id) theKey;

- (NSDate *) date;
- (void) setDate: (NSDate *) theDate;

- (id) owner;
- (void) setOwner: (id) theOwner;

- (NSMutableArray *) filteredMessagesFolders;
- (void) setFilteredMessagesFolders: (NSMutableArray *) theMutableArray;

- (void) addController: (id) theController;
- (NSArray *) allControllers;

- (NSString *) subtitle;
- (void) setSubtitle: (NSString *) theSubtitle;

@end

#endif // _GNUMail_H_Task
