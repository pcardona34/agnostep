/*
**  TaskManager.m
**
**  Copyright (c) 2002-2007 Ludovic Marcotte
**  Copyright (C) 2015-2022 Riccardo Mottola
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

#import "TaskManager.h"

#import "ConsoleWindowController.h"
#import "Constants.h"
#import "EditWindowController.h"
#import "ExtendedTableView.h"
#import "Filter.h"
#import "FilterManager.h"
#import "FindWindowController.h"
#import "GNUMail.h"
#import "MailboxManagerCache.h"
#import "MailboxManagerController.h"
#import "MailWindowController.h"
#import "MessageViewWindowController.h"
#import "NSPasteboard+Extensions.h"
#import "NSUserDefaults+Extensions.h"
#import "Task.h"
#import "Utilities.h"
#import "AddressBookController.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSException.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSTimer.h>
#import <Foundation/NSValue.h>

#import <Pantomime/CWConstants.h>
#import <Pantomime/CWFlags.h>
#import <Pantomime/CWFolderInformation.h>
#import <Pantomime/CWIMAPStore.h>
#import <Pantomime/CWIMAPFolder.h>
#import <Pantomime/CWLocalFolder.h>
#import <Pantomime/CWLocalFolder+mbox.h>
#import <Pantomime/CWLocalStore.h>
#import <Pantomime/CWMessage.h>
#import <Pantomime/CWPOP3CacheManager.h>
#import <Pantomime/CWPOP3Folder.h>
#import <Pantomime/CWPOP3Message.h>
#import <Pantomime/CWPOP3Store.h>
#import <Pantomime/CWSendmail.h>
#import <Pantomime/CWSMTP.h>
#import <Pantomime/CWTCPConnection.h>
#import <Pantomime/CWTransport.h>
#import <Pantomime/CWURLName.h>
#import <Pantomime/NSData+Extensions.h>
#import <Pantomime/NSString+Extensions.h>

#include <unistd.h>

static TaskManager *singleInstance;
static Class CWIMAPStore_class;
static Class CWLocalStore_class;
static Class CWPOP3Store_class;
static Class CWSMTP_class;

//
// TaskManager Private Interface
//
@interface TaskManager (Private)

- (void) _asyncOperationForTask: (Task *) theTask;

- (void) _checkMailForAccount: (NSString *) theAccountName
		       origin: (int) theOrigin
			owner: (id) theOwner;

- (void) _executeActionUsingFilter: (Filter *) theFilter
                           message: (NSData *) theMessage
                              task: (Task *) theTask;

- (BOOL) _matchFilterRuleFromRawSource: (NSData *) theRawSource
                                  task: (Task *) theTask;

#if 0
- (BOOL) _filterIMAPMessagesInFolder: (CWIMAPFolder *) theFolder;
#endif

- (void) _receiveUsingIMAPForTask: (Task *) theTask;
- (void) _receiveUsingPOP3ForTask: (Task *) theTask;
- (void) _receiveUsingUNIXForTask: (Task *) theTask;

- (void) _sendUsingSendmailForTask: (Task *) theTask;
- (void) _sendUsingSMTPForTask: (Task *) theTask;

- (void) _taskCompleted: (Task *) theTask;
- (void) _tick;
- (void) _tick_internal;

@end



//
//
//
@implementation TaskManager

+ (void) initialize
{
  CWIMAPStore_class = [CWIMAPStore class];
  CWLocalStore_class = [CWLocalStore class];
  CWPOP3Store_class = [CWPOP3Store class];
  CWSMTP_class = [CWSMTP class];
}


//
//
//
- (id) init
{
  self = [super init];
  if (self != nil)
    {
      _table = NSCreateMapTable(NSIntMapKeyCallBacks, NSObjectMapValueCallBacks, 128);
      _tasks = [[NSMutableArray alloc] init];

      // TaskManaer is a shared instance, so we use it to track all CWStores instances
      // That way we can release them properly
      _storesStorage = [[NSMutableArray alloc] init];
      _counter = 0;
    }
  return self;
}


//
//
//
- (void) dealloc
{
  NSFreeMapTable(_table);
  RELEASE(_tasks);
  RELEASE(_storesStorage);
  [super dealloc];
}


//
// This method is used to add a task to the runqueue. It will NOT
// add a task that is identical to one already in the runqueue.
//
// Those tasks include: RECEIVE_POP3 and RECEIVE_IMAP+IMAP_STATUS
//
- (void) addTask: (Task *) theTask
{
  // We insert it at the beginning of our array
  if (theTask)
    {
      Task *aTask;
      int count;

      count = [_tasks count];

      while (count--)
	{
	  aTask = [_tasks objectAtIndex: count];

	  if ((theTask->op == RECEIVE_POP3 || (theTask->op == RECEIVE_IMAP && theTask->sub_op == IMAP_STATUS) || theTask->op == EXPUNGE_ASYNC) &&
	      [[aTask key] isEqualToString: [theTask key]])
	    {
	      return;
	    }
	}
      
      [_tasks insertObject: theTask  atIndex: 0];
      [self nextTask];
      [[ConsoleWindowController singleInstance] reload];
    }
}


//
//
//
- (void) nextTask
{ 
  Task *aTask;
  int i;

  aTask = nil;

  //
  // This method is the ONLY one that assigns the current running task.
  // If there's already one set, it returns nil.
  //   
  // We search for a task that should be run immediately
  for (i = ([_tasks count] - 1); i >= 0; i--)
    {
      aTask = [_tasks objectAtIndex: i];

      if (!aTask->is_running)
	{
	  // We found one, let's use it.
	  if (aTask->immediate)
	    {
	      aTask->is_running = YES;
	      [[[ConsoleWindowController singleInstance] tasksTableView] setNeedsDisplay: YES];
	      break;
	    }
	}
      
      aTask = nil;
    }  
  
  // We haven't found an immediate task. We loop from the oldest task
  // to the newest one to find a task that -date meets the requirements of
  // the current date/time.
  if (!aTask)
    {
      NSDate *aDate;

      aDate = AUTORELEASE([[NSDate alloc] init]);
      
      for (i = ([_tasks count] - 1); i >= 0; i--)
	{
	  aTask = [_tasks objectAtIndex: i];
	  
	  if (!aTask->is_running)
	    {
	      if ([[aTask date] compare: aDate] == NSOrderedAscending)
		{
		  aTask->is_running = YES;
		  [[[ConsoleWindowController singleInstance] tasksTableView] setNeedsDisplay: YES];
		  break;
		}
	    }

	  aTask = nil;
	}
    }

  if (aTask)
    {
      NSAutoreleasePool *pool;
      
      pool = [[NSAutoreleasePool alloc] init];

      switch (aTask->op)
	{
	case SEND_SENDMAIL:
	  [self _sendUsingSendmailForTask: aTask];
	  break;
	  
	case SEND_SMTP:
	  [self _sendUsingSMTPForTask: aTask];
	  break;

	case RECEIVE_IMAP:
	  [self _receiveUsingIMAPForTask: aTask];
	  break;

	case RECEIVE_POP3:
	  [self _receiveUsingPOP3ForTask: aTask];
	  break;

	case RECEIVE_UNIX:
	  [self _receiveUsingUNIXForTask: aTask];
	  break;

	case LOAD_ASYNC:
	case CONNECT_ASYNC:
	case SAVE_ASYNC:
	case SEARCH_ASYNC:
	case OPEN_ASYNC:
	case EXPUNGE_ASYNC:
	  [self _asyncOperationForTask: aTask];
	  break;

	default:
	  NSDebugLog(@"Unknown task type. Ignoring and keeping in the queue.");
	}

      RELEASE(pool);
    }
}


//
//
//
- (void) removeTask: (Task *) theTask
{
  NSUInteger i;
  
  i = [_tasks indexOfObject: theTask];

  if (i != NSNotFound)
    {
      [_tasks removeObjectAtIndex: i];
      // We must do this check in case the console wasn't shown, the progress indicator
      // wouldn't exist.
      if (i < [[[ConsoleWindowController singleInstance] progressIndicators] count])
	{
	  [[[[ConsoleWindowController singleInstance] progressIndicators] objectAtIndex: i] removeFromSuperview];
	}
      [[ConsoleWindowController singleInstance] reload];
    }
}


//
//
//
- (Task *) taskForService: (CWService *) theService  message: (CWMessage *) theMessage
{
  Task *aTask;
  int count;

  count = [_tasks count];

  while (count--)
    {
      aTask = [_tasks objectAtIndex: count];

      if (aTask->service == theService && !theMessage)
	{
	  return aTask;
	}
      else if (aTask->service == theService && [aTask message] == theMessage)
	{
	  return aTask;
	}
    }

  return nil;
}


//
//
//
- (Task *) taskForService: (CWService *) theService
{
  return [self taskForService: theService  message: nil];
}




//
// Since this method is invoked a lot, we return
// the ivar directly to avoid creating objects.
//
- (NSArray *) allTasks
{
  return _tasks;
}


//
//
//
- (void) checkForNewMail: (id) theSender
	      controller: (MailWindowController *) theMailWindowController
{
  NSArray *allKeys;
  int i, origin;

  // First of all, we get the 'origin' of the action. That is, if it was 
  // initiated from the user, from the timer or from self, when verifying
  // mail on statup.
  if (theSender == theMailWindowController ||
      theSender == [NSApp delegate])
    {
      origin = ORIGIN_STARTUP;
    }
  else
    {
      // We clicked on the get button or on the menu item.
      origin = ORIGIN_USER;
    }

  // We reset our counter ivar since we don't want to check mails immediately
  // after we already checked for it.
  _counter = 0;
  
  //
  // If it's our menu item that called this method but, it's NOT the get "All"
  // that has been clicked. So, we must verify only one account.
  //
  if (theSender && 
      [theSender isKindOfClass: [NSMenuItem class]] &&
      [theSender tag] >= 0)
    {
      allKeys = [NSArray arrayWithObject: [theSender title]];
    }
  //
  // If the user has clicked on the Get button OR 
  // It is our "All" menu item that was clicked on.
  //
  else if ((theMailWindowController && theSender == theMailWindowController->get) ||
	   (theSender && [theSender isKindOfClass: [NSMenuItem class]] && [theSender tag] < 0))
    {
      // We get all accounts here but we'll verify later that we only use POP3 accounts.
      allKeys = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] allKeys]
		  sortedArrayUsingSelector: @selector(compare:)];
    }
  //
  // Our sender is the app's delegate. That means that we were asked to verify mails 
  // on startup. Let's only get the POP3 and UNIX accounts that we must verify on startup.
  // We skip over IMAP accounts since we don't want to establish the required connections.
  //
  else if (theSender == [NSApp delegate])
    {
      NSMutableArray *aMutableArray;
      
      aMutableArray = [[NSMutableArray alloc] initWithArray: [[[NSUserDefaults standardUserDefaults]
								objectForKey: @"ACCOUNTS"] allKeys]];      
      for (i = ([aMutableArray count]-1); i >= 0; i--)
	{
	  NSDictionary *allValues;
	  NSString *aKey;
	  
	  aKey = [aMutableArray objectAtIndex: i];

	  // If the account is disabled or it's set to never check mail, we skip over it
	  if ( ![[[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] objectForKey: aKey]
		   objectForKey: @"ENABLED"] boolValue] ||
	       [[[[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] objectForKey: aKey]
		   objectForKey: @"RECEIVE"] objectForKey: @"RETRIEVEMETHOD"] intValue] == NEVER )
	    {
	      continue;
	    }

	  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
			 objectForKey: aKey] objectForKey: @"RECEIVE"];
	  
	  if ( ![allValues objectForKey: @"CHECKONSTARTUP"] ||
	       [[allValues objectForKey: @"CHECKONSTARTUP"] intValue] == NSOffState ||
	       ([allValues objectForKey: @"SERVERTYPE"] && [[allValues objectForKey: @"SERVERTYPE"] intValue] == IMAP) )
	    {
	      [aMutableArray removeObject: aKey];
	    }
	  else
	    {
	      NSDebugLog(@"Will verify for new mail on startup for %@", aKey);
	    }
	}

      allKeys = AUTORELEASE(aMutableArray);
    }
  else
    {
      NSDebugLog(@"TaskManager: -checkForNewMail: controller: called w/o being handled.");
      return;
    }
  
  // We send all our tasks!
  for (i = 0; i < [allKeys count]; i++)
    {
      [self _checkMailForAccount: [allKeys objectAtIndex: i]
	    origin: origin
	    owner: theMailWindowController];
    }
}


//
//
//
- (void) setMessage: (id) theMessage  forHash: (NSUInteger) theHash
{
  NSMapInsert(_table, (void *)theHash, theMessage);
}


//
//
//
- (void) stopTask: (Task *) theTask
{
  int op;
  id o;
  
  o = theTask->service;
  op = theTask->op;

  if (op == SAVE_ASYNC || !o)
    {
      return;
    }

  theTask->is_running = NO; 
  [theTask->service cancelRequest];

  // We do not refer to the task object past here since it
  // might alread have been autoreleased.
  if (op == LOAD_ASYNC || op == SEARCH_ASYNC)
    {
      [self stopTasksForService: o];
      [o reconnect];
      
      if (op == SEARCH_ASYNC) [[FindWindowController singleInstance] setSearchResults: nil  forFolder: nil];
    }
}


//
//
//
- (void) stopTasksForService: (id) theService
{
  Task *aTask;
  int count;

  count = [_tasks count];

  while (count--)
    {
      aTask = [_tasks objectAtIndex: count];
      
      if (aTask->service == theService)
	{
	  [self removeTask: aTask];
	}
    }
}


//
//
//
- (void) run
{
  // We create our timer, it'll get added to the runloop in the NSDefaultRunLoopMode and NSEventTrackingRunLoopMode.
  _timer = [NSTimer timerWithTimeInterval: 5
		    target: self
		    selector: @selector(_tick)
		    userInfo: nil
		    repeats: YES];
  [[NSRunLoop currentRunLoop] addTimer: _timer  forMode: NSEventTrackingRunLoopMode];
  [[NSRunLoop currentRunLoop] addTimer: _timer  forMode: NSDefaultRunLoopMode];
  [[NSRunLoop currentRunLoop] addTimer: _timer  forMode: NSModalPanelRunLoopMode];
  RETAIN(_timer);
}


//
//
//
- (void) stop
{
  [_timer invalidate];
  RELEASE(_timer);
}


//
//
//
- (void) fire
{
  [_timer fire];
}


//
// Pantomime's delegate methods
//
- (void) authenticationCompleted: (NSNotification *) theNotification
{
  Task *aTask;
  id o;

  o = [theNotification object];
  aTask = [self taskForService: o]; 

  if ([o isKindOfClass: CWSMTP_class])
    {
      ADD_CONSOLE_MESSAGE(_(@"SMTP - Authenticated! Sending the message..."));
      [o sendMessage];

      // We reupdate the message's size, since we now know its final value.
      aTask->total_size = (float)[[o messageData] length]/(float)1024;;
    }
  else if ([o isKindOfClass: CWPOP3Store_class])
    {
      CWPOP3CacheManager *aCacheManager;	      
      NSString *aCacheFilename;
      
      // We get our POP3 cache
      aCacheFilename = [Utilities flattenPathFromString: [NSString stringWithFormat: @"%@ @ %@", [o username], [(CWService*)o name]]
				  separator: '/'];

      aCacheManager = [[CWPOP3CacheManager alloc] initWithPath: [NSString stringWithFormat: @"%@/POP3Cache_%@",
									  GNUMailUserLibraryPath(),
									  aCacheFilename]];
      [[o defaultFolder] setCacheManager: AUTORELEASE(aCacheManager)];
      
      ADD_CONSOLE_MESSAGE(_(@"POP3 - Authenticated! Transferring messages..."));
      [[o defaultFolder] prefetch];
    }
  else
    {
      NSString *aString;
      NSNumber *aNumber;

      ADD_CONSOLE_MESSAGE(_(@"IMAP - Authenticated!"));
      
      aString = [Utilities accountNameForServerName: [(CWService *)o name]  username: [o username]];

      aNumber = [[[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		    objectForKey: aString] objectForKey: @"RECEIVE"] objectForKey: @"SHOW_WHICH_MAILBOXES"];
      
      if (aNumber && [aNumber intValue] == IMAP_SHOW_SUBSCRIBED_ONLY)
	{
	  [o subscribedFolderEnumerator];
	}
      else
	{
	  [o folderEnumerator];
	}
    }
}


//
//
//
- (void) authenticationFailed: (NSNotification *) theNotification
{
  NSString *aString, *aName;
  Task *aTask;
  id o;
  
  o = [theNotification object];
  aTask = [self taskForService: o];

  // We get the right account name.
  if (aTask)
    {
      aName = [aTask key];
    }
  else
    {
      aName = [Utilities accountNameForServerName: [(CWService *)o name]  username: [o username]];
    }


  if ([o isKindOfClass: CWPOP3Store_class])
    {
      aString = _(@"POP3");
    }
  else if ([o isKindOfClass: CWIMAPStore_class])
    {
      aString = _(@"IMAP");
    }
  else
    {
      aString = _(@"SMTP");
    }

  NSRunAlertPanel(_(@"Error!"),
		  _(@"%@ authentication failed for account %@."),
		  _(@"OK"),
		  NULL,
		  NULL,
		  aString,
		  aName);
  
  // We now invalidate our password
  [[Utilities passwordCache] removeObjectForKey: [NSString stringWithFormat: @"%@ @ %@", [o username], [(CWService*)o name]]];
  
  // We close the TCP connection. The actual "Service" object will be
  // released in -connectionTerminated.
  [o close];
  
  // We leave the task in the queue if it's a SMTP related task.
  // Otherwise, we do nothing. We will do something else
  // in -connectionTerminated.
  if (aTask && [o isKindOfClass: CWSMTP_class])
    {
      [aTask setDate: [AUTORELEASE([[NSDate alloc] init]) addTimeInterval: 300]];
      aTask->is_running = NO;
      [[[ConsoleWindowController singleInstance] tasksTableView] setNeedsDisplay: YES];
    }
  else if ([o isKindOfClass: CWIMAPStore_class])
    {
      [[MailboxManagerController singleInstance] setStore: nil
						 name: [(CWService *)o name]
						 username: [o username]];
    }
}


//
//
//
- (void) serviceInitialized: (NSNotification *) theNotification
{
  NSDictionary *allValues;
  NSString *aPassword;
  id o;

  o = [theNotification object];

  if ([o isKindOfClass: CWSMTP_class])
    {
      Task *aTask;
      
      aTask = [self taskForService: o];

      ADD_CONSOLE_MESSAGE(_(@"SMTP - Connected to %@!"), [(CWSMTP *)o name]);

      // We must verify if we need to use SMTP authentifcation.
      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		     objectForKey: [aTask sendingKey]] objectForKey: @"SEND"];
     
      if (![(CWTCPConnection *)[o connection] isSSL] &&
	  (([[allValues objectForKey: @"USESECURECONNECTION"] intValue] == SECURITY_TLS_IF_AVAILABLE && [[o capabilities] containsObject: @"STARTTLS"]) ||
	   [[allValues objectForKey: @"USESECURECONNECTION"] intValue] == SECURITY_TLS))
	{
	  [o startTLS];
	  return;
	}

      if ([allValues objectForKey: @"SMTP_AUTH"] &&
	  [[allValues objectForKey: @"SMTP_AUTH"] intValue] == NSOnState)
	{
	  ADD_CONSOLE_MESSAGE(_(@"SMTP - Authenticating to %@ using %@..."),
			      [allValues objectForKey: @"SMTP_HOST"],
			      [allValues objectForKey: @"SMTP_USERNAME"]);
	  
	  aPassword = [Utilities passwordForKey: [aTask sendingKey]  type: OTHER  prompt: YES];
	  
	  if (aPassword)
	    {
	      [o authenticate: [allValues objectForKey: @"SMTP_USERNAME"]
		 password: aPassword
		 mechanism: [allValues objectForKey: @"SMTP_AUTH_MECHANISM"]];
	    }
	  else
	    {
	      [self authenticationFailed: theNotification];
	    }
	}
      else
	{
	  // We do not need to use SMTP AUTH, let's send the message right away.
	  [o sendMessage];
	  
	  // We reupdate the message's size, since we now know its final value.
	  aTask->total_size = (float)[[o messageData] length]/(float)1024;;
	}
    }
  else if ([o isKindOfClass: CWPOP3Store_class] ||
	   [o isKindOfClass: CWIMAPStore_class])
    {
      NSString *aMechanism, *aString;
     
      aString = [Utilities accountNameForServerName: [(CWService *)o name]  username: [o username]];

      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		     objectForKey: aString] objectForKey: @"RECEIVE"];
      aMechanism = nil;

      if (![(CWTCPConnection *)[o connection] isSSL] &&
	  (([[allValues objectForKey: @"USESECURECONNECTION"] intValue] == SECURITY_TLS_IF_AVAILABLE &&
	    ([[o capabilities] containsObject: @"STLS"] || [[o capabilities] containsObject: @"STARTTLS"])) ||
	   [[allValues objectForKey: @"USESECURECONNECTION"] intValue] == SECURITY_TLS))
	{
	  [o startTLS];
	  return;
	}      
      if ([o isKindOfClass: CWPOP3Store_class])
	{
	  ADD_CONSOLE_MESSAGE(_(@"POP3 - Connected to %@!"), [(CWService *)o name]);
	  
	  if ([allValues objectForKey: @"USEAPOP"])
	    {
	      aMechanism = ([[allValues objectForKey: @"USEAPOP"] intValue] == NSOnState ? (id)@"APOP" : nil);
	    }
	}
      else
	{
	  ADD_CONSOLE_MESSAGE(_(@"IMAP - Connected to %@!"), [(CWService *)o name]);
	  aMechanism = [allValues objectForKey: @"AUTH_MECHANISM"];
	  
	  if (aMechanism && [aMechanism isEqualToString: @"Password"])
	    {
	      aMechanism = nil;
	    }
	}
      
      aPassword = [Utilities passwordForKey: aString  type: IMAP  prompt: YES];
      
      if (aPassword)
	{
	  [o authenticate: [allValues objectForKey: @"USERNAME"]
	     password: aPassword
	     mechanism: aMechanism];
	}
      else
	{
	  [self authenticationFailed: theNotification];
	}
    }
}

//
//
//
- (void) serviceReconnected: (NSNotification *) theNotification
{
  id o;
  
  o = [theNotification object];
  
  if ([o isKindOfClass: CWIMAPStore_class])
    {
      ADD_CONSOLE_MESSAGE(_(@"Reconnected to server %@"), [(CWService *)o name]);
    }
}

//
//
//
- (void) connectionEstablished: (NSNotification *) theNotification
{
  NSDictionary *allValues;
  id o;

  o = [theNotification object];

  if ([o isKindOfClass: CWSMTP_class])
    {
      Task *aTask;
      
      aTask = [self taskForService: o];

      ADD_CONSOLE_MESSAGE(_(@"SMTP - Connected to %@!"), [(CWSMTP *)o name]);

      // We must verify if we need to use SMTP authentifcation.
      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		     objectForKey: [aTask sendingKey]] objectForKey: @"SEND"];

      // We check if we have to enable SSL
      if ([allValues objectForKey: @"USESECURECONNECTION"] &&
	  [[allValues objectForKey: @"USESECURECONNECTION"] intValue] == NSOnState)
	{
	  [(CWTCPConnection *)[o connection] startSSL];
	}
    }
  else if ([o isKindOfClass: CWPOP3Store_class] ||
	   [o isKindOfClass: CWIMAPStore_class])
    {
      NSString *aString;
      
      aString = [Utilities accountNameForServerName: [(CWService *)o name]  username: [o username]];

      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		     objectForKey: aString] objectForKey: @"RECEIVE"];

      // We check if we have to enable SSL
      if ([allValues objectForKey: @"USESECURECONNECTION"] &&
	  [[allValues objectForKey: @"USESECURECONNECTION"] intValue] == NSOnState)
	{
	  [(CWTCPConnection *)[o connection] startSSL];
	}
    }
}

//
//
//
- (void) connectionLost: (NSNotification *) theNotification
{
  id o;
  
  o = [theNotification object];

  if ([o isKindOfClass: CWIMAPStore_class] || [o isKindOfClass: CWPOP3Store_class])
    {
      Task *aTask;
      
      ADD_CONSOLE_MESSAGE(_(@"Connection lost to server %@"), [(CWService *)o name]);
      aTask = [self taskForService: o];
      
      if (aTask)
	{
	  [self _taskCompleted: aTask];
	}
      
      if ([o isKindOfClass: CWIMAPStore_class] && [(CWIMAPStore *)o lastCommand] != IMAP_LOGOUT)
	{
	  [o reconnect];
	}
      else
	{
	  [_storesStorage removeObjectIdenticalTo:o]; 
	}
    }
}


//
//
//
- (void) connectionTerminated: (NSNotification *) theNotification
{
  Task *aTask;
  id o;
  
  o = [theNotification object];
  aTask = [self taskForService: o];

  if (aTask)
    {
      if ([o isKindOfClass: CWPOP3Store_class])
	{
	  if (aTask->received_count == 0)
	    {
	      // We show the panel the user wants it and was able to succesfully authenticate to the POP3 server.
	      if ([[NSUserDefaults standardUserDefaults] integerForKey: @"SHOW_NO_NEW_MESSAGES_PANEL"  default: NSOnState] == NSOnState &&
		  [[Utilities passwordCache] objectForKey: [NSString stringWithFormat: @"%@ @ %@", [o username], [(CWService*)o name]]])
		{
		  NSRunAlertPanel(_(@"No New Messages..."),
				  _(@"There are no new messages on %@ @ %@."),
				  _(@"OK"),
				  NULL,
				  NULL,
				  [o username],
				  [(CWPOP3Store *)o name]);
		}
	      
	      ADD_CONSOLE_MESSAGE(_(@"No new messages on server %@"), [(CWPOP3Store *)o name]);
	    }
	  else
	    {
	      // We thread the folder, if we need to.
	      if ([aTask owner] && [[aTask owner] respondsToSelector: @selector(dataView)] &&
		  aTask->received_count != aTask->filtered_count &&
		  [[[aTask owner] folder] allContainers])
		{
		  [[[aTask owner] folder] thread];
		}
	    }
	}
      
      
      if ([o isKindOfClass: CWPOP3Store_class] || [o isKindOfClass: CWIMAPStore_class])
	{
	  [self _taskCompleted: aTask];
	}
    }

  [_storesStorage removeObjectIdenticalTo:o]; 
}


//
//
//
- (void) connectionTimedOut: (NSNotification *) theNotification
{
  NSString *aString;
  Task *aTask;
  id o;

  o = [theNotification object];
  aTask = [self taskForService: o];
  
  //
  // Here are the scenarios
  //
  // Connection NOT ESTABLISHED
  //
  // SEND_SMTP                              Show alert. Leave task in the queue.
  // RECEIVE_IMAP:                          Show alert. Remove task from the queue.
  // RECEIVE_POP3:                          Show alert. Remove task from the queue.
  // CONNECT_ASYNC+IMAP                     Show alert. Remove task from the queue + set store to nil.
  //
  // Connection ESTABLISHED
  //
  // SEND_SMTP:                             Show alert. Leave task in the queue.
  // RECEIVE_IMAP:                          Show alert. Remove task from the queue.
  // RECEIVE_POP3:                          Show alert. Remove task from the queue.
  // {LOAD,SAVE,SEARCH,OPEN,EXPUNGE}_ASYNC  Show alert. {LOAD,SEARCH,OPEN,EXPUNGE}_ASYNC close all assciated windows.
  //                                        or offer a reconnect option?
  //
  if ([o isKindOfClass: CWPOP3Store_class])
    {
      if ([o isConnected])
	{
	  aString = _(@"Connection timed out to the %@ POP3 server.");
	}
      else
	{
	  aString = _(@"Unable to connect to the %@ POP3 server.");
	}

      NSRunAlertPanel(_(@"Error!"), aString, _(@"OK"), NULL, NULL, [(CWService *)o name]);
      [self _taskCompleted: aTask];
      [_storesStorage removeObjectIdenticalTo:o];
      return;
    }
  else if ([o isKindOfClass: CWIMAPStore_class])
    {
      if ([o isConnected])
	{
	  NSRunAlertPanel(_(@"Error!"), _(@"Connection timed out to the %@ IMAP server."), _(@"OK"), NULL, NULL, [(CWService *)o name]);
	  [self stopTasksForService: o];
	  [[MailboxManagerController singleInstance] setStore: nil
						     name: [(CWService *)o name]
						     username: [o username]];
	  [[MailboxManagerController singleInstance] closeWindowsForStore: o];
	}
      else
	{
	  NSRunAlertPanel(_(@"Error!"), _(@"Unable to connect to the %@ IMAP server."), _(@"OK"), NULL, NULL, [(CWService *)o name]);
	  [self _taskCompleted: aTask];
	  
          if (nil != aTask)
            {
	      if (aTask->op == CONNECT_ASYNC)
	        {
	          [[MailboxManagerController singleInstance] setStore: nil  name: [(CWService *)o name]  username: [o username]];
	        }
            }
          else
            {
              NSLog(@"connectionTimedOut and no valid Task");
            }
	}

      [_storesStorage removeObjectIdenticalTo:o];
      return;
    }
  else
    {
      if ([o isConnected])
	{
	  aString = _(@"Connection timed out to the %@ SMTP server.");
	}
      else
	{
	  aString = _(@"Unable to connect to the %@ SMTP server.");
	}

      NSRunAlertPanel(_(@"Error!"), aString, _(@"OK"), NULL, NULL, [(CWService *)o name]);
      [aTask setDate: [AUTORELEASE([[NSDate alloc] init]) addTimeInterval: 300]];
      aTask->is_running = NO;
      [[ConsoleWindowController singleInstance] reload];
      
      [_storesStorage removeObjectIdenticalTo:o];
      return;
    }
}

//
//
//
- (void) folderExpungeCompleted: (NSNotification *) theNotification
{
  id o;

  o = [theNotification object];

  if ([o isKindOfClass: CWIMAPStore_class] || [o isKindOfClass: [CWLocalFolder class]])
    {
      Task *aTask;

      [[[[GNUMail lastMailWindowOnTop] windowController] folder] updateCache];
      [[[GNUMail lastMailWindowOnTop] windowController] tableViewShouldReloadData];
      ADD_CONSOLE_MESSAGE(_(@"Done compacting mailbox %@."), [[[[GNUMail lastMailWindowOnTop] windowController] folder] name]);

      aTask = [self taskForService: o];
      
      if (aTask)
	{
	  [self _taskCompleted: aTask];
	}
    }
  else
    {
      [o close];
    }
}

//
//
//
- (void) folderExpungeFailed: (NSNotification *) theNotification
{
  Task *aTask;
  id o;

  o = [theNotification object];
  aTask = [self taskForService: o];

  NSRunAlertPanel(_(@"Error!"),
		  _(@"Unable to compact mailbox %@."),
		  _(@"OK"),
		  NULL,
		  NULL,
		  [[[theNotification userInfo] objectForKey: @"Folder"] name]);
      
  if (aTask)
    {
      [self _taskCompleted: aTask];
    }
}

//
//
//
- (void) folderPrefetchCompleted: (NSNotification *) theNotification
{
  id o;

  o = [theNotification object];

  if ([o isKindOfClass: CWIMAPStore_class] || [o isKindOfClass: [CWLocalFolder class]])
    {
      NSUserDefaults *theDefaults;
      id aController, aFolder;
      Task *aTask;
      
      aTask = [self taskForService: o];
      
      if (aTask && aTask->op == OPEN_ASYNC)
      	{
	  [self _taskCompleted: aTask];
	}
      
      aFolder = [[theNotification userInfo] objectForKey: @"Folder"];
      
      if ([o isKindOfClass: CWIMAPStore_class])
	{
	  aController = [[Utilities windowForFolderName: nil  store: o] windowController];
	  
	  // If we just opened the IMAP INBOX, filter messages there
#if 0
	  if (aFolder == [o defaultFolder])
	    {
	      [self _filterIMAPMessagesInFolder: [o defaultFolder]];
	    }
#endif
	}
      else
	{
	  aController = [[Utilities windowForFolderName: [o name]  store: [o store]] windowController];
	}
      
      theDefaults = [NSUserDefaults standardUserDefaults];
      
      // NOTE: Hiding messages marked as deleted is the default behavior since 1.1.0pre2.
      if ([theDefaults integerForKey: @"HIDE_DELETED_MESSAGES"  default: NSOnState] == NSOffState)
	{
	  [aFolder setShowDeleted: YES];
	}
      else
	{
	  [aFolder setShowDeleted: NO];
	}
								  
      if ([theDefaults integerForKey: @"HIDE_READ_MESSAGES"  default: NSOffState] == NSOffState)
	{
	  [aFolder setShowRead: YES];
	}
      else
	{
	  [aFolder setShowRead: NO];
	}
    
      if ([theDefaults integerForKey: @"AutomaticallyThreadMessages"  default: NSOffState] == NSOffState)
	{
	  [aFolder unthread];
	}
      else
	{
	  [aFolder thread];
	}
						
      [aController updateDataView];
      [[aController dataView] scrollIfNeeded];

      if ([[aController folder] allContainers])
	{
	  [[aController folder] thread];
	}
    }
  else if ([o isKindOfClass: CWPOP3Store_class])
    {
      CWPOP3Message *aMessage;
      CWPOP3Folder *aFolder;
      NSString *aUID;
      Task *aTask;
      
      int i, count;
 
      aTask = [self taskForService: o];
      aFolder = [o defaultFolder];
      count = [aFolder countVisible];
   
      // We get all messages..
      for (i = 1; i <= count; i++)
	{
	  aMessage = (CWPOP3Message *)[aFolder messageAtIndex: i-1];
	  
	  aUID = [aMessage UID];
	  
	  // Next we verify if we really need to transfer the message
	  if (![(CWPOP3CacheManager *)[aFolder cacheManager] dateForUID: aUID])
	    {
	      // We do...
	      [aMessage rawSource];
	      aTask->total_size += (float)[aMessage size]/(float)1024;
	      aTask->total_count += 1;
	    }
	}

      // If we haven't transferred any messages or if there's none
      // available on the server, we close the connection right away.
      if (aTask->total_count == 0)
	{
	  [o close];
	}
    }
}


//
//
//
- (void) messagePrefetchCompleted: (NSNotification *) theNotification
{
  CWMessage *aMessage;
  Task *aTask;
  id o;

  aMessage = [[theNotification userInfo] objectForKey: @"Message"];
  o = [theNotification object];
  aTask = [self taskForService: o];

  if ([o isKindOfClass: CWPOP3Store_class])
    {
      NSData *aData;
      
      aTask->received_count++;
      aData = [aMessage rawSource];

      [self setMessage: aMessage  forHash: [aData hash]];
      [self _matchFilterRuleFromRawSource: [aMessage rawSource]  task: aTask];

      // If we worked on the last message in the folder, we are ready to close
      // the connection with the POP3 server.
      if ([aMessage messageNumber] == [[aMessage folder] countVisible])
	{
	  [o close];
	}
    }
}

//
//
//
- (void) messageNotSent: (NSNotification *) theNotification
{
  NSString *aString;
  Task *aTask;
  id o;

  o = [theNotification object];
 
  if ([o isKindOfClass: CWSMTP_class])
    {
      aString = [NSString stringWithFormat: _(@"An error occurred while sending the E-Mail. It might be a\nnetwork problem or an error in your sending preferences.\nLast response received from the server:\n\n(%d) %@\n\nTo save this E-Mail in the Drafts folder, open the Console window\nfrom the Windows menu and chose the \"Save in Drafts\" context menu item\non the corresponding row."), [[theNotification object] lastResponseCode], AUTORELEASE([[NSString alloc] initWithData: [[theNotification object] lastResponse] encoding: NSASCIIStringEncoding])];
    }
  else
    {
      aString = _(@"An error occurred while sending the E-Mail. The path to the\nmailer might be incorrect in your sending preferences.");
    }

  NSRunAlertPanel(_(@"Error!"),
		  aString,
		   _(@"OK"),
		  NULL,
		  NULL,
		  NULL);

  // The CWSMTP instance will be removed in -connectionTerminated: 
  // since we are calling close on it.
  aTask = [self taskForService: o];

  // We leave the task in queue.
  [aTask setDate: [AUTORELEASE([[NSDate alloc] init]) addTimeInterval: 300]];
  aTask->is_running = NO;
  [[ConsoleWindowController singleInstance] reload];

  if ([[theNotification object] isKindOfClass: CWSMTP_class])
    {
      [[theNotification object] close];
    }
}


//
//
//
- (void) messageSent: (NSNotification *) theNotification
{
  id<CWTransport> aTransport;
  Task *aTask;

  aTask = [self taskForService: [theNotification object]];

  ADD_CONSOLE_MESSAGE(_(@"SMTP - Sent!"));

  // We now remove the message from our unsent cache since it was
  // definitively delivered
  aTransport = [theNotification object];
  [[MailboxManagerController singleInstance] deleteSentMessageWithID: [[aTransport message] messageID]];
 
  if (aTask->sub_op != GNUMailRedirectMessage)
    {
      FilterManager *aFilterManager;
      CWURLName *theURLName;

      aFilterManager = (FilterManager *)[FilterManager singleInstance];
      
      theURLName = [aFilterManager matchedURLNameFromMessageAsRawSource: [[theNotification object] messageData]
				   type: TYPE_OUTGOING
				   key: [[self taskForService: [theNotification object]] key]
				   filter: nil];
      
      if (theURLName)
	{
	  [[MailboxManagerController singleInstance] addMessage: [[theNotification object] messageData]
						     toFolder: theURLName];
	}

      //
      // If the message sent was a reply to an other message, we add the PantomimeAnswered flag
      // to that original message.
      //
      if (aTask->sub_op == GNUMailReplyToMessage && [aTask unmodifiedMessage] && [[aTask unmodifiedMessage] folder])
	{
	  id aWindow;

	  aWindow = [Utilities windowForFolderName: [[[aTask unmodifiedMessage] folder] name]
			       store: [[[aTask unmodifiedMessage] folder] store]];
	  
	  if (aWindow)
	    {
	      CWFolder *aFolder;
       
	      aFolder = [[aWindow windowController] folder];

	      if ([[aFolder messages] containsObject: [aTask unmodifiedMessage]])
		{
		  CWFlags *theFlags;	
		  theFlags = [[[aTask unmodifiedMessage] flags] copy];
		  [theFlags add: PantomimeAnswered];
		  [[aTask unmodifiedMessage] setFlags: theFlags];
		  RELEASE(theFlags);
		  [[[aWindow windowController] dataView] setNeedsDisplay: YES];
		}
	    }
	}
    }

  if ([[theNotification object] isKindOfClass: CWSMTP_class])
    {
      [[theNotification object] close];
    }

  [self _taskCompleted: aTask];
}


//
//
//
- (void) service: (CWService *) theService 
    receivedData: (NSData *) theData
{
  Task *aTask;

  aTask = [self taskForService: theService];
  
  if (aTask)
    {
      aTask->current_size += (float)([theData length]/(float)1024);
      [[[ConsoleWindowController singleInstance] tasksTableView] setNeedsDisplay: YES];
    }
}


//
//
//
- (void) service: (CWService *) theService
	sentData: (NSData *) theData
{
  Task *aTask;

  aTask = [self taskForService: theService];

  if (aTask)
    {
      aTask->current_size += (float)([theData length]/(float)1024);
      [[[ConsoleWindowController singleInstance] tasksTableView] setNeedsDisplay: YES];
    }
}


//
//
//
- (void) requestCancelled: (NSNotification *) theNotification
{
  Task *aTask;
  id o;

  o = [theNotification object];
  aTask = [self taskForService: o];

  if ([o isKindOfClass: CWSMTP_class])
    {
      [aTask setDate: [AUTORELEASE([[NSDate alloc] init]) addTimeInterval: 300]];
      aTask->is_running = NO;
      aTask->current_size = 0;
    }
  else
    {
      if ([o isKindOfClass: CWIMAPStore_class] && aTask && aTask->op == CONNECT_ASYNC)
	{
	  [[MailboxManagerController singleInstance] setStore: nil  name: [(CWService *)o name]  username: [o username]];
	}

      [self _taskCompleted: aTask];
    }

  [_storesStorage removeObjectIdenticalTo:o];

  [[[ConsoleWindowController singleInstance] tasksTableView] setNeedsDisplay: YES];
}


//
// This method can be invoked if:
//
// 1) a message is copied to a mailbox when being received (like using POP3)
// 2) a message is copied to a mailbox when being DnD by the user
// 3) a message is copied to a mailbox when using "Copy/Cut & Paste"
// 4) a filter?
//
- (void) folderAppendCompleted: (NSNotification *) theNotification
{
  CWFolder *aFolder;
  id o, aWindow, aMessage;
  NSString *aFolderName;
  Task *aTask;

  o = [theNotification object];
  aTask = [self taskForService: o];

  if (aTask)
    {
      aTask->total_count--;
      
      if (aTask->total_count <= 0)
	{
	  [self _taskCompleted: aTask];
	}
    }

  //
  // Over POP3, we must mark messages as deleted if we have
  // successfully appended it to the desired folder.
  //
  aMessage =  NSMapGet(_table, (void *)[[[theNotification userInfo] objectForKey: @"NSData"] hash]);

  if (aMessage)
    {
      if ([aMessage isKindOfClass: [CWPOP3Message class]])
	{
	  // We cache the UID of the message we just got if we have been able to
	  // save the message on disk. If not, we'll leave it on the server.
	  [[[aMessage folder] cacheManager] synchronize];
	  
	  if (![(CWPOP3Folder *)[aMessage folder] leaveOnServer])
	    {
	      [aMessage setFlags: AUTORELEASE([[CWFlags alloc] initWithFlags: PantomimeDeleted])];
	    }
	}
      else if ([[aMessage propertyForKey: MessageOperation] intValue] == MOVE_MESSAGES)
	{
	  CWFlags *theFlags;
	  
	  theFlags = [[aMessage flags] copy];
	  [theFlags add: PantomimeDeleted];
	  [aMessage setFlags: theFlags];
	  RELEASE(theFlags);

	  //
	  // We refresh our _source_ window
	  //
	  aFolder = [aMessage folder];
	  aFolderName = [(CWFolder *)aFolder name];
  
	  aWindow = [Utilities windowForFolderName: aFolderName store: [aFolder store]];
	  [[aWindow delegate] tableViewShouldReloadData];
	  [[aWindow delegate] updateStatusLabel];
	}

      NSMapRemove(_table, (void *)[[[theNotification userInfo] objectForKey: @"NSData"] hash]);
    }
 
  //
  // We now refresh the _destination_ window / node.
  //
  aFolder = [[theNotification userInfo] objectForKey: @"Folder"];
  aFolderName = [(CWFolder *)aFolder name];
  
  aWindow = [Utilities windowForFolderName: aFolderName store: [aFolder store]];

  if (!aWindow)
    {
      //
      // We update the Mailbox Manager cache, IIF the folder wasn't open initially.
      // If it was open, we had its window and we are gonna refresh its cache in
      // -updateStatusLabel.
      //
      NSString *aUsername, *aStoreName;
      MailboxManagerCache *aCache;
      CWFlags *theFlags;

      NSUInteger nbOfMessages, nbOfUnreadMessages;
      
      aCache = [(MailboxManagerController *)[MailboxManagerController singleInstance] cache];
      theFlags = [[theNotification userInfo] objectForKey: @"Flags"];

      if ([o isKindOfClass: CWIMAPStore_class])
	{      
	  //
	  // If we are transferring to an IMAP folder, we must obtain the
	  // current values of the target folder since we haven't SELECT'ed it
	  // (so [aFolder count] and [aFolder numberOfUnreadMessages] return 0.
	  //
	  aStoreName = [(CWIMAPStore *)o name];
	  aUsername = [(CWIMAPStore *)o username];
	  [aCache allValuesForStoreName: aStoreName
		  folderName: [aFolderName stringByReplacingOccurrencesOfCharacter: [(CWIMAPStore *)o folderSeparator]  withCharacter: '/']
		  username: aUsername
		  nbOfMessages: &nbOfMessages
		  nbOfUnreadMessages: &nbOfUnreadMessages];
	  
	  if (theFlags && ![theFlags contain: PantomimeSeen]) nbOfUnreadMessages += 1;
	  nbOfMessages += 1;
	}
      else
	{
	  aStoreName = @"GNUMAIL_LOCAL_STORE";
	  aUsername = NSUserName();
	  nbOfMessages = [(CWLocalFolder*)aFolder countVisible];
	  nbOfUnreadMessages = [aFolder numberOfUnreadMessages];
	}      

      [aCache setAllValuesForStoreName: aStoreName
	      folderName: [aFolderName stringByReplacingOccurrencesOfCharacter: [(id<CWStore>)[aFolder store] folderSeparator]  withCharacter: '/']
	      username: aUsername
	      nbOfMessages: nbOfMessages
	      nbOfUnreadMessages: nbOfUnreadMessages];
      
      [[MailboxManagerController singleInstance] updateOutlineViewForFolder: aFolderName
						 store: aStoreName
						 username: aUsername
						 controller: nil];
    }
  else
    {
      [[aWindow delegate] tableViewShouldReloadData];
      [[aWindow delegate] updateStatusLabel];
    }
}


//
// This method can be invoked if:
//
// 1) the harddisk is full and we weren't able to write the message
// 2) the permissions on the mailbox (or it's parent) don't permit us to write
// 3) we tried to copy/move a message to a non-selectable mailbox
// 4) the message contains NUL characters and we are appending to a Cyrus
//    IMAP Server mailbox. This should NEVER happens unless it's a bug.
//
- (void) folderAppendFailed: (NSNotification *) theNotification
{
  Task *aTask;
  id o;

  NSMutableData *aMutableData;

  aMutableData = [[NSMutableData alloc] initWithData: [[theNotification userInfo] objectForKey: @"NSData"]];

  // We remove it from our table, in case we received it from a POP3 server.
  NSMapRemove(_table, (void *)[[[theNotification userInfo] objectForKey: @"NSData"] hash]);

  // We replace all CRLF by LF because if we were dealing with an IMAP message,
  // the raw source has CRLF instead of LF as line separators.
  [aMutableData replaceCRLFWithLF];

  [[MailboxManagerController singleInstance] panic: aMutableData  folder: [[[theNotification userInfo] objectForKey: @"Folder"] name]];
  RELEASE(aMutableData);

  o = [theNotification object];
  aTask = [self taskForService: o];

  if (aTask)
    {
      aTask->total_count--;
      
      if (aTask->total_count <= 0)
	{
	  [self _taskCompleted: aTask];
	}
    }
}


//
//
//
- (void) folderListCompleted: (NSNotification *) theNotification
{
  Task *aTask;
  id o;
  
  o = [theNotification object];
  aTask = [self taskForService: o];
  
  if (aTask && aTask->op != CONNECT_ASYNC)
    {
      NSArray *subscribedFolders;
      
      subscribedFolders = [NSArray arrayWithArray: [[[theNotification userInfo] objectForKey: @"NSEnumerator"] allObjects]];
      aTask->total_count = [subscribedFolders count];
      [o folderStatus: subscribedFolders];
      [o close];
    }
  else
    {
      [[MailboxManagerController singleInstance] reloadFoldersForStore: o
						 folders: [[theNotification userInfo] objectForKey: @"NSEnumerator"]];
      
      // If we completed opening an IMAP connection and got the full list of mailboxes...
      if (aTask && aTask->op == CONNECT_ASYNC)
      	{
	  [self _taskCompleted: aTask];
      	}

      // It's important to call this after the NSMapRemove(_table, o); Otherwise, we'll end up having to replace
      // our entry in our map table when calling -open and we would immediately remove the Task right after.
      [Utilities restoreOpenFoldersForStore: o];
    }
}

//
//
//
- (void) folderListSubscribedCompleted: (NSNotification *) theNotification
{
  [self folderListCompleted: theNotification];
}

//
//
//
- (void) folderSearchCompleted: (NSNotification *) theNotification
{
  Task *aTask;
  id o;
  
  o = [theNotification object];
  aTask = [self taskForService: o];
  
  [self _taskCompleted: aTask];
  
  [[FindWindowController singleInstance] setSearchResults: [[theNotification userInfo] objectForKey: @"Results"] 
					 forFolder: (CWFolder *)[[theNotification userInfo] objectForKey: @"Folder"]];
}

//
//
//
- (void) folderSearchFailed: (NSNotification *) theNotification
{
  [[FindWindowController singleInstance] setSearchResults: nil  forFolder: nil];
}


//
//
//
- (void) folderStatusCompleted: (NSNotification *) theNotification
{
  CWFolderInformation *aFolderInformation;
  NSDictionary *aDictionary;
  NSString *aFolderName;
  
  Task *aTask;
  id o;
  
  o = [theNotification object];
  aTask = [self taskForService: o];

  aTask->received_count += 1;

  aFolderInformation = [[theNotification userInfo] objectForKey: @"FolderInformation"];
  aFolderName = [[theNotification userInfo] objectForKey: @"FolderName"];

  [aTask setSubtitle: aFolderName];
  aDictionary = [NSDictionary dictionaryWithObjectsAndKeys: aFolderInformation, @"FOLDER_INFORMATION",
			      aFolderName, @"FOLDER_NAME",
			      [(CWService *)o name], @"STORE_NAME",
			      [o username], @"USERNAME", 
			      [NSString stringWithFormat: @"%c", [o folderSeparator]], @"FOLDER_SEPARATOR", nil];
  
  [[MailboxManagerController singleInstance] updateFolderInformation: aDictionary];
}


//
//
//
- (void) folderOpenCompleted: (NSNotification *) theNotification
{
  id aFolder;

  aFolder = [[theNotification userInfo] objectForKey: @"Folder"];
  [aFolder prefetch];
}


//
//
//
- (void) folderOpenFailed: (NSNotification *) theNotification
{
  NSArray *allWindows;
  id aFolder, aWindow;
  int i;

  aFolder = [[theNotification userInfo] objectForKey: @"Folder"];
  allWindows = [GNUMail allMailWindows];
  
  for (i = 0; i < [allWindows count]; i++)
    {
      aWindow = [allWindows objectAtIndex: i];
      if ([(MailWindowController *)[aWindow windowController] folder] == aFolder)
	{
	  Task *aTask;

	  NSRunAlertPanel(_(@"Error!"),
			  _(@"Unable to open mailbox %@ on %@."),
			  _(@"OK"),
			  NULL,
			  NULL,
			  [(CWFolder *)aFolder name],
			  [(CWService *)[theNotification object] name]);
	  [(MailWindowController *)[aWindow windowController] setFolder: nil];

	  aTask = [self taskForService: [theNotification object]];
	  
	  if (aTask && aTask->op == OPEN_ASYNC)
	    {
	      [self _taskCompleted: aTask];
	    }
	  break;
	}
    }
}


//
//
//
- (void) messagesCopyCompleted: (NSNotification *) theNotification
{
  NSArray *theMessages;

  NSUInteger nbOfTransferredMessages;

  theMessages = [[theNotification userInfo] objectForKey: @"Messages"];
  nbOfTransferredMessages = [theMessages count];
  
  //
  // We now update our MailboxManagerController cache. Since the operation
  // was server-side, we must obtain the current values in the cache and
  // increment them according to what has been transferred.
  //
  if (nbOfTransferredMessages > 0)
    {
      CWIMAPStore *theStore;
      NSString *aFolderName;

      NSUInteger nbOfMessages, nbOfUnreadMessages, nbOfUnreadTransferredMessages, i;

      aFolderName = [[theNotification userInfo] objectForKey: @"Name"];
      nbOfUnreadTransferredMessages = 0;
      theStore = [theNotification object];

      for (i = 0; i <nbOfTransferredMessages ; i++)
	{
	  if (![[[theMessages objectAtIndex: i] flags] contain: PantomimeSeen]) nbOfUnreadTransferredMessages += 1;
	}
      
      [[[MailboxManagerController singleInstance] cache] allValuesForStoreName: [theStore name]
							 folderName: [aFolderName
								       stringByReplacingOccurrencesOfCharacter: [theStore folderSeparator]
								       withCharacter: '/']
							 username: [theStore username]
							 nbOfMessages: &nbOfMessages
							 nbOfUnreadMessages: &nbOfUnreadMessages];
      
      nbOfUnreadMessages += nbOfUnreadTransferredMessages;
      nbOfMessages += nbOfTransferredMessages;
      
      [[[MailboxManagerController singleInstance] cache]  setAllValuesForStoreName: [theStore name]
							  folderName: [aFolderName
									stringByReplacingOccurrencesOfCharacter: [theStore folderSeparator]
									withCharacter: '/']
							  username: [theStore username]
							  nbOfMessages: nbOfMessages
							  nbOfUnreadMessages: nbOfUnreadMessages];

      [[MailboxManagerController singleInstance] updateOutlineViewForFolder: aFolderName
						 store: [theStore name]
						 username: [theStore username]
						 controller: nil];
    }
}


//
//
//
- (void) messagesCopyFailed: (NSNotification *) theNotification
{
  NSRunAlertPanel(_(@"Error!"),
		  _(@"An error occurred while trying to copy messages to the \"%@\" mailbox."),
		  _(@"OK"),
		  NULL,
		  NULL,
		  [[theNotification userInfo] objectForKey: @"Name"]);
}


//
//
//
- (void) messageFetchCompleted: (NSNotification *) theNotification
{
  CWMessage *aMessage;
  Task *aTask;
  id o;

  aMessage = [[theNotification userInfo] objectForKey: @"Message"];
  o = [theNotification object];

  if (![o isKindOfClass: [CWIMAPStore class]])
    {
      return;
    }

  aTask = [self taskForService: o];

  if ([aMessage propertyForKey: MessageLoading])
    {
      if ([aMessage propertyForKey: MessageDestinationChangeEncoding])
	{
	  CWMessage *messageUsingTextEncoding;
	  MailWindowController *aController;
	  NSAutoreleasePool *pool;		  
	  int i;

	  pool = [[NSAutoreleasePool alloc] init];
	 
	  messageUsingTextEncoding = [[CWMessage alloc] initWithData: [aMessage rawSource]  charset: [aMessage defaultCharset]];
	  [aMessage setHeaders: [messageUsingTextEncoding allHeaders]];

	  for (i = 0; i < [[aTask allControllers] count]; i++)
	    {
	      aController = [[aTask allControllers] objectAtIndex: i];

	      if ([aController selectedMessage] == aMessage)
		{
		  // We show the new message
		  [Utilities showMessage: messageUsingTextEncoding
			     target: [aController textView]
			     showAllHeaders: [aController showAllHeaders]];
		  
		}

	      // We refresh the table row. Needed if the headers have changed.
	      [[aController dataView] setNeedsDisplayInRect: [[aController dataView] rectOfRow: [[aController dataView] selectedRow]]];
	    }
  
	  [aMessage setProperty: nil  forKey: MessageDestinationChangeEncoding];

	  RELEASE(messageUsingTextEncoding);
	  RELEASE(pool);
	}
      else if ([aMessage propertyForKey: MessageDestinationPasteboard])
	{
	  [[NSPasteboard generalPasteboard] addMessage: aMessage];
	  
	  // We release our propertie
	  [aMessage setProperty: nil  forKey: MessageDestinationPasteboard];
	}
      else if ([aMessage propertyForKey: MessageDestinationStore])
	{
	  // We must transfer the message since it has been fully loaded
	  [[MailboxManagerController singleInstance] transferMessages: [NSArray arrayWithObject: aMessage]
						     fromStore: [[aMessage folder] store]
						     fromFolder: [aMessage folder]
						     toStore: [aMessage propertyForKey: MessageDestinationStore]
						     toFolder: [aMessage propertyForKey: MessageDestinationFolder]
						     operation: [[aMessage propertyForKey: MessageOperation] intValue]];
	  
	  // We release our properties
	  [aMessage setProperty: nil  forKey: MessageDestinationFolder];
	  [aMessage setProperty: nil  forKey: MessageDestinationStore];
	  [aMessage setProperty: nil  forKey: MessageOperation];
	}
      else if ([aMessage propertyForKey: MessageViewing])
	{
	  id aController;
	  int i;
	  
	  for (i = 0; i < [[aTask allControllers] count]; i++)
	    {
	      aController = [[aTask allControllers] objectAtIndex: i];

	      if ([aController selectedMessage] == aMessage)
		{
		  [Utilities showMessageRawSource: aMessage  target: [aController textView]];
		}
	    }

	  [aMessage setProperty: nil  forKey: MessageViewing];
	}
      
      [aMessage setProperty: nil  forKey: MessageLoading];

      if ([[aTask message] isKindOfClass: [NSArray class]] &&
	  [[aTask message] containsObject: aMessage])
	{
	  aTask->total_count--;
	}

      if (aTask && aTask->total_count == 0)
	{
	  [self _taskCompleted: aTask];
	}
    }
  else if ([aMessage propertyForKey: MessageRedirecting])
    {
      int i;

      for (i = 0; i < [[aTask allControllers] count]; i++)
	{
	  [(EditWindowController *)[[aTask allControllers] objectAtIndex: i] setMessage: aMessage];
	}

      [aMessage setProperty: nil  forKey: MessageRedirecting];

      [self _taskCompleted: aTask];
    }
}


//
//
//
- (void) commandCompleted: (NSNotification *) theNotification
{
  id o;

  o = [theNotification object];

  if ([o lastCommand] == IMAP_UID_FETCH_BODY_TEXT)
    {
      CWMessage *aMessage;
      Task *aTask;

      aMessage = [[theNotification userInfo] objectForKey: @"Message"];
      aTask = [self taskForService: o  message: aMessage];

      if ([aMessage propertyForKey: MessagePreloading])
	{
	  id aController;
	  int i;
	  
	  for (i = 0; i < [[aTask allControllers] count]; i++)
	    {
	      aController = [[aTask allControllers] objectAtIndex: i];
	      
	      if ([aController selectedMessage] == aMessage)
		{
		  [Utilities showMessage: aMessage
			     target: [aController textView]
			     showAllHeaders: [aController showAllHeaders]];
		}
	    }
	  
	  [aMessage setProperty: nil  forKey: MessagePreloading];
	}

      [self _taskCompleted: aTask];
    }
}

//
//
//
- (void) commandSent: (NSNotification *) theNotification
{
  // Do nothing for now.
}

//
// Class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[TaskManager alloc] init];
    }

  return singleInstance;
}

@end



//
// TaskManager private interface
//
@implementation TaskManager (Private)

//
// This will only be invoked for IMAP stores.
// See Task.h -> SAVE_ASYNC, LOAD_ASYNC, CONNET_ASYNC, SEARCH_ASYNC and others.
//
- (void) _asyncOperationForTask: (Task *) theTask
{
  NSDictionary *allValues;
  CWService *aService;

  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] objectForKey: [theTask key]] objectForKey: @"RECEIVE"];
  aService = [[MailboxManagerController singleInstance] storeForName: [allValues objectForKey: @"SERVERNAME"]
							username: [allValues objectForKey: @"USERNAME"]];

  theTask->service = aService;
}

//
//
//
- (void) _executeActionUsingFilter: (Filter *) theFilter
                           message: (NSData *) theMessage
                              task: (Task *) theTask
{
  switch ([theFilter actionEMailOperation])
    {
    case BOUNCE:
    case FORWARD:
    case REPLY:
      NSLog(@"Unimplemented action - ignoring.");
      break;

    default:
      NSLog(@"Unknown action - ignoring.");
    }
}


//
//
//
- (BOOL) _matchFilterRuleFromRawSource: (NSData *) theRawSource
				  task: (Task *) theTask
{
  FilterManager *aFilterManager;
  NSString *aFolderName;
  CWURLName *theURLName;
  Filter *aFilter;
  
  aFilterManager = (FilterManager *)[FilterManager singleInstance];
  aFilter = [aFilterManager matchedFilterForMessageAsRawSource: theRawSource  type: TYPE_INCOMING];
  aFolderName = nil;

  if (aFilter && [aFilter action] == BOUNCE_OR_FORWARD_OR_REPLY)
    {
      [self _executeActionUsingFilter: aFilter
	    message: theRawSource
	    task: theTask];
    }
  else if (aFilter && [aFilter action] == PLAY_SOUND)
    {
      if ([[NSFileManager defaultManager] fileExistsAtPath: [aFilter pathToSound]])
	{
	  NSSound *aSound;
	  
	  aSound = [[NSSound alloc] initWithContentsOfFile: [aFilter pathToSound]  byReference: YES];
	  [aSound play];
	  RELEASE(aSound);
	}
    }
  
  // Even if we bounced (or forward or replied to the) message, or played a sound
  // when receiving it, we append it to our folder.
  theURLName = [aFilterManager matchedURLNameFromMessageAsRawSource: theRawSource
			       type: TYPE_INCOMING
			       key: [theTask key]
			       filter: aFilter];
  
  if (theTask->origin == ORIGIN_USER)
    { 
      // We verify if our task owner is a MailWindowController. If it's the case,
      // we must check if we really need to add the the folder to our list of
      // filtered message folders.
      if ([theTask owner] && 
	  [[theTask owner] respondsToSelector: @selector(dataView)] &&
	  [Utilities URLWithString: [theURLName stringValue]
		     matchFolder: [[theTask owner] folder]])
	{
	  // Same folder, we skip it.
	  goto done;
	}
      
      if ([[theURLName protocol] caseInsensitiveCompare: @"LOCAL"] == NSOrderedSame)
	{
	  aFolderName = [NSString stringWithFormat: _(@"Local - %@"), [theURLName foldername]];
	}
      else
	{
	  aFolderName = [NSString stringWithFormat: _(@"IMAP %@@%@ - %@"), [theURLName username],
				  [theURLName host], [theURLName foldername]];
	}
    }
  
 done:
  [[MailboxManagerController singleInstance] addMessage: theRawSource  toFolder: theURLName];

  if (aFolderName)
    {
      theTask->filtered_count++;
      
      if (![[theTask filteredMessagesFolders] containsObject: aFolderName])
	{
	  [[theTask filteredMessagesFolders] addObject: aFolderName];
	}
    }

  return YES;
}


//
// See if an IMAP message matches a filter rule. But be careful at this
// point: we only want to check filters that just read the headers. It
// would be a pain to have to download every message just to check if it
// matched a filter
//
#if 0
- (BOOL) _filterIMAPMessagesInFolder: (CWIMAPFolder *) theFolder
{
  int j, count, filtered;
  NSArray *allMessages;
  FilterManager *aFilterManager;
  aFilterManager = (FilterManager *)[FilterManager singleInstance];
  if (theFolder == nil)
    return NO;
  
  /* Make extra sure we're only checking the INBOX */
  if (![theFolder isKindOfClass: [CWIMAPFolder class]] 
      || [[theFolder store] defaultFolder] != theFolder)
    return NO;
  
  allMessages = [theFolder allMessages];
  count = [allMessages count];
  filtered = 0;
  for (j = count-1; j >=0; j--)
    {
      Filter *aFilter;
      CWMessage *aMessage;
      aMessage = [allMessages objectAtIndex: j];
      
      if ([[aMessage flags] contain: PantomimeSeen])
	continue;
      
      aFilter = [aFilterManager matchedFilterForMessage: aMessage  
						   type: TYPE_INCOMING_QUICK];

      if (aFilter == nil)
	continue;
      
      filtered++;
      if ([aFilter action] == BOUNCE_OR_FORWARD_OR_REPLY)
	{
	  /* Not implemented */
	}
      else if ([aFilter action] == PLAY_SOUND)
	{
	  if ([[NSFileManager defaultManager] fileExistsAtPath: [aFilter pathToSound]])
	    {
	      NSSound *aSound;
	      
	      aSound = [[NSSound alloc] initWithContentsOfFile: [aFilter pathToSound]  byReference: YES];
	      [aSound play];
	      RELEASE(aSound);
	    }
	}
      else if ([aFilter action] == TRANSFER_TO_FOLDER || [aFilter action] == DELETE)
	{
	  CWFolder *aDestinationFolder;
	  CWURLName *theURLName;
	  
	  if ([aFilter action] == DELETE)
	    {
	      NSString *aString;
	      
	      aString = [Utilities accountNameForMessage: aMessage];
	      theURLName = [[CWURLName alloc] initWithString: [[[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] objectForKey: aString] 
						    objectForKey: @"MAILBOXES"] objectForKey: @"TRASHFOLDERNAME"]
						    path: [[NSUserDefaults standardUserDefaults] 
						   objectForKey: @"LOCALMAILDIR"]];
	    }
	  else
	    {
	      theURLName = [[CWURLName alloc] initWithString: [aFilter actionFolderName]
							path: [[NSUserDefaults standardUserDefaults] 
								objectForKey: @"LOCALMAILDIR"]];
	    }
	  
	  AUTORELEASE(theURLName);
	  
	  aDestinationFolder = [[MailboxManagerController singleInstance] folderForURLName: theURLName];
	  
	  if (!aDestinationFolder)
	    {
	      return NO;
	    }
	  
	  [aDestinationFolder setProperty: [NSDate date]  forKey: FolderExpireDate];
	  
	  [[MailboxManagerController singleInstance] transferMessages: [NSArray arrayWithObject: aMessage]
							fromStore: [[aMessage folder] store]
						       fromFolder: [aMessage folder]
							  toStore: [aDestinationFolder store]
							 toFolder: aDestinationFolder
							operation: MOVE_MESSAGES];
	}      
    }
  
  if (filtered) ADD_CONSOLE_MESSAGE(_(@"IMAP - filtered %d messages"), filtered);
  
  return YES;
}
#endif


