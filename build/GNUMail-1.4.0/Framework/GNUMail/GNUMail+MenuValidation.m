/*
**  GNUMail+MenuValidation.m
**
**  Copyright (c) 2007 Ludovic Marcotte
**  Copyright (C) 2018 Riccardo Mottola
**
**  Authors: Ludovic Marcotte <ludovic@Sophos.ca>
**           Riccardo Mottola <rm@gnu.org>
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

#import "GNUMail+MenuValidation.h"

#import "Constants.h"
#import "EditWindowController.h"
#import "MailWindowController.h"

#import <Pantomime/CWConstants.h>
#import <Pantomime/CWFlags.h>
#import <Pantomime/CWFolder.h>
#import <Pantomime/CWMessage.h>

@implementation GNUMail (MenuValidation)

- (BOOL) validateMenuItem: (id<NSMenuItem>) theMenuItem
{
  id aController;
  CWMessage *aMessage;
  SEL action;
  
  aController = [[GNUMail lastMailWindowOnTop] delegate];
  aMessage = nil;
  action = [theMenuItem action];
  
  if (aController)
    {
      if ([aController isKindOfClass: [MailWindowController class]] && [[aController dataView] numberOfSelectedRows] > 0)
	{
	  aMessage = [[aController selectedMessages] objectAtIndex: 0];
	}
      else
	{
	  aMessage = [aController selectedMessage];
	}
    }
  //
  // Save in Drafts
  if (sel_isEqual(action, @selector(saveInDrafts:)))
    {
      if ([[[NSApp keyWindow] windowController]  isKindOfClass: [EditWindowController class]])
	{
	  return YES;
	}
      
      return NO;
    }
  //
  //
  // Show All Headers / Filtered
  //
  else if (sel_isEqual(action, @selector(showAllHeaders:)))
    {
      if (!aMessage) return NO;

      if ([aController showAllHeaders])
        {
	  [theMenuItem setTitle: _(@"Filtered Headers")];
	  [theMenuItem setTag: HIDE_ALL_HEADERS];
        }
      else
        {
	  [theMenuItem setTitle: _(@"All Headers")];
	  [theMenuItem setTag: SHOW_ALL_HEADERS];
        }
    }
  //
  // Show / Hide Delete messages
  //
  else if (sel_isEqual(action, @selector(showOrHideDeletedMessages:)))
    {
      if (!aController) return NO;

      if ([[aController folder] showDeleted])
	{
	  [theMenuItem setTitle: _(@"Hide Deleted")];
	  [theMenuItem setTag: HIDE_DELETED_MESSAGES];
	}
      else
	{
	  [theMenuItem setTitle: _(@"Show Deleted")];
	  [theMenuItem setTag: SHOW_DELETED_MESSAGES];
	}
    }
  //
  // Show / Hide Read messages
  // 
  else if (sel_isEqual(action, @selector(showOrHideReadMessages:)))
    {
      if (!aController) return NO;
      
      if ([[aController folder] showRead])
	{
	  [theMenuItem setTitle: _(@"Hide Read")];
	  [theMenuItem setTag: HIDE_READ_MESSAGES];
	}
      else
	{
	  [theMenuItem setTitle: _(@"Show Read")];
	  [theMenuItem setTag: SHOW_READ_MESSAGES];
	}
    }
  //
  // Show / Hide Toolbar and Customize Toolbar...
  //
  else if (theMenuItem == customizeToolbar || theMenuItem == showOrHideToolbar)
    {
      id aWindow;
	
      aWindow = [NSApp keyWindow];
      
      if (!aWindow || ![aWindow toolbar])
	{
	  return NO;
	}

      if (theMenuItem == showOrHideToolbar)
	{
	  if ([(NSToolbar *)[aWindow toolbar] isVisible])
	    {
	      [showOrHideToolbar setTitle: _(@"Hide Toolbar")];
	    }
	  else
	    {
	      [showOrHideToolbar setTitle: _(@"Show Toolbar")];
	    }
	}
    }
  //
  // Show Raw Source / Normal Display
  //
  else if (sel_isEqual(action, @selector(showRawSource:)))
    {
      if (!aMessage) return NO;

      if ([aController showRawSource])
	{
	  [theMenuItem setTitle: _(@"Normal Display")];
	}
      else
	{
	  [theMenuItem setTitle: _(@"Raw Source")];
	}
    }
  //
  // Thread / Unthread messages
  //
  else if (theMenuItem == threadOrUnthreadMessages)
    {
      if (!aController) return NO;

      if ([[aController folder] allContainers])
	{
	  [theMenuItem setTitle: _(@"Unthread Messages")];
	  [theMenuItem setTag: UNTHREAD_MESSAGES];
	  [selectAllMessagesInThread setAction: @selector(selectAllMessagesInThread:)];
	}
      else
	{
	  [theMenuItem setTitle: _(@"Thread Messages")];
	  [theMenuItem setTag: THREAD_MESSAGES];
	  [selectAllMessagesInThread setAction: NULL];
	}
    }

  return YES;
}

@end
