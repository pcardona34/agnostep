/*
**  ExtendedWindow.m
**
**  Copyright (c) 2001-2005 Ludovic Marcotte
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

#include "ExtendedWindow.h"

#include "Constants.h"
#include "MailWindowController.h"

//
//
//
@implementation ExtendedWindow

#ifdef MACOSX
- (NSDragOperation) draggingUpdated: (id<NSDraggingInfo>)sender
{
  NSWindow *aWindow;
  
  aWindow = [sender draggingDestinationWindow];
  
  if ([[aWindow windowController] isKindOfClass: [MailWindowController class]])
    {
      NSPoint aPoint;
      NSRect aRect;
      int state;
      
      state = [[[aWindow drawers] lastObject] state];
      aPoint = [sender draggingLocation];
      aRect = [aWindow frame];
      
      if (aPoint.x < 5 && state == NSDrawerClosedState)
        {
          [[[aWindow drawers] lastObject] openOnEdge: NSMinXEdge];
        }
      else if (aPoint.x > aRect.size.width-5 && state == NSDrawerClosedState)
        {
          [[[aWindow drawers] lastObject] openOnEdge: NSMaxXEdge];
        }
    }
    
  return NSDragOperationNone;
}
#endif

//
//
//
- (void) keyDown: (NSEvent *) theEvent
{
  NSString *characters;
  unichar character;

  characters = [theEvent characters];

  if ( [characters length] > 0 )
    {
      MailWindowController *delegate = (MailWindowController*)[self delegate];
      character = [characters characterAtIndex: 0];
      
      switch ( character )
        {
	case '\n':
	case '\r':
#ifdef MACOSX
	case 0x03:  // Enter key
#endif
	  if ([delegate isKindOfClass: [MailWindowController class]])
	    {
	      [(MailWindowController *)delegate doubleClickedOnDataView: delegate];
	    }
	  break;
        case NSUpArrowFunctionKey:
	  if ([theEvent modifierFlags] & NSControlKeyMask)
	    {
	      [(MailWindowController *)delegate previousUnreadMessage: delegate];
	    }
	  else
	    {
	      [(MailWindowController *)delegate previousMessage: delegate];
	    }
	  break;
        case NSDownArrowFunctionKey:
	  if ([theEvent modifierFlags] & NSControlKeyMask)
	    {
	      [(MailWindowController *)delegate nextUnreadMessage: delegate];
	    }
	  else
	    {
	      [(MailWindowController *)delegate nextMessage: delegate];
	    }
          break;
	case NSLeftArrowFunctionKey:
	  if ([theEvent modifierFlags] & NSControlKeyMask)
	    {
	      [(MailWindowController *)delegate previousInThread: delegate];
	    }
	  break;
	case NSRightArrowFunctionKey:
	  if ([theEvent modifierFlags] & NSControlKeyMask)
	    {
	      [(MailWindowController *)delegate nextInThread: delegate];
	    }
	  break;
        case NSPageUpFunctionKey:
        case '-':
	  [(MailWindowController *)delegate pageUpMessage: delegate];
          break;
        case NSPageDownFunctionKey:
        case ' ':
	  [(MailWindowController *)delegate pageDownMessage: delegate];
	  break;
        case NSHomeFunctionKey:
        case NSBeginFunctionKey:
          [(MailWindowController *)delegate firstMessage: delegate];
          break;
        case NSEndFunctionKey:
          [(MailWindowController *)delegate lastMessage: delegate];
          break;
	case NSDeleteFunctionKey:
	case NSBackspaceCharacter:
	case NSDeleteCharacter:
	  [(MailWindowController *)delegate deleteMessage: self];
	  break;
	}
    }
}

@end