//
// We must get all body parts (download using body.peek[x]<from.increment>)
//
- (void) _receiveUsingIMAPForTask: (Task *) theTask
{
  NSDictionary *allValues;
  CWIMAPStore *aStore;
  
  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		 objectForKey: [theTask key]] objectForKey: @"RECEIVE"];
  
  aStore = [[CWIMAPStore alloc] initWithName: [allValues objectForKey: @"SERVERNAME"]
				port: [[allValues objectForKey: @"PORT"] intValue]];
  [aStore addRunLoopMode: NSEventTrackingRunLoopMode];
  [aStore addRunLoopMode: NSModalPanelRunLoopMode];
  [aStore setUsername: [allValues objectForKey: @"USERNAME"]];

  theTask->service = aStore;
  [aStore setDelegate: self];
  [aStore connectInBackgroundAndNotify];
  [_storesStorage addObject: aStore];
  [aStore release];
}


//
//
//
- (void) _receiveUsingPOP3ForTask: (Task *) theTask
{
  NSDictionary *allValues;
  CWPOP3Store *aStore;

  // We get the values associated with the key
  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		 objectForKey: [theTask key]] objectForKey: @"RECEIVE"];

  aStore = [[CWPOP3Store alloc] initWithName: [allValues objectForKey: @"SERVERNAME"]
				port: [[allValues objectForKey: @"PORT"] intValue]];
  [aStore addRunLoopMode: NSEventTrackingRunLoopMode];
  [aStore addRunLoopMode: NSModalPanelRunLoopMode];
  [aStore setUsername: [allValues objectForKey: @"USERNAME"]]; 

  theTask->service = aStore;
  [aStore setDelegate: self];

  // We set some attributes to the POP3Folder
  [[aStore defaultFolder] setLeaveOnServer: ([[allValues objectForKey: @"LEAVEONSERVER"] intValue] == NSOnState ? YES : NO)];
  [[aStore defaultFolder] setRetainPeriod: [[allValues objectForKey: @"RETAINPERIOD"] intValue]];
  [aStore connectInBackgroundAndNotify];
}


