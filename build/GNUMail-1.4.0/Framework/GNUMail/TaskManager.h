/*
**  TaskManager.h
**
**  Copyright (c) 2002-2007 Ludovic Marcotte
**                2022      Riccardo Mottola
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

#ifndef _GNUMail_H_TaskManager
#define _GNUMail_H_TaskManager

#import <Foundation/NSMapTable.h>
#import <Foundation/NSObject.h>

#if defined(__APPLE__) && (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#ifndef NSUInteger
#define NSUInteger unsigned int
#endif
#ifndef NSInteger
#define NSInteger int
#endif
#endif

@class CWMessage;
@class CWService;
@class MailWindowController;
@class NSMutableArray;
@class NSNotification;
@class NSTimer;
@class Task;

@interface TaskManager : NSObject
{
  @private
    NSTimer *_timer;
    NSMapTable *_table;
    
    NSMutableArray *_storesStorage;
  
    NSMutableArray *_tasks;

    unsigned int _counter;
}

- (void) run;
- (void) stop;

- (void) addTask: (Task *) theTask;
- (void) nextTask;
- (void) removeTask: (Task *) theTask;

- (Task *) taskForService: (CWService *) theService;
- (Task *) taskForService: (CWService *) theService  message: (CWMessage *) theMessage;

- (NSArray *) allTasks;

- (void) checkForNewMail: (id) theSender
              controller: (MailWindowController *) theMailWindowController;

- (void) stopTask: (Task *) theTask;
- (void) stopTasksForService: (id) theService;
- (void) setMessage: (id) theMessage  forHash: (NSUInteger) theHash;

//
// Pantomime's delegate methods
//
- (void) authenticationCompleted: (NSNotification *) theNotification;
- (void) authenticationFailed: (NSNotification *) theNotification;
- (void) connectionEstablished: (NSNotification *) theNotification;
- (void) connectionTerminated: (NSNotification *) theNotification;
- (void) connectionTimedOut: (NSNotification *) theNotification;
- (void) folderPrefetchCompleted: (NSNotification *) theNotification;
- (void) messagePrefetchCompleted: (NSNotification *) theNotification;
- (void) messageNotSent: (NSNotification *) theNotification;
- (void) messageSent: (NSNotification *) theNotification;
- (void) service: (CWService *) theService receivedData: (NSData *) theData;
- (void) service: (CWService *) theService sentData: (NSData *) theData;


//
// Class methods
//
+ (id) singleInstance;

@end

#endif // _GNUMail_H_TaskManager
