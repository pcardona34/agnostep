/*
**  ConsoleWindowController.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**  Copyright (C) 2015-2016 Riccardo Mottola
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

#import "ConsoleWindowController.h"

#import "Constants.h"
#import "GNUMail.h"
#import "MailWindowController.h"
#import "MailboxManagerController.h"
#import "Task.h"
#import "TaskManager.h"

#import <Pantomime/CWFolder.h>
#import <Pantomime/CWIMAPFolder.h>
#import <Pantomime/CWIMAPStore.h>
#import <Pantomime/CWMessage.h>
#import <Pantomime/CWTCPConnection.h>
#import <Pantomime/CWURLName.h>

//
// NOTE: For a good descriptions on what are the available "tasks" and how
//       each one of them is used, please read the documentation on top
//       of the TaskManager.m file.
//

static ConsoleWindowController *singleInstance = nil;

static NSMutableArray *progressIndicators = nil;
static NSProgressIndicator *progress = nil;

static NSImage *restart = nil;
static NSImage *stop = nil;


//
//
//
@interface ProgressIndicatorCell : NSCell
{
  Task *_task;
}
- (void) setTask: (Task *) theTask;
@end


@implementation ProgressIndicatorCell

- (id) copyWithZone: (NSZone *) theZone
{
  return [super copyWithZone:theZone];
}

- (void) drawWithFrame: (NSRect) cellFrame 
		inView: (NSView *) controlView
{
  NSString *aString;
  float f, w;
  NSUInteger i;

  [super drawWithFrame: cellFrame  inView: controlView];
  
  if (_task == nil)
    {
      return;
    }

  if (_task->op == RECEIVE_IMAP)
    {
      f = (float)_task->received_count/(float)_task->total_count;
    }
  else 
    {
      f = _task->current_size/_task->total_size;
    }


  cellFrame.size.width = cellFrame.size.width-40;
  cellFrame.origin.x += 1.5;
  w = cellFrame.size.width;

  //
  // We draw the text above our progress indicator.
  //
  switch (_task->op)
    {
    case RECEIVE_IMAP:
      aString = [NSString stringWithFormat: _(@"Receiving IMAP - %@"), [_task key]];
      break;
      
    case RECEIVE_POP3:
      aString = [NSString stringWithFormat: _(@"Receiving POP3 - %@"), [_task key]];
      break;
      
    case RECEIVE_UNIX:
      aString = [NSString stringWithFormat: _(@"Receiving UNIX - %@"), [_task key]];
      break;

    case SEND_SENDMAIL:
      aString = [NSString stringWithFormat: _(@"Sending Mailer - %@"), ([_task sendingKey] ? [_task sendingKey] : [_task key])];
      break;
      
    case SEND_SMTP:
      aString = [NSString stringWithFormat: _(@"Sending SMTP - %@"), ([_task sendingKey] ? [_task sendingKey] : [_task key])];
      break;
      
    case SAVE_ASYNC:
      aString = _(@"Saving message to the mailbox...");
      break;
      
    case LOAD_ASYNC:
      aString = _(@"Loading message from the mailbox...");
      break;

    case CONNECT_ASYNC:
      aString = [NSString stringWithFormat: _(@"Connecting to IMAP server %@..."), [_task key]];
      break;

    case SEARCH_ASYNC:
      aString = [NSString stringWithFormat: _(@"Searching in account %@..."), [_task key]];
      break;

    case OPEN_ASYNC:
      aString = [NSString stringWithFormat: _(@"Opening mailbox on %@..."), [_task key]];
      break;

    case EXPUNGE_ASYNC:
      aString = [NSString stringWithFormat: _(@"Compacting mailbox on %@..."), [_task key]];
      break;

    default:
      aString = nil;
    }

  if (aString)
    {
      NSMutableAttributedString *s;
      
      s = [[NSMutableAttributedString alloc] initWithString: aString];
      [s addAttribute: NSFontAttributeName
	 value: [NSFont boldSystemFontOfSize: [NSFont smallSystemFontSize]]
	 range: NSMakeRange(0, [s length])];
      [s drawAtPoint: NSMakePoint(cellFrame.origin.x,cellFrame.origin.y+2)];
      RELEASE(s);
    }

  
  //
  // We now draw our progress indicator
  //
  cellFrame.size.height = 12;
  cellFrame.origin.y += 18; 
  i = [[[TaskManager singleInstance] allTasks] indexOfObject: _task];
  
  if (i >= [progressIndicators count])
   {
     progress = [[NSProgressIndicator alloc] init];
     [progress setIndeterminate: NO];
     [progress setMinValue: 0];
     [progress setMaxValue: 1.0];
     [progress setDoubleValue: 0];
     [progressIndicators addObject: progress];
     RELEASE(progress);
   }
  
  progress = [progressIndicators objectAtIndex: i];
  [progress setFrame: cellFrame];
  if ([progress superview] != controlView)
    {
      [controlView addSubview: progress];
    }

  [progress setDoubleValue: f];
     
  cellFrame.origin.x -= 1.5;


  //
  // We draw the text below our progress indicator.
  //
  aString = nil;
 
  if (_task->is_running)
    {
      if (_task->op == RECEIVE_POP3 && _task->total_count)
	{
	  aString = [NSString stringWithFormat: _(@"Received message %d of %d"), _task->received_count, _task->total_count];
	}
      if (_task->op == RECEIVE_IMAP && _task->total_count)
	{
	  aString = [NSString stringWithFormat: _(@"Got status for mailbox %d (%-.*@) of %d"),
			      _task->received_count, 
			      20, [_task subtitle],
			      _task->total_count];
	}
      else if (_task->op == SEND_SMTP || _task->op == SAVE_ASYNC || _task->op == LOAD_ASYNC)
	{
	  aString = [NSString stringWithFormat: _(@"Completed %0.1fKB of %0.1fKB."),
			      (_task->current_size > _task->total_size ? _task->total_size : _task->current_size),
			      _task->total_size];
	}
    }
  else
    {
      aString = [NSString stringWithFormat: _(@"Suspended - Scheduled to run at %@"),
			  [[_task date] descriptionWithCalendarFormat: @"%H:%M:%S"
					timeZone: nil
					locale: nil]];
    }

  if (aString)
    {
      NSMutableAttributedString *s;

      s = [[NSMutableAttributedString alloc] initWithString: aString];
      [s addAttribute: NSFontAttributeName
	 value: [NSFont systemFontOfSize: [NSFont smallSystemFontSize]]
	 range: NSMakeRange(0, [s length])];
      [s drawAtPoint: NSMakePoint(cellFrame.origin.x,cellFrame.origin.y+15)];
      RELEASE(s);
    }

  
  //
  //
  //
  if (_task->is_running)
    {
      [stop compositeToPoint: NSMakePoint(w+6,cellFrame.origin.y+23) operation: NSCompositeSourceAtop];
    }
  else
    {
      [restart compositeToPoint: NSMakePoint(w+6,cellFrame.origin.y+23) operation: NSCompositeSourceAtop];
    }
}


- (void) setTask: (Task *) theTask
{
  _task = theTask;
}

@end


//
//
//
@interface ConsoleWindowController (Private)
- (void) _startAnimation;
- (void) _startTask;
- (void) _stopAnimation;
- (void) _stopTask;
@end

//
// 
//
@interface ConsoleMessage : NSObject
{
  @public
    NSString *message;
    NSCalendarDate *date;
}

- (id) initWithMessage: (NSString *) theMessage;

@end


//
//
//
@implementation ConsoleWindowController

- (id) initWithWindowNibName: (NSString *) windowNibName
{  
  self = [super initWithWindowNibName: windowNibName];

  [[self window] setTitle: _(@"GNUMail Console")];
  
  // We finally set our autosave window frame name and restore the one from the user's defaults.
  [[self window] setFrameAutosaveName: @"ConsoleWindow"];
  [[self window] setFrameUsingName: @"ConsoleWindow"];

  // We set the custom cell for the Status column
  [[tasksTableView tableColumnWithIdentifier: @"Status"] setDataCell: AUTORELEASE([[ProgressIndicatorCell alloc] init])];
  [tasksTableView setIntercellSpacing: NSZeroSize];

  // We initialize our static ivars
  restart = RETAIN([NSImage imageNamed: @"restart_32.tiff"]);
  stop = RETAIN([NSImage imageNamed: @"stop_32.tiff"]);

  progressIndicators = [[NSMutableArray alloc] init];

  // We remove the header / corner view from our tables
  [tasksTableView setHeaderView: nil];
  [tasksTableView setCornerView: nil];
  [messagesTableView setHeaderView: nil];
  [messagesTableView setCornerView: nil];

  return self;
}

//
//
//
- (void) dealloc
{
  [tasksTableView setDataSource: nil];
  [messagesTableView setDataSource: nil];

  RELEASE(allMessages);
  RELEASE(restart);
  RELEASE(stop);

  RELEASE(progressIndicators);

  [super dealloc];
}


//
// action methods
//
- (IBAction) clickedOnTableView: (id) sender
{
  NSPoint aPoint;
  float x, y;
  int row;

  row = [tasksTableView clickedRow];

  aPoint = [[[[NSApp currentEvent] window] contentView] convertPoint: [[NSApp currentEvent] locationInWindow]
							toView: [tasksTableView enclosingScrollView]];

  // We the location of our start/stop button on the clickedRow
  x = [[tasksTableView enclosingScrollView] frame].size.width-36;
  y = row*46+7;

  if (NSPointInRect(aPoint, NSMakeRect(x,y,32,32)))
    {
      if (((Task *)[[[TaskManager singleInstance] allTasks] objectAtIndex: row])->is_running)
	{
	  [self _stopTask];
	}
      else
	{
	  [self _startTask];
	}
    }
}

//
//
//
- (NSMenu *) dataView: (id) aDataView
    contextMenuForRow: (int) theRow
{
  Task *aTask;

  if (theRow >= 0 && [tasksTableView numberOfRows] > 0 &&
      (aTask = [[[TaskManager singleInstance] allTasks] objectAtIndex: theRow]) &&
      aTask->op != LOAD_ASYNC &&
      aTask->op != SAVE_ASYNC)
    {
      [[menu itemAtIndex: 0] setEnabled: YES]; // Start / Stop
      [[menu itemAtIndex: 1] setEnabled: YES]; // Delete
      [[menu itemAtIndex: 2] setEnabled: YES]; // Save in Drafts
    
      if (aTask->is_running)
	{
	  [[menu itemAtIndex: 0] setTitle: _(@"Stop")];
	  [[menu itemAtIndex: 0] setAction: @selector(_stopTask)];
	}
      else
	{
	  [[menu itemAtIndex: 0] setTitle: _(@"Start")];
	  [[menu itemAtIndex: 0] setAction: @selector(_startTask)];
	}
    }
  else
    {
      [[menu itemAtIndex: 0] setEnabled: NO]; // Start / Stop
      [[menu itemAtIndex: 1] setEnabled: NO]; // Delete
      [[menu itemAtIndex: 2] setEnabled: NO]; // Save in Drafts
    }

  return menu;
}

- (IBAction) deleteClicked: (id) sender
{
  int aRow;
     
  aRow = [tasksTableView selectedRow];

  if (aRow >= 0)
    {
      Task *aTask;
      
      // No need to call reloadData here since it's called in -removeTask.
      aTask = [[[TaskManager singleInstance] allTasks] objectAtIndex: aRow];
      
      if (aTask->is_running)
	{
	  NSRunInformationalAlertPanel(_(@"Delete error!"),
				       _(@"You can't delete a running task. Stop it first."),
				       _(@"OK"),
				       NULL, 
				       NULL,
				       NULL);
	  return;
	}

      [[TaskManager singleInstance] removeTask: aTask];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) saveClicked: (id) sender
{
  int aRow;
     
  aRow = [tasksTableView selectedRow];

  if (aRow >= 0)
    {
      CWURLName *theURLName;
      NSData *aData;
      Task *aTask;
      
      aTask = [[[TaskManager singleInstance] allTasks] objectAtIndex: aRow];

      if (aTask->is_running)
	{
	  NSRunInformationalAlertPanel(_(@"Save error!"),
				       _(@"You can't save the message in Drafts if the task is running. Stop it first."),
				       _(@"OK"),
				       NULL, 
				       NULL,
				       NULL);
	  return;
	}

      // We finally get our CWURLName object.
      theURLName = [[CWURLName alloc] initWithString: [[[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] objectForKey: [aTask key]] 
							 objectForKey: @"MAILBOXES"] objectForKey: @"DRAFTSFOLDERNAME"]
				      path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];
      
      if ([[aTask message] respondsToSelector: @selector(isEqualToData:)])
	{
	  aData = [aTask message];
	}
      else
	{
	  aData = [[aTask message] dataValue];
	}

      [[MailboxManagerController singleInstance] addMessage: aData
						 toFolder: theURLName];
      RELEASE(theURLName);
    }
  else
    {
      NSBeep();
    }
}



//
// delegate methods
//
- (void) windowWillClose: (NSNotification *) theNotification
{
  // Do nothing
}


//
//
//
- (void) windowDidLoad
{
  NSMenuItem *aMenuItem;

  allMessages = [[NSMutableArray alloc] init];

  // We set up our context menu
  menu = [[NSMenu alloc] init];
  [menu setAutoenablesItems: NO];
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Stop") action: NULL  keyEquivalent: @""];
  [aMenuItem setTarget: self];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);

  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Delete") action: @selector(deleteClicked:)  keyEquivalent: @""];
  [aMenuItem setTarget: self];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Save in Drafts") action: @selector(saveClicked:)  keyEquivalent: @""];
  [aMenuItem setTarget: self];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);

  [tasksTableView setAction: @selector(clickedOnTableView:)];
  [tasksTableView reloadData];
  [messagesTableView reloadData];
}


//
// Data Source methods
//
- (NSInteger) numberOfRowsInTableView: (NSTableView *)aTableView
{
  if (aTableView == tasksTableView)
    {
      return [[[TaskManager singleInstance] allTasks] count];
    }
  else
    {
      return [allMessages count];
    }
}


//
//
//
- (id)           tableView: (NSTableView *) aTableView
 objectValueForTableColumn: (NSTableColumn *) aTableColumn 
		       row: (NSInteger) rowIndex
{
  if (aTableView == messagesTableView)
    {
      ConsoleMessage *aMessage;
      
      aMessage = [allMessages objectAtIndex: rowIndex];
      
      if ([[aTableColumn identifier] isEqualToString: @"Message Date"])
        {
          return [aMessage->date descriptionWithCalendarFormat: _(@"%H:%M:%S")
			  timeZone: [aMessage->date timeZone]
			  locale: nil];
        }
      else
        {
          return aMessage->message;
        }
    }

  return nil;
}


//
//
//
- (void) tableView: (NSTableView *)aTableView
   willDisplayCell: (id)aCell
    forTableColumn: (NSTableColumn *)aTableColumn
               row: (NSInteger)rowIndex
{
  if (aTableView == tasksTableView && [[aTableColumn identifier] isEqualToString: @"Status"])
    {
      [(ProgressIndicatorCell *)[aTableColumn dataCell] setTask: [[[TaskManager singleInstance] allTasks] objectAtIndex: rowIndex]];
    }
  else if (aTableView == messagesTableView)
    {
      if ([[aTableColumn identifier] isEqualToString: @"Date"])
	{
	  [aCell setAlignment: NSRightTextAlignment];
	}
      [aCell setFont: [NSFont systemFontOfSize: [NSFont smallSystemFontSize]]];
    }
}


//
//
//
- (NSString *) tableView: (NSTableView *)aTableView 
	  toolTipForCell: (NSCell *)aCell 
		    rect: (NSRectPointer)rect 
	     tableColumn:(NSTableColumn *)aTableColumn 
		     row:(NSInteger)row
	   mouseLocation:(NSPoint)mouseLocation
{
  if (aTableView == messagesTableView)
    {
      ConsoleMessage *aMessage;
      
      aMessage = [allMessages objectAtIndex: row];
      
      return [NSString stringWithFormat: _(@"%@ (%@)"), aMessage->message,
		       [aMessage->date descriptionWithCalendarFormat: _(@"%H:%M:%S")
				timeZone: [aMessage->date timeZone]
				locale: nil]];
    }
  
  return nil;
}

//
// access / mutation method
//
- (NSTableView *) tasksTableView
{
  return tasksTableView;
}


//
//
//
- (id) progressIndicators
{
  return progressIndicators;
}


//
// Other methods
//
- (void) addConsoleMessage: (NSString *) theString
{
  ConsoleMessage *aMessage;
  
  aMessage = [[ConsoleMessage alloc] initWithMessage: theString];
  
  [allMessages insertObject: aMessage  atIndex: 0];
  RELEASE(aMessage);
  
  // We never keep more than 25 object in our array
  if ([allMessages count] > 25)
    {
      [allMessages removeLastObject];
    }
  
  [messagesTableView reloadData];
}

//
//
//
- (void) reload
{
  NSUInteger count;
  NSUInteger i;
  
  [tasksTableView reloadData];
  
  count = [[[TaskManager singleInstance] allTasks] count];

  // Remove all unused progress indicators from table view
  for (i = count; i < [progressIndicators count]; i++)
    {
      [[progressIndicators objectAtIndex: i] removeFromSuperview];
    }

  while (count--)
    {
      if (((Task *)[[[TaskManager singleInstance] allTasks] objectAtIndex: count])->is_running)
	{
	  [self _startAnimation];
	  return;
	}
    }

  [self _stopAnimation];
}

//
//
//
- (void) restoreImage
{
  MailWindowController *aController;
  NSUInteger count;

  count = [[GNUMail allMailWindows] count];
  
  while (count--)
    {
      aController = (MailWindowController *)[[[GNUMail allMailWindows] objectAtIndex: count] windowController];
      
      // We verify if we are using a secure (SSL) connection or not
      if ([[aController folder] isKindOfClass: [CWIMAPFolder class]] && 
	  [(CWTCPConnection *)[(CWIMAPStore *)[[aController folder] store] connection] isSSL])
	{
	  [aController->icon setImage: [NSImage imageNamed: @"pgp-mail-small.tiff"]];
	}
      else
	{
	  [aController->icon setImage: nil];
	}
    }
}

//
// class methods
//
+ (id) singleInstance
{
  if (singleInstance == nil)
    {
      singleInstance = [[ConsoleWindowController alloc] initWithWindowNibName: @"ConsoleWindow"];
    }

  return singleInstance;
}

@end


//
//
//
@implementation ConsoleWindowController (Private)

- (void) _startAnimation
{
  NSUInteger count;
      
  count = [[GNUMail allMailWindows] count];
  
  while (count--)
    {
      [((MailWindowController *)[[[GNUMail allMailWindows] objectAtIndex: count] windowController])->progressIndicator startAnimation: self];
    }  
}

- (void) _startTask
{
  NSInteger count, row;

  count = (NSInteger)[[[TaskManager singleInstance] allTasks] count];
  row = [tasksTableView selectedRow];

  if (row >= 0 && row < count)
    {
      Task *aTask;

      aTask = [[[TaskManager singleInstance] allTasks] objectAtIndex: row];
      [aTask setDate: [NSDate date]];
      aTask->immediate = YES;
      [[TaskManager singleInstance] nextTask];
      [[menu itemAtIndex: 0] setTitle: _(@"Stop")];
      [[menu itemAtIndex: 0] setAction: @selector(_stopTask)];
      [self reload];
    }
}

- (void) _stopAnimation
{
  MailWindowController *aController;
  NSUInteger count;
  
  count = [[GNUMail allMailWindows] count];
  
  while (count--)
    {
      aController = (MailWindowController *)[[[GNUMail allMailWindows] objectAtIndex: count] windowController];
      [aController->progressIndicator stopAnimation: self];
      [aController updateStatusLabel];
    }
  
  [self restoreImage];
}

- (void) _stopTask
{
  NSInteger count, row;

  count = (NSInteger)[[[TaskManager singleInstance] allTasks] count];
  row = [tasksTableView selectedRow];

  if (row >= 0 && row < count)
    {
      [[TaskManager singleInstance] stopTask: [[[TaskManager singleInstance] allTasks] objectAtIndex: row]];
      [[menu itemAtIndex: 0] setTitle: _(@"Start")];
      [[menu itemAtIndex: 0] setAction: @selector(_startTask)];
      [tasksTableView setNeedsDisplay: YES];
    }
}


@end



//
// 
//
@implementation ConsoleMessage

- (id) initWithMessage: (NSString *) theMessage
{
  self = [super init];

  message = RETAIN(theMessage);
  date = RETAIN([NSCalendarDate calendarDate]);

  return self;
}

- (void) dealloc
{
  RELEASE(message);
  RELEASE(date);
  [super dealloc];
}

@end