//
//
//
- (void) _receiveUsingUNIXForTask: (Task *) theTask
{
  CWLocalFolder *aMailSpoolFile;
  NSDictionary *allValues;
  NSAutoreleasePool *pool;
  NSArray *allMessages;
  int i;

  // We get our values associated with the key
  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		 objectForKey: [theTask key]] objectForKey: @"RECEIVE"];

  aMailSpoolFile = [[CWLocalFolder alloc] initWithPath: [allValues objectForKey: @"MAILSPOOLFILE"]];
  [aMailSpoolFile setType: PantomimeFormatMailSpoolFile];
  
  if (!aMailSpoolFile)
    {
      NSRunAlertPanel(_(@"Error!"),
		      _(@"Unable to open or lock the %@ spool file."),
		      _(@"OK"),
		      NULL,
		      NULL,
		      [allValues objectForKey: @"MAILSPOOLFILE"]);
      [self _taskCompleted: theTask];
      return;
    }

  allMessages = [aMailSpoolFile messagesFromMailSpoolFile];
  pool = nil;
  
  for (i = 0; i < [allMessages count]; i++)
    {
      if ( (i % 3) == 0 )
	{
	  TEST_RELEASE(pool);
	  pool = [[NSAutoreleasePool alloc] init];
	}
      
      [self _matchFilterRuleFromRawSource: [allMessages objectAtIndex: i]  task: theTask];
    }
  
  TEST_RELEASE(pool);

  [aMailSpoolFile close];
  RELEASE(aMailSpoolFile);

  [self _taskCompleted: theTask];
}

//
//
//
- (void) _sendUsingSendmailForTask: (Task *) theTask
{
  NSDictionary *allValues;
  CWSendmail *aSendmail;

  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		 objectForKey: [theTask sendingKey]] objectForKey: @"SEND"];
  
  aSendmail = [[CWSendmail alloc] initWithPath: [allValues objectForKey: @"MAILER_PATH"]]; 
  
  theTask->service = aSendmail;
  
  [aSendmail setDelegate: self];
  
  if ([[theTask message] isKindOfClass: [NSData class]])
    {
      [aSendmail setMessageData: [theTask message]];
    }
  else
    {
      [aSendmail setMessage: [theTask message]];
    }

  [aSendmail sendMessage];
}


//
//
//
- (void) _sendUsingSMTPForTask: (Task *) theTask
{
  NSDictionary *allValues;
  NSNumber *portValue;
  CWSMTP *aSMTP;

  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		 objectForKey: [theTask sendingKey]] objectForKey: @"SEND"];

  portValue = [allValues objectForKey: @"SMTP_PORT"];
  
  if (!portValue)
    {
      portValue = [NSNumber numberWithInt: 25];
    }

  aSMTP = [[CWSMTP alloc] initWithName: [allValues objectForKey: @"SMTP_HOST"]
			  port: [portValue intValue]];
  [aSMTP addRunLoopMode: NSEventTrackingRunLoopMode];
  [aSMTP addRunLoopMode: NSModalPanelRunLoopMode];
  
  theTask->service = aSMTP;
  
  [aSMTP setDelegate: self];

  if ([[theTask message] isKindOfClass: [NSData class]])
    {
      [aSMTP setMessageData: [theTask message]];
    }
  else
    {
      [aSMTP setMessage: [theTask message]];
    }

  // We save the unsent message in case something really bad happens when
  // trying to connect to the server and the application crashes
#warning make this work for redirected messages
  if (![[theTask message] isKindOfClass: [NSData class]])
    {
      [[MailboxManagerController singleInstance] saveUnsentMessage: [aSMTP messageData] ? [aSMTP messageData] : [[aSMTP message] dataValue]
						 withID: [[theTask message] messageID]];
    }

  ADD_CONSOLE_MESSAGE(_(@"SMTP - connecting to %@..."), [allValues objectForKey: @"SMTP_HOST"]);
  [aSMTP connectInBackgroundAndNotify];
}


//
//
//
- (void) _taskCompleted: (Task *) theTask
{
  int i;

  if (theTask)
    {
      // If it was a RECEIVE task and we transferred messages to other mailboxes,
      // we warn the user about this.
      if (theTask->op == RECEIVE_POP3 || theTask->op == RECEIVE_UNIX)
	{
	  if (theTask->received_count > 0 &&
	      (theTask->origin == ORIGIN_STARTUP || theTask->origin == ORIGIN_TIMER))
	    {
	      // We verify if we must play a sound. If the sound isn't found, we simply use NSBeep()
	      if ([[NSUserDefaults standardUserDefaults] boolForKey: @"PLAY_SOUND"])
		{
		  NSString *aString;

		  aString = [[NSUserDefaults standardUserDefaults] stringForKey: @"PATH_TO_SOUND"];
		  if ([[NSFileManager defaultManager] fileExistsAtPath: aString])
		    {
		      NSSound *aSound;
		      
		      aSound = [[NSSound alloc] initWithContentsOfFile: aString  byReference: YES];
		      [aSound play];
		      RELEASE(aSound);
		    }
		  else
		    {
		      NSBeep();
		    }
		}
	    }
	  
	  if ([[theTask filteredMessagesFolders] count] > 0)
	    {
	      if ([[NSUserDefaults standardUserDefaults] boolForKey: @"SHOW_FILTER_PANEL"])
		{
		  NSRunInformationalAlertPanel(_(@"Filtered messages..."),
					       _(@"%d messages have been transferred to the following folders:\n%@"),
					       _(@"OK"),
					       NULL,
					       NULL,
					       theTask->filtered_count,
					       [[theTask filteredMessagesFolders] componentsJoinedByString: @"\n"]);
		}

	      if ([[NSUserDefaults standardUserDefaults] boolForKey: @"OPEN_MAILBOX_AFTER_TRANSFER"])
		{
		  NSString *aString, *aStoreName, *aFolderName;
		  CWURLName *theURLName;
		  NSRange aRange;
 
		  for (i = 0; i < [[theTask filteredMessagesFolders] count]; i++)
		    {
		      aString = [[theTask filteredMessagesFolders] objectAtIndex: i];
		      aRange = [aString rangeOfString: @" - "];
		      
		      aFolderName = [aString substringFromIndex: NSMaxRange(aRange)];
		      aStoreName = [aString substringToIndex: aRange.location];

		      if ([aStoreName isEqualToString: _(@"Local")])
			{
			  NSString *thePathToLocalMailDir;

			  thePathToLocalMailDir = [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"];
			  theURLName = [[CWURLName alloc] initWithString: [NSString stringWithFormat: @"local://%@/%@", 
										    thePathToLocalMailDir, aFolderName]
							  path: thePathToLocalMailDir];
			  
			}
		      else
			{
			  // We skip the "IMAP " part
			  aRange = [aStoreName rangeOfString: _(@"IMAP ")];
			  aStoreName = [aStoreName substringFromIndex: NSMaxRange(aRange)];
			  theURLName = [[CWURLName alloc] initWithString: [NSString stringWithFormat: @"imap://%@/%@",
										    aStoreName, aFolderName]];
			}
		      
		      // We finally opens the folder and release our URLName object.
		      [[MailboxManagerController singleInstance] openFolderWithURLName: theURLName
								 sender: [NSApp delegate]];
		      RELEASE(theURLName);
		    }    
		}
	    }
	}

      [self removeTask: theTask];
    }

  // We check to see if there's any more task that needs to be fired
  [self nextTask];
}


//
// This method checks for new mail on the specified account name. 
//
// If the account type is POP3 or UNIX, this method adds a new task to 
// immediately check for new mails on this account.
//
// If the account type is IMAP, it NOOPs the folder or the store if
// and only if it is open.
//
- (void) _checkMailForAccount: (NSString *) theAccountName
		       origin: (int) theOrigin
			owner: (id) theOwner
{
  NSDictionary *allValues;
  Task *aTask;
  
  int op, subOp;
 
  // If the account is disabled or is set to never check mail we do nothing.
  if (![[[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] objectForKey: theAccountName]
	  objectForKey: @"ENABLED"] boolValue] ||
      [[[[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] objectForKey: theAccountName]
	  objectForKey: @"RECEIVE"] objectForKey: @"RETRIEVEMETHOD"] intValue] == NEVER)
    {
      return;
    }

  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		 objectForKey: theAccountName] objectForKey: @"RECEIVE"];
  subOp = 0;
  
  if (![allValues objectForKey: @"SERVERTYPE"] || [[allValues objectForKey: @"SERVERTYPE"] intValue] == POP3)
    {
      op = RECEIVE_POP3;
    }
  else if ([[allValues objectForKey: @"SERVERTYPE"] intValue] == IMAP)
    {
      CWIMAPStore *aStore;
      
      aStore = [[MailboxManagerController singleInstance] storeForName: [allValues objectForKey: @"SERVERNAME"]
							  username: [allValues objectForKey: @"USERNAME"]];
      
      // We noop the store, if one is initialized.
      if (aStore && [aStore isConnected])
	{  
	  ADD_CONSOLE_MESSAGE(_(@"NOOPing IMAP server %@."), [aStore name]);
	  [aStore noop];
	}
      else
	{
	  // The IMAP store is closed, no need to check for new mail on that one.
	  NSDebugLog(@"Skipping mail check for account %@", theAccountName);
	  return;
	}
      
      op = RECEIVE_IMAP;
      subOp = IMAP_STATUS;
    }
  else
    {
      op = RECEIVE_UNIX;
    }
  
  aTask = [[Task alloc] init];
  aTask->op = op;
  aTask->sub_op = subOp;
  [aTask setMessage: nil];
  [aTask setKey: theAccountName];
  aTask->immediate = YES;
  aTask->origin = theOrigin;
  [aTask setOwner: theOwner];
  [self addTask: aTask];
  RELEASE(aTask);
}


//
//
//
- (void) _tick
{
  _counter += 5;
  
  // Every single minute, we invoke _tick_internal:
  if (_counter%12 == 0)
    {
      [self _tick_internal];
    }
}


//
//
//
- (void) _tick_internal
{
  NSEnumerator *theEnumerator, *foldersEnumerator;
  id aController, aStore, aFolder;
  NSMutableArray *allFolders;
  NSArray *allWindows;

  NSDictionary *allValues;
  NSString *aKey;
  
  aController = [GNUMail lastMailWindowOnTop];

  if (aController)
    {
      aController = [[GNUMail lastMailWindowOnTop] windowController];

      if ([aController isKindOfClass: [MessageViewWindowController class]])
	{
	  aController = [(MessageViewWindowController *)aController mailWindowController];
	}
    }
 
  theEnumerator = [[Utilities allEnabledAccounts] keyEnumerator];

  while ((aKey = [theEnumerator nextObject]))
    {     
      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		     objectForKey: aKey] objectForKey: @"RECEIVE"];
      
      // If we check for new mails from this account automatically AND
      // If our counter modulo the retreive interval is zero, we check for new mails.
      if ([[allValues objectForKey: @"RETRIEVEMETHOD"] intValue] == AUTOMATICALLY &&
	  ((_counter/60) % [[allValues objectForKey: @"RETRIEVEMINUTES"] intValue]) == 0)
	{
	  [self _checkMailForAccount: aKey
		origin: ORIGIN_TIMER
		owner: aController];
	}
    }

  allFolders = [[NSMutableArray alloc] init];

  //
  // We now loop in all opened MailWindow:s and all messages of them to verify if we got
  // any messages that are expired, and not selected.   
  //
  allWindows = [GNUMail allMailWindows];
  
  if (allWindows)
    {
      NSArray *allMessages;
      CWFolder *aFolder;

      NSCalendarDate *date;
      NSDate *aDate;

      id aWindow, aMessage, aSelectedMessage;
      NSUInteger i, j, count;
      NSInteger seconds;
      
      date = (NSCalendarDate *)[NSCalendarDate calendarDate];

      for (i = 0; i < [allWindows count]; i++)
	{
	  aWindow = [allWindows objectAtIndex: i];
	  aFolder = [(MailWindowController *)[aWindow windowController] folder];

	  // If the window has no selected folder, skip it.
	  if (!aFolder) continue;
	    
	  [allFolders addObject: aFolder];

	  aSelectedMessage = [(MailWindowController *)[aWindow windowController] selectedMessage];

	  allMessages = [aFolder visibleMessages];
	  count = [aFolder countVisible];
	  
	  for (j = 0; j < count; j++)
	    {
	      aMessage = [allMessages objectAtIndex: j];
	      
	      // If this message is selected, skip it
	      if (aMessage == aSelectedMessage)
		{
		  continue;
		}

	      aDate = [aMessage propertyForKey: MessageExpireDate];
	      
	      // If this property doesn't exist, that means it was never initialzed, so skip it
	      if (!aDate) 
		{
		  continue;
		}
	      
	      [date years: NULL
		    months: NULL
		    days: NULL
		    hours: NULL
		    minutes: NULL
		    seconds: &seconds
		    sinceDate: (NSCalendarDate *)aDate];
	      
	      // If the message has expired, we release its content and we set it as uninitialzed
	      if (seconds > RETAIN_PERIOD)
		{
		  [aMessage setInitialized: NO];
		  [aMessage setRawSource: nil];
		  [(CWMessage *)aMessage setProperty: nil  forKey: MessageExpireDate];
		}
	    }
	}
#if 0
      /* Filter IMAP messages */
      [self _filterIMAPMessagesInFolder: aFolder];
#endif
    }

  //
  // We verify if we must expire (ie., close) some folders that were likely left into
  // an open state after a DnD operation.
  //
  theEnumerator = [[[MailboxManagerController singleInstance] allStores] objectEnumerator];

  while ((aStore = [theEnumerator nextObject]))
    {
      foldersEnumerator = [aStore openFoldersEnumerator];

      while ((aFolder = [foldersEnumerator nextObject]))
	{
	  if (![allFolders containsObject: aFolder])
	    {
	      NSDate *aDate;
	      NSInteger seconds;

	      aDate = [aFolder propertyForKey: FolderExpireDate];

	      if (!aDate)
		{
		  continue;
		}

	      [(NSCalendarDate *)[NSCalendarDate calendarDate] years: NULL
				 months: NULL
				 days: NULL
				 hours: NULL
				 minutes: NULL
				 seconds: &seconds
				 sinceDate: (NSCalendarDate *)aDate];
	            
	      if (seconds > RETAIN_PERIOD)
		{
		  [aFolder close];
		}
	    }
	}
    }

  RELEASE(allFolders);

  //
  // We expire our cache in AddressBookController
  //
  [[AddressBookController singleInstance] freeCache];
}

@end
